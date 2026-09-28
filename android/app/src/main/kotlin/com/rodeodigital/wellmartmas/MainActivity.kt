package com.rodeodigital.wellmartmas

import android.app.Activity
import android.content.ActivityNotFoundException
import android.content.Intent
import android.net.Uri
import android.os.Bundle
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterFragmentActivity() {
    private val upiChannelName = "com.waioz.cartel/upi"
    private val upiRequestCode = 7421
    private var pendingUpiResult: MethodChannel.Result? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
    }
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, upiChannelName)
            .setMethodCallHandler { call, result ->
                if (call.method != "launchUpi") {
                    result.notImplemented()
                    return@setMethodCallHandler
                }

                if (pendingUpiResult != null) {
                    result.error("UPI_ALREADY_OPEN", "A UPI app is already open", null)
                    return@setMethodCallHandler
                }

                val url = call.argument<String>("url")
                if (url.isNullOrBlank()) {
                    result.success(mapOf("launched" to false))
                    return@setMethodCallHandler
                }

                try {
                    val intent = Intent(Intent.ACTION_VIEW, Uri.parse(url))
                    pendingUpiResult = result
                    startActivityForResult(intent, upiRequestCode)
                } catch (_: ActivityNotFoundException) {
                    pendingUpiResult = null
                    result.success(mapOf("launched" to false))
                } catch (error: Exception) {
                    pendingUpiResult = null
                    result.error("UPI_LAUNCH_FAILED", error.message, null)
                }
            }
    }

    @Deprecated("Deprecated in Java")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)

        if (requestCode != upiRequestCode) return

        val result = pendingUpiResult ?: return
        pendingUpiResult = null

        val response = data?.getStringExtra("response")
            ?: data?.getStringExtra("Status")
            ?: data?.getStringExtra("status")

        result.success(
            mapOf(
                "launched" to true,
                "cancelled" to (resultCode == Activity.RESULT_CANCELED),
                "response" to response,
            )
        )
    }
}
