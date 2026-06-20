package com.creatoo.app

import android.app.Activity
import android.content.Intent
import android.net.Uri
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterFragmentActivity() {
    private val CHANNEL = "com.creatoo/upi_payment"
    private val UPI_REQUEST_CODE = 1001
    private var pendingResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "launchUpi") {
                val uriStr = call.argument<String>("uri")
                if (uriStr != null) {
                    pendingResult = result
                    val intent = Intent(Intent.ACTION_VIEW, Uri.parse(uriStr))
                    
                    val chooser = Intent.createChooser(intent, "Pay with")
                    if (intent.resolveActivity(packageManager) != null) {
                        startActivityForResult(chooser, UPI_REQUEST_CODE)
                    } else {
                        result.error("NO_APPS", "No UPI apps found", null)
                    }
                } else {
                    result.error("INVALID_ARGS", "URI string is null", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == UPI_REQUEST_CODE) {
            val result = pendingResult ?: return
            pendingResult = null

            if (data != null && data.getStringExtra("response") != null) {
                // e.g. txnId=...&responseCode=...&Status=SUCCESS&txnRef=...
                val resStr = data.getStringExtra("response") ?: ""
                val resultMap = parseUpiResponse(resStr)
                result.success(resultMap)
            } else if (resultCode == RESULT_CANCELED) {
                val map = mapOf("Status" to "USER_CANCELLED")
                result.success(map)
            } else {
                val map = mapOf("Status" to "APP_CLOSED_OR_NO_RESPONSE")
                result.success(map)
            }
        }
    }

    private fun parseUpiResponse(res: String): Map<String, String> {
        val map = mutableMapOf<String, String>()
        val pairs = res.split("&")
        for (pair in pairs) {
            val keyValue = pair.split("=")
            if (keyValue.size == 2) {
                map[keyValue[0]] = keyValue[1]
            }
        }
        return map
    }
}
