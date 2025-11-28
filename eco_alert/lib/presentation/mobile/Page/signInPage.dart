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
  final paeseController = TextEditingController();
  final nazioneController = TextEditingController();

  final formKey = GlobalKey<FormState>();
  bool isLoading = false;
  String? signInError;

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _logoScale;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _logoScale = Tween<double>(
      begin: 0.8,
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
    required VoidCallback onPressed,
    required bool isPrimary,
  }) {
    final backgroundColor = isPrimary ? Colors.green.shade700 : Colors.white;
    final borderColor = isPrimary
        ? Colors.green.shade800
        : Colors.green.shade700;
    final textColor = isPrimary ? Colors.white : Colors.green.shade800;

    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(color: borderColor, width: 1.5),
          ),
          elevation: 6,
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
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
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ScaleTransition(
                    scale: _logoScale,
                    child: Image.asset(
                      'assets/images/LOGO.png',
                      width: 120,
                      height: 120,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "Registrati a EcoAlert!",
                    style: TextStyle(
                      fontFamily: "Poppins",
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      foreground: Paint()
                        ..shader =
                            LinearGradient(
                              colors: [
                                Colors.green.shade800,
                                Colors.green.shade600,
                              ],
                            ).createShader(
                              const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0),
                            ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Form(
                    key: formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: nameController,
                          decoration: const InputDecoration(
                            labelText: "Nome",
                            prefixIcon: Icon(Icons.person),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) => (value == null || value.isEmpty)
                              ? 'Inserisci il nome'
                              : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: cognomeController,
                          decoration: const InputDecoration(
                            labelText: "Cognome",
                            prefixIcon: Icon(Icons.person_outline),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) => (value == null || value.isEmpty)
                              ? 'Inserisci il cognome'
                              : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: emailController,
                          decoration: const InputDecoration(
                            labelText: "Email",
                            prefixIcon: Icon(Icons.email),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) => (value == null || value.isEmpty)
                              ? 'Inserisci una email'
                              : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: passwordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: "Password",
                            prefixIcon: Icon(Icons.lock),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) => (value == null || value.isEmpty)
                              ? 'Inserisci una password'
                              : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: paeseController,
                          decoration: const InputDecoration(
                            labelText: "Paese / Città",
                            prefixIcon: Icon(Icons.location_city),
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: nazioneController,
                          decoration: const InputDecoration(
                            labelText: "Nazione",
                            prefixIcon: Icon(Icons.public),
                            border: OutlineInputBorder(),
                          ),
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
                          text: "Registrati",
                          onPressed: _signIn,
                          isPrimary: true,
                        ),
                        const SizedBox(height: 16),
                        _buildButton(
                          text: "Hai già un account? Accedi",
                          onPressed: () => Navigator.pop(context),
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
            ..paese = paeseController.text
            ..nazione = nazioneController.text,
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
