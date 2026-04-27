// lib/main.dart
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/services/admob_service.dart';
import 'core/theme/app_theme.dart';
import 'providers/settings_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Localization başlatma
  await EasyLocalization.ensureInitialized();

  // AdMob başlatma (yalnızca mobil)
  if (!kIsWeb) {
    await AdmobService.instance.initialize();
  }

  // Portrait lock (web'de geçersiz, sorun çıkarmaz)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(
    ProviderScope(
      child: EasyLocalization(
        supportedLocales: const [Locale('tr'), Locale('en')],
        path: 'assets/translations',
        fallbackLocale: const Locale('tr'),
        useOnlyLangCode: true,
        child: const GameDartApp(),
      ),
    ),
  );
}

class GameDartApp extends ConsumerWidget {
  const GameDartApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Ayarlar yüklenene kadar varsayılan değerler kullan
    final settings =
        ref.watch(settingsProvider).valueOrNull ?? const SettingsState();

    ThemeData getTheme() {
      if (settings.appTheme == 'neon') {
        return AppTheme.neonTheme;
      } else if (settings.isDarkMode) {
        return AppTheme.darkTheme;
      } else {
        return AppTheme.lightTheme;
      }
    }

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Dart Oyunu',
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      theme: AppTheme.lightTheme,
      darkTheme: getTheme(),
      themeMode: settings.appTheme == 'neon'
          ? ThemeMode.dark
          : (settings.isDarkMode ? ThemeMode.dark : ThemeMode.light),
      routerConfig: AppRouter.router,
    );
  }
}
