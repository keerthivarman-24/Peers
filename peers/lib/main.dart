import 'package:flutter/material.dart';
import 'login.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  final Color bg = const Color(0xFFFAFAFB);

  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login Demo',
      theme: ThemeData(
        scaffoldBackgroundColor: bg,
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: Color(0xFF536DFE),
        ),
      ),
      home: const LoginScreen(),
    );
  }
}
