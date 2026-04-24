// lib/features/game/presentation/screens/how_to_play_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';

class HowToPlayScreen extends StatefulWidget {
  const HowToPlayScreen({super.key});

  @override
  State<HowToPlayScreen> createState() => _HowToPlayScreenState();
}

class _HowToPlayScreenState extends State<HowToPlayScreen>
    with TickerProviderStateMixin {
  late AnimationController _scaleCtrl;
  late AnimationController _fadeCtrl;

  @override
  void initState() {
    super.initState();
    _scaleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        _fadeCtrl.forward();
        _scaleCtrl.forward();
      }
    });
  }

  @override
  void dispose() {
    _scaleCtrl.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDarkMode
                ? [
                    const Color(0xFF0A0A15),
                    const Color(0xFF1A0A2E),
                    const Color(0xFF0A0A15),
                  ]
                : [
                    const Color(0xFFF2F0FF),
                    const Color(0xFFE8E4FF),
                    const Color(0xFFF2F0FF),
                  ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeCtrl,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.92, end: 1.0)
                  .animate(CurvedAnimation(
                      parent: _scaleCtrl, curve: Curves.easeOutCubic)),
              child: CustomScrollView(
                slivers: [
                  // ─── AppBar ──────────────────────────────────────
                  SliverAppBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    scrolledUnderElevation: 0,
                    floating: true,
                    snap: true,
                    leading: IconButton(
                      icon: Icon(
                        Icons.arrow_back_ios_rounded,
                        color: isDarkMode
                            ? AppTheme.neonCyan
                            : AppTheme.primaryLight,
                      ),
                      onPressed: () => context.pop(),
                    ),
                    title: Text(
                      'Nasıl Oynanır',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                        color: isDarkMode
                            ? AppTheme.neonCyan
                            : AppTheme.primaryLight,
                        shadows: isDarkMode
                            ? [
                                const Shadow(
                                  color: AppTheme.neonCyan,
                                  blurRadius: 8,
                                ),
                              ]
                            : null,
                      ),
                    ),
                    centerTitle: true,
                  ),

                  // ─── Content ──────────────────────────────────────
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 20),

                          // ─ Hedef Bölümü ────────────────────────────
                          _buildSection(
                            title: '🎯 Oyunun Hedefi',
                            isDark: isDarkMode,
                            content:
                                'Dart tahtasına 10 kez dart fırlat. Her vuruşta puan kazan. '
                                'Mümkün olduğunca çok puan toplayarak oyunu tamamla!',
                          ),

                          const SizedBox(height: 16),

                          // ─ Nasıl Oynanır ───────────────────────────
                          _buildSection(
                            title: '🎮 Nasıl Oynanır',
                            isDark: isDarkMode,
                            content:
                                '1. Ekrana basılı tutarak hedefini belirle\n'
                                '2. Ekran üzerinde bir daire görünecek\n'
                                '3. Parmağını kaldırarak dartı fırlat\n'
                                '4. Tahtaya ne kadar yakın vursan o kadar puan!',
                          ),

                          const SizedBox(height: 16),

                          // ─ Puanlama Sistemi ────────────────────────
                          _buildSection(
                            title: '⭐ Puanlama Sistemi',
                            isDark: isDarkMode,
                            children: [
                              _buildScoreItem(
                                color: const Color(0xFFFFD700),
                                score: '+50 Puan',
                                label: '🟡 Merkez (Altın)',
                                isDark: isDarkMode,
                              ),
                              _buildScoreItem(
                                color: const Color(0xFF00E676),
                                score: '+25 Puan',
                                label: '🟢 Çok Yakın (Yeşil)',
                                isDark: isDarkMode,
                              ),
                              _buildScoreItem(
                                color: const Color(0xFF40C4FF),
                                score: '+20 Puan',
                                label: '🔵 Yakın (Mavi)',
                                isDark: isDarkMode,
                              ),
                              _buildScoreItem(
                                color: const Color(0xFFCE93D8),
                                score: '+15 Puan',
                                label: '🟣 Orta (Mor)',
                                isDark: isDarkMode,
                              ),
                              _buildScoreItem(
                                color: const Color(0xFFFFB74D),
                                score: '+10 Puan',
                                label: '🟠 Uzak (Turuncu)',
                                isDark: isDarkMode,
                              ),
                              _buildScoreItem(
                                color: const Color(0xFF9E9E9E),
                                score: '-1 Can',
                                label: '⚫ Iskalama (Gri)',
                                isDark: isDarkMode,
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // ─ Can Sistemi ─────────────────────────────
                          _buildSection(
                            title: '❤️ Can Sistemi',
                            isDark: isDarkMode,
                            content:
                                'Oyuna 3 can ile başlarsın. Iskaladığında (gri) '
                                'bir can kaybedersin. Tüm canlarını kaybedersen oyun biter.\n\n'
                                '💡 İpucu: İlan izleyerek ekstra bir can kazanabilirsin!',
                          ),

                          const SizedBox(height: 16),

                          // ─ İpuçları ────────────────────────────────
                          _buildSection(
                            title: '💡 Faydalı İpuçları',
                            isDark: isDarkMode,
                            children: const [
                              _TipItem(
                                emoji: '👆',
                                title: 'Hassas Hedefleme',
                                description:
                                    'Dartı fırlatmadan önce biraz bekleme zamanı var. '
                                    'Hızlıca karar ver!',
                              ),
                              _TipItem(
                                emoji: '🎯',
                                title: 'Merkeze Odaklan',
                                description:
                                    'En yüksek puanı için merkezi hedeflemeli. '
                                    'Ama dikkat et, ıskalama riski var!',
                              ),
                              _TipItem(
                                emoji: '📺',
                                title: 'Reklam Fırsatı',
                                description:
                                    'Oyun biterken bir reklam izleyerek devam edebilirsin.',
                              ),
                              _TipItem(
                                emoji: '🌙',
                                title: 'Tema Değiştir',
                                description:
                                    'Ayarlardan farklı tahta tasarımları ile oyna!',
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // ─ Başla Butonu ────────────────────────────
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: isDarkMode
                                  ? AppTheme.neonGradient2()
                                  : LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        AppTheme.primaryLight,
                                        AppTheme.secondaryLight,
                                      ],
                                    ),
                              borderRadius: BorderRadius.circular(20),
                              border: isDarkMode
                                  ? Border.all(
                                      color: AppTheme.neonCyan,
                                      width: 2,
                                    )
                                  : null,
                            ),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                              ),
                              onPressed: () => context.pop(),
                              child: const Text(
                                'Oyuna Başla!',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required bool isDark,
    String? content,
    List<Widget>? children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? AppTheme.neonCyan.withOpacity(0.5)
              : AppTheme.primaryLight.withOpacity(0.3),
          width: 2,
        ),
        color: isDark
            ? const Color(0xFF161129).withOpacity(0.6)
            : Colors.white.withOpacity(0.7),
        boxShadow: isDark
            ? [
                BoxShadow(
                  color: AppTheme.neonCyan.withOpacity(0.1),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ]
            : [],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
              color: isDark ? AppTheme.neonCyan : AppTheme.primaryLight,
            ),
          ),
          const SizedBox(height: 12),
          if (content != null)
            Text(
              content,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                height: 1.6,
                color: isDark ? Colors.white : const Color(0xFF1A1A2E),
              ),
            )
          else if (children != null)
            Column(
              children: children,
            ),
        ],
      ),
    );
  }

  Widget _buildScoreItem({
    required Color color,
    required String score,
    required String label,
    required bool isDark,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.6),
                  blurRadius: 8,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                  ),
                ),
                Text(
                  score,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? const Color(0xFFB0B0D9)
                        : const Color(0xFF666666),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TipItem extends StatelessWidget {
  final String emoji;
  final String title;
  final String description;

  const _TipItem({
    required this.emoji,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppTheme.neonCyan : AppTheme.primaryLight,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    height: 1.5,
                    color: isDark ? Colors.white70 : const Color(0xFF333333),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
