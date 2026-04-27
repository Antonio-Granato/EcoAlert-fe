import 'package:flutter/material.dart';
import 'package:openapi/openapi.dart';
import 'package:dio/dio.dart';
import 'welcomePage.dart';

class profiloPage extends StatefulWidget {
  final Dio dio;
  final UtentiApi utentiApi;
  final AuthApi authApi;
  final SegnalazioniApi segnalazioniApi;
  final EntiApi entiApi;
  final CommentiApi commentiApi;
  final AllegatiApi allegatiApi;

  const profiloPage({
    super.key,
    required this.utentiApi,
    required this.dio,
    required this.authApi,
    required this.segnalazioniApi,
    required this.entiApi,
    required this.commentiApi,
    required this.allegatiApi,
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
      final res = await widget.utentiApi.getMe();
      return res.data;
    } on DioException catch (e) {
      // Gestione 404 e 500 come errori critici

      // JWT SCADUTO / NON VALIDO
      if (e.response?.statusCode == 401) {
        await _showErrorDialog("Sessione scaduta. Effettua di nuovo il login.");
        _redirectToWelcome();
        return null;
      }

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
            allegatiApi: widget.allegatiApi,
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
    return Scaffold(
      body: Stack(
        children: [
          // 🔹 STESSO GRADIENT DELLA HOME
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF0F2F2B),
                  Color(0xFF0B3D35),
                  Color(0xFF083A33),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          SafeArea(
            child: FutureBuilder<UtenteDettaglioOutput?>(
              future: futureUser,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 3,
                    ),
                  );
                }

                final utente = snapshot.data;
                if (utente == null)
                  return const SizedBox(); // Se errore già gestito con dialog

                return LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 30,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _header(context),
                          const SizedBox(height: 30),
                          _profileHeader(utente),
                          const SizedBox(height: 20),
                          _infoCard(utente),
                        ],
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

  Future<void> _confirmDeleteUser() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Conferma eliminazione"),
        content: const Text(
          "Sei sicuro di voler eliminare il tuo account?\nQuesta azione è irreversibile.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Annulla"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Elimina", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _deleteUser();
    }
  }

  Future<void> _deleteUser() async {
    try {
      await widget.utentiApi.deleteUser();

      if (!mounted) return;

      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.green.shade50,
          title: const Text(
            "Account eliminato",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text("Il tuo account è stato eliminato con successo."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        ),
      );

      _redirectToWelcome();
    } on DioException catch (e) {
      final status = e.response?.statusCode;

      if (status == 401) {
        await _showErrorDialog("Sessione scaduta. Effettua di nuovo il login.");
        _redirectToWelcome();
        return;
      }

      String message = "Errore durante l'eliminazione";

      if (e.response?.data is Map<String, dynamic>) {
        message =
            (e.response?.data as Map<String, dynamic>)["message"]?.toString() ??
            message;
      }

      await _showErrorDialog(message);
    } catch (_) {
      await _showErrorDialog("Errore imprevisto durante l'eliminazione.");
    }
  }

  Widget _header(BuildContext context) {
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(14),
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white70),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        const SizedBox(width: 16),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Profilo",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 4),
              Text(
                "Le tue informazioni personali",
                style: TextStyle(fontSize: 14, color: Colors.white70),
              ),
            ],
          ),
        ),
        // Menu tre puntini
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Colors.white),
          onSelected: (value) {
            if (value == 'delete') {
              _confirmDeleteUser();
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'delete',
              child: Text('Elimina account'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _profileHeader(UtenteDettaglioOutput utente) {
    return Center(
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 55,
              backgroundColor: Colors.white.withOpacity(0.1),
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
          ),
          const SizedBox(height: 20),
          Text(
            "${utente.nome ?? ""} ${utente.cognome ?? ""}".trim(),
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoCard(UtenteDettaglioOutput utente) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 25,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          _infoRow(Icons.person, "Cognome", utente.cognome),
          const SizedBox(height: 16),
          _infoRow(Icons.person_outline, "Nome", utente.nome),
          const SizedBox(height: 16),
          _infoRow(Icons.flag, "Città", utente.citta),
          const SizedBox(height: 16),
          _infoRow(Icons.person, "Codice Fiscale", utente.codiceFiscale),
          const SizedBox(height: 16),
          _infoRow(Icons.email, "Email", utente.email),
          const SizedBox(height: 16),
          _infoRow(Icons.phone, "Numero di telefono", utente.numeroTelefono),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String? value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.white70, size: 22),
        const SizedBox(width: 12),
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.white70,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value ?? "-",
            style: const TextStyle(fontSize: 15, color: Colors.white),
          ),
        ),
      ],
    );
  }
}
