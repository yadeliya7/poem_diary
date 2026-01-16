import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme.dart';
import 'core/providers.dart';
import 'core/language_provider.dart';
import 'screens/main_scaffold.dart';
import 'screens/setup_profile_screen.dart';

import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting();

  final prefs = await SharedPreferences.getInstance();
  final bool isSetupDone = prefs.getBool('is_setup_done') ?? false;

  runApp(PoemDiaryApp(isSetupDone: isSetupDone));
}

class PoemDiaryApp extends StatelessWidget {
  final bool isSetupDone;

  const PoemDiaryApp({super.key, required this.isSetupDone});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => PoemProvider()),
        ChangeNotifierProvider(create: (_) => MoodProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'Habitual',
            theme: AppTheme.lightTheme(),
            darkTheme: AppTheme.darkTheme(),
            themeMode: themeProvider.isDarkMode
                ? ThemeMode.dark
                : ThemeMode.light,
            home: isSetupDone
                ? const MainScaffold()
                : const SetupProfileScreen(),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
