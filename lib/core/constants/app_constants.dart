// lib/core/constants/app_constants.dart
class AppConstants {
  AppConstants._();

  static const String appName = 'Game Dart';
  static const String packageName = 'com.ademiralay.game_dart';
  static const String developerName = 'Abdullah Demiralay';
  static const String developerEmail = 'abdullahdemiralay@gmail.com';
  static const String companyName = 'Saggio Ai';

  static const String playStoreUrl =
      'https://play.google.com/store/apps/details?id=com.ademiralay.game_dart';
  static const String appStoreUrl =
      'https://apps.apple.com/app/id000000000';

  // SharedPreferences Keys
  static const String keyDarkMode = 'isDarkMode';
  static const String keySoundEnabled = 'isSoundEnabled';
  static const String keyMusicEnabled = 'isMusicEnabled';
  static const String keyVibrationEnabled = 'isVibrationEnabled';
  static const String keyBoardTheme = 'boardThemeId';

  // Navigation Routes
  static const String routeSplash = '/';
  static const String routeHome = '/home';
  static const String routeSettings = '/settings';
  static const String routeGame = '/game';
  static const String routeGameOver = '/game-over';
  static const String routeHowToPlay = '/how-to-play';

  // Splash duration
  static const Duration splashDuration = Duration(milliseconds: 3500);

  // Game constants
  static const int totalThrows = 10;
  static const int maxLives = 3;
  static const int stars3Threshold = 400;
  static const int stars2Threshold = 250;
  static const int stars1Threshold = 100;
}
