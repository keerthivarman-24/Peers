import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

class FirebaseBootstrap {
  static Future<FirebaseInitResult> init() async {
    try {
      WidgetsFlutterBinding.ensureInitialized();
      await Firebase.initializeApp().timeout(const Duration(seconds: 12));
      return const FirebaseInitResult.ok();
    } catch (e) {
      return FirebaseInitResult.fail(e.toString());
    }
  }
}

class FirebaseInitResult {
  final bool success;
  final String? error;
  const FirebaseInitResult._(this.success, this.error);
  const FirebaseInitResult.ok() : this._(true, null);
  const FirebaseInitResult.fail(String e) : this._(false, e);
}

