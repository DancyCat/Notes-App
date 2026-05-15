import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:go_router/go_router.dart';
import '../providers/theme_provider.dart';
import '../i18n/strings.g.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final Uri _githubUrl = Uri.parse('https://github.com/Dancycat/Notes-App');
  String _selectedLanguageCode = 'sys';

  @override
  void initState() {
    super.initState();
    _loadSelectedLanguage();
  }

  void _loadSelectedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLang = prefs.getString('app_language');
    if (!mounted) return;
    setState(() {
      _selectedLanguageCode = savedLang ?? 'sys';
    });
    if (_selectedLanguageCode == 'sys') {
      String deviceLang =
          WidgetsBinding.instance.platformDispatcher.locale.languageCode;
      if (deviceLang != 'vi' && deviceLang != 'en') deviceLang = 'en';
      LocaleSettings.setLocale(
          deviceLang == 'vi' ? AppLocale.vi : AppLocale.en);
    } else {
      LocaleSettings.setLocale(
          _selectedLanguageCode == 'vi' ? AppLocale.vi : AppLocale.en);
    }
  }

  Future<void> _launchUrl(Uri url, BuildContext context) async {
    if (!await launchUrl(url)) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cannot open link: $url'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showLanguageSelectionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return RadioGroup<String>(
          groupValue: _selectedLanguageCode,
          onChanged: (String? value) async {
            if (value != null) {
              setState(() => _selectedLanguageCode = value);
              if (value == 'sys') {
                String deviceLang = WidgetsBinding
                    .instance.platformDispatcher.locale.languageCode;
                if (deviceLang != 'vi' && deviceLang != 'en') deviceLang = 'en';
                LocaleSettings.setLocale(
                    deviceLang == 'vi' ? AppLocale.vi : AppLocale.en);
              } else {
                LocaleSettings.setLocale(
                    value == 'vi' ? AppLocale.vi : AppLocale.en);
              }
              final prefs = await SharedPreferences.getInstance();
              await prefs.setString('app_language', value);
              if (!ctx.mounted) return;
              Navigator.pop(ctx);
            }
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  t.settings_screen.language_selection_sheet_title,
                  style: Theme.of(ctx).textTheme.headlineSmall,
                ),
              ),
              RadioListTile<String>(
                title: Text(t.settings_screen.language_system),
                value: 'sys',
              ),
              RadioListTile<String>(
                title: Text(t.settings_screen.language_vietnamese),
                value: 'vi',
              ),
              RadioListTile<String>(
                title: Text(t.settings_screen.language_english),
                value: 'en',
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  String _getLanguageName(String code) {
    switch (code) {
      case 'sys':
        return t.settings_screen.language_system;
      case 'vi':
        return t.settings_screen.language_vietnamese;
      case 'en':
        return t.settings_screen.language_english;
      default:
        return t.settings_screen.unknown;
    }
  }

  // FIX: Cache textTheme + colorScheme trong method thay vì gọi Theme.of() nhiều lần
  Widget _buildSectionHeader(BuildContext context, String title) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Text(
        title,
        style: theme.textTheme.labelLarge?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildSettingsItem(
    BuildContext context, {
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    // FIX: Cache theme một lần thay vì gọi Theme.of(context) 3-4 lần
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      title: Text(title, style: textTheme.titleMedium),
      subtitle: subtitle != null
          ? Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                subtitle,
                style: textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.normal,
                ),
              ),
            )
          : null,
      trailing: trailing,
      onTap: onTap,
    );
  }

  void _showThemeSelectionSheet(
      BuildContext context, ThemeProvider themeProvider) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return RadioGroup<ThemeMode>(
          groupValue: themeProvider.themeMode,
          onChanged: (ThemeMode? value) {
            if (value != null) {
              themeProvider.setThemeMode(value);
              Navigator.pop(ctx);
            }
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  t.settings_screen.theme_selection_sheet_title,
                  style: Theme.of(ctx).textTheme.headlineSmall,
                ),
              ),
              RadioListTile<ThemeMode>(
                title: Text(t.settings_screen.theme_system),
                value: ThemeMode.system,
              ),
              RadioListTile<ThemeMode>(
                title: Text(t.settings_screen.theme_light),
                value: ThemeMode.light,
              ),
              RadioListTile<ThemeMode>(
                title: Text(t.settings_screen.theme_dark),
                value: ThemeMode.dark,
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  String _getThemeModeName(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return t.settings_screen.theme_system;
      case ThemeMode.light:
        return t.settings_screen.theme_light;
      case ThemeMode.dark:
        return t.settings_screen.theme_dark;
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(t.settings_screen.app_bar_title),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 8.0),
          children: [
            const SizedBox(height: 8.0),
            _buildSectionHeader(context, t.settings_screen.section_appearance),
            const SizedBox(height: 8.0),
            _buildSettingsItem(
              context,
              title: t.settings_screen.theme_title,
              subtitle: _getThemeModeName(themeProvider.themeMode),
              onTap: () => _showThemeSelectionSheet(context, themeProvider),
            ),
            _buildSettingsItem(
              context,
              title: t.settings_screen.language_title,
              subtitle: _getLanguageName(_selectedLanguageCode),
              onTap: () => _showLanguageSelectionSheet(context),
            ),
            const Divider(height: 0, thickness: 1.5),
            const SizedBox(height: 16.0),
            _buildSectionHeader(context, t.settings_screen.section_about),
            const SizedBox(height: 12.0),
            _buildSettingsItem(
              context,
              title: t.settings_screen.view_source_title,
              subtitle: t.settings_screen.view_source_subtitle,
              onTap: () => _launchUrl(_githubUrl, context),
            ),
            _buildSettingsItem(
              context,
              title: t.settings_screen.help_translate_title,
              subtitle: t.settings_screen.help_translate_subtitle,
              onTap: () => _launchUrl(_githubUrl, context),
            ),
            _buildSettingsItem(
              context,
              title: t.settings_screen.report_bug_title,
              subtitle: t.settings_screen.report_bug_subtitle,
              onTap: () => _launchUrl(_githubUrl, context),
            ),
            // FIX: Dùng go_router thay vì MaterialPageRoute
            _buildSettingsItem(
              context,
              title: t.settings_screen.about_app_title,
              onTap: () => context.push('/settings/about'),
            ),
          ],
        ),
      ),
    );
  }
}
