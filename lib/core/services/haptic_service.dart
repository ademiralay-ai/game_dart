// lib/core/services/haptic_service.dart
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';

/// Titreşim servisi.
/// Flutter'ın kendi HapticFeedback API'sini kullanır - ek paket gerekmez.
/// Web'de otomatik olarak devre dışıdır.
class HapticService {
  HapticService._();
  static final HapticService instance = HapticService._();

  bool _enabled = true;
  void setEnabled(bool value) => _enabled = value;

  /// Hafif titreşim (buton dokunuşları için)
  Future<void> lightImpact() async {
    if (kIsWeb || !_enabled) return;
    await HapticFeedback.lightImpact();
  }

  /// Orta titreşim (önemli aksiyonlar için)
  Future<void> mediumImpact() async {
    if (kIsWeb || !_enabled) return;
    await HapticFeedback.mediumImpact();
  }

  /// Güçlü titreşim (başarı/hata bildirimleri için)
  Future<void> heavyImpact() async {
    if (kIsWeb || !_enabled) return;
    await HapticFeedback.heavyImpact();
  }

  /// Seçim tıklaması (liste geçişleri için)
  Future<void> selectionClick() async {
    if (kIsWeb || !_enabled) return;
    await HapticFeedback.selectionClick();
  }
}
