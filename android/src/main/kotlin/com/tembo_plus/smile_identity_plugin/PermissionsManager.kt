import android.Manifest
import android.app.Activity
import android.content.pm.PackageManager
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat

fun checkForCameraPermission(activity: Activity): Boolean {
  val permission = ContextCompat.checkSelfPermission(activity, Manifest.permission.CAMERA)
  return permission == PackageManager.PERMISSION_GRANTED
}

fun requestCameraPermission(activity: Activity) {
  val permissions = arrayOf(Manifest.permission.CAMERA)
  ActivityCompat.requestPermissions(activity, permissions, 2023)
}
