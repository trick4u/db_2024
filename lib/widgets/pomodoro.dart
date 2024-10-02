

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


class PomodoroMusicPlayer extends StatefulWidget {
  @override
  _PomodoroMusicPlayerState createState() => _PomodoroMusicPlayerState();
}

class _PomodoroMusicPlayerState extends State<PomodoroMusicPlayer> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  List<Map<String, dynamic>> _tracks = [];
  int _currentTrackIndex = 0;

  @override
  void initState() {
    super.initState();
    _fetchTracks();
  }

  Future<void> _fetchTracks() async {
    final response = await http.get(Uri.parse(
        'https://api.jamendo.com/v3.0/tracks/?client_id=6b572951&format=json&limit=20&tags=lofi+ambient&include=musicinfo&groupby=artist_id'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _tracks = List<Map<String, dynamic>>.from(data['results']);
      });
      if (_tracks.isNotEmpty) {
        _playTrack(_tracks[0]);
      }
    } else {
      print('Failed to load tracks: ${response.statusCode}');
      // Handle error - maybe show a dialog to the user
    }
  }

  Future<void> _playTrack(Map<String, dynamic> track) async {
    try {
      await _audioPlayer.setUrl(track['audio']);
      _audioPlayer.play();
      setState(() {
        // Update UI to show current track info
      });
    } catch (e) {
      print('Error playing track: $e');
      // Handle error - maybe skip to next track or show error to user
    }
  }

  void _playNextTrack() {
    if (_currentTrackIndex < _tracks.length - 1) {
      _currentTrackIndex++;
      _playTrack(_tracks[_currentTrackIndex]);
    } else {
      // Reached end of playlist, maybe start over or shuffle
      _currentTrackIndex = 0;
      _playTrack(_tracks[_currentTrackIndex]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Text(_tracks.isNotEmpty 
              ? 'Now Playing: ${_tracks[_currentTrackIndex]['name']} by ${_tracks[_currentTrackIndex]['artist_name']}'
              : 'Loading tracks...'),
          ElevatedButton(
            onPressed: () {
              if (_audioPlayer.playing) {
                _audioPlayer.pause();
              } else {
                _audioPlayer.play();
              }
            },
            child: Text(_audioPlayer.playing ? 'Pause' : 'Play'),
          ),
          ElevatedButton(
            onPressed: _playNextTrack,
            child: Text('Next Track'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}