package com.maxim.qazaqsha

import android.os.Build
import android.view.InputDevice
import android.view.MotionEvent
import android.view.ViewConfiguration
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel

class MainActivity : FlutterActivity() {
    /// Where turns of a watch's bezel or crown go: pixels to scroll.
    private var rotary: EventChannel.EventSink? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, "qazaqsha/rotary")
            .setStreamHandler(object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    rotary = events
                }

                override fun onCancel(arguments: Any?) {
                    rotary = null
                }
            })
    }

    override fun onGenericMotionEvent(event: MotionEvent): Boolean {
        val sink = rotary
        if (sink != null &&
            event.action == MotionEvent.ACTION_SCROLL &&
            event.isFromSource(InputDevice.SOURCE_ROTARY_ENCODER)
        ) {
            val factor = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                ViewConfiguration.get(this).scaledVerticalScrollFactor
            } else {
                64f
            }
            sink.success((-event.getAxisValue(MotionEvent.AXIS_SCROLL) * factor).toDouble())
            return true
        }
        return super.onGenericMotionEvent(event)
    }
}
