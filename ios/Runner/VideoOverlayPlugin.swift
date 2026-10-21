import AVFoundation
import Flutter
import UIKit

/// `pulse/video_overlay`: `burn(videoPath, overlayPng)` writes an H.264 copy of the video with the picture
/// stretched over every frame, optionally keeping only `trimStartMs`..`trimEndMs` and without sound
/// (AVFoundation, hardware encoder), `delete(path)` removes a copy. Progress goes
/// back as `progress` calls (0..1).
final class VideoOverlayPlugin {
  private let channel: FlutterMethodChannel
  private let progressInterval: TimeInterval = 0.2

  init(messenger: FlutterBinaryMessenger) {
    channel = FlutterMethodChannel(name: "pulse/video_overlay", binaryMessenger: messenger)
    channel.setMethodCallHandler { [weak self] call, result in
      self?.handle(call, result: result)
    }
  }

  private func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    let args = call.arguments as? [String: Any]
    switch call.method {
    case "burn":
      guard let path = args?["videoPath"] as? String,
        let png = (args?["overlayPng"] as? FlutterStandardTypedData)?.data,
        let overlay = UIImage(data: png)?.cgImage
      else {
        result(FlutterError(code: "bad_args", message: "Missing video or overlay", details: nil))
        return
      }
      let start = args?["trimStartMs"] as? Int
      let end = args?["trimEndMs"] as? Int
      burn(
        path: path, overlay: overlay, trim: start.flatMap { s in end.map { (s, $0) } },
        removeAudio: args?["removeAudio"] as? Bool ?? false, result: result)
    case "delete":
      if let path = args?["path"] as? String {
        try? FileManager.default.removeItem(atPath: path)
      }
      result(nil)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func burn(
    path: String, overlay: CGImage, trim: (Int, Int)?, removeAudio: Bool,
    result: @escaping FlutterResult
  ) {
    let source = AVURLAsset(url: URL(fileURLWithPath: path))
    Task { @MainActor in
      do {
        let tracks = try await source.loadTracks(withMediaType: .video)
        guard let track = tracks.first else { throw VideoOverlayError.noVideo }

        // Display size: the natural size turned by the track's rotation.
        let natural = try await track.load(.naturalSize)
        let transform = try await track.load(.preferredTransform)
        let size = natural.applying(transform)
        let renderSize = CGSize(width: abs(size.width), height: abs(size.height))

        // The kept part is copied into a composition of its own, so the picture is drawn on a video that
        // starts at zero: an export time range with the animation tool gave black frames.
        let range: CMTimeRange
        if let (start, end) = trim {
          range = CMTimeRange(
            start: CMTime(value: CMTimeValue(start), timescale: 1000),
            end: CMTime(value: CMTimeValue(end), timescale: 1000))
        } else {
          range = CMTimeRange(start: .zero, duration: try await source.load(.duration))
        }
        let asset = AVMutableComposition()
        guard
          let videoTrack = asset.addMutableTrack(
            withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)
        else { throw VideoOverlayError.noVideo }
        try videoTrack.insertTimeRange(range, of: track, at: .zero)
        videoTrack.preferredTransform = transform
        if !removeAudio {
          for audio in try await source.loadTracks(withMediaType: .audio) {
            let audioTrack = asset.addMutableTrack(
              withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)
            try audioTrack?.insertTimeRange(range, of: audio, at: .zero)
          }
        }

        let composition = AVMutableVideoComposition(propertiesOf: asset)
        composition.renderSize = renderSize
        // Phone videos are often HDR (HEVC, HLG); drawn on with the animation tool they came out black.
        // Rendering in the standard colour space (SDR) keeps the picture.
        composition.colorPrimaries = AVVideoColorPrimaries_ITU_R_709_2
        composition.colorTransferFunction = AVVideoTransferFunction_ITU_R_709_2
        composition.colorYCbCrMatrix = AVVideoYCbCrMatrix_ITU_R_709_2

        let videoLayer = CALayer()
        videoLayer.frame = CGRect(origin: .zero, size: renderSize)
        let overlayLayer = CALayer()
        overlayLayer.frame = videoLayer.frame
        overlayLayer.contents = overlay
        overlayLayer.contentsGravity = .resize
        let parentLayer = CALayer()
        parentLayer.frame = videoLayer.frame
        parentLayer.addSublayer(videoLayer)
        parentLayer.addSublayer(overlayLayer)
        composition.animationTool = AVVideoCompositionCoreAnimationTool(
          postProcessingAsVideoLayer: videoLayer, in: parentLayer)

        let output = FileManager.default.temporaryDirectory
          .appendingPathComponent("pulse_overlay_\(UInt64(Date().timeIntervalSince1970 * 1000)).mp4")
        guard
          let session = AVAssetExportSession(
            asset: asset, presetName: AVAssetExportPreset1920x1080)
        else { throw VideoOverlayError.noSession }
        session.videoComposition = composition
        session.outputURL = output
        session.outputFileType = .mp4
        session.shouldOptimizeForNetworkUse = true

        let timer = Timer.scheduledTimer(withTimeInterval: progressInterval, repeats: true) {
          [weak self] _ in
          self?.channel.invokeMethod("progress", arguments: Double(session.progress))
        }
        await session.export()
        timer.invalidate()

        if session.status == .completed {
          result(output.path)
        } else {
          try? FileManager.default.removeItem(at: output)
          result(
            FlutterError(
              code: "export_failed", message: session.error?.localizedDescription, details: nil))
        }
      } catch {
        result(
          FlutterError(code: "export_failed", message: error.localizedDescription, details: nil))
      }
    }
  }
}

private enum VideoOverlayError: Error {
  case noVideo
  case noSession
}
