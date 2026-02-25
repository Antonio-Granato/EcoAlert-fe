import 'package:flutter/material.dart';
import 'loginPage.dart';
import 'signInPage.dart';
import 'package:openapi/openapi.dart';
import 'package:dio/dio.dart';
import 'dart:math';
import 'package:google_fonts/google_fonts.dart';

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
    required double width,
  }) {
    return SizedBox(
      width: width,
      height: 52,
      child: ElevatedButton.icon(
        icon: Icon(icon, size: 20),
        label: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 15.5,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.6,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF00BFA5),
          foregroundColor: const Color(0xFF00332F),
          elevation: 8,
          shadowColor: Colors.black.withOpacity(0.25),
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
    required double width,
  }) {
    return SizedBox(
      width: width,
      height: 52,
      child: OutlinedButton.icon(
        icon: Icon(icon, size: 20),
        label: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 15.5,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.6,
            color: Colors.white70,
          ),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
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
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 650;

    final imageSize = isMobile
        ? size.width * 0.6
        : min(520.0, size.width * 0.45);
    final subtitleSize = isMobile ? 16.0 : 18.0;
    final buttonWidth = isMobile ? size.width * 0.75 : 240.0;

    return Scaffold(
      body: Stack(
        children: [
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

          // Animated ambient circles
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: imageSize,
                    height: imageSize,
                    child: Image.asset(
                      'assets/images/ecoalert_logo.png',
                      fit: BoxFit.contain,
                      alignment: Alignment.center,
                    ),
                  ),

                  const SizedBox(height: 8),

                  ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 520),
                    child: Text(
                      "Segnala e monitora le criticità ambientali nel tuo territorio.",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: subtitleSize,
                        fontWeight: FontWeight.w300,
                        height: 1.9,
                        letterSpacing: 0.6,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  const SizedBox(height: 36),

                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 22,
                    runSpacing: 12,
                    children: [
                      _primaryButton(
                        label: "Accedi",
                        icon: Icons.login_rounded,
                        width: buttonWidth,
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

                      _secondaryButton(
                        label: "Crea un account",
                        icon: Icons.person_add_alt_1_rounded,
                        width: buttonWidth,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  SignInPage(authApi: widget.authApi),
                            ),
                          );
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 44),

                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 18,
                    children: [
                      Text(
                        "© 2025 EcoAlert",
                        style: GoogleFonts.inter(
                          fontSize: 12.5,
                          color: Colors.white70,
                        ),
                      ),
                      _footerLink("Privacy"),
                      _footerLink("Termini"),
                      Icon(Icons.facebook, color: Colors.white70, size: 18),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _footerLink(String text) {
    return InkWell(
      onTap: () {},
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 13,
          color: Colors.grey.shade600,
          decoration: TextDecoration.underline,
        ),
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
