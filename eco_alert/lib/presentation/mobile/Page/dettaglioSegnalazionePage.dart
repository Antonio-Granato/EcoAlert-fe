import 'package:flutter/material.dart';
import 'package:openapi/openapi.dart';
import 'package:dio/dio.dart';

class DettaglioSegnalazionePage extends StatefulWidget {
  final UtentiApi utentiApi;
  final AuthApi authApi;
  final Dio dio;
  final int userId;
  final int segnalazioneId;
  final SegnalazioniApi segnalazioniApi;
  final EntiApi entiApi;
  final CommentiApi commentiApi;

  const DettaglioSegnalazionePage({
    super.key,
    required this.utentiApi,
    required this.userId,
    required this.segnalazioneId,
    required this.dio,
    required this.authApi,
    required this.segnalazioniApi,
    required this.entiApi,
    required this.commentiApi,
  });

  @override
  State<DettaglioSegnalazionePage> createState() =>
      _DettaglioSegnalazionePageState();
}

class _DettaglioSegnalazionePageState extends State<DettaglioSegnalazionePage> {
  late Future<SegnalazioneOutput?> futureSegnalazione;
  Error? error;

  final TextEditingController _commentoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _refreshSegnalazione();
  }

  void _refreshSegnalazione() {
    setState(() {
      futureSegnalazione = _loadDettaglio();
    });
  }

  Future<SegnalazioneOutput?> _loadDettaglio() async {
    try {
      final res = await widget.utentiApi.getSegnalazioneById(
        id: widget.userId,
        idSegnalazione: widget.segnalazioneId,
      );

      if (res.data == null) {
        setState(() {
          error = Error(
            (b) => b
              ..code = 404
              ..message = "Segnalazione non trovata.",
          );
        });
        return null;
      }

      setState(() => error = null);
      return res.data!;
    } on DioException catch (ex) {
      int code = ex.response?.statusCode ?? 0;
      String msg = "Errore durante il caricamento della segnalazione";
      if (ex.response?.data is Map) {
        msg = (ex.response!.data as Map)['message']?.toString() ?? msg;
      }
      setState(() {
        error = Error(
          (b) => b
            ..code = code
            ..message = msg,
        );
      });
      return null;
    } catch (_) {
      setState(() {
        error = Error((b) => b..message = "Errore imprevisto. Riprova.");
      });
      return null;
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

  // ========= Commenti =========
  Future<void> _creaCommento() async {
    final testo = _commentoController.text.trim();
    if (testo.isEmpty) return;

    try {
      final input = CommentoInput((b) => b..descrizione = testo);

      await widget.commentiApi.createCommento(
        id: widget.userId,
        idSegnalazione: widget.segnalazioneId,
        commentoInput: input,
      );

      _commentoController.clear();
      _refreshSegnalazione();
    } on DioException catch (ex) {
      int code = ex.response?.statusCode ?? 500;
      String message = "Errore durante la creazione del commento";
      if (ex.response?.data is Map) {
        message = (ex.response!.data as Map)['message']?.toString() ?? message;
      }
      await _showErrorDialog("Errore $code: $message");
    }
  }

  Future<void> _deleteCommento(int idCommento) async {
    try {
      await widget.commentiApi.deleteCommento(
        id: widget.userId,
        idSegnalazione: widget.segnalazioneId,
        idCommento: idCommento,
      );
      _refreshSegnalazione();
    } on DioException catch (ex) {
      int code = ex.response?.statusCode ?? 500;
      String message = "Errore durante l'eliminazione del commento";
      if (ex.response?.data is Map) {
        message = (ex.response!.data as Map)['message']?.toString() ?? message;
      }
      await _showErrorDialog("Errore $code: $message");
    }
  }

  // ========= Elimina segnalazione =========
  Future<void> _deleteSegnalazione() async {
    final conferma = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Conferma eliminazione"),
        content: const Text(
          "Vuoi davvero eliminare questa segnalazione? L'operazione è irreversibile.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Annulla"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Elimina"),
          ),
        ],
      ),
    );

    if (conferma != true) return;

    try {
      await widget.segnalazioniApi.deleteSegnalazione(
        id: widget.userId,
        idSegnalazione: widget.segnalazioneId,
      );

      if (!mounted) return;
      Navigator.pop(context, true); // Torna a HomePage e trigger refresh
    } on DioException catch (ex) {
      int code = ex.response?.statusCode ?? 500;
      String message = "Errore durante l'eliminazione della segnalazione";
      if (ex.response?.data is Map) {
        message = (ex.response!.data as Map)['message']?.toString() ?? message;
      }
      await _showErrorDialog("Errore $code: $message");
    }
  }

  // ========= Badge stato =========
  String _statoToString(StatoEnum? stato) =>
      stato?.name.replaceAll("_", " ").toUpperCase() ?? "SCONOSCIUTO";

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
      backgroundColor: Colors.green.shade50,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 30, 78, 33),
        title: const Text(
          "Dettaglio Segnalazione",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _deleteSegnalazione,
        backgroundColor: Colors.red.shade700,
        icon: const Icon(Icons.delete),
        foregroundColor: Colors.white,
        label: const Text(
          "Elimina Segnalazione",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
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
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 22,
                                  backgroundColor: _badgeColor(
                                    segnalazione.stato,
                                  ).withOpacity(0.3),
                                  child: Icon(
                                    _statoIcon(segnalazione.stato),
                                    color: Colors.black,
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
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              segnalazione.descrizione ??
                                  "Nessuna descrizione fornita",
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 16),
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
                                (c) => Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        "- ${c.descrizione}",
                                        style: const TextStyle(fontSize: 15),
                                      ),
                                    ),
                                    if (c.idUtente == widget.userId)
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                        ),
                                        onPressed: () => _deleteCommento(c.id!),
                                      ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],
                            const Text(
                              "Aggiungi un commento",
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _commentoController,
                              decoration: InputDecoration(
                                hintText: "Scrivi un commento...",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              maxLines: 2,
                            ),
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerRight,
                              child: ElevatedButton(
                                onPressed: _creaCommento,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color.fromARGB(
                                    255,
                                    30,
                                    78,
                                    33,
                                  ),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text("Invia"),
                              ),
                            ),
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
