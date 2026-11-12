package com.waioz.cartel

import android.app.Activity
import android.content.ActivityNotFoundException
import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.provider.ContactsContract
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterFragmentActivity() {
    private val upiChannelName = "com.waioz.cartel/upi"
    private val upiRequestCode = 7421
    private var pendingUpiResult: MethodChannel.Result? = null
    private val contactPickerChannel = "com.annachi_maligai/contact_picker"
    private val pickPhoneRequestCode = 7241
    private var pendingContactPickResult: MethodChannel.Result? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, contactPickerChannel)
            .setMethodCallHandler { call, result ->
                if (call.method == "pickPhoneNumber") {
                    pickPhoneNumber(result)
                } else {
                    result.notImplemented()
                }
            }

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

    private fun pickPhoneNumber(result: MethodChannel.Result) {
        if (pendingContactPickResult != null) {
            result.error("already_active", "Contact picker is already open.", null)
            return
        }
        val intent = Intent(Intent.ACTION_PICK, ContactsContract.CommonDataKinds.Phone.CONTENT_URI)
        try {
            pendingContactPickResult = result
            startActivityForResult(intent, pickPhoneRequestCode)
        } catch (_: ActivityNotFoundException) {
            pendingContactPickResult = null
            result.error("unavailable", "No contacts app is available.", null)
        }
    }

    @Deprecated("Deprecated in Java")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)

        if (requestCode == pickPhoneRequestCode) {
            val result = pendingContactPickResult ?: return
            pendingContactPickResult = null
            val selectedUri = data?.data
            if (resultCode != Activity.RESULT_OK || selectedUri == null) {
                result.success(null)
                return
            }
            try {
                val phone = contentResolver.query(
                    selectedUri,
                    arrayOf(ContactsContract.CommonDataKinds.Phone.NUMBER),
                    null, null, null
                )?.use { cursor ->
                    if (cursor.moveToFirst()) cursor.getString(0) else null
                }
                result.success(phone)
            } catch (error: Exception) {
                result.error("read_failed", "Unable to read the selected contact.", null)
            }
            return
        }

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
