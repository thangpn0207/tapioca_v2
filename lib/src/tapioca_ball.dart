import "dart:typed_data";
import "dart:ui";

import "package:tapioca_v2/src/util.dart";

/// TapiocaBall is a effect to apply to the video.
abstract class TapiocaBall {
  /// Creates a object to apply color filter from [Filters].
  static TapiocaBall filter(Filters filter, double degree) {
    return _Filter(filter, degree);
  }

  /// Creates a object to apply color filter from [Color].
  static TapiocaBall filterFromColor(Color color, double alpha) {
    return _Filter.color(color, alpha);
  }

  /// Creates a object to overlay text.
  static TapiocaBall textOverlay(
      String text, int x, int y, int size, Color color) {
    return _TextOverlay(text: text, x: x, y: y, size: size, color: color);
  }

  /// Creates a object to overlay a image.
  static TapiocaBall imageOverlay(Uint8List bitmap, int x, int y) {
    return _ImageOverlay(bitmap, x, y);
  }

  /// Creates a object to overlay a watermark.
  static TapiocaBall watermark(Uint8List bitmap, Position position) {
    return _WatermarkOverlay(bitmap, position);
  }

  /// Returns a [Map<String, dynamic>] representation of this object.
  Map<String, dynamic> toMap();

  /// Returns a TapiocaBall type name.
  String toTypeName();
}

/// Enum that specifies the color filter type.
enum Filters { pink, white, blue }

class _Filter extends TapiocaBall {
  late String color;
  late double alpha;
  _Filter(Filters type, this.alpha) {
    switch (type) {
      case Filters.pink:
        color = "#ffc0cb";
        break;
      case Filters.white:
        color = "#ffffff";
        break;
      case Filters.blue:
        color = "#1f8eed";
    }
  }
  _Filter.color(Color colorInstance, this.alpha) {
    color = colorInstance.toHex(leadingHashSign: true);
  }

  @override
  Map<String, dynamic> toMap() {
    return {'type': color, 'alpha': alpha};
  }

  @override
  String toTypeName() {
    return 'Filter';
  }
}

class _TextOverlay extends TapiocaBall {
  final String text;
  final int x;
  final int y;
  final int size;
  final Color color;
  _TextOverlay({
    required this.text,
    required this.x,
    required this.y,
    required this.size,
    required this.color,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'x': x,
      'y': y,
      'size': size,
      'color': color.toHex(leadingHashSign: true)
    };
  }

  @override
  String toTypeName() {
    return 'TextOverlay';
  }
}

class _ImageOverlay extends TapiocaBall {
  final Uint8List bitmap;
  final int x;
  final int y;
  _ImageOverlay(this.bitmap, this.x, this.y);

  @override
  Map<String, dynamic> toMap() {
    return {'bitmap': bitmap, 'x': x, 'y': y};
  }

  @override
  String toTypeName() {
    return 'ImageOverlay';
  }
}

class _WatermarkOverlay extends TapiocaBall {
  final Uint8List bitmap;
  final Position position;
  _WatermarkOverlay(this.bitmap, this.position);

  @override
  Map<String, dynamic> toMap() {
    return {
      'bitmap': bitmap,
      'position': position.value,
    };
  }

  @override
  String toTypeName() {
    return 'Watermark';
  }
}

enum Position {
  leftTop(0),
  leftBottom(1),
  rightTop(2),
  rightBottom(3);

  const Position(this.value);
  final int value;
}
