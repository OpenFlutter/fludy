package club.openflutter.fludy

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.util.Log
import android.widget.Toast
import club.openflutter.fludy.utils.readDouYinCallbackIntent
import com.bytedance.sdk.open.aweme.CommonConstants
import com.bytedance.sdk.open.aweme.authorize.model.Authorization
import com.bytedance.sdk.open.aweme.common.handler.IApiEventHandler
import com.bytedance.sdk.open.aweme.common.model.BaseReq
import com.bytedance.sdk.open.aweme.common.model.BaseResp
import com.bytedance.sdk.open.aweme.init.DouYinOpenSDKConfig
import com.bytedance.sdk.open.douyin.DouYinOpenApiFactory
import com.bytedance.sdk.open.douyin.api.DouYinOpenApi
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.NewIntentListener


/** FludyPlugin */
class FludyPlugin : FlutterPlugin, MethodCallHandler, ActivityAware, NewIntentListener {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var douYinChannel: MethodChannel

    private var douYinOpenApi: DouYinOpenApi? = null

    private var applicationContext: Context? = null
    private var currentActivity: Activity? = null

    private var dyApiHandler = object : IApiEventHandler {
        override fun onReq(p0: BaseReq?) {

        }

        override fun onResp(resp: BaseResp?) {
            when (resp?.type) {
                CommonConstants.ModeType.SEND_AUTH_RESPONSE -> {
                    (resp as? Authorization.Response)?.let { response ->
                        val result = mapOf(
                            "state" to response.state,
                            "cancel" to response.isCancel,
                            "authCode" to response.authCode,
                            "grantedPermissions" to response.grantedPermissions?.split(","),
                            "errorCode" to response.errorCode,
                            "errorMsg" to response.errorMsg
                        )

                        douYinChannel.invokeMethod("onAuthResponse", result)
                    }
                }

                else -> {}
            }

        }

        override fun onErrorIntent(p0: Intent?) {

        }
    }

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        applicationContext = flutterPluginBinding.applicationContext
        douYinChannel =
            MethodChannel(flutterPluginBinding.binaryMessenger, "club.openflutter/fludy")
        douYinChannel.setMethodCallHandler(this)
        flutterPluginBinding.applicationContext
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "initializeApi" -> {
                DouYinOpenApiFactory.initConfig(
                    DouYinOpenSDKConfig.Builder()
                        .clientKey(call.argument<String?>("clientKey"))
                        .context(applicationContext)
                        .build()
                )
                result.success(null)
            }

            "isDouYinInstalled" -> {
                ensureOpenApi()
                douYinOpenApi?.let {
                    result.success(it.isAppInstalled)
                } ?: result.error("SDK_NOT_INITIALIZED", "DouYinOpenApi is not initialized", null)
            }

            "authorization" -> {
                ensureOpenApi()
                authorization(call = call, result = result)
            }

            else -> {}
        }

    }

    private fun ensureOpenApi() {
        currentActivity?.let {
            douYinOpenApi = DouYinOpenApiFactory.create(it)
        }
    }

    private fun authorization(call: MethodCall, result: Result) {
        val request = Authorization.Request()
        val scopeList = call.argument<List<String>?>("scope").orEmpty()
        if (scopeList.isEmpty()) {
            result.error("BAD_SCOPE", "Wrong argument - scope must be not empty", null)
            return
        }
        val state = call.argument<String?>("state")
        val optionalScope0 = call.argument<String?>("optionalScope0")
        val optionalScope1 = call.argument<String?>("optionalScope1")
        request.scope = scopeList.joinToString(separator = ",")
        state?.also {
            request.state = it
        }
        optionalScope0?.also {
            request.optionalScope0 = it
        }

        optionalScope1?.also {
            request.optionalScope1 = it
        }
        result.success(douYinOpenApi?.authorize(request) ?: false)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        douYinChannel.setMethodCallHandler(null)
        applicationContext = null
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        currentActivity = binding.activity
        binding.addOnNewIntentListener(this)
    }

    override fun onDetachedFromActivityForConfigChanges() {
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        onAttachedToActivity(binding)
    }

    override fun onDetachedFromActivity() {
        currentActivity = null
    }

    override fun onNewIntent(intent: Intent): Boolean = letDouYinHandleIntent(intent)

    private fun letDouYinHandleIntent(intent: Intent): Boolean =
        intent.readDouYinCallbackIntent()?.let {
            douYinOpenApi?.handleIntent(it, dyApiHandler) ?: false
        } ?: run {
            false
        }

}
