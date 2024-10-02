import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../services/pexels_service.dart';

class PomodoroController extends GetxController {
  final AudioPlayer audioPlayer = AudioPlayer();
  RxList<Map<String, dynamic>> tracks = <Map<String, dynamic>>[].obs;
  RxInt currentTrackIndex = 0.obs;
  RxBool isPlaying = false.obs;
   Rx<String?> backgroundImageUrl = Rx<String?>(null);
  final PexelsService _pexelsService = PexelsService();

  @override
  void onInit() {
    super.onInit();
    fetchTracks();
      fetchBackgroundImage();
  }

   Future<void> fetchBackgroundImage() async {
    try {
      final imageUrl = await _pexelsService.getRandomImageUrl();
      backgroundImageUrl.value = imageUrl;
    } catch (e) {
      print('Error fetching background image: $e');
    }
  }

    Future<void> fetchRandomBackgroundImage() async {
    // if (imageFetchCount.value >= 20) {

    //   return;
    // }

    try {
      final imageUrl = await _pexelsService.getRandomImageUrl();
      if (imageUrl.isNotEmpty) {
        backgroundImageUrl.value = imageUrl;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('background_image_url', imageUrl);

        // // Increment and save the fetch count
        // imageFetchCount.value++;
        // lastFetchDate.value = DateFormat('yyyy-MM-dd').format(DateTime.now());
        // await prefs.setInt('image_fetch_count', imageFetchCount.value);
        // await prefs.setString('last_fetch_date', lastFetchDate.value);
      } else {
        throw Exception('Received empty image URL');
      }
    } catch (e) {
      print('Error fetching random background image: $e');
      await loadSavedBackgroundImage();
    }
  }


  Future<void> loadSavedBackgroundImage() async {
    final prefs = await SharedPreferences.getInstance();
    final savedImageUrl = prefs.getString('background_image_url');
    if (savedImageUrl != null && savedImageUrl.isNotEmpty) {
      backgroundImageUrl.value = savedImageUrl;
    } else {
      // Use a default image URL if no saved image is available
      backgroundImageUrl.value =
          'https://cdn.pixabay.com/photo/2024/04/09/22/28/trees-8686902_1280.jpg';
    }
  }



  Future<void> fetchTracks() async {
    final response = await http.get(
      Uri.parse(
          'https://api.jamendo.com/v3.0/tracks/?client_id=6b572951&format=json&limit=20&tags=chill&include=musicinfo&groupby=artist_id'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      tracks.value = List<Map<String, dynamic>>.from(data['results']);
      if (tracks.isNotEmpty) {
        playTrack(tracks[0]);
      }
    } else {
      print('Failed to load tracks: ${response.statusCode}');
    }
  }

  Future<void> playTrack(Map<String, dynamic> track) async {
    try {
      await audioPlayer.setUrl(track['audio']);
      audioPlayer.play();
      isPlaying.value = true;
    } catch (e) {
      print('Error playing track: $e');
    }
  }

  void playNextTrack() {
    if (currentTrackIndex.value < tracks.length - 1) {
      currentTrackIndex++;
    } else {
      currentTrackIndex.value = 0;
    }
    playTrack(tracks[currentTrackIndex.value]);
  }

  void togglePlayPause() {
    if (isPlaying.value) {
      audioPlayer.pause();
      isPlaying.value = false;
    } else {
      audioPlayer.play();
      isPlaying.value = true;
    }
  }

  @override
  void onClose() {
    audioPlayer.dispose();
    super.onClose();
  }
}