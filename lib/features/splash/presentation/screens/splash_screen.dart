// lib/features/splash/presentation/screens/splash_screen.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _logoController;
  late final AnimationController _textController;
  late final AnimationController _rotateController;
  late final AnimationController _particleController;

  late final Animation<double> _logoScale;
  late final Animation<double> _logoOpacity;
  late final Animation<Offset> _textSlide;
  late final Animation<double> _textOpacity;
  late final Animation<double> _taglineOpacity;

  @override
  void initState() {
    super.initState();

    // Logo animasyonu
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _logoScale = Tween<double>(begin: 0.2, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    // Metin animasyonu
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOutCubic),
    );
    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeIn),
    );
    _taglineOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: const Interval(0.4, 1.0, curve: Curves.easeIn),
      ),
    );

    // Dart döndürme animasyonu (sürekli)
    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    // Parçacık animasyonu
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    // Animasyonları sırayla başlat
    _logoController.forward().then((_) {
      _textController.forward();
    });

    // Home'a geçiş
    Future.delayed(AppConstants.splashDuration, () {
      if (mounted) context.go(AppConstants.routeHome);
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _rotateController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.splashGradient()),
        child: Stack(
          children: [
            // Arka plan parçacıkları
            ...List.generate(12, (i) => _buildParticle(i)),

            // Ana içerik
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Dart logosu
                  AnimatedBuilder(
                    animation: _logoController,
                    builder: (_, child) => Opacity(
                      opacity: _logoOpacity.value,
                      child: Transform.scale(
                        scale: _logoScale.value,
                        child: child,
                      ),
                    ),
                    child: _buildDartTarget(),
                  ),
                  const SizedBox(height: 32),

                  // Uygulama adı
                  SlideTransition(
                    position: _textSlide,
                    child: FadeTransition(
                      opacity: _textOpacity,
                      child: ShaderMask(
                        shaderCallback: (bounds) =>
                            AppTheme.accentGradient().createShader(bounds),
                        child: const Text(
                          'GAME DART',
                          style: TextStyle(
                            fontSize: 42,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 4,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Alt başlık
                  FadeTransition(
                    opacity: _taglineOpacity,
                    child: const Text(
                      'Hedefi vur, rekoru kır! 🎯',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Alt yükleme göstergesi
            Positioned(
              bottom: 60,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: _taglineOpacity,
                child: Column(
                  children: [
                    SizedBox(
                      width: 120,
                      child: LinearProgressIndicator(
                        backgroundColor: Colors.white12,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppTheme.primaryDark,
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Saggio Ai',
                      style: TextStyle(
                        color: Colors.white38,
                        fontSize: 12,
                        letterSpacing: 2,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDartTarget() {
    return AnimatedBuilder(
      animation: _rotateController,
      builder: (_, child) => Transform.rotate(
        angle: _rotateController.value * 2 * math.pi * 0.05,
        child: child,
      ),
      child: Container(
        width: 140,
        height: 140,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryDark.withOpacity(0.6),
              blurRadius: 40,
              spreadRadius: 10,
            ),
          ],
        ),
        child: CustomPaint(
          painter: _DartBoardPainter(),
        ),
      ),
    );
  }

  Widget _buildParticle(int index) {
    final random = math.Random(index * 42);
    final x = random.nextDouble();
    final y = random.nextDouble();
    final size = 4.0 + random.nextDouble() * 6;
    final delay = random.nextDouble();
    final color = index % 3 == 0
        ? AppTheme.primaryDark
        : index % 3 == 1
            ? AppTheme.secondaryDark
            : AppTheme.accentCyan;

    return AnimatedBuilder(
      animation: _particleController,
      builder: (context, _) {
        final progress =
            (((_particleController.value + delay) % 1.0));
        final opacity = (math.sin(progress * math.pi)).clamp(0.0, 1.0);
        return Positioned(
          left: MediaQuery.of(context).size.width * x,
          top: MediaQuery.of(context).size.height * y +
              (progress * 30 - 15),
          child: Opacity(
            opacity: opacity * 0.7,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─── Dart Tahtası CustomPainter ────────────────────────────────────
class _DartBoardPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2;

    final colors = [
      const Color(0xFFFF2D2D), // kırmızı - en dış
      const Color(0xFF1A1A2E), // siyah
      const Color(0xFFFF2D2D), // kırmızı
      const Color(0xFF1A1A2E), // siyah
      const Color(0xFF00C853), // yeşil
      const Color(0xFFFFD700), // altın - bull
    ];

    final ratios = [1.0, 0.82, 0.65, 0.48, 0.30, 0.12];

    for (int i = 0; i < colors.length; i++) {
      final paint = Paint()
        ..color = colors[i]
        ..style = PaintingStyle.fill;
      canvas.drawCircle(center, maxRadius * ratios[i], paint);

      // Halka çizgisi
      if (i < colors.length - 1) {
        final borderPaint = Paint()
          ..color = Colors.white.withOpacity(0.15)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5;
        canvas.drawCircle(center, maxRadius * ratios[i], borderPaint);
      }
    }

    // Merkez nokta (bullseye)
    final bullPaint = Paint()
      ..color = const Color(0xFFFF2D2D)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, maxRadius * 0.06, bullPaint);

    // Dış halka parlaklığı
    final glowPaint = Paint()
      ..color = AppTheme.primaryDark.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 8);
    canvas.drawCircle(center, maxRadius, glowPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
