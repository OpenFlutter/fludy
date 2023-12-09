package club.openflutter.fludy.callback

import android.content.Intent
import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import club.openflutter.fludy.utils.startFlutterActivity

class DyCallbackActivity : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        startFlutterActivity(intent)
        finish()
    }

    override fun onNewIntent(intent: Intent?) {
        super.onNewIntent(intent)
        intent?.also {
            startFlutterActivity(intent)
        }
        finish()
    }
}