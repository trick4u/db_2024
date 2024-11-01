import 'dart:math';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio_background/just_audio_background.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../services/pexels_service.dart';

class PomodoroController extends GetxController with WidgetsBindingObserver {
  final defaultImageUrl = dotenv.env['DEFAULT_IMAGE_URL'] ?? '';
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
  RxDouble overlayOpacity = 0.3.obs;
  RxBool isVolumeMuted = false.obs;
  RxInt sessionDuration = 25.obs; // Default 25 minutes
  RxInt breakDuration = 5.obs; // Default 5 minutes break
  RxBool isBreakTime = false.obs;
  RxBool isSetupComplete = false.obs;
  RxInt totalSessions = 4.obs; // Default to 4 sessions
  RxInt currentSession = 1.obs;

  //new variables
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(milliseconds: 500);
  final RxBool isLoadingTrack = false.obs;

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
    'peaceful'
  ].obs;

  Timer? sessionTimer;
  Timer? trackTimer;
  RxInt remainingTime = 1500.obs; // 25 minutes in seconds

  int? _savedRemainingTime;
  bool? _wasPlaying;

  RxBool isSessionActive = false.obs;
  RxBool isBreakActive = false.obs;

  RxInt trackSwitchCount = 0.obs;
  final int requiredSwitchesBeforeGenreChange = 5;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    _initializePlayer();
    randomizeInitialGenre();
    fetchTracks();
    fetchBackgroundImage();
    setupAudioPlayerListeners();
    audioPlayer.setVolume(volume.value);
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    audioPlayer.dispose();
    sessionTimer?.cancel();
    trackTimer?.cancel();
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        // Only save the state but don't pause playback
        _savedRemainingTime = remainingTime.value;
        _wasPlaying = isPlaying.value;
        break;
      case AppLifecycleState.resumed:
        _resumeEverything();
        break;
      case AppLifecycleState.detached:
        // Clean up resources if needed
        break;
      default:
        break;
    }
  }

  Future<void> _initializePlayer() async {
    try {
      await audioPlayer.setVolume(volume.value);
      await audioPlayer.setAutomaticallyWaitsToMinimizeStalling(true);
      setupAudioPlayerListeners();
    } catch (e) {
      print('Error initializing player: $e');
    }
  }

  void decreaseVolume() {
    if (isBreakTime.value) return; // Prevent volume change during break

    if (isPlaying.value) {
      audioPlayer.pause();
      isPlaying.value = false;
      isVolumeMuted.value = true;
      updateOverlayOpacity();
    }
  }

  void increaseVolume() {
    if (isBreakTime.value) return; // Prevent volume change during break

    if (!isPlaying.value) {
      audioPlayer.play();
      isPlaying.value = true;
      isVolumeMuted.value = false;
      volume.value = volume.value > 0 ? volume.value : 0.5;
      audioPlayer.setVolume(volume.value);
      updateOverlayOpacity();
    }
  }

  void updateOverlayOpacity() {
    overlayOpacity.value = isPlaying.value ? 0.3 : 0;
  }

  void _pauseEverything() {
    // Only save state without affecting playback
    _savedRemainingTime = remainingTime.value;
    _wasPlaying = isPlaying.value;
    
    // Only pause the timer, not the music
    sessionTimer?.cancel();
  }

  void _resumeEverything() {
    // Resume the timer if it was running
    if (_savedRemainingTime != null && _wasPlaying == true) {
      remainingTime.value = _savedRemainingTime!;
      startPomodoroSession();
    }

    // Resume the music if it was playing
    if (_wasPlaying == true) {
      audioPlayer.play();
      isPlaying.value = true;
    }

    // Reset the saved state
    _savedRemainingTime = null;
    _wasPlaying = null;
  }

  // void increaseVolume() {
  //   if (volume.value < 1.0) {
  //     volume.value = (volume.value + 0.1).clamp(0.0, 10.0);
  //     audioPlayer.setVolume(volume.value);
  //   }
  // }

  // void decreaseVolume() {
  //   if (volume.value > 0.0) {
  //     volume.value = (volume.value - 0.1).clamp(0.0, 1.0);
  //     audioPlayer.setVolume(volume.value);
  //   }
  // }

  void randomizeInitialGenre() {
    final random = Random();
    currentGenre.value =
        availableGenres[random.nextInt(availableGenres.length)];
  }

  void setupAudioPlayerListeners() {
    // Listen for playback state changes
    audioPlayer.playerStateStream.listen(
      (playerState) async {
        if (playerState.processingState == ProcessingState.completed) {
          await _safePlayNextTrack();
        }
      },
      onError: (error) {
        print('Player state stream error: $error');
        _handlePlaybackError();
      },
    );

    // Listen for errors
    audioPlayer.playbackEventStream.listen(
      (event) {},
      onError: (Object e, StackTrace stackTrace) {
        print('Playback event stream error: $e');
        _handlePlaybackError();
      },
    );
  }

  Future<void> _handlePlaybackError() async {
    if (isPlaying.value && !isLoadingTrack.value) {
      await _safePlayNextTrack();
    }
  }

  Future<void> _safePlayNextTrack() async {
    try {
      if (tracks.isEmpty) return;

      int nextIndex = (currentTrackIndex.value + 1) % tracks.length;
      currentTrackIndex.value = nextIndex;

      await _safePlayTrack(tracks[nextIndex]);
    } catch (e) {
      print('Error in safe play next track: $e');
    }
  }

  Future<void> _safePlayTrack(Map<String, dynamic> track) async {
    if (isLoadingTrack.value) return;

    isLoadingTrack.value = true;
    int attemptCount = 0;

    try {
      while (attemptCount < maxRetries) {
        try {
          final success = await _attemptPlayTrack(track);
          if (success) {
            isLoadingTrack.value = false;
            return;
          }
        } catch (e) {
          print('Attempt ${attemptCount + 1} failed: $e');
        }

        attemptCount++;
        if (attemptCount < maxRetries) {
          await Future.delayed(retryDelay);
        }
      }

      // If all attempts failed, try next track
      print('All attempts failed, trying next track');
      isLoadingTrack.value = false;
      await _safePlayNextTrack();
    } finally {
      isLoadingTrack.value = false;
    }
  }

  Future<bool> _attemptPlayTrack(Map<String, dynamic> track) async {
    try {
      final artUri = Uri.parse(backgroundImageUrl.value ??
          'https://cdn.pixabay.com/photo/2024/04/09/22/28/trees-8686902_1280.jpg');

      final mediaItem = MediaItem(
        id: track['id']?.toString() ?? DateTime.now().toString(),
        album: 'Pomodoro Focus',
        title: track['name'] ?? 'Unknown Track',
        artist: track['artist_name'] ?? 'Unknown Artist',
        duration: Duration(
            seconds: int.tryParse(track['duration']?.toString() ?? '0') ?? 0),
        artUri: artUri,
        displayDescription: 'Genre: ${currentGenre.value}',
        extras: {
          'url': track['audio'],
          'genre': currentGenre.value,
          'keepPlaying': true,
        },
      );

      // Create and set the audio source
      final audioSource = AudioSource.uri(
        Uri.parse(track['audio']),
        tag: mediaItem,
      );

      // Set the audio source with a timeout
      bool sourceSet = await _setAudioSourceWithTimeout(audioSource);
      if (!sourceSet) return false;

      // Start playback
      if (!isBreakTime.value) {
        await audioPlayer.play();
        isPlaying.value = true;
        await audioPlayer.setAutomaticallyWaitsToMinimizeStalling(false);
        updateOverlayOpacity();
      }

      return true;
    } on PlatformException catch (e) {
      print('Platform Exception in attempt play track: ${e.message}');
      return false;
    } catch (e) {
      print('Error in attempt play track: $e');
      return false;
    }
  }

  Future<bool> _setAudioSourceWithTimeout(AudioSource source) async {
    try {
      await audioPlayer.setAudioSource(source).timeout(Duration(seconds: 5),
          onTimeout: () {
        throw TimeoutException('Setting audio source timed out');
      });
      return true;
    } on TimeoutException {
      print('Setting audio source timed out');
      return false;
    } catch (e) {
      print('Error setting audio source: $e');
      return false;
    }
  }

  Future<void> _recoverPlayback() async {
    try {
      if (tracks.isNotEmpty) {
        await playTrack(tracks[currentTrackIndex.value], retry: true);
      }
    } catch (e) {
      print('Error recovering playback: $e');
    }
  }

  Future<bool> _trySetAudioSource(AudioSource source,
      {int retryCount = 0}) async {
    try {
      await audioPlayer.setAudioSource(source);
      return true;
    } catch (e) {
      print('Error setting audio source (attempt ${retryCount + 1}): $e');
      if (retryCount < maxRetries) {
        await Future.delayed(retryDelay);
        return _trySetAudioSource(source, retryCount: retryCount + 1);
      }
      return false;
    }
  }

  void startPomodoroSession() {
    if (!isSessionActive.value) {
      remainingTime.value = sessionDuration.value * 60;
      isSessionActive.value = true;
      isBreakTime.value = false;
      isSetupComplete.value = true;
      enableMusicControls(); // Re-enable music controls when starting a new session
    }

    sessionTimer?.cancel();
    sessionTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (remainingTime.value > 0) {
        remainingTime.value--;
      } else {
        if (isBreakTime.value) {
          if (currentSession.value < totalSessions.value) {
            currentSession.value++;
            isBreakTime.value = false;
            remainingTime.value = sessionDuration.value * 60;
            enableMusicControls(); // Re-enable music controls when break ends
            playCurrentTrack();
          } else {
            resetPomodoro();
          }
        } else {
          startBreak();
        }
      }
    });

    if (!isPlaying.value) {
      playCurrentTrack();
    }
    isPlaying.value = true;
  }

  void resetPomodoro() {
    sessionTimer?.cancel();
    isSessionActive.value = false;
    isBreakTime.value = false;
    isSetupComplete.value = false;
    remainingTime.value = sessionDuration.value * 60;
    isPlaying.value = false;
    currentSession.value = 1;
    audioPlayer.stop();
  }

  void startBreak() {
    remainingTime.value = breakDuration.value * 60;
    isBreakTime.value = true;
    audioPlayer.pause();
    isPlaying.value = false;
    // Disable music controls during break
    disableMusicControls();
  }

  void disableMusicControls() {
    // Disable volume controls and music playback during break
    volume.value = 0;
    audioPlayer.setVolume(0);
    isVolumeMuted.value = true;
  }

  void enableMusicControls() {
    // Re-enable volume controls and music playback after break
    volume.value = 1;
    audioPlayer.setVolume(1);
    isVolumeMuted.value = false;
  }

  Future<void> playNextTrack() async {
    if (tracks.isEmpty) return;
    try {
      int nextIndex = (currentTrackIndex.value + 1) % tracks.length;
      currentTrackIndex.value = nextIndex;
      await playTrack(tracks[nextIndex]);
    } catch (e) {
      print('Error switching to next track: $e');
      // If error occurs, try the next track after a delay
      await Future.delayed(Duration(seconds: 1));
      currentTrackIndex.value = (currentTrackIndex.value + 1) % tracks.length;
      await playTrack(tracks[currentTrackIndex.value], retry: true);
    }
  }

  void playCurrentTrack() {
    if (tracks.isNotEmpty) {
      playTrack(tracks[currentTrackIndex.value]);
    }
  }

  void endPomodoroSession() {
    sessionTimer?.cancel();
    isSessionActive.value = false;
    isBreakTime.value = false;
    currentSession.value = 1;
  }

  void switchGenre() {
    if (isBreakTime.value) return; // Prevent switching genre during break

    if (trackSwitchCount.value < requiredSwitchesBeforeGenreChange) {
      // Switch track within the same genre
      switchTrack();
      trackSwitchCount.value++;
    } else {
      // Switch to a new genre
      int nextGenreIndex = (availableGenres.indexOf(currentGenre.value) + 1) %
          availableGenres.length;
      currentGenre.value = availableGenres[nextGenreIndex];
      fetchTracks();
      trackSwitchCount.value = 0; // Reset the track switch count
    }
  }

  Future<void> switchTrack() async {
    if (tracks.isEmpty) return;

    try {
      if (!isLimitedMode.value && switchCount.value < 5) {
        int nextIndex = (currentTrackIndex.value + 1) % tracks.length;
        currentTrackIndex.value = nextIndex;
        updateLastFiveTracks(nextIndex);
        await playTrack(tracks[nextIndex]);
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
        await playTrack(tracks[currentTrackIndex.value]);
      }
    } catch (e) {
      print('Error switching track: $e');
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
    if (isBreakTime.value) return; // Prevent toggling during break

    if (isVolumeMuted.value) {
      volume.value = volume.value > 0 ? volume.value : 0.5;
      audioPlayer.setVolume(volume.value);
      audioPlayer.play();
      isVolumeMuted.value = false;
      isPlaying.value = true;
    } else if (isPlaying.value) {
      volume.value = 0.0;
      audioPlayer.setVolume(0.0);
      isVolumeMuted.value = true;
    } else {
      startPomodoroSession();
    }
    updateOverlayOpacity();
  }

  Future<void> fetchBackgroundImage() async {
    try {
      final imageUrl = await _pexelsService.getRandomImageUrl();
      backgroundImageUrl.value = imageUrl;

      // Update the current media item with the new background image if playing
      if (isPlaying.value && tracks.isNotEmpty) {
        await playTrack(tracks[currentTrackIndex.value]);
      }
    } catch (e) {
      print('Error fetching background image: $e');
    }
  }

  Future<void> fetchRandomBackgroundImage() async {
    try {
      final imageUrl = await _pexelsService.getRandomImageUrlAbs();
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
    try {
      final clientId = dotenv.env['JAMENDO_CLIENT_ID'] ?? '';
      final baseUrl = dotenv.env['JAMENDO_API_URL'] ?? '';

      final response = await http.get(
        Uri.parse(
            '$baseUrl/tracks/?client_id=$clientId&format=json&limit=20&tags=${currentGenre.value}&include=musicinfo&groupby=artist_id'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List<dynamic>;

        tracks.value = results
            .map((track) => {
                  'id': track['id']?.toString() ?? DateTime.now().toString(),
                  'name': track['name'] ?? 'Unknown Track',
                  'artist_name': track['artist_name'] ?? 'Unknown Artist',
                  'duration': track['duration'] ?? 0,
                  'audio': track['audio'] ?? '',
                  'image': track['image'] ?? defaultImageUrl,
                })
            .toList()
            .cast<Map<String, dynamic>>();

        if (tracks.isNotEmpty) {
          currentTrackIndex.value = 0;
          await preloadTrack(tracks[0]);
        }
      } else {
        print('Failed to load tracks: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching tracks: $e');
    }
  }

  Future<void> preloadTrack(Map<String, dynamic> track) async {
    try {
      final artUri = Uri.parse(backgroundImageUrl.value ??
          'https://cdn.pixabay.com/photo/2024/04/09/22/28/trees-8686902_1280.jpg');

      final mediaItem = MediaItem(
        id: track['id']?.toString() ?? DateTime.now().toString(),
        album: 'Pomodoro Focus',
        title: 'goalKeep',
        // title: track['name'] ?? 'Unknown Track',
        // artist: track['artist_name'] ?? 'Unknown Artist',
        duration: Duration(
            seconds: int.tryParse(track['duration']?.toString() ?? '0') ?? 0),
        artUri: artUri,
        displayDescription: 'Genre: ${currentGenre.value}',
      );

      final audioSource = AudioSource.uri(
        Uri.parse(track['audio']),
        tag: mediaItem,
      );

      await _trySetAudioSource(audioSource);
    } catch (e) {
      print('Error preloading track: $e');
    }
  }

  Future<void> playTrack(Map<String, dynamic> track,
      {bool retry = false}) async {
    if (!retry) {
      // Only update state if this isn't a retry attempt
      isPlaying.value = true;
      updateOverlayOpacity();
    }

    try {
      final artUri = Uri.parse(backgroundImageUrl.value ??
          'https://cdn.pixabay.com/photo/2024/04/09/22/28/trees-8686902_1280.jpg');

      final mediaItem = MediaItem(
        id: track['id']?.toString() ?? DateTime.now().toString(),
        album: 'Pomodoro Focus',
        title: "goalKeep",
        // title: track['name'] ?? 'Unknown Track',
        // artist: track['artist_name'] ?? 'Unknown Artist',
        duration: Duration(
            seconds: int.tryParse(track['duration']?.toString() ?? '0') ?? 0),
        artUri: artUri,
        displayDescription: 'Genre: ${currentGenre.value}',
        extras: {
          'url': track['audio'],
          'genre': currentGenre.value,
          'keepPlaying': true,
        },
      );

      final audioSource = AudioSource.uri(
        Uri.parse(track['audio']),
        tag: mediaItem,
      );

      // Try to set the audio source with retries
      final success = await _trySetAudioSource(audioSource);
      if (success) {
        await audioPlayer.play();
      } else {
        // If setting audio source failed after retries, try next track
        print('Failed to set audio source after retries, trying next track');
        if (!retry) {
          await playNextTrack();
        }
      }
    } catch (e) {
      print('Error playing track: $e');
      if (!retry) {
        // Only try next track if this wasn't already a retry attempt
        await Future.delayed(Duration(seconds: 1));
        await playNextTrack();
      }
    }
  }

  void togglePlayPause() {
    if (isBreakTime.value) return; // Prevent toggling during break

    if (isPlaying.value) {
      audioPlayer.pause();
      isPlaying.value = false;
      sessionTimer?.cancel();
    } else {
      if (isSessionActive.value) {
        startPomodoroSession();
      } else {
        remainingTime.value = sessionDuration.value * 60;
        startPomodoroSession();
      }
    }
  }
}
