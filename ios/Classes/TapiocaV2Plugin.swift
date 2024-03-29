import Flutter
import UIKit

public class TapiocaV2Plugin: NSObject, FlutterPlugin {
    private var events: FlutterEventSink?
    let video = VideoGeneratorService()

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "video_editor", binaryMessenger: registrar.messenger())
        let eventChannel = FlutterEventChannel(name: "video_editor_progress", binaryMessenger: registrar.messenger())
        
        let instance = TapiocaV2Plugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
         eventChannel.setStreamHandler(instance)

  }

public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "writeVideofile":
        guard let args = call.arguments as? [String: Any] else {
          result(FlutterError(code: "arguments_not_found",
                            message: "the arguments is not found.",
                            details: nil))
          return
        }
        guard let srcName = args["srcFilePath"] as? String else {
                result(FlutterError(code: "src_file_path_not_found",
                                    message: "the src file path sr is not found.",
                                    details: nil))
                return
            }
            guard let destName = args["destFilePath"] as? String else {
                result(FlutterError(code: "dest_file_path_not_found",
                                    message: "the dest file path is not found.",
                                    details: nil))
                return
            }
            guard let processing = args["processing"] as?  [String: [String: Any]] else {
                result(FlutterError(code: "processing_data_not_found",
                                    message: "the processing is not found.",
                                    details: nil))
                return
            }
            video.writeVideofile(srcPath: srcName, destPath: destName,
                                 processing: processing,result: result, eventSink : self.events)

    case "cancelExport":
        video.cancelCompression(result: result)
    default:
            result("iOS d" + UIDevice.current.systemVersion)
        }
    }
}

extension TapiocaV2Plugin : FlutterStreamHandler {

    public func onListen(withArguments arguments: Any?,
                         eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.events = events
        return nil
    }

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        self.events = nil
        return nil
    }
}
