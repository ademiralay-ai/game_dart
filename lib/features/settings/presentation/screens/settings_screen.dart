// lib/features/settings/presentation/screens/settings_screen.dart
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/constants/board_color_themes.dart';
import '../../../../core/services/haptic_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../providers/settings_provider.dart';
import '../widgets/developer_card.dart';
import '../widgets/settings_section.dart';

// PackageInfo provider
final _packageInfoProvider = FutureProvider<PackageInfo>((ref) async {
  return PackageInfo.fromPlatform();
});

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsProvider);
    final packageInfoAsync = ref.watch(_packageInfoProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return settingsAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(body: Center(child: Text('Hata: $e'))),
      data: (settings) => Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient(Theme.of(context).brightness),
          ),
          child: SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // ─── Başlık ─────────────────────────────────────────
                SliverToBoxAdapter(
                  child: _buildHeader(context),
                ),

                // ─── İçerik ─────────────────────────────────────────
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // GÖRÜNÜM
                      SettingsSection(
                        title: tr('settings.appearance_section'),
                        children: [
                          // Karanlık Mod
                          SettingsTile(
                            icon: isDark
                                ? Icons.dark_mode_rounded
                                : Icons.light_mode_rounded,
                            iconColor: const Color(0xFFF59E0B),
                            title: tr('settings.dark_mode'),
                            trailing: _AnimatedSwitch(
                              value: settings.isDarkMode,
                              onChanged: (_) async {
                                await HapticService.instance.selectionClick();
                                ref
                                    .read(settingsProvider.notifier)
                                    .toggleDarkMode();
                              },
                            ),
                          ),

                          // Uygulama Teması
                          SettingsTile(
                            icon: Icons.palette_rounded,
                            iconColor: const Color(0xFFFF006E),
                            title: 'Uygulama Teması',
                            trailing: _ThemePicker(
                              currentTheme: settings.appTheme,
                              onChanged: (theme) {
                                HapticService.instance.selectionClick();
                                ref
                                    .read(settingsProvider.notifier)
                                    .setAppTheme(theme);
                              },
                            ),
                          ),

                          // Dil
                          SettingsTile(
                            icon: Icons.language_rounded,
                            iconColor: const Color(0xFF10B981),
                            title: tr('settings.language'),
                            trailing: _LanguagePicker(
                              currentLocale: context.locale.languageCode,
                              onChanged: (lang) {
                                HapticService.instance.selectionClick();
                                context.setLocale(Locale(lang));
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // SES VE TİTREŞİM
                      SettingsSection(
                        title: tr('settings.sound_section'),
                        children: [
                          SettingsTile(
                            icon: Icons.volume_up_rounded,
                            iconColor: const Color(0xFF6C63FF),
                            title: tr('settings.sound_effects'),
                            trailing: _AnimatedSwitch(
                              value: settings.isSoundEnabled,
                              onChanged: (_) async {
                                await HapticService.instance.selectionClick();
                                ref
                                    .read(settingsProvider.notifier)
                                    .toggleSound();
                              },
                            ),
                          ),
                          SettingsTile(
                            icon: Icons.music_note_rounded,
                            iconColor: const Color(0xFFEC4899),
                            title: tr('settings.background_music'),
                            trailing: _AnimatedSwitch(
                              value: settings.isMusicEnabled,
                              onChanged: (_) async {
                                await HapticService.instance.selectionClick();
                                ref
                                    .read(settingsProvider.notifier)
                                    .toggleMusic();
                              },
                            ),
                          ),
                          SettingsTile(
                            icon: Icons.vibration_rounded,
                            iconColor: const Color(0xFFF59E0B),
                            title: tr('settings.vibration'),
                            trailing: _AnimatedSwitch(
                              value: settings.isVibrationEnabled,
                              onChanged: (_) async {
                                ref
                                    .read(settingsProvider.notifier)
                                    .toggleVibration();
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // OYUN TAHTASI TEMA
                      SettingsSection(
                        title: 'Tahta Teması',
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: BoardColorTheme.all
                                      .map((t) => _ThemeCircle(
                                            theme: t,
                                            isSelected:
                                                settings.boardThemeId == t.id,
                                            onTap: () {
                                              HapticService.instance
                                                  .selectionClick();
                                              ref
                                                  .read(settingsProvider
                                                      .notifier)
                                                  .setBoardTheme(t.id);
                                            },
                                          ))
                                      .toList(),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // UYGULAMA
                      SettingsSection(
                        title: tr('settings.app_section'),
                        children: [
                          // Versiyon
                          SettingsTile(
                            icon: Icons.info_outline_rounded,
                            iconColor: const Color(0xFF00D9FF),
                            title: tr('settings.version'),
                            trailing: packageInfoAsync.when(
                              data: (info) => Text(
                                '${info.version} (${info.buildNumber})',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                              ),
                              loading: () => const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2),
                              ),
                              error: (_, __) => const Text('1.0.0'),
                            ),
                          ),

                          // Arkadaşlarına Öner
                          SettingsTile(
                            icon: Icons.share_rounded,
                            iconColor: const Color(0xFF6C63FF),
                            title: tr('settings.share_app'),
                            trailing: Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 14,
                              color: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.color,
                            ),
                            onTap: () => _shareApp(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // GELİŞTİRİCİ
                      SettingsSection(
                        title: tr('settings.developer_label'),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: const DeveloperCard(),
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // Alt logo
                      Center(
                        child: Column(
                          children: [
                            ShaderMask(
                              shaderCallback: (bounds) =>
                                  AppTheme.accentGradient().createShader(bounds),
                              child: const Text(
                                'GAME DART',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 4,
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Made with ❤️ by Saggio Ai',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      child: Row(
        children: [
          // Geri butonu
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface.withOpacity(0.8),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).dividerColor,
                  width: 1,
                ),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            tr('settings.title'),
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  fontSize: 24,
                ),
          ),
        ],
      ),
    );
  }

  void _shareApp(BuildContext context) {
    final shareText = tr('settings.share_text');
    Share.share(shareText, subject: tr('app_name'));
  }
}

// ─── Animasyonlu Switch ────────────────────────────────────────────
class _AnimatedSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _AnimatedSwitch({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: 0.85,
      child: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppTheme.primaryLight,
      ),
    );
  }
}

// ─── Dil Seçici ─────────────────────────────────────────────────────
class _LanguagePicker extends StatelessWidget {
  final String currentLocale;
  final ValueChanged<String> onChanged;

  const _LanguagePicker({
    required this.currentLocale,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showPicker(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppTheme.primaryLight.withOpacity(0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppTheme.primaryLight.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              currentLocale == 'tr' ? '🇹🇷 TR' : '🇺🇸 EN',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 16,
              color: AppTheme.primaryLight,
            ),
          ],
        ),
      ),
    );
  }

  void _showPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              tr('settings.language'),
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            _LangOption(
              flag: '🇹🇷',
              label: tr('settings.language_tr'),
              isSelected: currentLocale == 'tr',
              onTap: () {
                Navigator.pop(context);
                onChanged('tr');
              },
            ),
            const SizedBox(height: 12),
            _LangOption(
              flag: '🇺🇸',
              label: tr('settings.language_en'),
              isSelected: currentLocale == 'en',
              onTap: () {
                Navigator.pop(context);
                onChanged('en');
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _LangOption extends StatelessWidget {
  final String flag;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _LangOption({
    required this.flag,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryLight.withOpacity(0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? AppTheme.primaryLight.withOpacity(0.5)
                : Colors.grey.withOpacity(0.2),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 14),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight:
                    isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? AppTheme.primaryLight
                    : Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            const Spacer(),
            if (isSelected)
              Icon(Icons.check_circle_rounded,
                  color: AppTheme.primaryLight, size: 22),
          ],
        ),
      ),
    );
  }
}

// ─── Tahta Tema Dairesi ───────────────────────────────────────────
class _ThemeCircle extends StatelessWidget {
  final BoardColorTheme theme;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeCircle({
    required this.theme,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [theme.ring1, theme.ring2],
              ),
              border: Border.all(
                color: isSelected ? Colors.white : Colors.transparent,
                width: 3,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: theme.glowColor.withOpacity(0.6),
                        blurRadius: 14,
                        spreadRadius: 2,
                      )
                    ]
                  : null,
            ),
            child: isSelected
                ? const Icon(Icons.check_rounded,
                    color: Colors.white, size: 24)
                : null,
          ),
          const SizedBox(height: 6),
          Text(
            theme.emoji,
            style: const TextStyle(fontSize: 16),
          ),
          Text(
            theme.name,
            style: TextStyle(
              fontSize: 10,
              fontWeight:
                  isSelected ? FontWeight.w700 : FontWeight.w400,
              color: isSelected
                  ? AppTheme.primaryLight
                  : Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Tema Seçici ──────────────────────────────────────────────────
class _ThemePicker extends StatelessWidget {
  final String currentTheme;
  final ValueChanged<String> onChanged;

  const _ThemePicker({
    required this.currentTheme,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final themes = [
      ('dark', '🌙 Normal'),
      ('neon', '⚡ Neon'),
    ];

    final selectedTheme =
        themes.firstWhere((t) => t.$1 == currentTheme, orElse: () => ('dark', '🌙 Normal'));

    return GestureDetector(
      onTap: () => _showPicker(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppTheme.primaryLight.withOpacity(0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppTheme.primaryLight.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              selectedTheme.$2,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 16,
              color: AppTheme.primaryLight,
            ),
          ],
        ),
      ),
    );
  }

  void _showPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Tema Seç',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            _ThemeOption(
              emoji: '🌙',
              label: 'Normal Tema',
              description: 'Standart dark mode tasarımı',
              isSelected: currentTheme == 'dark',
              onTap: () {
                Navigator.pop(context);
                onChanged('dark');
              },
            ),
            const SizedBox(height: 12),
            _ThemeOption(
              emoji: '⚡',
              label: 'Neon Tema',
              description: 'Parlak neon renkleri ile futuristik tasarım',
              isSelected: currentTheme == 'neon',
              onTap: () {
                Navigator.pop(context);
                onChanged('neon');
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final String emoji;
  final String label;
  final String description;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeOption({
    required this.emoji,
    required this.label,
    required this.description,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryLight.withOpacity(0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? AppTheme.primaryLight.withOpacity(0.5)
                : Colors.grey.withOpacity(0.2),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected
                          ? AppTheme.primaryLight
                          : Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle_rounded,
                color: AppTheme.primaryLight,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}
