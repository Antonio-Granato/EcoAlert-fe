import 'dart:math';
import 'package:eco_alert/web/Page/LoginWebPage.dart';
import 'package:eco_alert/web/Page/SignInWebPage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dio/dio.dart';
import 'package:openapi/openapi.dart';

class WelcomeWebPage extends StatefulWidget {
  final AuthApi authApi;
  final UtentiApi utentiApi;
  final Dio dio;
  final SegnalazioniApi segnalazioniApi;
  final EntiApi entiApi;
  final CommentiApi commentiApi;
  final AllegatiApi allegatiApi;

  const WelcomeWebPage({
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
  State<WelcomeWebPage> createState() => _WelcomeWebPageState();
}

class _WelcomeWebPageState extends State<WelcomeWebPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;
  final Random _random = Random();
  final List<_CircleData> _circles = [];

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);

    _controller.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final size = MediaQuery.of(context).size;
      for (int i = 0; i < 40; i++) {
        _circles.add(
          _CircleData(
            size: 30 + _random.nextDouble() * 60,
            left: _random.nextDouble() * size.width,
            top: _random.nextDouble() * size.height,
            opacity: 0.03 + _random.nextDouble() * 0.05,
            speedX: (_random.nextDouble() - 0.5) * 0.25,
            speedY: (_random.nextDouble() - 0.5) * 0.25,
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

          if (c.left < 0 || c.left > size.width - c.size) {
            c.speedX *= -1;
          }
          if (c.top < 0 || c.top > size.height - c.size) {
            c.speedY *= -1;
          }
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
          elevation: 12,
          shadowColor: Colors.black.withOpacity(0.35),
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

    final logoSize = isMobile ? 110.0 : 150.0;
    final titleSize = isMobile ? 40.0 : 64.0;
    final subtitleSize = isMobile ? 16.0 : 18.0;
    final buttonWidth = isMobile ? size.width * 0.75 : 240.0;

    return Scaffold(
      body: Stack(
        children: [
          // ✅ SFONDO VERDE SCURO MODERNO
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

          // ✅ AMBIENT CIRCLES
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

          // ✅ CONTENUTO CENTRALE (NO CARD)
          Center(
            child: FadeTransition(
              opacity: _fade,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ✅ CERCHIO BIANCO DIETRO LOGO
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

                  const SizedBox(height: 36),

                  // ✅ TITOLO BIANCO
                  Text(
                    'EcoAlert',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.manrope(
                      fontSize: titleSize,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.4,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 18),

                  // ✅ SOTTOTITOLO BIANCO
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 520),
                    child: Text(
                      "Segnala e monitora le criticità ambientali nel tuo territorio",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: subtitleSize,
                        fontWeight: FontWeight.w300,
                        height: 1.9,
                        letterSpacing: 0.6,
                        color: Colors.white.withOpacity(0.75),
                      ),
                    ),
                  ),

                  const SizedBox(height: 48),

                  // ✅ BOTTONI
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 22,
                    runSpacing: 16,
                    children: [
                      _primaryButton(
                        label: "Accedi",
                        icon: Icons.login_rounded,
                        width: buttonWidth,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => LoginWebPage(
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
                              builder: (_) => SignInWebPage(
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
                    ],
                  ),

                  const SizedBox(height: 50),

                  // ✅ FOOTER BIANCO
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
                      // Icona di Facebook al posto del numero di telefono
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
