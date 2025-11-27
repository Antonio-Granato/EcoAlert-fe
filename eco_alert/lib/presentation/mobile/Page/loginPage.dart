import 'package:flutter/foundation.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              color: Colors.white.withOpacity(0.95),
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
                        validator: (value) => (value == null || value.isEmpty)
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
                        validator: (value) => (value == null || value.isEmpty)
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

                      // Button
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

      final ruolo = response.data?.ruolo;

      // MOBILE → solo cittadini
      if (!kIsWeb && ruolo != "cittadino") {
        setState(() {
          loginError =
              "Accesso negato: gli enti non possono accedere da mobile.";
        });
        return;
      }

      // WEB → solo enti
      if (kIsWeb && ruolo != "ente") {
        setState(() {
          loginError =
              "Accesso negato: i cittadini non possono accedere da web.";
        });
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Login effettuato! UserId: ${response.data?.userId}"),
        ),
      );
    } catch (ex) {
      if (ex is DioException) {
        String? serverMessage;
        if (ex.response?.data is Map<String, dynamic>) {
          serverMessage = (ex.response?.data as Map<String, dynamic>)['message']
              ?.toString();
        }

        final err = Error(
          (b) => b
            ..message =
                serverMessage ??
                (ex.response?.statusCode == 401
                    ? "Credenziali non valide"
                    : "Si è verificato un errore. Riprova."),
        );

        setState(() {
          loginError = err.message;
        });
      } else {
        final err = Error(
          (b) => b..message = "Si è verificato un errore. Riprova.",
        );
        setState(() {
          loginError = err.message;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }
}
