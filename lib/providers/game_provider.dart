// lib/providers/game_provider.dart
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/game/domain/models/game_state.dart';
import '../core/services/haptic_service.dart';
import 'records_provider.dart';

class GameNotifier extends Notifier<GameState> {
  @override
  GameState build() => const GameState();

  // ─── Skor hesaplama ──────────────────────────────────────────
  static int _score(double r) {
    if (r <= 0.00) return 50;
    if (r <= 0.12) return 50;  // bullseye
    if (r <= 0.22) return 25;  // dış boğa
    if (r <= 0.40) return 20;  // triple ring
    if (r <= 0.55) return 15;
    if (r <= 0.70) return 10;
    if (r <= 0.85) return 5;
    return 0;                   // miss
  }

  void startGame() {
    state = const GameState(phase: GamePhase.aiming);
  }

  void onThrow(double ringRadius, double angleRadians) {
    if (state.phase != GamePhase.aiming) return;

    final isMiss = ringRadius > 0.85;
    final throwScore = isMiss ? 0 : _score(ringRadius);
    final result = ThrowResult(
      ringRadius: ringRadius.clamp(0.0, 1.1),
      angleRadians: angleRadians,
      score: throwScore,
      isMiss: isMiss,
    );

    final newLives = isMiss ? state.lives - 1 : state.lives;
    final newScore = state.score + throwScore;
    final newDone = state.throwsDone + 1;
    final newHistory = [...state.throwHistory, result];

    HapticService.instance.mediumImpact();

    // ── 1. Tüm atışlar bitti → oyun bitti
    if (newDone >= state.totalThrows) {
      state = state.copyWith(
        score: newScore,
        lives: newLives.clamp(0, state.maxLives),
        throwsDone: newDone,
        throwHistory: newHistory,
        phase: GamePhase.gameOver,
        lastThrowScore: throwScore,
      );
      ref.read(recordsProvider.notifier).saveGame(newScore);
      return;
    }

    // ── 2. Can bitti (atışlar bitmedi)
    if (newLives <= 0) {
      state = state.copyWith(
        score: newScore,
        lives: 0,
        throwsDone: newDone,
        throwHistory: newHistory,
        phase: GamePhase.livesOut,
        lastThrowScore: throwScore,
      );
      return;
    }

    // ── 3. Normal atış → kısa sonuç göster, devam et
    state = state.copyWith(
      score: newScore,
      lives: newLives,
      throwsDone: newDone,
      throwHistory: newHistory,
      phase: GamePhase.showResult,
      lastThrowScore: throwScore,
    );

    Timer(const Duration(milliseconds: 1100), () {
      if (state.phase == GamePhase.showResult) {
        state = state.copyWith(phase: GamePhase.aiming, clearLastScore: true);
      }
    });
  }

  /// Reklam izledi → +1 can ile devam
  void onAdRevive() {
    if (state.phase != GamePhase.livesOut || state.adUsed) return;
    HapticService.instance.heavyImpact();
    state = state.copyWith(
      lives: 1,
      phase: GamePhase.aiming,
      adUsed: true,
      clearLastScore: true,
    );
  }

  /// Vazgeç → oyunu bitir ve kaydet
  void giveUp() {
    if (state.phase != GamePhase.livesOut) return;
    final s = state.copyWith(phase: GamePhase.gameOver);
    state = s;
    ref.read(recordsProvider.notifier).saveGame(s.score);
  }

  void resetGame() {
    state = const GameState(phase: GamePhase.aiming);
  }
}

final gameProvider =
    NotifierProvider<GameNotifier, GameState>(GameNotifier.new);
