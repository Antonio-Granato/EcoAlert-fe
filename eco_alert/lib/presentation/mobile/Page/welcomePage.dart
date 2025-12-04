import 'package:flutter/material.dart';
import 'loginPage.dart';
import 'signInPage.dart';
import 'package:openapi/openapi.dart';
import 'package:dio/dio.dart';

class WelcomePage extends StatefulWidget {
  final AuthApi authApi;
  final UtentiApi utentiApi;
  final Dio dio;
  final SegnalazioniApi segnalazioniApi;
  final EntiApi entiApi;
  final CommentiApi commentiApi;

  const WelcomePage({
    super.key,
    required this.authApi,
    required this.utentiApi,
    required this.dio,
    required this.segnalazioniApi,
    required this.entiApi,
    required this.commentiApi,
  });

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _logoScale;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _logoScale = Tween<double>(
      begin: 0.85,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildButton({
    required String text,
    required IconData icon,
    required VoidCallback onPressed,
    required Color backgroundColor,
    required Color borderColor,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton.icon(
        icon: Icon(icon, size: 22, color: Colors.white),
        label: Text(
          text,
          style: const TextStyle(
            fontFamily: "Poppins",
            fontSize: 18,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(color: borderColor, width: 1.5),
          ),
          elevation: 6,
          padding: EdgeInsets.zero,
        ),
        onPressed: onPressed,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gradientColors = [
      Color(0xFFe0f2f1),
      Color(0xFFb2dfdb),
      Color(0xFF80cbc4),
    ];

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // LOGO SEMPLICE
                  ScaleTransition(
                    scale: _logoScale,
                    child: Image.asset(
                      'assets/images/LOGO.png',
                      width: 140,
                      height: 140,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // TITOLO ECOALERT ELEGANTE
                  Text(
                    "EcoAlert!",
                    style: TextStyle(
                      fontFamily: "Poppins",
                      fontSize: 56,
                      fontWeight: FontWeight.w900,
                      foreground: Paint()
                        ..shader =
                            LinearGradient(
                              colors: <Color>[
                                Colors.green.shade800,
                                Colors.green.shade600,
                              ],
                            ).createShader(
                              const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0),
                            ),
                      letterSpacing: 1.5,
                      shadows: const [
                        Shadow(
                          blurRadius: 4,
                          color: Colors.black26,
                          offset: Offset(2, 2),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // PULSANTE ENTRA
                  _buildButton(
                    text: "Entra",
                    icon: Icons.login,
                    backgroundColor: Colors.green.shade700.withOpacity(0.85),
                    borderColor: Colors.green.shade800,
                    onPressed: () {
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
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 18),

                  // PULSANTE CREA ACCOUNT
                  _buildButton(
                    text: "Crea un account",
                    icon: Icons.person_add_alt_1,
                    backgroundColor: Colors.green.shade700.withOpacity(0.85),
                    borderColor: Colors.green.shade800,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SignInPage(authApi: widget.authApi),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
