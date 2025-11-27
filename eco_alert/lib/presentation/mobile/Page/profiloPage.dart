import 'package:flutter/material.dart';
import 'package:openapi/openapi.dart';
import 'package:dio/dio.dart';

class profiloPage extends StatelessWidget {
  final Dio dio;
  final UtentiApi utentiApi;
  final int userId;

  const profiloPage({
    super.key,
    required this.utentiApi,
    required this.userId,
    required this.dio,
  });

  Future<UtenteDettaglioOutput?> _loadUser() async {
    try {
      final res = await utentiApi.getUserById(id: userId);
      return res.data;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return null;
      }
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text(
          "Profilo Utente",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: FutureBuilder<UtenteDettaglioOutput?>(
        future: _loadUser(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.green,
                strokeWidth: 3,
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Errore nel caricamento del profilo:\n${snapshot.error}",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.red.shade700),
              ),
            );
          }

          final utente = snapshot.data;

          if (utente == null) {
            return const Center(
              child: Text(
                "Utente non trovato",
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Avatar utente
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.green.shade200,
                  child: Text(
                    (utente.nome?.isNotEmpty ?? false)
                        ? utente.nome![0].toUpperCase()
                        : "?",
                    style: const TextStyle(
                      fontSize: 40,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Card informazioni
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _infoRow(Icons.person, "Nome", utente.nome),
                        const Divider(),
                        _infoRow(
                          Icons.person_outline,
                          "Cognome",
                          utente.cognome,
                        ),
                        const Divider(),
                        _infoRow(Icons.email, "Email", utente.email),
                        const Divider(),
                        _infoRow(Icons.location_on, "Paese", utente.paese),
                        const Divider(),
                        _infoRow(Icons.flag, "Nazione", utente.nazione),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: Colors.green),
          const SizedBox(width: 12),
          Text(
            "$label: ",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Expanded(
            child: Text(
              value ?? "-",
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
