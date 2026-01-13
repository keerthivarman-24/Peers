import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:peers/home.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  bool _obscure = true;
  late AnimationController _anim;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _anim.forward();
  }

  Future<void> _continueAsGuest() async {
    final name = await _showGuestNameDialog();
    if (name == null || name.trim().isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('guest_name', name.trim());
    // proceed to guest flow, e.g. Navigator.pushReplacement(...)
  }

  Future<String?> _showGuestNameDialog() {
    final TextEditingController _nameController = TextEditingController();
    return showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return AlertDialog(
          title: const Text('Continue as guest'),
          content: TextField(
            controller: _nameController,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Your name',
              hintText: 'Enter your name',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(null),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final name = _nameController.text;
                if (name.trim().isEmpty) return;
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const HomeScreen()),
                );
              },
              child: const Text('Continue'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gradient = const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF3F51B5), Color(0xFF536DFE), Color(0xFF7C4DFF)],
    );

    return Scaffold(
      body: Stack(
        children: [
          // Decorative gradient blobs
          Positioned(
            top: -120,
            left: -80,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                gradient: gradient,
                shape: BoxShape.circle,
              ),
              foregroundDecoration: BoxDecoration(
                color: Colors.white.withOpacity(0.02),
              ),
            ),
          ),
          Positioned(
            bottom: -140,
            right: -100,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                gradient: gradient,
                shape: BoxShape.circle,
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  // App title / logo
                  FadeTransition(
                    opacity: CurvedAnimation(
                      parent: _anim,
                      curve: Curves.easeOut,
                    ),
                    child: Column(
                      children: [
                        // Replace with Image.asset or your logo widget
                        CircleAvatar(
                          radius: 36,
                          backgroundColor: Colors.white.withOpacity(0.12),
                          child: Icon(
                            Icons.flutter_dash,
                            size: 36,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Welcome Back',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Sign in to continue',
                          style: TextStyle(fontSize: 14, color: Colors.black54),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Glass card
                  FadeTransition(
                    opacity: CurvedAnimation(
                      parent: _anim,
                      curve: Interval(0.2, 1.0, curve: Curves.easeOut),
                    ),
                    child: _buildGlassCard(context, gradient),
                  ),

                  const SizedBox(height: 28),

                  // Continue as guest pinned at bottom visually
                  TextButton(
                    onPressed: () {
                      _continueAsGuest();
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 20,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(
                          Icons.person_outline,
                          size: 18,
                          color: Colors.black54,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Continue as guest',
                          style: TextStyle(color: Colors.black87),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassCard(BuildContext context, Gradient gradient) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.12),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.14)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Email
                TextFormField(
                  keyboardType: TextInputType.emailAddress,
                  decoration: _inputDecoration(
                    label: 'Email',
                    icon: Icons.email_outlined,
                  ),
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Enter email' : null,
                ),
                const SizedBox(height: 12),

                // Password
                TextFormField(
                  obscureText: _obscure,
                  decoration: _inputDecoration(
                    label: 'Password',
                    icon: Icons.lock_outline,
                    suffix: IconButton(
                      icon: Icon(
                        _obscure ? Icons.visibility_off : Icons.visibility,
                        color: Colors.black54,
                      ),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                  validator: (v) => (v == null || v.length < 6)
                      ? 'Minimum 6 characters'
                      : null,
                ),
                const SizedBox(height: 18),

                // Sign in button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState?.validate() ?? false) {
                        // Process login
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const HomeScreen(),
                          ),
                        );
                      }
                    },
                    style:
                        ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 4,
                          backgroundColor: null,
                        ).copyWith(
                          // gradient background via MaterialStateProperty
                          backgroundColor: MaterialStateProperty.resolveWith(
                            (states) => null,
                          ),
                          shadowColor: MaterialStateProperty.all(
                            Colors.black26,
                          ),
                        ),
                    child: Ink(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF3F51B5), Color(0xFF7C4DFF)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Container(
                        alignment: Alignment.center,
                        constraints: const BoxConstraints(minHeight: 48),
                        child: const Text(
                          'Sign In',

                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Forgot and social row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {},
                      child: const Text(
                        'Forgot password?',
                        style: TextStyle(color: Colors.black54),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.black54),
      suffixIcon: suffix,
      filled: true,
      fillColor: Colors.white.withOpacity(0.06),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
    );
  }
}
