import 'dart:math';

import 'homePage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:openapi/openapi.dart';
import 'package:dio/dio.dart';
import 'signInPage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({
    super.key,
    required this.authApi,
    required this.utentiApi,
    required this.dio,
    required this.segnalazioniApi,
    required this.entiApi,
    required this.commentiApi,
    required this.allegatiApi,
  });
  final AuthApi authApi;
  final UtentiApi utentiApi;
  final Dio dio;
  final SegnalazioniApi segnalazioniApi;
  final EntiApi entiApi;
  final CommentiApi commentiApi;
  final AllegatiApi allegatiApi;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool isLoading = false;
  bool _obscurePassword = true;
  String? loginError;

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  final Random _random = Random();
  final List<_CircleData> _circles = [];

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _controller.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final size = MediaQuery.of(context).size;
      for (int i = 0; i < 30; i++) {
        _circles.add(
          _CircleData(
            size: 20 + _random.nextDouble() * 50,
            left: _random.nextDouble() * size.width,
            top: _random.nextDouble() * size.height,
            opacity: 0.02 + _random.nextDouble() * 0.05,
            speedX: (_random.nextDouble() - 0.5) * 0.2,
            speedY: (_random.nextDouble() - 0.5) * 0.2,
          ),
        );
      }
      _animate();
    });
  }

  void _animate() {
    final size = MediaQuery.of(context).size;
    _controller.addListener(() {
      setState(() {
        for (final c in _circles) {
          c.left += c.speedX;
          c.top += c.speedY;
          if (c.left < 0 || c.left > size.width - c.size) c.speedX *= -1;
          if (c.top < 0 || c.top > size.height - c.size) c.speedY *= -1;
        }
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Widget _buildButton({
    required String label,
    required VoidCallback onTap,
    required bool isPrimary,
  }) {
    final bgColor = isPrimary
        ? const Color(0xFF00BFA5)
        : Colors.white.withOpacity(0.1);
    final fgColor = isPrimary ? Colors.white : Colors.white70;

    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: isLoading ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: fgColor,
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.white.withOpacity(0.3)),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
      ),
    );
  }

  Future _login() async {
    if (!formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      final response = await widget.authApi.login(
        loginInput: LoginInput(
          (b) => b
            ..email = emailController.text
            ..password = passwordController.text,
        ),
      );

      final ruolo = response.data?.ruolo;

      if (!kIsWeb && ruolo != "cittadino") {
        await _showErrorDialog(
          "Accesso negato: gli enti non possono accedere da mobile.",
        );
        return;
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => HomePage(
            utentiApi: widget.utentiApi,
            userId: response.data!.userId!,
            dio: widget.dio,
            authApi: widget.authApi,
            segnalazioniApi: widget.segnalazioniApi,
            entiApi: widget.entiApi,
            commentiApi: widget.commentiApi,
            allegatiApi: widget.allegatiApi,
          ),
        ),
      );
    } catch (ex) {
      String message = "Si è verificato un errore. Riprova.";
      if (ex is DioException) {
        if (ex.response?.data is Map<String, dynamic>) {
          message =
              (ex.response?.data as Map<String, dynamic>)['message']
                  ?.toString() ??
              message;
        } else if (ex.response?.statusCode == 401) {
          message = "Credenziali non valide";
        }
      }
      await _showErrorDialog(message);
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _showErrorDialog(String message) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.red.shade50,
        title: Row(
          children: const [
            Icon(Icons.error_outline, color: Colors.red, size: 32),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                "Errore",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Text(message, style: const TextStyle(fontSize: 16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "OK",
              style: TextStyle(
                color: Colors.red.shade800,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscure = false,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure ? _obscurePassword : false,
      validator: (v) => (v == null || v.isEmpty) ? "Campo obbligatorio" : null,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.white70),
        suffixIcon: obscure
            ? IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  color: Colors.white70,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              )
            : null,
        filled: true,
        fillColor: Colors.white.withOpacity(0.08),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF00BFA5), width: 2),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 650;
    final logoSize = isMobile ? 100.0 : 140.0;

    return Scaffold(
      body: Stack(
        children: [
          // Sfondo verde scuro
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF0F2F2B),
                  Color(0xFF0B3D35),
                  Color(0xFF0A4A40),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // Cerchi animati
          ..._circles.map(
            (c) => Positioned(
              left: c.left,
              top: c.top,
              child: Container(
                width: c.size,
                height: c.size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.white.withOpacity(c.opacity),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),

          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 40,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Cerchio bianco dietro logo
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 20,
                          ),
                        ],
                      ),
                      child: Image.asset(
                        'assets/images/LOGO.png',
                        width: logoSize,
                        height: logoSize,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      "Accedi a EcoAlert",
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    Form(
                      key: formKey,
                      child: Column(
                        children: [
                          _buildTextField(
                            controller: emailController,
                            label: "Email",
                            icon: Icons.email,
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            controller: passwordController,
                            label: "Password",
                            icon: Icons.lock,
                            obscure: true,
                          ),
                          if (loginError != null) ...[
                            const SizedBox(height: 12),
                            Text(
                              loginError!,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 14,
                              ),
                            ),
                          ],
                          const SizedBox(height: 24),
                          _buildButton(
                            label: "Accedi",
                            onTap: _login,
                            isPrimary: true,
                          ),
                          const SizedBox(height: 16),
                          _buildButton(
                            label: "Non hai un account? Registrati",
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    SignInPage(authApi: widget.authApi),
                              ),
                            ),
                            isPrimary: false,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ignore: unused_element
class _CircleData {
  double size;
  double left;
  double top;
  double opacity;
  double speedX;
  double speedY;

  _CircleData({
    required this.size,
    required this.left,
    required this.top,
    required this.opacity,
    required this.speedX,
    required this.speedY,
  });
}
