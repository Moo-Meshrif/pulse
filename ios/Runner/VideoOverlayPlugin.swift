import AVFoundation
import Flutter
import UIKit

/// `pulse/video_overlay`: `burn(videoPath, overlayPng)` writes an H.264 copy of the video with the picture
/// stretched over every frame (AVFoundation, hardware encoder), `delete(path)` removes a copy. Progress goes
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
      burn(path: path, overlay: overlay, result: result)
    case "delete":
      if let path = args?["path"] as? String {
        try? FileManager.default.removeItem(atPath: path)
      }
      result(nil)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func burn(path: String, overlay: CGImage, result: @escaping FlutterResult) {
    let asset = AVURLAsset(url: URL(fileURLWithPath: path))
    Task { @MainActor in
      do {
        let tracks = try await asset.loadTracks(withMediaType: .video)
        guard let track = tracks.first else { throw VideoOverlayError.noVideo }

        // Display size: the natural size turned by the track's rotation.
        let natural = try await track.load(.naturalSize)
        let transform = try await track.load(.preferredTransform)
        let size = natural.applying(transform)
        let renderSize = CGSize(width: abs(size.width), height: abs(size.height))

        let composition = AVMutableVideoComposition(propertiesOf: asset)
        composition.renderSize = renderSize

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
            asset: asset, presetName: AVAssetExportPresetHighestQuality)
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
