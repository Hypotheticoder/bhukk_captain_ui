package com.bhukk.delivery

import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.bhukk.delivery/app_lifecyle"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "bringToForeground") {
                // 🔥 Use applicationContext instead of 'this'
                val intent = Intent(applicationContext, MainActivity::class.java)
                
                // 🔥 The ultimate combination of flags to force the app open
                intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or 
                                Intent.FLAG_ACTIVITY_SINGLE_TOP or 
                                Intent.FLAG_ACTIVITY_CLEAR_TOP)
                
                applicationContext.startActivity(intent)
                result.success(true)
            } else if (call.method == "minimizeApp") {
                moveTaskToBack(true)
                result.success(true)
            } else {
                result.notImplemented()
            }
        }
    }
}
