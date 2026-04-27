// lib/features/game/presentation/screens/game_screen.dart
import 'dart:math' as math;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/board_color_themes.dart';
import '../../../../core/services/admob_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../features/game/domain/models/game_state.dart';
import '../../../../providers/game_provider.dart';
import '../../../../providers/settings_provider.dart';

class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

enum _LaunchDifficulty {
  easy('Kolay', 0.26),
  medium('Orta', 0.20),
  hard('Zor', 0.14);

  final String label;
  final double assistStrength;
  const _LaunchDifficulty(this.label, this.assistStrength);
}

class _GameScreenState extends ConsumerState<GameScreen>
    with TickerProviderStateMixin {
  late AnimationController _aimCtrl;
  late AnimationController _boardCtrl;
  late AnimationController _confettiCtrl;
  final math.Random _random = math.Random();
  bool _dialogOpen = false;
  bool _isPulling = false;
  Offset _dragDelta = Offset.zero;
  double _pullStrength = 0;
  _LaunchDifficulty _difficulty = _LaunchDifficulty.medium;

  static const double _maxPullDistance = 170;

  @override
  void initState() {
    super.initState();
    _aimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1700),
    );
    _boardCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat(reverse: true);
    _confettiCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(gameProvider.notifier).startGame();
      _startAiming();
    });
  }

  @override
  void dispose() {
    _aimCtrl.dispose();
    _boardCtrl.dispose();
    _confettiCtrl.dispose();
    super.dispose();
  }

  bool get _isInAimingPhase => ref.read(gameProvider).phase == GamePhase.aiming;

  void _startAiming() {
    if (!mounted) return;
    setState(() {
      _isPulling = false;
      _dragDelta = Offset.zero;
      _pullStrength = 0;
    });
    _aimCtrl.reset();
  }

  void _triggerThrow(double radius, double angleRadians) {
    if (!_isInAimingPhase) return;
    setState(() {
      _isPulling = false;
      _dragDelta = Offset.zero;
      _pullStrength = 0;
    });
    _aimCtrl.stop();
    ref.read(gameProvider.notifier).onThrow(radius, angleRadians);
  }

  void _onArrowDragStart(DragStartDetails details) {
    if (!_isInAimingPhase) return;
    setState(() {
      _isPulling = true;
      _dragDelta = Offset.zero;
      _pullStrength = 0;
    });
  }

  void _onArrowDragUpdate(DragUpdateDetails details) {
    if (!_isInAimingPhase || !_isPulling) return;
    final next = _dragDelta + details.delta;
    final dx = next.dx.clamp(-120.0, 120.0);
    final dy = next.dy.clamp(0.0, _maxPullDistance);

    setState(() {
      _dragDelta = Offset(dx, dy);
      _pullStrength = (dy / _maxPullDistance).clamp(0.0, 1.0);
    });
  }

  void _releaseCurrentArrow({double verticalVelocity = 0}) {
    if (!_isInAimingPhase || !_isPulling) return;

    if (_pullStrength < 0.12) {
      setState(() {
        _isPulling = false;
        _dragDelta = Offset.zero;
        _pullStrength = 0;
      });
      return;
    }

    final upSpeed = verticalVelocity.clamp(0.0, 2800.0);
    final speedNorm = (upSpeed / 2200).clamp(0.0, 1.0);
    final releaseNorm = ((_pullStrength - 0.12) / 0.88).clamp(0.0, 1.0);
    final launchPower = math.max(speedNorm, releaseNorm);
    final sideError = (_dragDelta.dx.abs() / 120).clamp(0.0, 1.0);
    final pullControl = (1 - (_pullStrength - 0.72).abs() * 1.8).clamp(0.0, 1.0);
    final assistedSideError =
        (sideError * (1 - _difficulty.assistStrength)).clamp(0.0, 1.0);

    final precision =
        (launchPower * 0.45 + pullControl * 0.40 + (1 - assistedSideError) * 0.15)
            .clamp(0.0, 1.0);

    final radius =
      ((1 - precision) * 0.88 + assistedSideError * 0.08).clamp(0.0, 1.0);
    _triggerThrow(radius, _predictAimAngleForPreview());
  }

  void _onArrowDragEnd(DragEndDetails details) {
    _releaseCurrentArrow(
      verticalVelocity: -details.velocity.pixelsPerSecond.dy,
    );
  }

  double _predictRadiusForAimPreview() {
    final sideError = (_dragDelta.dx.abs() / 120).clamp(0.0, 1.0);
    final pullControl =
        (1 - (_pullStrength - 0.72).abs() * 1.8).clamp(0.0, 1.0);
    final assistedSideError =
        (sideError * (1 - _difficulty.assistStrength)).clamp(0.0, 1.0);

    final precision =
        (pullControl * 0.85 + (1 - assistedSideError) * 0.15).clamp(0.0, 1.0);

    return ((1 - precision) * 0.88 + assistedSideError * 0.08)
        .clamp(0.0, 1.0);
  }

  double _predictOffsetXForAimPreview() {
    final sideNorm = (_dragDelta.dx / 120).clamp(-1.0, 1.0);
    final assisted = sideNorm * (1 - _difficulty.assistStrength);
    return assisted.clamp(-1.0, 1.0);
  }

  double _predictAimAngleForPreview() {
    return -math.pi / 2 + (_predictOffsetXForAimPreview() * 0.38);
  }

  void _onArrowDragCancel() {
    _releaseCurrentArrow();
  }

  void _triggerRandomThrow() {
    if (!_isInAimingPhase) return;

    final randomRadius = _random.nextDouble().clamp(0.0, 1.0);
    final randomAngle = -math.pi + (_random.nextDouble() * math.pi * 2);
    _triggerThrow(randomRadius, randomAngle);
  }

  void _showReviveDialog(BuildContext ctx) {
    if (_dialogOpen) return;
    _dialogOpen = true;
    showDialog<void>(
      context: ctx,
      barrierDismissible: false,
      builder: (_) => _ReviveDialog(
        onWatchAd: () {
          Navigator.of(ctx).pop();
          _dialogOpen = false;
          if (!kIsWeb) {
            AdmobService.instance.showRewarded(
              onRewarded: (_) {
                ref.read(gameProvider.notifier).onAdRevive();
              },
            );
          } else {
            // Web'de reklam yok — direkt can ver (test)
            ref.read(gameProvider.notifier).onAdRevive();
          }
        },
        onGiveUp: () {
          Navigator.of(ctx).pop();
          _dialogOpen = false;
          ref.read(gameProvider.notifier).giveUp();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameProvider);
    final boardThemeId =
        ref.watch(settingsProvider).valueOrNull?.boardThemeId ?? 'classic';
    final boardTheme = BoardColorTheme.fromId(boardThemeId);

    // Faz değişikliklerine tepki ver
    ref.listen<GameState>(gameProvider, (prev, next) {
      if (next.phase == GamePhase.aiming &&
          prev?.phase == GamePhase.showResult) {
        _startAiming();
      }
      if (next.phase == GamePhase.aiming && prev?.phase == GamePhase.ready) {
        _startAiming();
      }
      if (next.phase == GamePhase.livesOut &&
          prev?.phase != GamePhase.livesOut) {
        _showReviveDialog(context);
      }
      if (next.phase == GamePhase.gameOver &&
          prev?.phase != GamePhase.gameOver) {
        _aimCtrl.stop();
        setState(() => _isPulling = false);
        Future.delayed(const Duration(milliseconds: 600), () {
          // ignore: use_build_context_synchronously
          if (mounted) context.go(AppConstants.routeGameOver, extra: next);
        });
      }
      if (next.phase == GamePhase.showResult &&
          prev?.phase != GamePhase.showResult &&
          (next.lastThrowScore ?? 0) >= 50) {
        _confettiCtrl.forward(from: 0);
      }
    });

    final size = MediaQuery.of(context).size;
    final boardSize = math.min(size.width * 0.82, 320.0);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (did, _) async {
        if (!did) _confirmExit(context);
      },
      child: Scaffold(
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
            child: Column(
              children: [
                _buildTopBar(context, gameState),
                const SizedBox(height: 8),
                _buildScoreRow(gameState),
                const SizedBox(height: 12),

                // ─── Tahta + Aim Ring ──────────────────────────────
                Expanded(
                  child: Center(
                    child: LayoutBuilder(
                      builder: (context, constraints) => GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                          // Glow arka plan
                          Container(
                            width: boardSize + 40,
                            height: boardSize + 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      boardTheme.glowColor.withOpacity(0.25),
                                  blurRadius: 60,
                                  spreadRadius: 10,
                                ),
                              ],
                            ),
                          ),
                          // Dart tahtası
                          AnimatedBuilder(
                            animation: _boardCtrl,
                            builder: (_, __) {
                              final wobble = math.sin(_boardCtrl.value * math.pi * 2) * 0.007;
                              final breathe = 1 + math.sin(_boardCtrl.value * math.pi * 2) * 0.003;
                              return Transform.rotate(
                                angle: wobble,
                                child: Transform.scale(
                                  scale: breathe,
                                  child: SizedBox(
                                    width: boardSize,
                                    height: boardSize,
                                    child: CustomPaint(
                                      painter: _GameBoardPainter(
                                        theme: boardTheme,
                                        throwHistory: gameState.throwHistory,
                                        motion: _boardCtrl.value,
                                        aimPreviewRadius: _predictRadiusForAimPreview(),
                                        aimPreviewAngle:
                                          _predictAimAngleForPreview(),
                                        showAimPreview:
                                            gameState.phase == GamePhase.aiming &&
                                            _isPulling,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          // Skor popup
                          if (gameState.lastThrowScore != null &&
                              gameState.phase == GamePhase.showResult)
                            _ScorePopup(score: gameState.lastThrowScore!),
                          IgnorePointer(
                            child: SizedBox(
                              width: boardSize + 220,
                              height: boardSize + 220,
                              child: AnimatedBuilder(
                                animation: _confettiCtrl,
                                builder: (_, __) => CustomPaint(
                                  painter: _ConfettiPainter(
                                    progress: _confettiCtrl.value,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),
                _buildThrowCounter(gameState),
                const SizedBox(height: 16),
                _buildArrowLauncher(gameState),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── Üst Bar ──────────────────────────────────────────────────────
  Widget _buildTopBar(BuildContext context, GameState gs) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => _confirmExit(context),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close_rounded,
                  color: Colors.white70, size: 20),
            ),
          ),
          const Spacer(),
          const Text(
            'DART OYUNU',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w900,
              letterSpacing: 3,
            ),
          ),
          const Spacer(),
          // Can göstergesi
          Row(
            children: List.generate(gs.maxLives, (i) {
              final active = i < gs.lives;
              return Padding(
                padding: const EdgeInsets.only(left: 4),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  child: Icon(
                    active ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    color: active
                        ? const Color(0xFFFF4F4F)
                        : Colors.white24,
                    size: 22,
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  // ─── Skor Satırı ──────────────────────────────────────────────────
  Widget _buildScoreRow(GameState gs) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.07),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.stars_rounded, color: Color(0xFFFFD700), size: 20),
          const SizedBox(width: 8),
          TweenAnimationBuilder<int>(
            tween: IntTween(begin: 0, end: gs.score),
            duration: const Duration(milliseconds: 400),
            builder: (_, v, __) => Text(
              '$v',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
              ),
            ),
          ),
          const SizedBox(width: 6),
          const Text(
            'PTS',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Atış Sayacı ──────────────────────────────────────────────────
  Widget _buildThrowCounter(GameState gs) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ...List.generate(gs.totalThrows, (i) {
          final done = i < gs.throwsDone;
          final current =
              i == gs.throwsDone && gs.phase == GamePhase.aiming;
          final result =
              done && i < gs.throwHistory.length ? gs.throwHistory[i] : null;

          Color dotColor = Colors.white12;
          if (done && result != null) dotColor = result.dotColor;
          if (current) dotColor = Colors.white;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: current ? 14 : 10,
            height: current ? 14 : 10,
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
              boxShadow: current
                  ? [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.6),
                        blurRadius: 6,
                        spreadRadius: 1,
                      )
                    ]
                  : null,
            ),
          );
        }),
      ],
    );
  }

  // ─── Ok Fırlatma Alanı ────────────────────────────────────────────
  Widget _buildArrowLauncher(GameState gs) {
    final ready = gs.phase == GamePhase.aiming;
    final hintText = ready
        ? 'Oku aşağı çek, yukarı fırlat! Zorluk: ${_difficulty.label}'
        : 'Sonraki atış hazırlanıyor...';
    final shaftHeight = 14 + (34 * _pullStrength);
    final shaftWidth = 4 + (3 * _pullStrength);
    final arrowSize = 56 + (14 * _pullStrength);
    final pullBottom = 34 - (_dragDelta.dy * 0.45);

    return Column(
      children: [
        Text(
          hintText,
          style: TextStyle(
            color: ready ? Colors.white70 : Colors.white38,
            fontSize: 13,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: 10),
        _buildDifficultySelector(ready),
        const SizedBox(height: 10),
        Listener(
          onPointerUp: (_) => _releaseCurrentArrow(),
          onPointerCancel: (_) => _onArrowDragCancel(),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onPanStart: _onArrowDragStart,
            onPanUpdate: _onArrowDragUpdate,
            onPanEnd: _onArrowDragEnd,
            onPanCancel: _onArrowDragCancel,
            child: Container(
              width: 240,
              height: 110,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.06),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: Colors.white.withOpacity(0.12)),
              ),
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  Positioned(
                    bottom: 20,
                    child: Container(
                      width: 74,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.16),
                        borderRadius: BorderRadius.circular(40),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 18,
                    child: Container(
                      width: shaftWidth,
                      height: shaftHeight,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.white.withOpacity(0.25),
                            AppTheme.primaryLight.withOpacity(0.75),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                  AnimatedPositioned(
                    duration: _isPulling
                        ? Duration.zero
                        : const Duration(milliseconds: 220),
                    curve: Curves.easeOutCubic,
                    left: 120 - 28 + (_dragDelta.dx * 0.35),
                    bottom: pullBottom,
                    child: Transform.rotate(
                      angle: _dragDelta.dx * 0.004 + (_pullStrength * 0.03),
                      child: Icon(
                        Icons.navigation_rounded,
                        size: arrowSize,
                        color:
                            ready ? const Color(0xFFFFF2CC) : Colors.white38,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: ready ? _triggerRandomThrow : null,
          icon: const Icon(Icons.casino_rounded, size: 18),
          label: const Text('Rastgele Fırlat'),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white,
            side: BorderSide(color: Colors.white.withOpacity(0.18)),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDifficultySelector(bool ready) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: _LaunchDifficulty.values.map((difficulty) {
        final selected = _difficulty == difficulty;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: GestureDetector(
            onTap: ready
                ? () => setState(() {
                      _difficulty = difficulty;
                    })
                : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: selected
                    ? AppTheme.primaryLight.withOpacity(0.35)
                    : Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: selected
                      ? AppTheme.accentCyan
                      : Colors.white.withOpacity(0.16),
                ),
              ),
              child: Text(
                difficulty.label,
                style: TextStyle(
                  color: selected ? Colors.white : Colors.white60,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  void _confirmExit(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Oyunu Bırak?',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
        content: const Text('Mevcut oyun ilerlemen kaybolacak.',
            style: TextStyle(color: Colors.white60)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Devam Et',
                style: TextStyle(color: Color(0xFF6C63FF))),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.go(AppConstants.routeHome);
            },
            child: const Text('Çık',
                style: TextStyle(color: Color(0xFFFF4F4F))),
          ),
        ],
      ),
    );
  }
}

// ─── Konfeti Painter ──────────────────────────────────────────────
class _ConfettiPainter extends CustomPainter {
  final double progress;

  const _ConfettiPainter({required this.progress});

  static const List<Color> _palette = [
    Color(0xFFFFD54F),
    Color(0xFFFF8A65),
    Color(0xFF4FC3F7),
    Color(0xFF81C784),
    Color(0xFFCE93D8),
    Color(0xFFFFF176),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0 || progress >= 1) return;
    final eased = Curves.easeOut.transform(progress);
    final fade = (1 - Curves.easeIn.transform(progress)).clamp(0.0, 1.0);
    final origin = Offset(size.width / 2, size.height / 2);

    for (int i = 0; i < 64; i++) {
      final seed = i + 1.0;
      final angle = (-math.pi) + (i / 64) * (math.pi * 2);
      final speed = 120 + (i % 7) * 24;
      final spread = 40 + (i % 11) * 18;
      final sway = math.sin((progress * 10) + seed) * 10;

      final dx = origin.dx + math.cos(angle) * spread * eased + sway;
      final dy = origin.dy + math.sin(angle) * spread * eased + speed * progress * 0.35;
      final rot = (progress * 8) + seed;
      final w = 6 + (i % 5).toDouble();
      final h = 10 + (i % 6).toDouble();

      canvas.save();
      canvas.translate(dx, dy);
      canvas.rotate(rot);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset.zero, width: w, height: h),
          const Radius.circular(2),
        ),
        Paint()..color = _palette[i % _palette.length].withOpacity(fade),
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter oldDelegate) =>
      progress != oldDelegate.progress;
}

// ─── Game Board Painter ───────────────────────────────────────────
class _GameBoardPainter extends CustomPainter {
  final BoardColorTheme theme;
  final List<ThrowResult> throwHistory;
  final double motion;
  final double aimPreviewRadius;
  final double aimPreviewAngle;
  final bool showAimPreview;

  const _GameBoardPainter({
    required this.theme,
    required this.throwHistory,
    required this.motion,
    required this.aimPreviewRadius,
    required this.aimPreviewAngle,
    required this.showAimPreview,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxR = size.width / 2;
    final pulse = 0.5 + 0.5 * math.sin(motion * math.pi * 2);

    const boardOrder = [
      20,
      1,
      18,
      4,
      13,
      6,
      10,
      15,
      2,
      17,
      3,
      19,
      7,
      16,
      8,
      11,
      14,
      9,
      12,
      5,
    ];
    final sectorAngle = math.pi * 2 / boardOrder.length;

    final boardOuter = maxR * 0.80;
    final doubleInner = boardOuter * 0.953;
    final tripleOuter = boardOuter * 0.629;
    final tripleInner = boardOuter * 0.582;
    final outerBull = boardOuter * 0.0935;
    final bull = boardOuter * 0.0375;
    final numberRingOuter = maxR * 0.98;
    final numberRingInner = boardOuter * 1.02;

    final lightSingle = Color.lerp(
      const Color(0xFFF5F5F5),
      theme.numberColor.withOpacity(0.15),
      0.2,
    )!;
    final darkSingle = Color.lerp(
      const Color(0xFF111111),
      theme.ring2,
      0.55,
    )!;
    final redBand = Color.lerp(
      const Color(0xFFC62828),
      theme.ring1,
      0.55,
    )!;
    final greenBand = Color.lerp(
      const Color(0xFF138A4B),
      theme.outerBull,
      0.45,
    )!;
    final wireColor = Color.lerp(
      const Color(0xFFBDBDBD),
      theme.wire,
      0.35,
    )!;

    Path ringSegment(
      double innerRadius,
      double outerRadius,
      double start,
      double sweep,
    ) {
      return Path()
        ..arcTo(
          Rect.fromCircle(center: center, radius: outerRadius),
          start,
          sweep,
          false,
        )
        ..arcTo(
          Rect.fromCircle(center: center, radius: innerRadius),
          start + sweep,
          -sweep,
          false,
        )
        ..close();
    }

    // Metal dış çerçeve
    canvas.drawCircle(
      center,
      maxR * 0.995,
      Paint()
        ..shader = SweepGradient(
          transform: GradientRotation(motion * math.pi * 0.05),
          colors: const [
            Color(0xFFB5B8BC),
            Color(0xFF61646A),
            Color(0xFFE2E4E7),
            Color(0xFF74777D),
            Color(0xFFB5B8BC),
          ],
        ).createShader(Rect.fromCircle(center: center, radius: maxR * 0.995)),
    );
    canvas.drawCircle(
      center,
      maxR * 0.97,
      Paint()..color = const Color(0xFF0F1012),
    );

    // Arka plandaki dış halka (numara bölgesi)
    canvas.drawCircle(
      center,
      numberRingOuter,
      Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFF2B2B2B),
            const Color(0xFF151515),
          ],
        ).createShader(Rect.fromCircle(center: center, radius: numberRingOuter)),
    );

    // Double + single + triple + single dilimler
    for (int i = 0; i < boardOrder.length; i++) {
      final start = -math.pi / 2 - sectorAngle / 2 + i * sectorAngle;
      final isDark = i.isEven;
      final isRed = i.isEven;

      final singleColor = isDark ? darkSingle : lightSingle;
      final bandColor = isRed ? redBand : greenBand;

      canvas.drawPath(
        ringSegment(doubleInner, boardOuter, start, sectorAngle),
        Paint()..color = bandColor,
      );
      canvas.drawPath(
        ringSegment(tripleOuter, doubleInner, start, sectorAngle),
        Paint()..color = singleColor,
      );
      canvas.drawPath(
        ringSegment(tripleInner, tripleOuter, start, sectorAngle),
        Paint()..color = bandColor,
      );
      canvas.drawPath(
        ringSegment(outerBull, tripleInner, start, sectorAngle),
        Paint()..color = singleColor,
      );

      // Tel gibi görünen dilim çizgileri
      final radialPaint = Paint()
        ..color = wireColor.withOpacity(0.75)
        ..strokeWidth = 1.15
        ..style = PaintingStyle.stroke;
      final lineStart = Offset(
        center.dx + outerBull * math.cos(start),
        center.dy + outerBull * math.sin(start),
      );
      final lineEnd = Offset(
        center.dx + boardOuter * math.cos(start),
        center.dy + boardOuter * math.sin(start),
      );
      canvas.drawLine(lineStart, lineEnd, radialPaint);
    }

    // Boğa gözleri
    canvas.drawCircle(center, outerBull, Paint()..color = theme.outerBull);
    canvas.drawCircle(center, bull, Paint()..color = theme.bullseye);

    // Konsantrik tel halkaları
    final ringWirePaint = Paint()
      ..color = wireColor.withOpacity(0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    for (final ring in [boardOuter, doubleInner, tripleOuter, tripleInner, outerBull, bull]) {
      canvas.drawCircle(center, ring, ringWirePaint);
    }

    // Dış parlama
    canvas.drawCircle(
      center,
      boardOuter + 2,
      Paint()
        ..color = theme.glowColor.withOpacity(0.24 + pulse * 0.12)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 8),
    );

    // Numaralar (metalik ve daha okunakli)
    for (int i = 0; i < boardOrder.length; i++) {
      final theta = -math.pi / 2 + i * sectorAngle;
      final pos = Offset(
        center.dx + ((numberRingInner + numberRingOuter) * 0.5) * math.cos(theta),
        center.dy + ((numberRingInner + numberRingOuter) * 0.5) * math.sin(theta),
      );

      final text = '${boardOrder[i]}';
      final outlinePainter = TextPainter(
        text: TextSpan(
          text: text,
          style: TextStyle(
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2.1
              ..color = Colors.black.withOpacity(0.82),
            fontSize: 16,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.2,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      final textPainter = TextPainter(
        text: TextSpan(
          text: text,
          style: TextStyle(
            foreground: Paint()
              ..shader = const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFF5F7FA),
                  Color(0xFFB7BDC7),
                  Color(0xFFE7EAEE),
                ],
              ).createShader(
                Rect.fromLTWH(
                  pos.dx - 12,
                  pos.dy - 12,
                  24,
                  24,
                ),
              ),
            fontSize: 16,
            fontWeight: FontWeight.w900,
            shadows: [
              Shadow(
                color: Colors.white.withOpacity(0.25),
                offset: const Offset(0, -0.6),
                blurRadius: 1,
              ),
            ],
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      outlinePainter.paint(
        canvas,
        Offset(
          pos.dx - outlinePainter.width / 2,
          pos.dy - outlinePainter.height / 2,
        ),
      );
      textPainter.paint(
        canvas,
        Offset(pos.dx - textPainter.width / 2, pos.dy - textPainter.height / 2),
      );
    }

    // Vida başları
    for (int i = 0; i < 8; i++) {
      final screwAngle = -math.pi / 2 + (math.pi * 2 / 8) * i;
      final screwCenter = Offset(
        center.dx + (maxR * 0.955) * math.cos(screwAngle),
        center.dy + (maxR * 0.955) * math.sin(screwAngle),
      );
      canvas.drawCircle(
        screwCenter,
        4.2,
        Paint()
          ..shader = RadialGradient(
            colors: [
              const Color(0xFFE4E7EC),
              const Color(0xFF7A8088),
            ],
          ).createShader(Rect.fromCircle(center: screwCenter, radius: 4.2)),
      );
      final slotPaint = Paint()
        ..color = const Color(0xFF4A4E55)
        ..strokeWidth = 1.1
        ..strokeCap = StrokeCap.round;
      final slotAngle = screwAngle + motion * 0.8;
      canvas.drawLine(
        Offset(
          screwCenter.dx - 2.1 * math.cos(slotAngle),
          screwCenter.dy - 2.1 * math.sin(slotAngle),
        ),
        Offset(
          screwCenter.dx + 2.1 * math.cos(slotAngle),
          screwCenter.dy + 2.1 * math.sin(slotAngle),
        ),
        slotPaint,
      );
    }

    // Üstten gelen ışık katmanı
    canvas.drawCircle(
      center,
      boardOuter,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.28, -0.36),
          radius: 1.1,
          colors: [
            Colors.white.withOpacity(0.19),
            Colors.transparent,
          ],
          stops: const [0.0, 0.62],
        ).createShader(Rect.fromCircle(center: center, radius: boardOuter)),
    );

    // Dıştan içe vignette
    canvas.drawCircle(
      center,
      boardOuter,
      Paint()
        ..shader = RadialGradient(
          colors: [
            Colors.transparent,
            Colors.black.withOpacity(0.32),
          ],
          stops: const [0.72, 1],
        ).createShader(Rect.fromCircle(center: center, radius: boardOuter)),
    );

    // Dart geçmişi (altın açı ile yayılmış)
    for (int i = 0; i < throwHistory.length; i++) {
      final t = throwHistory[i];
      if (t.isMiss) continue;
      final angle = t.angleRadians;
      final r = boardOuter * t.ringRadius.clamp(0.0, 0.90);
      final dx = center.dx + r * math.cos(angle);
      final dy = center.dy + r * math.sin(angle);

      // Gölge
      canvas.drawCircle(
        Offset(dx + 1, dy + 1),
        5,
        Paint()..color = Colors.black38,
      );
      // Dart noktası
      canvas.drawCircle(Offset(dx, dy), 5, Paint()..color = t.dotColor);
      canvas.drawCircle(
        Offset(dx, dy),
        5,
        Paint()
          ..color = Colors.white.withOpacity(0.7)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );

      // ─── Puan yazısı ──────────────────────────────
      final textPainter = TextPainter(
        text: TextSpan(
          text: '${t.score}',
          style: TextStyle(
            color: t.dotColor,
            fontSize: 11,
            fontWeight: FontWeight.w900,
            shadows: [
              Shadow(
                color: Colors.black54,
                offset: const Offset(0.5, 0.5),
                blurRadius: 2,
              ),
            ],
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(dx - textPainter.width / 2, dy - textPainter.height / 2),
      );
    }

    if (showAimPreview) {
      final previewR = boardOuter * aimPreviewRadius.clamp(0.0, 0.90);
      final previewCenter = Offset(
        center.dx + previewR * math.cos(aimPreviewAngle),
        center.dy + previewR * math.sin(aimPreviewAngle),
      );

      canvas.drawCircle(
        previewCenter,
        11,
        Paint()..color = const Color(0x55FF3B30),
      );
      canvas.drawCircle(
        previewCenter,
        11,
        Paint()
          ..color = const Color(0xFFFF3B30)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5,
      );
      canvas.drawCircle(
        previewCenter,
        4,
        Paint()
          ..color = const Color(0xFFFF3B30)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
    }
  }

  @override
  bool shouldRepaint(_GameBoardPainter old) =>
      theme.id != old.theme.id ||
      throwHistory.length != old.throwHistory.length ||
      motion != old.motion ||
      showAimPreview != old.showAimPreview ||
      aimPreviewRadius != old.aimPreviewRadius ||
      aimPreviewAngle != old.aimPreviewAngle;
}

// ─── Skor Popup ───────────────────────────────────────────────────
class _ScorePopup extends StatefulWidget {
  final int score;
  const _ScorePopup({required this.score});

  @override
  State<_ScorePopup> createState() => _ScorePopupState();
}

class _ScorePopupState extends State<_ScorePopup>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _scale;
  late final Animation<double> _opacity;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _scale = Tween<double>(begin: 0.5, end: 1.2).animate(
        CurvedAnimation(parent: _c, curve: const Interval(0, 0.4, curve: Curves.elasticOut)));
    _opacity = Tween<double>(begin: 1, end: 0).animate(
        CurvedAnimation(parent: _c, curve: const Interval(0.55, 1)));
    _slide = Tween<Offset>(begin: Offset.zero, end: const Offset(0, -0.8))
        .animate(CurvedAnimation(parent: _c, curve: const Interval(0.4, 1)));
    _c.forward();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.score >= 50
        ? const Color(0xFFFFD700)
        : widget.score >= 25
            ? const Color(0xFF00E676)
            : widget.score >= 10
                ? const Color(0xFF40C4FF)
                : const Color(0xFFFFB74D);

    return AnimatedBuilder(
      animation: _c,
      builder: (_, __) => SlideTransition(
        position: _slide,
        child: FadeTransition(
          opacity: _opacity,
          child: ScaleTransition(
            scale: _scale,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: color, width: 2),
              ),
              child: Text(
                widget.score == 0 ? 'ISKALADI! 💨' : '+${widget.score} PTS',
                style: TextStyle(
                  color: color,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Can Bitti Dialog ─────────────────────────────────────────────
class _ReviveDialog extends StatelessWidget {
  final VoidCallback onWatchAd;
  final VoidCallback onGiveUp;

  const _ReviveDialog({required this.onWatchAd, required this.onGiveUp});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1A1A35), Color(0xFF0D0D1A)],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
              color: AppTheme.secondaryDark.withOpacity(0.5), width: 1.5),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('💔', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            const Text(
              'Canlar Bitti!',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            const Text(
              'Kısa bir reklam izleyerek 1 can kazan\nve oyuna devam et!',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white60, fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 28),
            // Reklam izle butonu
            GestureDetector(
              onTap: onWatchAd,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  gradient: AppTheme.accentGradient(),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                        color: AppTheme.primaryLight.withOpacity(0.4),
                        blurRadius: 16)
                  ],
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.play_circle_filled_rounded,
                        color: Colors.white, size: 22),
                    SizedBox(width: 8),
                    Text(
                      'Reklam İzle  +1 ❤️',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Vazgeç
            TextButton(
              onPressed: onGiveUp,
              child: const Text(
                'Vazgeç — Oyunu Bitir',
                style: TextStyle(color: Colors.white38, fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
