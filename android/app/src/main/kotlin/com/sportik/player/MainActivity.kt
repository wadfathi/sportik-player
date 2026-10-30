package com.sportik.player

import android.content.Intent
import android.os.Build
import android.os.Bundle
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val channelName = "sportik/player_launch"
    private var launchData: Map<String, String> = emptyMap()

    override fun onCreate(savedInstanceState: Bundle?) {
        launchData = readExtras(intent)
        super.onCreate(savedInstanceState)
        applyFullscreen()
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName).setMethodCallHandler { call, result ->
            if (call.method == "getLaunchData") result.success(launchData) else result.notImplemented()
        }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        launchData = readExtras(intent)
        flutterEngine?.dartExecutor?.binaryMessenger?.let { messenger ->
            MethodChannel(messenger, channelName).invokeMethod("launchDataChanged", launchData)
        }
    }

    private fun readExtras(intent: Intent?): Map<String, String> {
        val keys = listOf("sdurl", "hdurl", "sdname", "hdname", "displayname", "gettoken", "key", "host")
        val output = mutableMapOf<String, String>()
        keys.forEach { key -> intent?.getStringExtra(key)?.let { output[key] = it } }
        return output
    }

    private fun applyFullscreen() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) window.setDecorFitsSystemWindows(false)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            val params = window.attributes
            params.layoutInDisplayCutoutMode = WindowManager.LayoutParams.LAYOUT_IN_DISPLAY_CUTOUT_MODE_SHORT_EDGES
            window.attributes = params
        }
    }
}
