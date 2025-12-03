import 'package:flutter/material.dart';
import 'package:openapi/openapi.dart';
import 'package:dio/dio.dart';
import 'package:eco_alert/presentation/mobile/Page/welcomePage.dart';

class DettaglioSegnalazionePage extends StatefulWidget {
  final UtentiApi utentiApi;
  final AuthApi authApi;
  final Dio dio;
  final int userId;
  final int segnalazioneId;

  const DettaglioSegnalazionePage({
    super.key,
    required this.utentiApi,
    required this.userId,
    required this.segnalazioneId,
    required this.dio,
    required this.authApi,
  });

  @override
  State<DettaglioSegnalazionePage> createState() =>
      _DettaglioSegnalazionePageState();
}

class _DettaglioSegnalazionePageState extends State<DettaglioSegnalazionePage> {
  late Future<SegnalazioneOutput?> futureSegnalazione;

  Error? error;

  @override
  void initState() {
    super.initState();
    futureSegnalazione = _loadDettaglio();
  }

  Future<SegnalazioneOutput?> _loadDettaglio() async {
    try {
      final res = await widget.utentiApi.getSegnalazioneById(
        id: widget.userId,
        idSegnalazione: widget.segnalazioneId,
      );

      return res.data;
    } on DioException catch (ex) {
      int code = ex.response?.statusCode ?? 500;
      String message = "Errore durante il caricamento";

      // Ottieni messaggio dalla API se presente
      if (ex.response?.data is Map) {
        message = (ex.response!.data as Map)['message']?.toString() ?? message;
      }

      // redirect solo se è realmente 500
      if (code == 500) {
        Error((b) => b..message = "Errore del server. Riprova più tardi.");
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (_) => WelcomePage(
                authApi: widget.authApi, // riusa quello esistente
                utentiApi: widget.utentiApi,
                dio: widget.dio,
              ),
            ),
            (route) => false,
          );
        }
        return null;
      }

      // Errori previsti dalla OpenAPI:
      // 400, 401, 404
      setState(() {
        error = Error(
          (b) => b
            ..code = code
            ..message = message,
        );
      });

      return null;
    } catch (e) {
      setState(() {
        error = Error(
          (b) => b
            ..code = 500
            ..message = "Errore imprevisto",
        );
      });
      return null;
    }
  }

  // ----- Utility UI Stato -----
  String _statoToString(StatoEnum? stato) {
    if (stato == null) return "Sconosciuto";
    return stato.name.replaceAll("_", " ").toUpperCase();
  }

  Color _badgeColor(StatoEnum? stato) {
    switch (stato) {
      case StatoEnum.INSERITO:
        return Colors.green.shade100;
      case StatoEnum.PRESO_IN_CARICO:
        return Colors.blue.shade100;
      case StatoEnum.SOSPESO:
        return Colors.yellow.shade100;
      case StatoEnum.CHIUSO:
        return Colors.red.shade300;
      default:
        return Colors.grey.shade100;
    }
  }

  Color _badgeTextColor(StatoEnum? stato) {
    switch (stato) {
      case StatoEnum.INSERITO:
        return Colors.black;
      case StatoEnum.PRESO_IN_CARICO:
        return Colors.black;
      case StatoEnum.SOSPESO:
        return Colors.black;
      case StatoEnum.CHIUSO:
        return Colors.black;
      default:
        return Colors.black;
    }
  }

  IconData _statoIcon(StatoEnum? stato) {
    switch (stato) {
      case StatoEnum.INSERITO:
        return Icons.fiber_new_rounded;
      case StatoEnum.PRESO_IN_CARICO:
        return Icons.work_rounded;
      case StatoEnum.SOSPESO:
        return Icons.pause_circle_filled_rounded;
      case StatoEnum.CHIUSO:
        return Icons.check_circle_rounded;
      default:
        return Icons.help_outline;
    }
  }

  // ---- BUILD ----
  @override
  Widget build(BuildContext context) {
    final gradientColors = [
      const Color(0xFFe0f2f1),
      const Color(0xFFb2dfdb),
      const Color(0xFF80cbc4),
    ];

    return Scaffold(
      backgroundColor: Colors.green.shade50,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 30, 78, 33),
        title: const Text(
          "Dettaglio Segnalazione",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),

      body: Stack(
        children: [
          // Sfondo gradient full screen
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // Contenuto principale sopra il gradient
          SafeArea(
            child: FutureBuilder<SegnalazioneOutput?>(
              future: futureSegnalazione,
              builder: (context, snapshot) {
                if (error != null) {
                  return Center(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red.shade600,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        "Errore ${error!.code}: ${error!.message}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.green),
                  );
                }

                final segnalazione = snapshot.data;

                if (segnalazione == null) {
                  return const Center(
                    child: Text(
                      "Segnalazione non trovata.",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  );
                }

                // ---- UI SEGNALAZIONE ----

                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Material(
                    elevation: 6,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ---- Header Stato ----
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 22,
                                  backgroundColor: _badgeColor(
                                    segnalazione.stato,
                                  ).withOpacity(0.3),
                                  child: Icon(
                                    _statoIcon(segnalazione.stato),
                                    color: _badgeTextColor(segnalazione.stato),
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        segnalazione.titolo ?? "Segnalazione",
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: _badgeColor(
                                            segnalazione.stato,
                                          ).withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Text(
                                          _statoToString(segnalazione.stato),
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color: _badgeTextColor(
                                              segnalazione.stato,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),

                            // ---- Descrizione ----
                            Text(
                              segnalazione.descrizione ??
                                  "Nessuna descrizione fornita",
                              style: const TextStyle(fontSize: 16),
                            ),

                            const SizedBox(height: 16),

                            // ---- Ente e Ditta ----
                            Row(
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.business_rounded,
                                        color: Colors.green.shade700,
                                      ),
                                      const SizedBox(width: 6),
                                      Flexible(
                                        child: Text(
                                          segnalazione.idEnte?.toString() ??
                                              "Nessun ente",
                                          style: const TextStyle(fontSize: 15),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.apartment_rounded,
                                        color: Colors.blue.shade700,
                                      ),
                                      const SizedBox(width: 6),
                                      Flexible(
                                        child: Text(
                                          segnalazione.ditta ?? "Nessuna ditta",
                                          style: const TextStyle(fontSize: 15),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),

                            // ---- Commenti ----
                            if (segnalazione.commenti != null &&
                                segnalazione.commenti!.isNotEmpty) ...[
                              const Text(
                                "Commenti",
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              ...segnalazione.commenti!.map(
                                (c) => Padding(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  child: Text(
                                    "- ${c.descrizione}",
                                    style: const TextStyle(fontSize: 15),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
