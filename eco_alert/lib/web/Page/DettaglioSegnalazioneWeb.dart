import 'package:flutter/material.dart';
import 'package:openapi/openapi.dart';
import 'package:dio/dio.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class DettaglioSegnalazioneWebPage extends StatefulWidget {
  final Dio dio;
  final UtentiApi utentiApi;
  final AuthApi authApi;
  final int userId;
  final int segnalazioneId;
  final SegnalazioniApi segnalazioniApi;
  final EntiApi entiApi;
  final CommentiApi commentiApi;
  final AllegatiApi allegatiApi;

  const DettaglioSegnalazioneWebPage({
    super.key,
    required this.utentiApi,
    required this.userId,
    required this.segnalazioneId,
    required this.dio,
    required this.authApi,
    required this.segnalazioniApi,
    required this.entiApi,
    required this.commentiApi,
    required this.allegatiApi,
  });

  @override
  State<DettaglioSegnalazioneWebPage> createState() =>
      _DettaglioSegnalazioneWebPageState();
}

class _DettaglioSegnalazioneWebPageState
    extends State<DettaglioSegnalazioneWebPage> {
  late Future<SegnalazioneOutput?> futureSegnalazione;

  StatoEnum? _statoSelezionato;
  final _dittaController = TextEditingController();
  final _commentoController = TextEditingController();
  bool _loadingComment = false;
  // ignore: unused_field
  bool _loadingAperturaAllegato = false;

  @override
  void initState() {
    super.initState();
    futureSegnalazione = _load();
  }

  Future<SegnalazioneOutput?> _load() async {
    final res = await widget.utentiApi.getSegnalazioneById(
      id: widget.userId,
      idSegnalazione: widget.segnalazioneId,
    );
    return res.data;
  }

  void _refreshSegnalazione() {
    setState(() {
      futureSegnalazione = _load();
    });
  }

  // ===== Commenti =====
  // Funzione per creare commento
  Future<void> _creaCommento() async {
    final testo = _commentoController.text.trim();
    if (testo.isEmpty) return;

    setState(() {
      _loadingComment = true;
    });

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
    } finally {
      if (mounted) {
        setState(() {
          _loadingComment = false;
        });
      }
    }
  }

  // Funzione per cancellare commento

  Future<void> _deleteCommento(int idCommento) async {
    try {
      await widget.commentiApi.deleteCommento(
        id: widget.userId, // se la tua API richiede userId
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

  // Funzione per aprire allegato
  Future<void> _apriAllegato(int idAllegato) async {
    setState(() {
      _loadingAperturaAllegato = true;
    });

    try {
      final response = await widget.allegatiApi.downloadAllegato(
        idAllegato: idAllegato,
      );

      showDialog(
        context: context,
        builder: (_) => Dialog(
          backgroundColor: Colors.black,
          insetPadding: const EdgeInsets.all(16),
          child: InteractiveViewer(
            child: Image.memory(response.data!, fit: BoxFit.contain),
          ),
        ),
      );
    } on DioException catch (ex) {
      int code = ex.response?.statusCode ?? 500;
      String message = "Errore durante il download dell'allegato";
      if (ex.response?.data is Map) {
        message = (ex.response!.data as Map)['message']?.toString() ?? message;
      }
      await _showErrorDialog("Errore $code: $message");
    } finally {
      if (mounted) {
        setState(() {
          _loadingAperturaAllegato = false;
        });
      }
    }
  }

  Future<void> _showErrorDialog(String message) async {
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Errore"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  // ================= MODIFICA =================

  Future<void> _modificaEnte(SegnalazioneOutput s) async {
    _statoSelezionato = s.stato;
    _dittaController.text = s.ditta ?? "";

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Aggiorna Segnalazione"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<StatoEnum>(
                value: _statoSelezionato,
                items: StatoEnum.values
                    .map(
                      (e) => DropdownMenuItem(
                        value: e,
                        child: Text(e.name.replaceAll("_", " ")),
                      ),
                    )
                    .toList(),
                onChanged: (v) => _statoSelezionato = v,
                decoration: const InputDecoration(labelText: "Stato"),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _dittaController,
                decoration: const InputDecoration(labelText: "Ditta"),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Annulla"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Salva"),
          ),
        ],
      ),
    );

    if (ok != true) return;

    await widget.segnalazioniApi.updateSegnalazioneEnte(
      idSegnalazione: widget.segnalazioneId,
      idEnte: s.idEnte!,
      segnalazioneUpdateInputEnte: SegnalazioneUpdateInputEnte(
        (b) => b
          ..stato = _statoSelezionato
          ..ditta = _dittaController.text.trim().isEmpty
              ? null
              : _dittaController.text,
      ),
    );

    // Chiudi la pagina e segnala alla home che serve refresh
    if (mounted) Navigator.of(context).pop(true);
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B3D35),
        title: const Text(
          "Dettaglio Segnalazione",
          style: TextStyle(color: Colors.white),
        ),
        leading: BackButton(color: Colors.white),
      ),
      body: Stack(
        children: [
          // ===== BACKGROUND =====
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0B3D35), Color(0xFF0A4A40)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // ===== CONTENUTO SCROLLABILE =====
          SafeArea(
            child: FutureBuilder<SegnalazioneOutput?>(
              future: futureSegnalazione,
              builder: (_, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.green),
                  );
                }

                final s = snapshot.data;
                if (s == null) {
                  return const Center(
                    child: Text(
                      "Segnalazione non trovata",
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 720),
                      child: _card(s),
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

  // ===== UI CARD =====
  Widget _card(SegnalazioneOutput s) {
    return Container(
      padding: const EdgeInsets.all(36),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _header(s),
          const SizedBox(height: 32),

          /// ===== CONTENUTO ORIZZONTALE =====
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// ===== MAPPA A SINISTRA =====
              if (s.latitudine != null && s.longitudine != null)
                Expanded(flex: 4, child: _mappa(s.latitudine!, s.longitudine!)),

              const SizedBox(width: 32),

              /// ===== INFO + COMMENTI A DESTRA =====
              Expanded(flex: 6, child: _infoECommenti(s)),
            ],
          ),

          const SizedBox(height: 32),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.edit),
              label: const Text("Aggiorna stato"),
              onPressed: () => _modificaEnte(s),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00BFA5),
                foregroundColor: const Color(0xFF00332F),
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoECommenti(SegnalazioneOutput s) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _section("Descrizione", s.descrizione ?? "Nessuna descrizione"),

        if (s.ditta != null && s.ditta!.isNotEmpty)
          _section("Ditta assegnata", s.ditta!),

        const SizedBox(height: 24),

        /// ===== COMMENTI =====
        if (s.commenti != null && s.commenti!.isNotEmpty)
          _sectionWidget(
            "Commenti",
            Column(
              children: s.commenti!.map((c) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        "- ${c.descrizione}",
                        style: const TextStyle(
                          color: Colors.white70,
                          height: 1.5,
                        ),
                      ),
                    ),
                    if (c.idUtente == widget.userId)
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.redAccent),
                        onPressed: () => _deleteCommento(c.id!),
                      ),
                  ],
                );
              }).toList(),
            ),
          ),

        const SizedBox(height: 16),

        _sectionWidget(
          "Aggiungi un commento",
          Column(
            children: [
              TextField(
                controller: _commentoController,
                decoration: const InputDecoration(
                  hintText: "Scrivi un commento...",
                  hintStyle: TextStyle(color: Colors.white70),
                  border: OutlineInputBorder(),
                ),
                style: const TextStyle(color: Colors.white),
                maxLines: 2,
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: _loadingComment ? null : _creaCommento,
                  child: _loadingComment
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text("Invia"),
                ),
              ),
            ],
          ),
        ),

        if (s.allegati != null && s.allegati!.isNotEmpty)
          _sectionWidget(
            "Allegati",
            Column(
              children: s.allegati!.map((c) {
                return Card(
                  color: Colors.grey.shade900,
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () {
                      // esempio: apri immagine
                      _apriAllegato(c.id!);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.image, color: Colors.white70),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              c.nomeFile ?? 'Allegato',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          if (s.idUtente == widget.userId)
                            IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.redAccent,
                              ),
                              onPressed: () => _deleteCommento(c.id!),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  Widget _header(SegnalazioneOutput s) => Row(
    children: [
      CircleAvatar(
        radius: 26,
        backgroundColor: _statoColor(s.stato),
        child: Icon(_statoIcon(s.stato), color: Colors.black),
      ),
      const SizedBox(width: 16),
      Expanded(
        child: Text(
          s.titolo ?? "Segnalazione",
          style: GoogleFonts.manrope(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    ],
  );

  Widget _section(String title, String body) => Padding(
    padding: const EdgeInsets.only(top: 24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.manrope(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(body, style: const TextStyle(color: Colors.white70, height: 1.6)),
      ],
    ),
  );

  Widget _sectionWidget(String title, Widget child) => Padding(
    padding: const EdgeInsets.only(top: 24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.manrope(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        child,
      ],
    ),
  );

  Widget _mappa(double lat, double lon) => ClipRRect(
    borderRadius: BorderRadius.circular(18),
    child: SizedBox(
      height: 260,
      child: FlutterMap(
        options: MapOptions(initialCenter: LatLng(lat, lon), initialZoom: 15),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.app',
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: LatLng(lat, lon),
                width: 50,
                height: 50,
                child: const Icon(
                  Icons.location_on_rounded,
                  color: Color(0xFF00BFA5),
                  size: 46,
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );

  Color _statoColor(StatoEnum? s) {
    switch (s) {
      case StatoEnum.INSERITO:
        return Colors.greenAccent;
      case StatoEnum.RICEVUTO:
        return Colors.blueAccent;
      case StatoEnum.SOSPESO:
        return Colors.orangeAccent;
      case StatoEnum.CHIUSO:
        return Colors.redAccent;
      default:
        return Colors.grey;
    }
  }

  IconData _statoIcon(StatoEnum? s) {
    switch (s) {
      case StatoEnum.INSERITO:
        return Icons.new_releases_rounded;
      case StatoEnum.RICEVUTO:
        return Icons.work_rounded;
      case StatoEnum.SOSPESO:
        return Icons.pause_circle_filled_rounded;
      case StatoEnum.CHIUSO:
        return Icons.check_circle_rounded;
      default:
        return Icons.help_outline;
    }
  }
}
