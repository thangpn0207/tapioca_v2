# Tapioca_V2 - a Flutter plugin for video editing
[![Version](https://img.shields.io/pub/v/tapioca.svg)](https://pub.dev/packages/tapioca_v2)
[![Generic badge](https://img.shields.io/badge/platform-android%20|%20ios%20|%20web%20-blue.svg)](https://pub.dev/packages/tapioca_v2)

"Tapioca_v2 is a Flutter plugin designed for video editing on both Android and iOS platforms.
It has been updated and improved based on the source code of Tapioca."

*Note:* Feedback welcome and Pull Requests are most welcome!

## Previews

<table>
    <td><img src="https://raw.githubusercontent.com/anharu2394/tapioca/master/assets/non_filter.gif"><br>No filter</td>
    <td><img src="https://raw.githubusercontent.com/anharu2394/tapioca/master/assets/pink_filter.gif"><br>Apply pink filter</td>
    <td><img src="https://raw.githubusercontent.com/anharu2394/tapioca/master/assets/blue_filter.gif"><br>Apply blue filter</td>
    <td><img src="https://raw.githubusercontent.com/anharu2394/tapioca/master/assets/text_filter.gif"><br>Apply text filter</td>
</table>

## Features

- Develop for iOS and Android from a single codebase
- Edit videos(Apply filter, Overlay text)

## Installation

First, add `tapioca_V2` as a [dependency in your pubspec.yaml file.](https://flutter.dev/docs/development/packages-and-plugins/using-packages)

### iOS

Add the following entry to your _Info.plist_ file, located in `<project root>/ios/Runner/Info.plist`:

- NSPhotoLibraryUsageDescription - Specifies the reason for your app to access the user’s photo library. This is called `Privacy - Photo Library Usage Description` in the visual editor.
- NSPhotoLibraryAddUsageDescription - Specifies the reason for your app to get write-only access to the user’s photo library. This is called `Privacy - Photo Library Additions Usage Description` in the visual editor.


### Android

Step 1. Ensure the following permission is present in your Android Manifest file, located in `<project root>/android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
```

Step 2. Add the JitPack repository to your Android build file, located in `<project root>/android/build.gradle`:

```
allprojects {
	repositories {
		...
		maven { url 'https://jitpack.io' }
	}
}

```
```
        minSdkVersion 21
```

## Usage

Add filter,text for your video
```dart
import 'package:tapioca_v2/tapioca.dart';
import 'package:path_provider/path_provider.dart';

final tapiocaBalls = [
    TapiocaBall.filter(Filters.pink),
    TapiocaBall.textOverlay("text",100,10,100,Color(0xffffc0cb)),
];
var tempDir = await getTemporaryDirectory();
final path = '${tempDir.path}/result.mp4';
final cup = Cup(Content(videoPath), tapiocaBalls);
cup.suckUp(path).then((_) {
  print("finish processing");
});
```
Cancel export
```dart
    await VideoEditorTapioca.cancelExport();
```

### TapiocaBall

TapiocaBall is a effect to apply to the video.

| TapiocaBall                                                                |       Effect       |
|:---------------------------------------------------------------------------| :----------------: |
| TapiocaBall.filter(Filters filter)                                         | Apply color filter |
| TapiocaBall.textOverlay(String text, int x, int y, int size, Color color,double? alpha) |    Overlay text    |

## Content

Content is a class to wrap a video file.

## Cup

Cup is a class to wrap a `Content` object and `List<TapiocaBall>` object.

You can edit the video by executing `.suckUp()`.


## Supported Formats

- On iOS, the backing video editor is [AVFoundation](https://developer.apple.com/documentation/avfoundation).
  please refer [here](https://developer.apple.com/documentation/avfoundation/avfiletype) for list of supported video formats.
- On Android, the backing video editor is [Mp4Composer-android](https://github.com/MasayukiSuda/Mp4Composer-android),
  The supported format is only MP4.

## Articles

- “Tapioca_V2”, the flutter package to edit videos easily and not using 
  FFmpeg

## Contributing
Contributions are welcomed!

- Report bugs and scenarios that are difficult to implement
- Report parts of the documentation that are unclear
- Update the documentation / add examples
- Implement new features by making a pull-request

Please see the following guidelines when modifying the repository  
[Contributing](CONTRIBUTING.md)
