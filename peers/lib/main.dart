import 'package:flutter/material.dart';
import 'core/app_theme.dart';
import 'login.dart';

void main() {
  runApp(const PeersApp());
}

class PeersApp extends StatelessWidget {
  const PeersApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Peers',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: const LoginScreen(),
    );
  }
}
