// lib/features/home/presentation/screens/home_screen.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/board_color_themes.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/ad_banner_widget.dart';
import '../../../../providers/game_provider.dart';
import '../../../../providers/records_provider.dart';
import '../../../../providers/settings_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with TickerProviderStateMixin {
  late final AnimationController _bounceCtrl;
  late final AnimationController _shimmerCtrl;
  late final AnimationController _bgCtrl;
  late final AnimationController _btnPulseCtrl;

  late final Animation<double> _bounceAnim;

  @override
  void initState() {
    super.initState();

    _bounceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    _bounceAnim = Tween<double>(begin: -10, end: 10).animate(
      CurvedAnimation(parent: _bounceCtrl, curve: Curves.easeInOut),
    );

    _shimmerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    _bgCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(reverse: true);

    _btnPulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _bounceCtrl.dispose();
    _shimmerCtrl.dispose();
    _bgCtrl.dispose();
    _btnPulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final records = ref.watch(recordsProvider).valueOrNull;
    final boardThemeId =
        ref.watch(settingsProvider).valueOrNull?.boardThemeId ?? 'classic';
    final boardTheme = BoardColorTheme.fromId(boardThemeId);

    return Scaffold(
      body: AnimatedBuilder(
        animation: _bgCtrl,
        builder: (context, child) => Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      Color.lerp(const Color(0xFF0D0D1A),
                          boardTheme.background, _bgCtrl.value * 0.4)!,
                      const Color(0xFF0D0D1A),
                    ]
                  : [
                      Color.lerp(const Color(0xFFF2F0FF),
                          const Color(0xFFFFEFE8), _bgCtrl.value)!,
                      const Color(0xFFE8E4FF),
                    ],
            ),
          ),
          child: child,
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(context),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      const SizedBox(height: 16),

                      // ─── Rekor & Son Oyun Kartları ─────────────
                      if (records != null && records.gamesPlayed > 0)
                        _buildStatsRow(context, records),

                      const SizedBox(height: 20),

                      // ─── Zıplayan Tahta ─────────────────────────
                      AnimatedBuilder(
                        animation: _bounceAnim,
                        builder: (_, child) => Transform.translate(
                          offset: Offset(0, _bounceAnim.value),
                          child: child,
                        ),
                        child: _buildDartBoard(context, boardTheme),
                      ),

                      const SizedBox(height: 28),

                      // ─── OYNA Butonu ────────────────────────────
                      _buildPlayButton(context),

                      const SizedBox(height: 12),

                      // ─── Nasıl Oynanır Butonu ───────────────────
                      _buildHowToPlayButton(context),

                      const SizedBox(height: 14),

                      // ─── Animasyonlu noktalar ───────────────────
                      _buildAnimDots(),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),

              // ─── Banner Reklam ──────────────────────────────────
              const AdBannerWidget(),
              const SizedBox(height: 6),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      child: Row(
        children: [
          // Logo
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              gradient: AppTheme.accentGradient(),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text('🎯', style: TextStyle(fontSize: 20)),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'GAME DART',
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                  fontSize: 22,
                ),
          ),
          const Spacer(),
          _AnimatedIconButton(
            icon: Icons.settings_rounded,
            onTap: () => context.push(AppConstants.routeSettings),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context, RecordsState records) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _StatCard(
              icon: Icons.emoji_events_rounded,
              label: 'En Yüksek',
              value: '${records.highScore}',
              color: const Color(0xFFFFD700),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _StatCard(
              icon: Icons.history_rounded,
              label: 'Son Oyun',
              value: '${records.lastScore}',
              color: AppTheme.accentCyan,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _StatCard(
              icon: Icons.sports_score_rounded,
              label: 'Oyunlar',
              value: '${records.gamesPlayed}',
              color: AppTheme.secondaryLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDartBoard(BuildContext context, BoardColorTheme boardTheme) {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: boardTheme.glowColor.withOpacity(0.45),
            blurRadius: 50,
            spreadRadius: 8,
          ),
        ],
      ),
      child: CustomPaint(
        painter: _HomeBoard(theme: boardTheme),
      ),
    );
  }

  Widget _buildPlayButton(BuildContext context) {
    return AnimatedBuilder(
      animation: _btnPulseCtrl,
      builder: (_, child) {
        final glow = 0.35 + _btnPulseCtrl.value * 0.25;
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(36),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryLight.withOpacity(glow),
                blurRadius: 28,
                spreadRadius: 3,
              ),
            ],
          ),
          child: child,
        );
      },
      child: GestureDetector(
        onTap: () {
          ref.read(gameProvider.notifier).resetGame();
          context.go(AppConstants.routeGame);
        },
        child: Container(
          width: 200,
          height: 62,
          decoration: BoxDecoration(
            gradient: AppTheme.accentGradient(),
            borderRadius: BorderRadius.circular(36),
          ),
          child: const Center(
            child: Text(
              '🎯  OYNA',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHowToPlayButton(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () => context.push(AppConstants.routeHowToPlay),
      child: Container(
        width: 200,
        height: 48,
        decoration: BoxDecoration(
          border: Border.all(
            color: isDark ? AppTheme.neonCyan : AppTheme.primaryLight,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(30),
          color: Colors.transparent,
        ),
        child: Center(
          child: Text(
            '❓  NASIL OYNANIR',
            style: TextStyle(
              color: isDark ? AppTheme.neonCyan : AppTheme.primaryLight,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimDots() {
    return AnimatedBuilder(
      animation: _bounceCtrl,
      builder: (_, __) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(3, (i) {
          final delay = i * 0.33;
          final progress = ((_bounceCtrl.value + delay) % 1.0);
          final scale = 0.5 + 0.5 * math.sin(progress * math.pi).abs();
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Transform.scale(
              scale: scale,
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: [
                    AppTheme.primaryLight,
                    AppTheme.secondaryLight,
                    AppTheme.accentCyan,
                  ][i],
                  shape: BoxShape.circle,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ─── Ev Tahta Painter ─────────────────────────────────────────────
class _HomeBoard extends CustomPainter {
  final BoardColorTheme theme;
  const _HomeBoard({required this.theme});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxR = size.width / 2;

    final zones = [
      (1.00, theme.ring1),
      (0.82, theme.ring2),
      (0.65, theme.ring1),
      (0.48, theme.ring2),
      (0.30, theme.outerBull),
      (0.12, theme.bullseye),
    ];

    for (final z in zones) {
      canvas.drawCircle(center, maxR * z.$1, Paint()..color = z.$2);
      canvas.drawCircle(
          center, maxR * z.$1,
          Paint()
            ..color = theme.wire.withOpacity(0.4)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5);
    }

    // Glow
    canvas.drawCircle(center, maxR,
        Paint()
          ..color = theme.glowColor.withOpacity(0.35)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 5
          ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 10));
  }

  @override
  bool shouldRepaint(_HomeBoard old) => theme.id != old.theme.id;
}

// ─── Stat Kartı ───────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard(
      {required this.icon,
      required this.label,
      required this.value,
      required this.color});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : AppTheme.cardLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 4),
          Text(value,
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w900, height: 1.1)),
          Text(label,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontSize: 10)),
        ],
      ),
    );
  }
}

// ─── Animasyonlu İkon Butonu ──────────────────────────────────────
class _AnimatedIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _AnimatedIconButton({required this.icon, required this.onTap});

  @override
  State<_AnimatedIconButton> createState() => _AnimatedIconButtonState();
}

class _AnimatedIconButtonState extends State<_AnimatedIconButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 150),
        lowerBound: 0.85,
        upperBound: 1.0,
        value: 1.0);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _c.reverse(),
      onTapUp: (_) {
        _c.forward();
        widget.onTap();
      },
      onTapCancel: () => _c.forward(),
      child: ScaleTransition(
        scale: _c,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            gradient: AppTheme.accentGradient(),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryLight.withOpacity(0.4),
                blurRadius: 12,
                spreadRadius: 2,
              )
            ],
          ),
          child: Icon(widget.icon, color: Colors.white, size: 22),
        ),
      ),
    );
  }
}
