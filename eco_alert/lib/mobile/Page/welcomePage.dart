import 'package:flutter/material.dart';
import 'loginPage.dart';
import 'signInPage.dart';
import 'package:openapi/openapi.dart';
import 'package:dio/dio.dart';
import 'dart:math';

class WelcomePage extends StatefulWidget {
  final AuthApi authApi;
  final UtentiApi utentiApi;
  final Dio dio;
  final SegnalazioniApi segnalazioniApi;
  final EntiApi entiApi;
  final CommentiApi commentiApi;
  final AllegatiApi allegatiApi;
  const WelcomePage({
    super.key,
    required this.authApi,
    required this.utentiApi,
    required this.dio,
    required this.segnalazioniApi,
    required this.entiApi,
    required this.commentiApi,
    required this.allegatiApi,
  });

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage>
    with SingleTickerProviderStateMixin {
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
            opacity: 0.03 + _random.nextDouble() * 0.05,
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
    super.dispose();
  }

  Widget _primaryButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        icon: Icon(icon, size: 20),
        label: Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF00BFA5),
          foregroundColor: const Color(0xFF00332F),
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        onPressed: onTap,
      ),
    );
  }

  Widget _secondaryButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton.icon(
        icon: Icon(icon, size: 20, color: Colors.white70),
        label: Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.white70,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.white70, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        onPressed: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final logoSize = 110.0;

    return Scaffold(
      body: Stack(
        children: [
          // Sfondo verde scuro simile alla versione web
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
                    // Cerchio bianco dietro il logo
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.4),
                            blurRadius: 30,
                          ),
                        ],
                      ),
                      child: Image.asset(
                        'assets/images/LOGO.png',
                        width: logoSize,
                        height: logoSize,
                      ),
                    ),

                    const SizedBox(height: 30),

                    Text(
                      "EcoAlert",
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        letterSpacing: 1.2,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 16),

                    Text(
                      "Segnala e monitora le criticità ambientali nel tuo territorio",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w300,
                        color: Colors.white70,
                        height: 1.8,
                      ),
                    ),

                    const SizedBox(height: 40),

                    _primaryButton(
                      label: "Accedi",
                      icon: Icons.login_rounded,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => LoginPage(
                              authApi: widget.authApi,
                              utentiApi: widget.utentiApi,
                              dio: widget.dio,
                              segnalazioniApi: widget.segnalazioniApi,
                              entiApi: widget.entiApi,
                              commentiApi: widget.commentiApi,
                              allegatiApi: widget.allegatiApi,
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 16),

                    _secondaryButton(
                      label: "Crea un account",
                      icon: Icons.person_add_alt_1_rounded,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => SignInPage(authApi: widget.authApi),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 30),

                    // Footer
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 12,
                      children: [
                        Text(
                          "© 2025 EcoAlert",
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                        Text(
                          "Privacy",
                          style: TextStyle(
                            color: Colors.grey.shade400,
                            decoration: TextDecoration.underline,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          "Termini",
                          style: TextStyle(
                            color: Colors.grey.shade400,
                            decoration: TextDecoration.underline,
                            fontSize: 12,
                          ),
                        ),
                        Icon(Icons.facebook, color: Colors.white70, size: 16),
                      ],
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
