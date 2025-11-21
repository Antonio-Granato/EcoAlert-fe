import 'package:flutter/material.dart';
import 'package:openapi/openapi.dart';
import 'package:dio/dio.dart';
import 'package:built_value/serializer.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class SignInPage extends StatefulWidget {
  const SignInPage({super.key, required this.authApi});
  final AuthApi authApi;

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();
  final cognomeController = TextEditingController();
  final paeseController = TextEditingController();
  final nazioneController = TextEditingController();

  final formKey = GlobalKey<FormState>();
  bool isLoading = false;
  String? signInError;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 📸 Sfondo
          Positioned.fill(
            child: Image.asset("assets/images/sfondo1.jpg", fit: BoxFit.cover),
          ),

          // 🌟 Contenuto centrato
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 400,
                ), // card non troppo larga
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  color: Colors.white.withOpacity(0.9),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            "Registrati",
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Nome
                          TextFormField(
                            controller: nameController,
                            decoration: const InputDecoration(
                              labelText: "Nome",
                              prefixIcon: Icon(Icons.person),
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) =>
                                (value == null || value.isEmpty)
                                ? 'Inserisci il nome'
                                : null,
                          ),
                          const SizedBox(height: 16),

                          // Cognome
                          TextFormField(
                            controller: cognomeController,
                            decoration: const InputDecoration(
                              labelText: "Cognome",
                              prefixIcon: Icon(Icons.person_outline),
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) =>
                                (value == null || value.isEmpty)
                                ? 'Inserisci il cognome'
                                : null,
                          ),
                          const SizedBox(height: 16),

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
                                ? 'Inserisci una email'
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
                                ? 'Inserisci una password'
                                : null,
                          ),
                          const SizedBox(height: 16),

                          // Paese
                          TextFormField(
                            controller: paeseController,
                            decoration: const InputDecoration(
                              labelText: "Paese / Città",
                              prefixIcon: Icon(Icons.location_city),
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Nazione
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

                          // Bottone Registrati
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: isLoading ? null : _signIn,
                              child: isLoading
                                  ? const CircularProgressIndicator(
                                      color: Colors.white,
                                    )
                                  : const Text(
                                      "Registrati",
                                      style: TextStyle(fontSize: 16),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Link alla login
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("Hai già un account? Accedi"),
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

  Future _signIn() async {
    if (!formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
      signInError = null;
    });

    try {
      final ruolo = kIsWeb ? "ente" : "cittadino";

      final response = await widget.authApi.signIn(
        utenteInput: UtenteInput(
          (b) => b
            ..nome = nameController.text
            ..cognome = cognomeController.text
            ..email = emailController.text
            ..password = passwordController.text
            ..paese = paeseController.text
            ..nazione = nazioneController.text
            ..ruolo = ruolo,
        ),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Registrazione completata! UserId: ${response.data?.id}",
          ),
        ),
      );

      Navigator.pop(context);
    } catch (ex) {
      ex as DioException;
      if (ex.response?.statusCode == 409) {
        final raw = ex.response?.data;
        Error? responseError;
        responseError = raw == null
            ? null
            : standardSerializers.deserialize(
                    raw,
                    specifiedType: const FullType(Error),
                  )
                  as Error;
        setState(() => signInError = "${responseError!.message}");
      } else {
        setState(() => signInError = "Errore durante la registrazione");
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }
}
