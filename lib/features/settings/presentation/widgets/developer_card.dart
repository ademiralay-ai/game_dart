// lib/features/settings/presentation/widgets/developer_card.dart
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_theme.dart';

class DeveloperCard extends StatefulWidget {
  const DeveloperCard({super.key});

  @override
  State<DeveloperCard> createState() => _DeveloperCardState();
}

class _DeveloperCardState extends State<DeveloperCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _hoverCtrl;

  @override
  void initState() {
    super.initState();
    _hoverCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  void dispose() {
    _hoverCtrl.dispose();
    super.dispose();
  }

  void _copyEmail() {
    Clipboard.setData(
      const ClipboardData(text: 'abdullahdemiralay@gmail.com'),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('E-posta kopyalandı!'),
        backgroundColor: AppTheme.primaryLight,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return MouseRegion(
      onEnter: (_) => _hoverCtrl.forward(),
      onExit: (_) => _hoverCtrl.reverse(),
      child: AnimatedBuilder(
        animation: _hoverCtrl,
        builder: (_, child) => Transform.scale(
          scale: 1.0 + _hoverCtrl.value * 0.02,
          child: child,
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.primaryLight.withOpacity(0.15),
                AppTheme.secondaryLight.withOpacity(0.10),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppTheme.primaryLight.withOpacity(0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryLight
                    .withOpacity(isDark ? 0.25 : 0.12),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              // Avatar
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: AppTheme.accentGradient(),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text(
                    'AD',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Bilgiler
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tr('settings.developer_name'),
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      tr('settings.company'),
                      style: TextStyle(
                        color: AppTheme.primaryLight,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    GestureDetector(
                      onTap: _copyEmail,
                      child: Text(
                        tr('settings.developer_email'),
                        style: TextStyle(
                          color: AppTheme.accentCyan,
                          fontSize: 12,
                          decoration: TextDecoration.underline,
                          decorationColor: AppTheme.accentCyan,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Kopyala ikonu
              IconButton(
                onPressed: _copyEmail,
                icon: Icon(
                  Icons.copy_rounded,
                  size: 18,
                  color: AppTheme.primaryLight.withOpacity(0.7),
                ),
                tooltip: 'E-posta kopyala',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
