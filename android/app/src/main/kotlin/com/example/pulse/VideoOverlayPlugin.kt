package com.example.pulse

import android.content.Context
import android.graphics.BitmapFactory
import android.net.Uri
import android.os.Handler
import android.os.Looper
import androidx.media3.common.Effect
import androidx.media3.common.MediaItem
import androidx.media3.common.MimeTypes
import androidx.media3.common.audio.AudioProcessor
import androidx.media3.effect.BitmapOverlay
import androidx.media3.effect.OverlayEffect
import androidx.media3.transformer.Composition
import androidx.media3.transformer.EditedMediaItem
import androidx.media3.transformer.Effects
import androidx.media3.transformer.ExportException
import androidx.media3.transformer.ExportResult
import androidx.media3.transformer.ProgressHolder
import androidx.media3.transformer.Transformer
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.File

/**
 * `pulse/video_overlay`: `burn(videoPath, overlayPng)` writes an H.264/AAC copy of the video with the
 * picture stretched over every frame (Media3 Transformer, hardware encoder), `delete(path)` removes a copy.
 * Progress goes back as `progress` calls (0..1). Transformer must run on the main thread.
 */
class VideoOverlayPlugin(
    private val context: Context,
    messenger: BinaryMessenger,
) : MethodChannel.MethodCallHandler {
    private val channel = MethodChannel(messenger, "pulse/video_overlay")
    private val main = Handler(Looper.getMainLooper())

    init {
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "burn" -> burn(
                call.argument<String>("videoPath"),
                call.argument<ByteArray>("overlayPng"),
                result,
            )
            "delete" -> {
                call.argument<String>("path")?.let { File(it).delete() }
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }

    private fun burn(videoPath: String?, png: ByteArray?, result: MethodChannel.Result) {
        val bitmap = png?.let { BitmapFactory.decodeByteArray(it, 0, it.size) }
        if (videoPath == null || bitmap == null) {
            result.error("bad_args", "Missing video or overlay", null)
            return
        }
        val output = File(context.cacheDir, "pulse_overlay_${System.nanoTime()}.mp4")
        val overlay = OverlayEffect(listOf(BitmapOverlay.createStaticBitmapOverlay(bitmap)))
        val effects = Effects(emptyList<AudioProcessor>(), listOf<Effect>(overlay))
        val item = EditedMediaItem.Builder(MediaItem.fromUri(Uri.fromFile(File(videoPath))))
            .setEffects(effects)
            .build()

        lateinit var transformer: Transformer
        val poll = object : Runnable {
            override fun run() {
                val holder = ProgressHolder()
                if (transformer.getProgress(holder) == Transformer.PROGRESS_STATE_AVAILABLE) {
                    channel.invokeMethod("progress", holder.progress / 100.0)
                }
                main.postDelayed(this, PROGRESS_INTERVAL_MS)
            }
        }
        transformer = Transformer.Builder(context)
            .setVideoMimeType(MimeTypes.VIDEO_H264)
            .setAudioMimeType(MimeTypes.AUDIO_AAC)
            .addListener(object : Transformer.Listener {
                override fun onCompleted(composition: Composition, exportResult: ExportResult) {
                    main.removeCallbacks(poll)
                    result.success(output.absolutePath)
                }

                override fun onError(
                    composition: Composition,
                    exportResult: ExportResult,
                    exportException: ExportException,
                ) {
                    main.removeCallbacks(poll)
                    output.delete()
                    result.error("export_failed", exportException.message, null)
                }
            })
            .build()
        main.post {
            transformer.start(item, output.absolutePath)
            main.postDelayed(poll, PROGRESS_INTERVAL_MS)
        }
    }

    private companion object {
        const val PROGRESS_INTERVAL_MS = 200L
    }
}
