import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'providers/note_provider.dart';
import 'providers/theme_provider.dart';
import 'utils/app_router.dart';
import 'i18n/strings.g.dart';

Future<String> getInitialLanguage() async {
  final prefs = await SharedPreferences.getInstance();
  final savedLang = prefs.getString('app_language');
  if (savedLang == null || savedLang == 'sys') {
    String deviceLang =
        WidgetsBinding.instance.platformDispatcher.locale.languageCode;
    if (deviceLang != 'vi' && deviceLang != 'en') {
      deviceLang = 'en';
    }
    return deviceLang;
  } else {
    return savedLang;
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // FIX: Lock orientation — tránh layout thrashing khi xoay máy
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // FIX: Edge-to-edge — Flutter không cần tính toán lại layout khi system bars thay đổi
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  // Thiết lập ngôn ngữ ban đầu
  final initialLanguage = await getInitialLanguage();
  if (initialLanguage == 'vi') {
    LocaleSettings.setLocale(AppLocale.vi);
  } else {
    LocaleSettings.setLocale(AppLocale.en);
  }

  runApp(
    TranslationProvider(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => NoteProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp.router(
            routerConfig: appRouter,
            title: 'Note',
            debugShowCheckedModeBanner: true,
            themeMode: themeProvider.themeMode,
            theme: _buildTheme(Brightness.light),
            darkTheme: _buildTheme(Brightness.dark),
          );
        },
      ),
    );
  }

  ThemeData _buildTheme(Brightness brightness) {
    return ThemeData(
      brightness: brightness,
      colorSchemeSeed: Colors.indigo,
      useMaterial3: true,
    );
  }
}
