// lib/providers/records_provider.dart
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

@immutable
class RecordsState {
  final int highScore;
  final int lastScore;
  final int gamesPlayed;

  const RecordsState({
    this.highScore = 0,
    this.lastScore = 0,
    this.gamesPlayed = 0,
  });

  bool isNewRecord(int score) => score > highScore && score > 0;

  RecordsState copyWith({int? highScore, int? lastScore, int? gamesPlayed}) =>
      RecordsState(
        highScore: highScore ?? this.highScore,
        lastScore: lastScore ?? this.lastScore,
        gamesPlayed: gamesPlayed ?? this.gamesPlayed,
      );
}

class RecordsNotifier extends AsyncNotifier<RecordsState> {
  static const _kHigh = 'highScore';
  static const _kLast = 'lastScore';
  static const _kPlayed = 'gamesPlayed';

  @override
  Future<RecordsState> build() async {
    final p = await SharedPreferences.getInstance();
    return RecordsState(
      highScore: p.getInt(_kHigh) ?? 0,
      lastScore: p.getInt(_kLast) ?? 0,
      gamesPlayed: p.getInt(_kPlayed) ?? 0,
    );
  }

  Future<void> saveGame(int score) async {
    final cur = state.valueOrNull ?? const RecordsState();
    final next = cur.copyWith(
      highScore: score > cur.highScore ? score : cur.highScore,
      lastScore: score,
      gamesPlayed: cur.gamesPlayed + 1,
    );
    state = AsyncData(next);
    final p = await SharedPreferences.getInstance();
    await p.setInt(_kHigh, next.highScore);
    await p.setInt(_kLast, next.lastScore);
    await p.setInt(_kPlayed, next.gamesPlayed);
  }
}

final recordsProvider =
    AsyncNotifierProvider<RecordsNotifier, RecordsState>(RecordsNotifier.new);
