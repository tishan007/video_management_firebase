import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoDetails extends StatefulWidget {
  final DocumentSnapshot item;
  const VideoDetails({Key? key, required this.item}) : super(key: key);

  @override
  State<VideoDetails> createState() => _VideoDetailsState();
}

class _VideoDetailsState extends State<VideoDetails> {

  late VideoPlayerController _controller;
  Future<void>? _initializeVideoPlayerFuture;
  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(
      //'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
        widget.item["video"]
    );

    _initializeVideoPlayerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Details", style: TextStyle(color: Colors.black)),
          centerTitle: true,
          backgroundColor: const Color(0xFF5bc8e5),
        ),
        body: FutureBuilder(
          future: _initializeVideoPlayerFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              var str = _controller.value.duration.toString().split(".");
              var vdoDuration = str[0].trim();
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Title : ${widget.item["title"]}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
                  const SizedBox(height: 10,),
                  Text("Description : ${widget.item["description"]}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
                  const SizedBox(height: 10,),
                  Text("Duration : $vdoDuration", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
                  const SizedBox(height: 30,),

                  _controller.value.isInitialized
                      ? SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: 300,
                        child: AspectRatio(
                            aspectRatio: _controller.value.aspectRatio,
                            child: VideoPlayer(_controller)
                  ),
                      )
                      : const Center(
                        child: Text("Firebase storage Quota has been exceeded: 1GB/daily", style: TextStyle(color: Colors.red),),
                      ),
                  const SizedBox(height: 10,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                          onPressed: () {
                            _controller.pause();
                          },
                          child: const Icon(Icons.pause)),
                      const Padding(padding: EdgeInsets.all(2)),
                      ElevatedButton(
                          onPressed: () {
                            _controller.play();
                          },
                          child: const Icon(Icons.play_arrow))
                    ],
                  ),
                  VideoProgressIndicator(
                    _controller,
                    allowScrubbing: true,
                    colors: const VideoProgressColors(
                        backgroundColor: Colors.red,
                        bufferedColor: Colors.black,
                        playedColor: Colors.blueAccent),
                  )
                ],
              );
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ));
  }
}
