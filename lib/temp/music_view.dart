import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'dart:developer' as developer;


class MusicView extends StatelessWidget {
  final AudioController audioController = Get.put(AudioController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Pomodoro Timer')),
      body: Center(
        child: Obx(() {
          if (audioController.isLoading.value) {
            return CircularProgressIndicator();
          } else if (audioController.streams.isEmpty) {
            return Text(
                'No streams available. Please check your internet connection.');
          } else {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Your pomodoro timer widgets here
                SizedBox(height: 20),
                Text(
                  'Current Stream: ${audioController.getCurrentStreamName()}',
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: audioController.togglePlayPause,
                      child: Text(
                          audioController.isPlaying.value ? 'Pause' : 'Play'),
                    ),
                    SizedBox(width: 20),
                    ElevatedButton(
                      onPressed: audioController.nextStream,
                      child: Text('Next Stream'),
                    ),
                  ],
                ),
              ],
            );
          }
        }),
      ),
    );
  }
}

class AudioController extends GetxController {
  final player = AudioPlayer();
  var isPlaying = false.obs;
  var currentStreamIndex = 0.obs;
  var streams = <Map<String, String>>[].obs;
  var isLoading = true.obs;
  final Dio dio = Dio();

  @override
  void onInit() {
    super.onInit();
    fetchStreams();
  }

  Future<void> fetchStreams() async {
    isLoading.value = true;
    try {
      final response = await dio.get('https://www.lofi.cafe/api/stations');
      if (response.statusCode == 200) {
        final String data = response.data;
          developer.log('API Response:', name: 'AudioController', error: data);
        // Parse the string response
        final List<Map<String, String>> parsedStreams = parseStreams(data);
        streams.value = parsedStreams;
        if (streams.isNotEmpty) {
          initializePlayer();
        }
      } else {
        print('Failed to load streams');
      }
    } catch (e) {
      print('Error fetching streams: $e');
    } finally {
      isLoading.value = false;
    }
  }

  List<Map<String, String>> parseStreams(String data) {
    final List<Map<String, String>> result = [];
    final List<String> lines = data.split('\n');
    for (String line in lines) {
      final parts = line.split(':');
      if (parts.length == 2) {
        result.add({
          'name': parts[0].trim(),
          'streamUrl': parts[1].trim(),
        });
      }
    }
    return result;
  }

  void initializePlayer() async {
    if (streams.isNotEmpty) {
      await player.setUrl(streams[currentStreamIndex.value]['streamUrl']!);
      player.playbackEventStream.listen((event) {
        isPlaying.value = player.playing;
      });
    }
  }

  void togglePlayPause() {
    if (streams.isEmpty) return;
    if (player.playing) {
      player.pause();
    } else {
      player.play();
    }
  }

  void nextStream() async {
    if (streams.isEmpty) return;
    currentStreamIndex.value = (currentStreamIndex.value + 1) % streams.length;
    await player.stop();
    await player.setUrl(streams[currentStreamIndex.value]['streamUrl']!);
    player.play();
  }

  String getCurrentStreamName() {
    return streams.isNotEmpty
        ? streams[currentStreamIndex.value]['name']!
        : 'No stream available';
  }

  @override
  void onClose() {
    player.dispose();
    super.onClose();
  }
}
