// lib/core/services/audio_service.dart
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart' show debugPrint;

/// Oyun ses servisi.
/// Ses dosyaları assets/audio/ altına eklendikçe aktif olur.
class AudioService {
  AudioService._();
  static final AudioService instance = AudioService._();

  final AudioPlayer _musicPlayer = AudioPlayer();
  final AudioPlayer _sfxPlayer = AudioPlayer();

  bool _soundEnabled = true;
  bool _musicEnabled = true;

  void setSoundEnabled(bool value) => _soundEnabled = value;
  void setMusicEnabled(bool value) {
    _musicEnabled = value;
    if (!value) {
      _musicPlayer.stop();
    } else {
      // Müzik tekrar başlatılabilir
    }
  }

  /// Arka plan müziğini başlat (loop).
  Future<void> playMusic(String assetPath) async {
    if (!_musicEnabled) return;
    try {
      await _musicPlayer.setReleaseMode(ReleaseMode.loop);
      await _musicPlayer.play(AssetSource(assetPath));
    } catch (e) {
      debugPrint('[AudioService] Müzik başlatılamadı: $e');
    }
  }

  /// Ses efekti çal.
  Future<void> playSfx(String assetPath) async {
    if (!_soundEnabled) return;
    try {
      await _sfxPlayer.play(AssetSource(assetPath));
    } catch (e) {
      debugPrint('[AudioService] SFX çalınamadı: $e');
    }
  }

  Future<void> stopMusic() async => _musicPlayer.stop();
  Future<void> pauseMusic() async => _musicPlayer.pause();
  Future<void> resumeMusic() async => _musicPlayer.resume();

  void dispose() {
    _musicPlayer.dispose();
    _sfxPlayer.dispose();
  }
}
