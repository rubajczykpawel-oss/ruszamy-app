import 'package:flutter/material.dart';

import 'screens/login_screen.dart';

class RuszamyApp extends StatelessWidget {
  const RuszamyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ruszamy App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.green,
      ),
      home: const LoginScreen(),
    );
  }
}