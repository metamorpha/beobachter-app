import 'package:flutter/material.dart';

import 'presentation/screens/game_list/game_list_screen.dart';
import 'presentation/theme/app_theme.dart';

class BeobachterApp extends StatelessWidget {
  const BeobachterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Beobachter',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      themeMode: ThemeMode.light,
      home: const GameListScreen(),
    );
  }
}
