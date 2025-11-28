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
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text(
          "Profilo Utente",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<UtenteDettaglioOutput?>(
        future: _loadUser(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.green),
            );
          }

          if (snapshot.hasError) {
            return _errorMessage("Errore nel caricamento del profilo");
          }

          final utente = snapshot.data;
          if (utente == null) {
            return _errorMessage("Utente non trovato");
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _profileHeader(utente),
                const SizedBox(height: 20),
                _infoCard(utente),
              ],
            ),
          );
        },
      ),
    );
  }

  // --- HEADER PROFILO (avatar + nome)
  Widget _profileHeader(UtenteDettaglioOutput utente) {
    return Column(
      children: [
        CircleAvatar(
          radius: 55,
          backgroundColor: Colors.green.shade300,
          child: Text(
            (utente.nome?.isNotEmpty ?? false)
                ? utente.nome![0].toUpperCase()
                : "?",
            style: const TextStyle(
              fontSize: 42,
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 15),
        Text(
          "${utente.nome ?? ""} ${utente.cognome ?? ""}".trim(),
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  // --- CARD INFO UTENTE
  Widget _infoCard(UtenteDettaglioOutput utente) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            _infoRow(Icons.email, "Email", utente.email),
            const Divider(),
            _infoRow(Icons.person_outline, "Nome", utente.nome),
            const Divider(),
            _infoRow(Icons.person, "Cognome", utente.cognome),
            const Divider(),
            _infoRow(Icons.location_on, "Paese", utente.paese),
            const Divider(),
            _infoRow(Icons.flag, "Nazione", utente.nazione),
          ],
        ),
      ),
    );
  }

  // --- RIGA INFORMATIVA STILIZZATA
  Widget _infoRow(IconData icon, String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.green, size: 26),
          const SizedBox(width: 12),

          // LABEL fissa → evita overflow
          SizedBox(
            width: 90,
            child: Text(
              "$label:",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),

          // Valore flessibile → no overflow
          Expanded(
            child: Text(
              value ?? "-",
              softWrap: true,
              overflow: TextOverflow.visible,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  // --- MESSAGGIO DI ERRORE
  Widget _errorMessage(String text) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 18,
            color: Colors.red,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
