import 'package:flutter/material.dart';
import 'package:openapi/openapi.dart';
import 'package:dio/dio.dart';
import 'signInPage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, required this.authApi});
  final AuthApi authApi;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  bool isLoading = false;
  String? loginError;

  // 🔥 Variabili per l’animazione del gradient
  List<Color> gradientColors1 = [Colors.green.shade200, Colors.teal.shade300];

  List<Color> gradientColors2 = [
    Colors.green.shade400,
    Colors.lightGreen.shade200,
  ];

  bool toggle = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 📸 Sfondo
          Positioned.fill(
            child: Image.asset("assets/images/sfondo1.jpg", fit: BoxFit.cover),
          ),

          // 🌟 Contenuto
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 400, // qui scegli la larghezza massima
                ),
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            "EcoAlert",
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Email
                          TextFormField(
                            controller: emailController,
                            decoration: const InputDecoration(
                              labelText: "Email",
                              prefixIcon: Icon(Icons.email),
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) =>
                                (value == null || value.isEmpty)
                                ? "Inserisci una email"
                                : null,
                          ),

                          const SizedBox(height: 16),

                          // Password
                          TextFormField(
                            controller: passwordController,
                            obscureText: true,
                            decoration: const InputDecoration(
                              labelText: "Password",
                              prefixIcon: Icon(Icons.lock),
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) =>
                                (value == null || value.isEmpty)
                                ? "Inserisci una password"
                                : null,
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

                          // Bottone Login
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: isLoading ? null : _login,
                              child: isLoading
                                  ? const CircularProgressIndicator(
                                      color: Colors.white,
                                    )
                                  : const Text(
                                      "Accedi",
                                      style: TextStyle(fontSize: 16),
                                    ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Link Registrazione
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      SignInPage(authApi: widget.authApi),
                                ),
                              );
                            },
                            child: const Text("Non hai un account? Registrati"),
                          ),
                        ],
                      ),
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

  Future _login() async {
    if (!formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
      loginError = null;
    });

    try {
      final response = await widget.authApi.login(
        loginInput: LoginInput(
          (b) => b
            ..email = emailController.text
            ..password = passwordController.text,
        ),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Login effettuato! UserId: ${response.data?.userId}"),
        ),
      );
    } catch (ex) {
      ex as DioException;
      if (ex.response?.statusCode == 401) {
        setState(() => loginError = "Credenziali non valide");
      } else {
        setState(() => loginError = "Si è verificato un errore. Riprova.");
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }
}
