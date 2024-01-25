import 'dart:async';
import 'package:flutter/services.dart';

abstract class IVideoEditor {}

class _VideoEditorImpl extends IVideoEditor {
  _VideoEditorImpl._();

  static _VideoEditorImpl? _instance;

  static _VideoEditorImpl get instance {
    return _instance ??= _VideoEditorImpl._();
  }

  static void _dispose() {
    _instance = null;
  }
}

// ignore: non_constant_identifier_names
IVideoEditor get VideoEditorV2 => _VideoEditorImpl.instance;

extension VideoEditorTapioca on IVideoEditor {
  static const MethodChannel _channel = MethodChannel('video_editor');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future writeVideofile(String srcFilePath, String destFilePath,
      Map<String, Map<String, dynamic>> processing) async {
    await _channel.invokeMethod('writeVideofile', <String, dynamic>{
      'srcFilePath': srcFilePath,
      'destFilePath': destFilePath,
      'processing': processing
    });
  }

  static Future cancelExport() async {
    await _channel.invokeMethod('cancelExport', <String, dynamic>{});
  }
}
