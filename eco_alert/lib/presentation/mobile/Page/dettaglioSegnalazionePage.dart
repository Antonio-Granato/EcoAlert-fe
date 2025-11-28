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

  String _statoToString(StatoEnum? stato) {
    if (stato == null) return "Sconosciuto";
    return stato.name.replaceAll("_", " ").toUpperCase();
  }

  Color _badgeColor(StatoEnum? stato) {
    switch (stato) {
      case StatoEnum.INSERITO:
        return Colors.orange.shade100;
      case StatoEnum.PRESO_IN_CARICO:
        return Colors.blue.shade100;
      case StatoEnum.SOSPESO:
        return Colors.green.shade100;
      case StatoEnum.CHIUSO:
        return Colors.grey.shade300;
      default:
        return Colors.red.shade100;
    }
  }

  Color _badgeTextColor(StatoEnum? stato) {
    switch (stato) {
      case StatoEnum.INSERITO:
        return Colors.green;
      case StatoEnum.PRESO_IN_CARICO:
        return Colors.blue;
      case StatoEnum.SOSPESO:
        return Colors.yellow.shade700;
      case StatoEnum.CHIUSO:
        return Colors.red;
      default:
        return Colors.grey;
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

  @override
  Widget build(BuildContext context) {
    final gradientColors = [
      const Color(0xFFe0f2f1),
      const Color(0xFFb2dfdb),
      const Color(0xFF80cbc4),
    ];

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.green.shade700,
        title: const Text(
          "Dettaglio Segnalazione",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: FutureBuilder<SegnalazioneOutput?>(
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Titolo + stato
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
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                                      borderRadius: BorderRadius.circular(12),
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

                        // Descrizione
                        Text(
                          segnalazione.descrizione ??
                              "Nessuna descrizione fornita",
                          style: const TextStyle(fontSize: 16),
                        ),

                        const SizedBox(height: 16),

                        // Ente e ditta
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

                        // Commenti
                        if (segnalazione.commenti != null &&
                            segnalazione.commenti!.isNotEmpty)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
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
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
