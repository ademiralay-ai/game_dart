// lib/features/game/domain/models/game_state.dart
import 'package:flutter/material.dart';

enum GamePhase { ready, aiming, showResult, livesOut, gameOver }

@immutable
class ThrowResult {
  final double ringRadius; // 0.0–1.0 arası (0 = merkez)
  final double angleRadians; // -pi..pi, tahtadaki açısal konum
  final int score;
  final bool isMiss; // ring > 0.85 → can kaybı

  const ThrowResult({
    required this.ringRadius,
    required this.angleRadians,
    required this.score,
    required this.isMiss,
  });

  Color get dotColor {
    if (isMiss) return const Color(0xFF616161);
    if (score >= 50) return const Color(0xFFFFD700); // altın
    if (score >= 25) return const Color(0xFF00E676); // yeşil
    if (score >= 20) return const Color(0xFF40C4FF); // mavi
    if (score >= 15) return const Color(0xFFCE93D8); // mor
    if (score >= 10) return const Color(0xFFFFB74D); // turuncu
    return const Color(0xFF9E9E9E);                   // gri
  }
}

@immutable
class GameState {
  final int score;
  final int lives;
  final int maxLives;
  final int throwsDone;
  final int totalThrows;
  final List<ThrowResult> throwHistory;
  final GamePhase phase;
  final int? lastThrowScore;
  final bool adUsed;

  const GameState({
    this.score = 0,
    this.lives = 3,
    this.maxLives = 3,
    this.throwsDone = 0,
    this.totalThrows = 10,
    this.throwHistory = const [],
    this.phase = GamePhase.ready,
    this.lastThrowScore,
    this.adUsed = false,
  });

  int get stars {
    if (score >= 400) return 3;
    if (score >= 250) return 2;
    if (score >= 100) return 1;
    return 0;
  }

  int get remainingThrows => totalThrows - throwsDone;

  bool get isGameOver => phase == GamePhase.gameOver;

  GameState copyWith({
    int? score,
    int? lives,
    int? maxLives,
    int? throwsDone,
    int? totalThrows,
    List<ThrowResult>? throwHistory,
    GamePhase? phase,
    int? lastThrowScore,
    bool clearLastScore = false,
    bool? adUsed,
  }) =>
      GameState(
        score: score ?? this.score,
        lives: lives ?? this.lives,
        maxLives: maxLives ?? this.maxLives,
        throwsDone: throwsDone ?? this.throwsDone,
        totalThrows: totalThrows ?? this.totalThrows,
        throwHistory: throwHistory ?? this.throwHistory,
        phase: phase ?? this.phase,
        lastThrowScore:
            clearLastScore ? null : (lastThrowScore ?? this.lastThrowScore),
        adUsed: adUsed ?? this.adUsed,
      );
}
