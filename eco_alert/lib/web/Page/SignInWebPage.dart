import 'dart:math';
import 'package:eco_alert/web/Page/LoginWebPage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dio/dio.dart';
import 'package:openapi/openapi.dart';

class SignInWebPage extends StatefulWidget {
  final AuthApi authApi;
  final UtentiApi utentiApi;
  final Dio dio;
  final SegnalazioniApi segnalazioniApi;
  final EntiApi entiApi;
  final CommentiApi commentiApi;
  final AllegatiApi allegatiApi;

  const SignInWebPage({
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
  State<SignInWebPage> createState() => _SignInWebPageState();
}

class _SignInWebPageState extends State<SignInWebPage>
    with SingleTickerProviderStateMixin {
  final nameController = TextEditingController();
  final cognomeController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final paeseController = TextEditingController();
  final nazioneController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  bool isLoading = false;
  String? signInError;

  late AnimationController _controller;
  late Animation<double> _fade;
  final Random _random = Random();
  final List<_CircleData> _circles = [];
  bool _showPassword = false;

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
    nameController.dispose();
    cognomeController.dispose();
    emailController.dispose();
    passwordController.dispose();
    paeseController.dispose();
    nazioneController.dispose();
    super.dispose();
  }

  Widget _signUpButton({required double width}) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: width,
        height: 52,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 6,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: isLoading ? null : _signIn,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00BFA5),
            foregroundColor: Colors.white,
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
                    "Registrati",
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

  Future _signIn() async {
    if (!formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
      signInError = null;
    });

    try {
      final response = await widget.authApi.signIn(
        utenteInput: UtenteInput(
          (b) => b
            ..nome = nameController.text
            ..cognome = cognomeController.text
            ..email = emailController.text
            ..password = passwordController.text
            ..nazione = nazioneController.text
            ..ruolo = "ente",
        ),
      );

      final roleFromServer = response.data?.ruolo;

      if (kIsWeb && roleFromServer != "ente") {
        await _showErrorDialog("I cittadini non possono registrarsi da web.");
        return;
      }

      if (!kIsWeb && roleFromServer != "cittadino") {
        await _showErrorDialog("Gli enti non possono registrarsi da mobile.");
        return;
      }

      // Dialog di successo
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.green.shade50,
          title: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 32),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  "Registrazione completata!",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            "Benvenuto, ${nameController.text}!\nIl tuo account è stato creato con successo.\nUserID: ${response.data?.id}",
            style: const TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "OK",
                style: TextStyle(
                  color: Colors.green.shade800,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );

      Navigator.pop(context); // torna alla pagina di login
    } catch (ex) {
      String message = "Errore durante la registrazione";
      if (ex is DioException) {
        if (ex.response?.data is Map<String, dynamic>) {
          message =
              (ex.response?.data as Map<String, dynamic>)["message"]
                  ?.toString() ??
              message;
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
        contentPadding: const EdgeInsets.symmetric(
          vertical: 18,
          horizontal: 16,
        ),
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
    final formWidth = isMobile ? size.width * 0.85 : 400.0;

    return Scaffold(
      body: Stack(
        children: [
          // Sfondo gradient soft
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0B3D35), Color(0xFF0A4A40)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          // Particelle decorative
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
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ClipOval(
                          child: SizedBox(
                            width: logoSize,
                            height: logoSize,
                            child: Image.asset(
                              'assets/images/ecoalert_logo.png',
                              fit: BoxFit.cover,
                              alignment: Alignment(0, -0.35),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Registrazione Enti',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.manrope(
                            fontSize: isMobile ? 28 : 32,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 32),
                        Form(
                          key: formKey,
                          child: Column(
                            children: [
                              _buildTextField(
                                controller: nameController,
                                label: "Nome Ente",
                                icon: Icons.person,
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                controller: emailController,
                                label: "Email",
                                icon: Icons.email,
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: passwordController,
                                obscureText: !_showPassword,
                                validator: (v) => (v == null || v.isEmpty)
                                    ? "Campo obbligatorio"
                                    : null,
                                style: const TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  prefixIcon: Icon(
                                    Icons.lock,
                                    color: Colors.white70,
                                  ),
                                  labelText: "Password",
                                  labelStyle: const TextStyle(
                                    color: Colors.white70,
                                  ),
                                  filled: true,
                                  fillColor: Colors.white.withOpacity(0.08),
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 18,
                                    horizontal: 16,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Color(0xFF00BFA5),
                                      width: 2,
                                    ),
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _showPassword
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                      color: Colors.white70,
                                    ),
                                    onPressed: () => setState(
                                      () => _showPassword = !_showPassword,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                controller: paeseController,
                                label: "Paese / Città",
                                icon: Icons.location_city,
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                controller: nazioneController,
                                label: "Nazione",
                                icon: Icons.public,
                              ),
                              if (signInError != null) ...[
                                const SizedBox(height: 12),
                                Text(
                                  signInError!,
                                  style: const TextStyle(
                                    color: Colors.red,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 28),
                              _signUpButton(width: formWidth),
                              const SizedBox(height: 12),
                              // Pulsante secondario login
                              TextButton(
                                onPressed: () => Navigator.push(
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
                                ),
                                child: Text(
                                  "Hai già un account? Accedi",
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
