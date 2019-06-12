package io.github.abrasumente233.pickyouth

import android.Manifest
import android.content.pm.PackageManager
import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle
import android.os.Handler
import android.transition.Visibility
import android.view.SurfaceHolder
import android.view.SurfaceView
import android.view.View
import android.widget.TextView
import android.widget.Toast
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import com.google.android.gms.vision.CameraSource
import com.google.android.gms.vision.Detector
import com.google.android.gms.vision.barcode.Barcode
import com.google.android.gms.vision.barcode.BarcodeDetector
import kotlinx.android.synthetic.main.activity_check_ticket.*

/**
 * An example full-screen activity that shows and hides the system UI (i.e.
 * status bar and navigation/system bar) with user interaction.
 */
class CheckTicketActivity : AppCompatActivity() {

    private lateinit var detector: BarcodeDetector
    private lateinit var cameraSource: CameraSource

    private var readyShow = true

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        setContentView(R.layout.activity_check_ticket)
        supportActionBar?.setDisplayHomeAsUpEnabled(true)

        tv_ready.visibility = View.VISIBLE
        listOf<View>(btn_check_ticket, tv_used, tv_used_date, tv_check_title).forEach { it.visibility = View.INVISIBLE }

        init_camera()

    }

    private fun init_camera() {

        detector = BarcodeDetector.Builder(this).setBarcodeFormats(Barcode.QR_CODE).build()
        detector.setProcessor(object: Detector.Processor<Barcode> {
            override fun release() {

            }

            override fun receiveDetections(detections: Detector.Detections<Barcode>?) {
                val barcodes = detections?.detectedItems
                if (barcodes!!.size() > 0) {
                    if (readyShow) {
                        tv_ready.visibility = View.INVISIBLE
                        listOf<View>(btn_check_ticket, tv_used, tv_used_date, tv_check_title).forEach { it.visibility = View.VISIBLE }
                    }

                    tv_used.post {
                        tv_used.text = barcodes.valueAt(0).displayValue
                    }
                }
            }

        })

        cameraSource = CameraSource.Builder(this, detector).setRequestedPreviewSize(1024, 768)
            .setRequestedFps(25f).setAutoFocusEnabled(true).build()

        sv_barcode.holder.addCallback(object: SurfaceHolder.Callback2 {
            override fun surfaceRedrawNeeded(holder: SurfaceHolder?) {}

            override fun surfaceChanged(holder: SurfaceHolder?, format: Int, w: Int, h: Int) {}

            override fun surfaceDestroyed(holder: SurfaceHolder?) {
                cameraSource.stop()
            }

            override fun surfaceCreated(holder: SurfaceHolder?) {
                if (ContextCompat.checkSelfPermission(this@CheckTicketActivity, Manifest.permission.CAMERA) ==
                    PackageManager.PERMISSION_GRANTED)
                    cameraSource.start(holder)
                else ActivityCompat.requestPermissions(this@CheckTicketActivity, arrayOf(Manifest.permission.CAMERA), 233)

            }


        })
    }

    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == 233) {
            if (grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                cameraSource.start(sv_barcode.holder)
            } else {
                Toast.makeText(this, "Scanner requires camera permission, which is not given.", Toast.LENGTH_SHORT).show()
            }
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        detector.release()
        cameraSource.stop()
        cameraSource.release()
    }

}
