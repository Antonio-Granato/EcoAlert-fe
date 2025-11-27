import 'package:flutter/material.dart';
import 'loginPage.dart';
import 'signInPage.dart';
import 'package:openapi/openapi.dart';
import 'package:dio/dio.dart';

class WelcomePage extends StatelessWidget {
  final AuthApi authApi;
  final UtentiApi utentiApi;
  final Dio dio;
  const WelcomePage({
    super.key,
    required this.authApi,
    required this.utentiApi,
    required this.dio,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade50, // colore chiaro e soft
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Container(
                width: 120,
                height: 120,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/ECO.jpg'),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Titolo
              const Text(
                "EcoAlert",
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 12),

              // Messaggio breve
              const Text(
                "Segnala problemi ambientali nella tua città",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.black87),
              ),
              const SizedBox(height: 36),

              // Pulsante Accedi
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => LoginPage(
                          authApi: authApi,
                          utentiApi: utentiApi,
                          dio: dio,
                        ),
                      ),
                    );
                  },
                  child: const Text(
                    "Accedi",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Pulsante Registrati
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.green),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SignInPage(authApi: authApi),
                      ),
                    );
                  },
                  child: const Text(
                    "Registrati",
                    style: TextStyle(fontSize: 16, color: Colors.green),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
