import 'package:flutter/material.dart';
import 'package:openapi/openapi.dart';

class DettaglioSegnalazionePage extends StatefulWidget {
  final UtentiApi utentiApi;
  final int userId;
  final int segnalazioneId;

  const DettaglioSegnalazionePage({
    super.key,
    required this.utentiApi,
    required this.userId,
    required this.segnalazioneId,
  });

  @override
  State<DettaglioSegnalazionePage> createState() =>
      _DettaglioSegnalazionePageState();
}

class _DettaglioSegnalazionePageState extends State<DettaglioSegnalazionePage> {
  late Future<SegnalazioneOutput?> futureSegnalazione;

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
    } catch (e) {
      print("Errore dettaglio: $e");
      return null;
    }
  }

  // -------------------------------------------------------------
  // CONVERSIONE ENUM STATO → STRINGA
  // -------------------------------------------------------------
  String statoToString(StatoEnum? stato) {
    if (stato == null) return "Sconosciuto";
    return stato.name; // OpenAPI enum → string
  }

  // -------------------------------------------------------------
  // COLORI STATO
  // -------------------------------------------------------------
  Color _statoColor(StatoEnum? stato) {
    switch (stato) {
      case StatoEnum.INSERITO:
        return Colors.orange;
      case StatoEnum.PRESO_IN_CARICO:
        return Colors.blue;
      case StatoEnum.SOSPESO:
        return Colors.green;
      case StatoEnum.CHIUSO:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // -------------------------------------------------------------
  // ICONE STATO
  // -------------------------------------------------------------
  IconData _statoIcon(StatoEnum? stato) {
    switch (stato) {
      case StatoEnum.INSERITO:
        return Icons.warning_rounded;
      case StatoEnum.PRESO_IN_CARICO:
        return Icons.build_rounded;
      case StatoEnum.SOSPESO:
        return Icons.pause_circle_rounded;
      case StatoEnum.CHIUSO:
        return Icons.check_circle_rounded;
      default:
        return Icons.info_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text(
          "Dettaglio Segnalazione",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: FutureBuilder<SegnalazioneOutput?>(
        future: futureSegnalazione,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.green),
            );
          }

          final segnalazione = snapshot.data;
          if (segnalazione == null) {
            return const Center(
              child: Text(
                "Impossibile caricare la segnalazione.",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.red,
                ),
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(18),
            children: [
              // -------------------------------------------------------------
              // CARD TITOLO + STATO
              // -------------------------------------------------------------
              Material(
                elevation: 2,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: colorScheme.surfaceContainerHighest,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        segnalazione.titolo ?? "Segnalazione",
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),

                      Row(
                        children: [
                          CircleAvatar(
                            radius: 14,
                            backgroundColor: _statoColor(
                              segnalazione.stato,
                            ).withOpacity(0.15),
                            child: Icon(
                              _statoIcon(segnalazione.stato),
                              color: _statoColor(segnalazione.stato),
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            statoToString(segnalazione.stato),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: _statoColor(segnalazione.stato),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // -------------------------------------------------------------
              // DESCRIZIONE
              // -------------------------------------------------------------
              Material(
                elevation: 2,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: colorScheme.surfaceContainerHighest,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Descrizione",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        segnalazione.descrizione ??
                            "Nessuna descrizione fornita.",
                        style: TextStyle(
                          fontSize: 16,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 25),

              // -------------------------------------------------------------
              // ENTE ASSOCIATO
              // -------------------------------------------------------------
              Material(
                elevation: 2,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: colorScheme.surfaceContainerHighest,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.business_rounded,
                        color: Colors.green.shade700,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Ente responsabile",
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              segnalazione.idEnte?.toString() ??
                                  "Nessun ente assegnato",
                              style: TextStyle(
                                fontSize: 15,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
