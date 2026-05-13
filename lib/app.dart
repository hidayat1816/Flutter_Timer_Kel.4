import 'package:flutter/material.dart';
import 'package:flutter_timer/timer/view/timer_page.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Timer',

      theme: ThemeData(
        brightness: Brightness.light,

        scaffoldBackgroundColor: const Color(0xFFF5F7FB),

        colorScheme: const ColorScheme.light(
          primary: Color.fromRGBO(72, 74, 126, 1),
        ),

        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),

        iconTheme: const IconThemeData(
          color: Colors.black87,
        ),
      ),

      home: const TimerPage(),
    );
  }
}