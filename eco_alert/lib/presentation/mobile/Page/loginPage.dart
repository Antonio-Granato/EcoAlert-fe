import 'package:eco_alert/presentation/mobile/Page/homePage.dart';
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
  });
  final AuthApi authApi;
  final UtentiApi utentiApi;
  final Dio dio;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  bool isLoading = false;
  Error? error;

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
                    "Accedi a EcoAlert!",
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
                          controller: emailController,
                          decoration: const InputDecoration(
                            labelText: "Email",
                            prefixIcon: Icon(Icons.email),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) => (value == null || value.isEmpty)
                              ? "Inserisci una email"
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
                              ? "Inserisci una password"
                              : null,
                        ),
                        if (error != null) ...[
                          const SizedBox(height: 12),
                          Text(
                            error!.toString(),
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 14,
                            ),
                          ),
                        ],
                        const SizedBox(height: 24),
                        _buildButton(
                          text: "Accedi",
                          onPressed: _login,
                          isPrimary: true,
                        ),
                        const SizedBox(height: 16),
                        _buildButton(
                          text: "Non hai un account? Registrati",
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    SignInPage(authApi: widget.authApi),
                              ),
                            );
                          },
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

  Future _login() async {
    if (!formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
    });

    try {
      final response = await widget.authApi.login(
        loginInput: LoginInput(
          (b) => b
            ..email = emailController.text
            ..password = passwordController.text,
        ),
      );

      final ruolo = response.data?.ruolo;

      // MOBILE → solo cittadini
      if (!kIsWeb && ruolo != "cittadino") {
        await Error(
          (b) => b
            ..message =
                "Accesso negato: gli enti non possono accedere da mobile.",
        );
        return;
      }

      // WEB → solo enti
      if (kIsWeb && ruolo != "ente") {
        await Error(
          (b) => b
            ..message =
                "Accesso negato: i cittadini non possono accedere da web.",
        );
        return;
      }

      // LOGIN SUCCESS → vai a HomePage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => HomePage(
            utentiApi: widget.utentiApi,
            userId: response.data!.userId!,
            dio: widget.dio,
            authApi: widget.authApi,
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
      await Error((b) => b..message = message);
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }
}
