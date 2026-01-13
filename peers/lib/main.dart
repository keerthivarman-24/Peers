import 'package:flutter/material.dart';
import 'package:peers/chat.dart';
import 'login.dart';
import 'home.dart';
import 'chat.dart';

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
      home: const DoubtScreen(),
    );
  }
}
