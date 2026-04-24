// lib/features/game/presentation/screens/game_over_screen.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/board_color_themes.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../features/game/domain/models/game_state.dart';
import '../../../../providers/game_provider.dart';
import '../../../../providers/records_provider.dart';
import '../../../../providers/settings_provider.dart';

class GameOverScreen extends ConsumerStatefulWidget {
  final GameState gameState;
  const GameOverScreen({super.key, required this.gameState});

  @override
  ConsumerState<GameOverScreen> createState() => _GameOverScreenState();
}

class _GameOverScreenState extends ConsumerState<GameOverScreen>
    with TickerProviderStateMixin {
  late AnimationController _bgCtrl;
  late AnimationController _scoreCtrl;
  late List<AnimationController> _starCtrls;
  late AnimationController _buttonsCtrl;
  late AnimationController _historyCtrl;

  @override
  void initState() {
    super.initState();
    final stars = widget.gameState.stars;

    _bgCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600))
      ..forward();

    _scoreCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));

    _starCtrls = List.generate(
      3,
      (_) => AnimationController(
          vsync: this, duration: const Duration(milliseconds: 500)),
    );

    _buttonsCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));

    _historyCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));

    // Staggered animasyon
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      _scoreCtrl.forward();
    });

    for (int i = 0; i < stars; i++) {
      Future.delayed(Duration(milliseconds: 600 + i * 220), () {
        if (mounted) _starCtrls[i].forward();
      });
    }

    Future.delayed(const Duration(milliseconds: 700 + 3 * 220), () {
      if (mounted) {
        _historyCtrl.forward();
        _buttonsCtrl.forward();
      }
    });
  }

  @override
  void dispose() {
    _bgCtrl.dispose();
    _scoreCtrl.dispose();
    for (final c in _starCtrls) {
      c.dispose();
    }
    _buttonsCtrl.dispose();
    _historyCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gs = widget.gameState;
    final records = ref.watch(recordsProvider).valueOrNull;
    final boardThemeId =
        ref.watch(settingsProvider).valueOrNull?.boardThemeId ?? 'classic';
    final boardTheme = BoardColorTheme.fromId(boardThemeId);
    final isNewRecord = records?.isNewRecord(gs.score) == false &&
        gs.score > 0 &&
        gs.score >= (records?.highScore ?? 0);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              boardTheme.background,
              const Color(0xFF080812),
            ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _bgCtrl,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 24),

                    // ─── Başlık mesajı ──────────────────────────────
                    _buildTitle(gs.stars),
                    const SizedBox(height: 8),

                    // ─── Yıldızlar ──────────────────────────────────
                    _buildStars(gs.stars),
                    const SizedBox(height: 28),

                    // ─── Ana Skor ───────────────────────────────────
                    _buildScoreCard(gs, records, isNewRecord),
                    const SizedBox(height: 20),

                    // ─── Atış Geçmişi ────────────────────────────────
                    _buildThrowHistory(gs),
                    const SizedBox(height: 28),

                    // ─── Butonlar ───────────────────────────────────
                    FadeTransition(
                      opacity: _buttonsCtrl,
                      child: _buildButtons(context),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─── Başlık ───────────────────────────────────────────────────────
  Widget _buildTitle(int stars) {
    final (emoji, text, color) = switch (stars) {
      3 => ('🏆', 'Mükemmel!', const Color(0xFFFFD700)),
      2 => ('🎯', 'Harika!', const Color(0xFF00E676)),
      1 => ('👏', 'İyi İş!', const Color(0xFF40C4FF)),
      _ => ('💪', 'Devam Et!', const Color(0xFFFFB74D)),
    };

    return ScaleTransition(
      scale: Tween<double>(begin: 0.5, end: 1.0).animate(
          CurvedAnimation(parent: _scoreCtrl, curve: Curves.elasticOut)),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 52)),
          const SizedBox(height: 6),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 32,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Yıldız Sırası ───────────────────────────────────────────────
  Widget _buildStars(int earnedStars) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (i) {
        final earned = i < earnedStars;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: ScaleTransition(
            scale: earned
                ? Tween<double>(begin: 0, end: 1).animate(
                    CurvedAnimation(
                        parent: _starCtrls[i], curve: Curves.elasticOut))
                : const AlwaysStoppedAnimation(1),
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (earned)
                  // Parlama
                  AnimatedBuilder(
                    animation: _starCtrls[i],
                    builder: (_, __) => Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFFD700)
                                .withOpacity(_starCtrls[i].value * 0.6),
                            blurRadius: 20,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                    ),
                  ),
                Icon(
                  Icons.star_rounded,
                  size: 54,
                  color: earned
                      ? const Color(0xFFFFD700)
                      : Colors.white.withOpacity(0.15),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  // ─── Skor Kartı ───────────────────────────────────────────────────
  Widget _buildScoreCard(
      GameState gs, RecordsState? records, bool isNewRecord) {
    final highScore = records?.highScore ?? 0;
    final lastScore = records?.lastScore ?? gs.score;

    return ScaleTransition(
      scale: Tween<double>(begin: 0.8, end: 1.0)
          .animate(CurvedAnimation(parent: _scoreCtrl, curve: Curves.easeOut)),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.12)),
        ),
        child: Column(
          children: [
            // Yeni rekor rozeti
            if (isNewRecord || gs.score >= highScore && gs.score > 0) ...[
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  gradient: AppTheme.accentGradient(),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text('🎊  YENİ REKOR!',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                        letterSpacing: 1)),
              ),
              const SizedBox(height: 16),
            ],

            // Bu oyun skoru
            TweenAnimationBuilder<int>(
              tween: IntTween(begin: 0, end: gs.score),
              duration: const Duration(milliseconds: 1000),
              curve: Curves.easeOut,
              builder: (_, v, __) => Text(
                '$v',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 60,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -2,
                  height: 1,
                ),
              ),
            ),
            const Text(
              'PUAN',
              style: TextStyle(
                  color: Colors.white38, fontSize: 14, letterSpacing: 3),
            ),
            const SizedBox(height: 20),

            // Rekor / Son oyun satırları
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _StatItem(
                    icon: Icons.emoji_events_rounded,
                    label: 'Rekor',
                    value: '${math.max(highScore, gs.score)}',
                    color: const Color(0xFFFFD700)),
                Container(
                    width: 1, height: 40, color: Colors.white12),
                _StatItem(
                    icon: Icons.history_rounded,
                    label: 'Önceki',
                    value: records?.gamesPlayed != null &&
                            records!.gamesPlayed > 1
                        ? '$lastScore'
                        : '-',
                    color: const Color(0xFF80DEEA)),
                Container(
                    width: 1, height: 40, color: Colors.white12),
                _StatItem(
                    icon: Icons.sports_bar_rounded,
                    label: 'Atış',
                    value: '${gs.throwsDone}',
                    color: AppTheme.secondaryDark),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ─── Atış Geçmişi ─────────────────────────────────────────────────
  Widget _buildThrowHistory(GameState gs) {
    return FadeTransition(
      opacity: _historyCtrl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ATIŞ GEÇMİŞİ',
            style: TextStyle(
              color: Colors.white38,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(gs.throwHistory.length, (i) {
              final t = gs.throwHistory[i];
              return _ThrowDot(result: t, index: i);
            }),
          ),
        ],
      ),
    );
  }

  // ─── Butonlar ─────────────────────────────────────────────────────
  Widget _buildButtons(BuildContext context) {
    return Column(
      children: [
        // Tekrar Oyna
        GestureDetector(
          onTap: () {
            ref.read(gameProvider.notifier).resetGame();
            context.go(AppConstants.routeGame);
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 18),
            decoration: BoxDecoration(
              gradient: AppTheme.accentGradient(),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                    color: AppTheme.primaryLight.withOpacity(0.4),
                    blurRadius: 20)
              ],
            ),
            child: const Center(
              child: Text(
                '🎯  Tekrar Oyna',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Ana Menü
        GestureDetector(
          onTap: () => context.go(AppConstants.routeHome),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withOpacity(0.15)),
            ),
            child: const Center(
              child: Text(
                '🏠  Ana Menü',
                style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Yardımcı Widget'lar ──────────────────────────────────────────
class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatItem(
      {required this.icon,
      required this.label,
      required this.value,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
                color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
        Text(label,
            style: const TextStyle(color: Colors.white38, fontSize: 11)),
      ],
    );
  }
}

class _ThrowDot extends StatelessWidget {
  final ThrowResult result;
  final int index;

  const _ThrowDot({required this.result, required this.index});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: result.isMiss
          ? 'Atış ${index + 1}: ISKALADI'
          : 'Atış ${index + 1}: ${result.score} pts',
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: result.dotColor.withOpacity(0.18),
          shape: BoxShape.circle,
          border: Border.all(color: result.dotColor, width: 2),
        ),
        child: Center(
          child: Text(
            result.isMiss ? '✕' : '${result.score}',
            style: TextStyle(
              color: result.dotColor,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}
