import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';

// Player instance to control music
final audioPlayerProvider = Provider<AudioPlayer>((ref) {
  return AudioPlayer();
});

// Provider to track music enabled state
final musicEnabledProvider = StateNotifierProvider<MusicEnabledNotifier, bool>((ref) {
  return MusicEnabledNotifier(ref);
});

class MusicEnabledNotifier extends StateNotifier<bool> {
  final Ref _ref;
  
  MusicEnabledNotifier(this._ref) : super(true) {
    _loadSavedPreference();
  }

  // Load saved music preference
  Future<void> _loadSavedPreference() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool('isMusicEnabled') ?? true;
    
    // Initialize music if enabled
    if (state) {
      _playBackgroundMusic();
    }
  }

  // Save preference and toggle music
  Future<void> toggle() async {
    state = !state;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isMusicEnabled', state);
    
    if (state) {
      _playBackgroundMusic();
    } else {
      _stopBackgroundMusic();
    }
  }

void _playBackgroundMusic() async {
  final player = _ref.read(audioPlayerProvider);
  await player.play(AssetSource('audio/background_music.mp3'));
  await player.setReleaseMode(ReleaseMode.loop);
}

void _stopBackgroundMusic() {
  final player = _ref.read(audioPlayerProvider);
  player.stop();
}
  
  @override
  void dispose() {
    _ref.read(audioPlayerProvider).dispose();
    super.dispose();
  }

 
}