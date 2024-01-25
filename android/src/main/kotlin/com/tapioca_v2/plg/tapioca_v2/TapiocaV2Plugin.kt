@file:Suppress("DEPRECATION")

package com.tapioca_v2.plg.tapioca_v2

import android.Manifest
import android.app.Activity
import androidx.core.app.ActivityCompat
import com.daasuu.mp4compose.composer.Mp4Composer
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.*
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar


/** TapiocaV2Plugin */
class TapiocaV2Plugin: FlutterPlugin, MethodCallHandler, PluginRegistry.RequestPermissionsResultListener, ActivityAware {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  var activity: Activity? = null
  private var methodChannel: MethodChannel? = null
  private var eventChannel: EventChannel? = null
  private val myPermissionCode = 34264
  private var eventSink : EventChannel.EventSink? = null
  private var composer: Mp4Composer? = null

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    onAttachedToEngine(flutterPluginBinding.binaryMessenger)
  }
  fun onAttachedToEngine(messenger: BinaryMessenger) {
    methodChannel = MethodChannel(messenger, "video_editor")
    eventChannel = EventChannel(messenger, "video_editor_progress")
    methodChannel?.setMethodCallHandler(this)
    eventChannel?.setStreamHandler(object : EventChannel.StreamHandler {
      override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
        eventSink = events

      }
      override fun onCancel(arguments: Any?) {
        println("Event Channel is canceled.")
      }
    })
  }
  companion object {
    @JvmStatic
    fun registerWith(registrar: Registrar) {
      val instance = TapiocaV2Plugin()
      instance.onAttachedToEngine(registrar.messenger())
    }
  }


  override fun onMethodCall(call: MethodCall, result: Result) {
    if (call.method == "getPlatformVersion") {
      result.success("Android ${android.os.Build.VERSION.RELEASE}")
    } else if (call.method == "writeVideofile") {
      val getActivity = activity ?: return
      val newEventSink = eventSink ?: return
      checkPermission(getActivity)

      val srcFilePath: String = call.argument("srcFilePath") ?: run {
        result.error("src_file_path_not_found", "the src file path is not found.", null)
        return
      }
      val destFilePath: String = call.argument("destFilePath") ?: run {
        result.error("dest_file_path_not_found", "the dest file path is not found.", null)
        return
      }
      val processing: HashMap<String, HashMap<String, Any>> = call.argument("processing")
        ?: run {
          result.error("processing_data_not_found", "the processing is not found.", null)
          return
        }
      composer = Mp4Composer(srcFilePath, destFilePath)
      val generator = VideoGeneratorService(composer!!)
      generator.writeVideofile(processing, result, getActivity,newEventSink)
    } else if (call.method == "cancelExport") {
      val generator = composer?.let { VideoGeneratorService(it) }
      generator?.cancelExport( result)
    }else {
      result.notImplemented()
    }
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    activity = binding.activity
    binding.addRequestPermissionsResultListener(this)
  }

  override fun onDetachedFromActivity() {
    methodChannel!!.setMethodCallHandler(null)
    methodChannel = null
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    onAttachedToActivity(binding)
  }

  override fun onDetachedFromActivityForConfigChanges() {
    onDetachedFromActivity()
  }

  override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>,
                                          grantResults: IntArray): Boolean {
    when (requestCode) {
      myPermissionCode -> {
        // Only return true if handling the requestCode
        return true
      }
    }
    return false
  }

  // Invoked either from the permission result callback or permission check
  private fun completeInitialization() {

  }

  private fun checkPermission(activity: Activity) {
    ActivityCompat.requestPermissions(activity,
      arrayOf(Manifest.permission.READ_EXTERNAL_STORAGE, Manifest.permission.WRITE_EXTERNAL_STORAGE), myPermissionCode)
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
  }
}
