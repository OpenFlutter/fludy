package club.openflutter.fludy.utils

import android.app.Activity
import android.content.ActivityNotFoundException
import android.content.Context
import android.content.Intent
import android.os.Build
import android.util.Log
import club.openflutter.fludy.FludyConfigurations

internal const val KEY_FLUDY_EXTRA = "KEY_FLUDY_EXTRA"
internal const val FLAG_PAYLOAD_FROM_DOUYIN = "FLAG_PAYLOAD_FROM_DOUYIN"

internal fun Activity.startFlutterActivity(
    extra: Intent,
) {
    flutterActivityIntent()?.also { intent ->
        intent.addFluwxExtras()
        intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP)
        intent.putExtra(KEY_FLUDY_EXTRA, extra)
        intent.putExtra(FLAG_PAYLOAD_FROM_DOUYIN, true)
        try {
            startActivity(intent)
        } catch (e: ActivityNotFoundException) {
            Log.w("fludy", "Can not start activity for Intent: $intent")
        }
    }
}


internal fun Context.flutterActivityIntent(): Intent? {
    return if (FludyConfigurations.flutterActivity.isBlank()) {
        packageManager.getLaunchIntentForPackage(packageName)
    } else {
        Intent().also {
            it.setClassName(this, "${packageName}.${FludyConfigurations.flutterActivity}")
        }
    }
}

internal fun Intent.addFluwxExtras() {
    putExtra("fluwx_payload_from_fluwx", true)
}

internal fun Intent.readDouYinCallbackIntent(): Intent? {
    return if (getBooleanExtra(FLAG_PAYLOAD_FROM_DOUYIN, false)) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            getParcelableExtra(KEY_FLUDY_EXTRA,Intent::class.java)
        } else {
            getParcelableExtra(KEY_FLUDY_EXTRA)
        }
    } else {
        null
    }
}
