import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme.dart';
import 'core/providers.dart';
import 'screens/main_scaffold.dart';

void main() {
  runApp(const PoemDiaryApp());
}

class PoemDiaryApp extends StatelessWidget {
  const PoemDiaryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => PoemProvider()),
        ChangeNotifierProvider(create: (_) => MoodProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'Poem Diary',
            theme: AppTheme.lightTheme(),
            darkTheme: AppTheme.darkTheme(),
            themeMode: themeProvider.isDarkMode
                ? ThemeMode.dark
                : ThemeMode.light,
            home: const MainScaffold(),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
