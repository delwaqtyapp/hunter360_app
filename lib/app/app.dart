import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/l10n/app_localizations.dart';
import '../core/services/settings_service.dart';
import '../core/theme/app_theme.dart';
import '../core/network/api_client.dart';
import '../features/auth/presentation/providers/auth_provider.dart';
import 'router.dart';

class Hunter360App extends ConsumerStatefulWidget {
  const Hunter360App({super.key});

  @override
  ConsumerState<Hunter360App> createState() => _Hunter360AppState();
}

class _Hunter360AppState extends ConsumerState<Hunter360App> {
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final service = SettingsService();
    final results = await Future.wait([
      service.getDarkMode(),
      service.getLanguage(),
      service.getServerUrl(),
      service.getNotificationsEnabled(),
      service.getAutoLogoutMinutes(),
    ]);

    final darkMode = results[0] as bool;
    final langCode = results[1] as String;
    final serverUrl = results[2] as String;
    final notifications = results[3] as bool;
    final autoLogout = results[4] as int;

    if (!mounted) return;
    ref.read(themeModeProvider.notifier).state = darkMode;
    ref.read(localeProvider.notifier).state = Locale(langCode);
    ref.read(serverUrlProvider.notifier).state = serverUrl;
    ref.read(notificationsEnabledProvider.notifier).state = notifications;
    ref.read(autoLogoutMinutesProvider.notifier).state = autoLogout;

    setState(() => _initialized = true);

    // Propagate auto-login token to Dio interceptor after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = ref.read(authProvider);
      if (authState.token != null && authState.token!.isNotEmpty) {
        ref.read(authTokenProvider.notifier).state = authState.token!;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme(),
        home: const Scaffold(
          body: Center(child: CircularProgressIndicator(color: Color(0xFF156082))),
        ),
      );
    }

    final router = ref.watch(routerProvider);
    final isDarkMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'Abqarino SCADA',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      routerConfig: router,
      locale: ref.watch(localeProvider),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}

final themeModeProvider = StateProvider<bool>((ref) => false);
final localeProvider = StateProvider<Locale>((ref) => const Locale('en'));
final notificationsEnabledProvider = StateProvider<bool>((ref) => true);
final autoLogoutMinutesProvider = StateProvider<int>((ref) => 0);
