import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:openapi/openapi.dart';
import 'package:dio/dio.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key, required this.authApi});
  final AuthApi authApi;

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage>
    with SingleTickerProviderStateMixin {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();
  final cognomeController = TextEditingController();
  final codiceFiscaleController = TextEditingController();
  final numeroTelefonoController = TextEditingController();
  final nazioneController = TextEditingController();

  final formKey = GlobalKey<FormState>();
  bool isLoading = false;
  bool _obscurePassword = true;
  String? signInError;

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    nameController.dispose();
    cognomeController.dispose();
    emailController.dispose();
    passwordController.dispose();
    nazioneController.dispose();
    codiceFiscaleController.dispose();
    numeroTelefonoController.dispose();
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
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
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
          // Sfondo
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
                    // Logo
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
                      child: ClipOval(
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
                    ),

                    const SizedBox(height: 24),

                    const Text(
                      "Registrati a EcoAlert",
                      style: TextStyle(
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
                            controller: nameController,
                            label: "Nome",
                            icon: Icons.person,
                          ),
                          const SizedBox(height: 16),

                          _buildTextField(
                            controller: cognomeController,
                            label: "Cognome",
                            icon: Icons.person_outline,
                          ),
                          const SizedBox(height: 16),

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
                          const SizedBox(height: 16),

                          _buildTextField(
                            controller: codiceFiscaleController,
                            label: "Codice Fiscale",
                            icon: Icons.badge,
                          ),
                          const SizedBox(height: 16),

                          _buildTextField(
                            controller: numeroTelefonoController,
                            label: "Numero di telefono",
                            icon: Icons.phone,
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
                          const SizedBox(height: 24),
                          _buildButton(
                            label: "Registrati",
                            onTap: _signIn,
                            isPrimary: true,
                          ),
                          const SizedBox(height: 16),
                          _buildButton(
                            label: "Hai già un account? Accedi",
                            onTap: () => Navigator.pop(context),
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
            ..codiceFiscale = codiceFiscaleController.text
            ..numeroTelefono = numeroTelefonoController.text
            ..nazione = nazioneController.text
            ..ruolo = kIsWeb ? "ente" : "cittadino",
        ),
      );

      final roleFromServer = response.data?.ruolo?.toLowerCase().trim();

      if (kIsWeb && roleFromServer != "ente") {
        await _showErrorDialog("I cittadini non possono registrarsi da web.");
        return;
      }

      if (!kIsWeb && roleFromServer != "cittadino") {
        await _showErrorDialog("Gli enti non possono registrarsi da mobile.");
        return;
      }

      // Mostra dialog di successo
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
            softWrap: true,
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

  // Funzione helper per mostrare errori in dialog
  Future<void> _showErrorDialog(String message) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.red.shade50,
        title: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 32),
            const SizedBox(width: 12),
            Expanded(
              child: const Text(
                "Errore",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: const TextStyle(fontSize: 16),
          softWrap: true,
        ),
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
}
