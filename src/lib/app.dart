import 'package:flutter/material.dart';

import 'presentation/screens/game_list/game_list_screen.dart';

class BeobachterApp extends StatelessWidget {
  const BeobachterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Beobachter',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.green,
        brightness: Brightness.light,
        useMaterial3: true,
      ),
      home: const GameListScreen(),
    );
  }
}
