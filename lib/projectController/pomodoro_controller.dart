import 'dart:math';
import 'dart:async';

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
  RxBool isMuted = false.obs;

  RxInt switchCount = 0.obs;
  RxList<int> lastFiveTracks = <int>[].obs;
  RxBool isLimitedMode = false.obs;

  RxString currentGenre = 'chill'.obs;
  RxDouble volume = 1.0.obs;
  RxList<String> availableGenres = <String>[
    'chill',
    'ambient',
    'lofi',
    'classical',
    'jazz',
    'nature',
    'electronic',
    'postrock',
    'piano',
    'acoustic',
    'minimal',
    'soundtrack',
    'instrumental',
  ].obs;

  Timer? sessionTimer;
  Timer? trackTimer;
  RxInt remainingTime = 1500.obs; // 25 minutes in seconds

  @override
  void onInit() {
    super.onInit();
    randomizeInitialGenre();
    fetchTracks();
    fetchBackgroundImage();
    setupAudioPlayerListeners();
    audioPlayer.setVolume(volume.value);
  }

  void increaseVolume() {
    if (volume.value < 1.0) {
      volume.value = (volume.value + 0.1).clamp(0.0, 10.0);
      audioPlayer.setVolume(volume.value);
    }
  }

  void decreaseVolume() {
    if (volume.value > 0.0) {
      volume.value = (volume.value - 0.1).clamp(0.0, 1.0);
      audioPlayer.setVolume(volume.value);
    }
  }

  void randomizeInitialGenre() {
    final random = Random();
    currentGenre.value =
        availableGenres[random.nextInt(availableGenres.length)];
  }

  void setupAudioPlayerListeners() {
    audioPlayer.playerStateStream.listen((playerState) {
      if (playerState.processingState == ProcessingState.completed) {
        playNextTrack();
      }
    });
  }

  void startPomodoroSession() {
    remainingTime.value = 1500; // Reset to 25 minutes
    sessionTimer?.cancel();
    sessionTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (remainingTime.value > 0) {
        remainingTime.value--;
      } else {
        endPomodoroSession();
      }
    });

    if (!isPlaying.value) {
      playNextTrack();
    }
    isPlaying.value = true;
  }

  void endPomodoroSession() {
    sessionTimer?.cancel();
    audioPlayer.stop();
    isPlaying.value = false;
    remainingTime.value = 1500; // Reset to 25 minutes
  }

  void switchGenre() {
    int nextGenreIndex = (availableGenres.indexOf(currentGenre.value) + 1) %
        availableGenres.length;
    currentGenre.value = availableGenres[nextGenreIndex];
    fetchTracks();
  }

  void switchTrack() {
    if (tracks.isEmpty) return;

    if (!isLimitedMode.value && switchCount.value < 5) {
      int nextIndex = (currentTrackIndex.value + 1) % tracks.length;
      currentTrackIndex.value = nextIndex;
      updateLastFiveTracks(nextIndex);
      playTrack(tracks[nextIndex]);
      switchCount.value++;

      if (switchCount.value == 5) {
        isLimitedMode.value = true;
      }
    } else {
      if (lastFiveTracks.length < 2) return;
      int randomIndex = Random().nextInt(lastFiveTracks.length);
      while (lastFiveTracks[randomIndex] == currentTrackIndex.value) {
        randomIndex = Random().nextInt(lastFiveTracks.length);
      }
      currentTrackIndex.value = lastFiveTracks[randomIndex];
      playTrack(tracks[currentTrackIndex.value]);
    }
  }

  void updateLastFiveTracks(int index) {
    if (!lastFiveTracks.contains(index)) {
      if (lastFiveTracks.length >= 5) {
        lastFiveTracks.removeAt(0);
      }
      lastFiveTracks.add(index);
    }
  }

  void toggleMutePlayPause() {
    if (isMuted.value) {
      audioPlayer.setVolume(1.0);
      audioPlayer.play();
      isMuted.value = false;
      isPlaying.value = true;
    } else if (isPlaying.value) {
      audioPlayer.setVolume(0.0);
      isMuted.value = true;
    } else {
      startPomodoroSession();
    }
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
    try {
      final imageUrl = await _pexelsService.getRandomImageUrl();
      if (imageUrl.isNotEmpty) {
        backgroundImageUrl.value = imageUrl;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('background_image_url', imageUrl);
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
      backgroundImageUrl.value =
          'https://cdn.pixabay.com/photo/2024/04/09/22/28/trees-8686902_1280.jpg';
    }
  }

  Future<void> fetchTracks() async {
    final response = await http.get(
      Uri.parse(
          'https://api.jamendo.com/v3.0/tracks/?client_id=6b572951&format=json&limit=20&tags=${currentGenre.value}&include=musicinfo&groupby=artist_id'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      tracks.value = List<Map<String, dynamic>>.from(data['results']);
      if (tracks.isNotEmpty) {
        currentTrackIndex.value = 0;
        if (isPlaying.value) {
          playTrack(tracks[0]);
        }
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
    if (tracks.isEmpty) return;
    currentTrackIndex.value = (currentTrackIndex.value + 1) % tracks.length;
    playTrack(tracks[currentTrackIndex.value]);
  }

  void togglePlayPause() {
    if (isPlaying.value) {
      audioPlayer.pause();
      isPlaying.value = false;
      sessionTimer?.cancel();
    } else {
      startPomodoroSession();
    }
  }

  @override
  void onClose() {
    audioPlayer.dispose();
    sessionTimer?.cancel();
    trackTimer?.cancel();
    super.onClose();
  }
}
