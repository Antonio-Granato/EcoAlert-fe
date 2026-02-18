import 'dart:math';
import 'package:eco_alert/utils/web_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dio/dio.dart';
import 'package:openapi/openapi.dart';

class LoginWebPage extends StatefulWidget {
  final AuthApi authApi;
  final UtentiApi utentiApi;
  final Dio dio;
  final SegnalazioniApi segnalazioniApi;
  final EntiApi entiApi;
  final CommentiApi commentiApi;
  final AllegatiApi allegatiApi;

  const LoginWebPage({
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
  State<LoginWebPage> createState() => _LoginWebPageState();
}

class _LoginWebPageState extends State<LoginWebPage>
    with SingleTickerProviderStateMixin {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool isLoading = false;
  String? loginError;

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
            size: 20 + _random.nextDouble() * 40,
            left: _random.nextDouble() * size.width,
            top: _random.nextDouble() * size.height,
            opacity: 0.02 + _random.nextDouble() * 0.05,
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

  Widget _loginButton({required double width}) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: SizedBox(
        width: width,
        height: 52,
        child: ElevatedButton(
          onPressed: isLoading ? null : _login,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00BFA5),
            foregroundColor: Colors.white,
            elevation: 10,
            shadowColor: Colors.black.withOpacity(0.2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : Text(
                    "Accedi",
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
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

      if (kIsWeb && ruolo != "ente") {
        await _showErrorDialog(
          "Accesso negato: i cittadini non possono accedere da web.",
        );
        return;
      }

      // Naviga a HomeWeb includendo userId nella query string così il reload conserva l'utente
      final routeName = '/HomeWeb?userId=${response.data!.userId!}';
      // salva userId e route per garantire restore su Invio/refresh
      WebStorage.setUserId(response.data!.userId!);
      WebStorage.setLastRoute(routeName);
      Navigator.pushReplacementNamed(context, routeName);
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

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 650;
    final logoSize = isMobile ? 100.0 : 140.0;
    final formWidth = isMobile ? size.width * 0.85 : 400.0;

    return Scaffold(
      body: Stack(
        children: [
          // Sfondo gradient + animazioni soft
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0B3D35), Color(0xFF0A4A40)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

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

          // Contenuto centrale
          Center(
            child: FadeTransition(
              opacity: _fade,
              child: Card(
                elevation: 24,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                color: Colors.white.withOpacity(0.05),
                child: Container(
                  width: formWidth + 40,
                  padding: const EdgeInsets.symmetric(
                    vertical: 40,
                    horizontal: 32,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        'assets/images/LOGO.png',
                        width: logoSize,
                        height: logoSize,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Login Enti',
                        style: GoogleFonts.manrope(
                          fontSize: isMobile ? 36 : 48,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 32),
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
                              obscureText: true,
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
                            const SizedBox(height: 28),
                            _loginButton(width: formWidth),

                            const SizedBox(height: 12),
                            // Pulsante secondario login
                            TextButton(
                              onPressed: () =>
                                  Navigator.pushNamed(context, '/SignInWeb'),
                              child: Text(
                                "Non hai un account?, Registrati.",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontWeight: FontWeight.w500,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
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
    bool obscureText = false,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: (v) => (v == null || v.isEmpty) ? "Campo obbligatorio" : null,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.white70),
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
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
