import 'dart:async';

import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:tapioca_v2/tapioca_v2.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/services.dart' show rootBundle;

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final navigatorKey = GlobalKey<NavigatorState>();
  late XFile _video;
  bool isLoading = false;
  late StreamSubscription _streamSubscription;
  int processPercentage = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _disableEventReceiver();
  }

  void _disableEventReceiver() {
    _streamSubscription.cancel();
  }

  _pickVideo() async {
    try {
      final ImagePicker picker = ImagePicker();
      XFile? video = await picker.pickVideo(source: ImageSource.gallery);
      if (video != null) {
        setState(() {
          _video = video;
          isLoading = true;
        });
      }
    } catch (error) {
      print(error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
            child: isLoading
                ? Column(mainAxisSize: MainAxisSize.min, children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 10),
                    Text(
                      "$processPercentage%",
                      style: const TextStyle(fontSize: 20),
                    ),
                  ])
                : ElevatedButton(
                    child: const Text("Pick a video and Edit it"),
                    onPressed: () async {
                      print("clicked!");
                      await _pickVideo();
                      var tempDir = await getTemporaryDirectory();
                      final path =
                          '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}result.mp4';
                      print(tempDir);
                      final ByteData bmp = await rootBundle.load('assets/cool'
                          '.png');
                      final currentState = navigatorKey.currentState;
                      // if (currentState != null) {
                      //   currentState.push(
                      //     MaterialPageRoute(
                      //         builder: (context) => VideoScreen(_video.path)),
                      //   );
                      // }
                      try {
                        final tapiocaBalls = [
                          //TapiocaBall.filter(Filters.pink, 0.2),
                          // TapiocaBall.textOverlay(
                          //     "text", 100, 10, 100, const Color(0xffffc0cb)),
                          TapiocaBall.watermark(
                              bmp.buffer.asUint8List(), Position.rightTop),
                        ];
                        print("will start");
                        final cup = Cup(Content(_video.path), tapiocaBalls);
                        cup.suckUp(path).then((_) async {
                          print("finished");
                          setState(() {
                            processPercentage = 0;
                          });
                          print(path);
                          GallerySaver.saveVideo(path).then((bool? success) {
                            print(success.toString());
                          });
                          final currentState = navigatorKey.currentState;
                          if (currentState != null) {
                            currentState.push(
                              MaterialPageRoute(
                                  builder: (context) =>
                                      VideoScreen(_video.path)),
                            );
                          }

                          setState(() {
                            isLoading = false;
                          });
                        }).catchError((e) {
                          print('Got error: $e');
                        });
                      } on PlatformException {
                        print("error!!!!");
                      }
                    },
                  )),
      ),
    );
  }
}

class VideoScreen extends StatefulWidget {
  final String path;

  const VideoScreen(this.path, {super.key});

  @override
  _VideoAppState createState() => _VideoAppState(path);
}

class _VideoAppState extends State<VideoScreen> {
  final String path;

  _VideoAppState(this.path);

  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(File(path))
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {});
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: _controller.value.isInitialized
            ? AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: Stack(children: [
                  VideoPlayer(_controller),
                ]),
              )
            : Container(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            if (!_controller.value.isPlaying &&
                _controller.value.isInitialized &&
                (_controller.value.duration == _controller.value.position)) {
              _controller.initialize();
              _controller.play();
            } else {
              _controller.value.isPlaying
                  ? _controller.pause()
                  : _controller.play();
            }
          });
        },
        child: Icon(
          _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}
