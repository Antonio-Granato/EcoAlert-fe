import 'package:flutter/material.dart';
import 'package:openapi/openapi.dart';
import 'package:dio/dio.dart';
import 'package:eco_alert/presentation/mobile/Page/welcomePage.dart';

class profiloPage extends StatefulWidget {
  final Dio dio;
  final UtentiApi utentiApi;
  final AuthApi authApi;
  final int userId;
  final SegnalazioniApi segnalazioniApi;
  final EntiApi entiApi;
  final CommentiApi commentiApi;

  const profiloPage({
    super.key,
    required this.utentiApi,
    required this.userId,
    required this.dio,
    required this.authApi,
    required this.segnalazioniApi,
    required this.entiApi,
    required this.commentiApi,
  });

  @override
  State<profiloPage> createState() => _profiloPageState();
}

class _profiloPageState extends State<profiloPage> {
  late Future<UtenteDettaglioOutput?> futureUser;

  @override
  void initState() {
    super.initState();
    futureUser = _loadUser();
  }

  Future<UtenteDettaglioOutput?> _loadUser() async {
    try {
      final res = await widget.utentiApi.getUserById(id: widget.userId);
      return res.data;
    } on DioException catch (e) {
      // Gestione 404 e 500 come errori critici
      if (e.response != null &&
          (e.response!.statusCode == 404 || e.response!.statusCode == 500)) {
        await _showErrorDialog(
          "Utente non trovato o errore del server. Riprova più tardi.",
        );
        _redirectToWelcome();
        return null;
      }
      // Altri errori generici
      await _showErrorDialog(
        "Errore imprevisto: ${e.response?.statusCode ?? e.message}",
      );
      _redirectToWelcome();
      return null;
    } catch (_) {
      await _showErrorDialog("Errore imprevisto.");
      _redirectToWelcome();
      return null;
    }
  }

  void _redirectToWelcome() {
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => WelcomePage(
            authApi: widget.authApi,
            utentiApi: widget.utentiApi,
            dio: widget.dio,
            segnalazioniApi: widget.segnalazioniApi,
            entiApi: widget.entiApi,
            commentiApi: widget.commentiApi,
          ),
        ),
        (route) => false,
      );
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

  @override
  Widget build(BuildContext context) {
    final backgroundColors = [
      const Color(0xFFe0f2f1),
      const Color(0xFFb2dfdb),
      const Color(0xFF80cbc4),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 30, 78, 33),
        title: const Text(
          "Profilo Utente",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: backgroundColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          SafeArea(
            child: FutureBuilder<UtenteDettaglioOutput?>(
              future: futureUser,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.green),
                  );
                }

                final utente = snapshot.data;
                if (utente == null)
                  return const SizedBox(); // Se errore già gestito con dialog

                return LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          color: Colors.transparent,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              _profileHeader(utente),
                              const SizedBox(height: 20),
                              _infoCard(utente),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

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

  Widget _infoRow(IconData icon, String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.green, size: 26),
          const SizedBox(width: 12),
          SizedBox(
            width: 90,
            child: Text(
              "$label:",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
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
}
