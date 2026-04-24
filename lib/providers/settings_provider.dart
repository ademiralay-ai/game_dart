// lib/providers/settings_provider.dart
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';
import '../core/services/audio_service.dart';
import '../core/services/haptic_service.dart';

@immutable
class SettingsState {
  final bool isDarkMode;
  final bool isSoundEnabled;
  final bool isMusicEnabled;
  final bool isVibrationEnabled;
  final String boardThemeId;
  final String appTheme; // 'normal', 'dark', 'neon'

  const SettingsState({
    this.isDarkMode = false,
    this.isSoundEnabled = true,
    this.isMusicEnabled = true,
    this.isVibrationEnabled = true,
    this.boardThemeId = 'classic',
    this.appTheme = 'dark',
  });

  SettingsState copyWith({
    bool? isDarkMode,
    bool? isSoundEnabled,
    bool? isMusicEnabled,
    bool? isVibrationEnabled,
    String? boardThemeId,
    String? appTheme,
  }) =>
      SettingsState(
        isDarkMode: isDarkMode ?? this.isDarkMode,
        isSoundEnabled: isSoundEnabled ?? this.isSoundEnabled,
        isMusicEnabled: isMusicEnabled ?? this.isMusicEnabled,
        isVibrationEnabled: isVibrationEnabled ?? this.isVibrationEnabled,
        boardThemeId: boardThemeId ?? this.boardThemeId,
        appTheme: appTheme ?? this.appTheme,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SettingsState &&
          isDarkMode == other.isDarkMode &&
          isSoundEnabled == other.isSoundEnabled &&
          isMusicEnabled == other.isMusicEnabled &&
          isVibrationEnabled == other.isVibrationEnabled &&
          boardThemeId == other.boardThemeId &&
          appTheme == other.appTheme;

  @override
  int get hashCode =>
      Object.hash(isDarkMode, isSoundEnabled, isMusicEnabled,
          isVibrationEnabled, boardThemeId, appTheme);
}

class SettingsNotifier extends AsyncNotifier<SettingsState> {
  @override
  Future<SettingsState> build() async {
    final p = await SharedPreferences.getInstance();
    final s = SettingsState(
      isDarkMode: p.getBool(AppConstants.keyDarkMode) ?? false,
      isSoundEnabled: p.getBool(AppConstants.keySoundEnabled) ?? true,
      isMusicEnabled: p.getBool(AppConstants.keyMusicEnabled) ?? true,
      isVibrationEnabled: p.getBool(AppConstants.keyVibrationEnabled) ?? true,
      boardThemeId: p.getString(AppConstants.keyBoardTheme) ?? 'classic',
      appTheme: p.getString('appTheme') ?? 'dark',
    );
    AudioService.instance.setSoundEnabled(s.isSoundEnabled);
    AudioService.instance.setMusicEnabled(s.isMusicEnabled);
    HapticService.instance.setEnabled(s.isVibrationEnabled);
    return s;
  }

  Future<void> toggleDarkMode() async {
    final c = state.valueOrNull ?? const SettingsState();
    final n = c.copyWith(isDarkMode: !c.isDarkMode);
    state = AsyncData(n);
    final p = await SharedPreferences.getInstance();
    await p.setBool(AppConstants.keyDarkMode, n.isDarkMode);
  }

  Future<void> toggleSound() async {
    final c = state.valueOrNull ?? const SettingsState();
    final n = c.copyWith(isSoundEnabled: !c.isSoundEnabled);
    state = AsyncData(n);
    AudioService.instance.setSoundEnabled(n.isSoundEnabled);
    final p = await SharedPreferences.getInstance();
    await p.setBool(AppConstants.keySoundEnabled, n.isSoundEnabled);
  }

  Future<void> toggleMusic() async {
    final c = state.valueOrNull ?? const SettingsState();
    final n = c.copyWith(isMusicEnabled: !c.isMusicEnabled);
    state = AsyncData(n);
    AudioService.instance.setMusicEnabled(n.isMusicEnabled);
    final p = await SharedPreferences.getInstance();
    await p.setBool(AppConstants.keyMusicEnabled, n.isMusicEnabled);
  }

  Future<void> toggleVibration() async {
    final c = state.valueOrNull ?? const SettingsState();
    final n = c.copyWith(isVibrationEnabled: !c.isVibrationEnabled);
    state = AsyncData(n);
    HapticService.instance.setEnabled(n.isVibrationEnabled);
    final p = await SharedPreferences.getInstance();
    await p.setBool(AppConstants.keyVibrationEnabled, n.isVibrationEnabled);
  }

  Future<void> setBoardTheme(String themeId) async {
    final c = state.valueOrNull ?? const SettingsState();
    final n = c.copyWith(boardThemeId: themeId);
    state = AsyncData(n);
    final p = await SharedPreferences.getInstance();
    await p.setString(AppConstants.keyBoardTheme, themeId);
  }

  Future<void> setAppTheme(String theme) async {
    final c = state.valueOrNull ?? const SettingsState();
    final n = c.copyWith(appTheme: theme);
    state = AsyncData(n);
    final p = await SharedPreferences.getInstance();
    await p.setString('appTheme', theme);
  }
}

final settingsProvider =
    AsyncNotifierProvider<SettingsNotifier, SettingsState>(SettingsNotifier.new);
