import 'package:flutter/material.dart';
import 'package:openapi/openapi.dart';
import 'package:dio/dio.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:ui';
import 'dart:math';

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
    final res = await widget.segnalazioniApi.getSegnalazioneById(
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
          backgroundColor: Colors.white,
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
      body: Stack(
        children: [
          // Base verde scuro elegante
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0B3D35), // verde profondo
                  Color(0xFF0F4F45), // leggermente più chiaro
                  Color(0xFF08332C), // profondità
                ],
              ),
            ),
          ),

          // Glow soft superiore
          Positioned(
            top: -250,
            left: -200,
            child: Container(
              width: 600,
              height: 600,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.greenAccent.withOpacity(0.12),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Glow inferiore
          Positioned(
            bottom: -300,
            right: -250,
            child: Container(
              width: 700,
              height: 700,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.tealAccent.withOpacity(0.10),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1600),
                child: FutureBuilder<SegnalazioneOutput?>(
                  future: futureSegnalazione,
                  builder: (_, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final s = snapshot.data!;
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 22,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _topBar(s),
                          const SizedBox(height: 40),
                          Expanded(
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                if (constraints.maxWidth < 1000) {
                                  return Column(
                                    children: [
                                      _mainGlass(s),
                                      const SizedBox(height: 24),
                                      _sideGlass(s),
                                    ],
                                  );
                                }
                                return Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(flex: 8, child: _mainGlass(s)),
                                    const SizedBox(width: 32),
                                    Expanded(flex: 4, child: _sideGlass(s)),
                                  ],
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _topBar(SegnalazioneOutput s) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            s.titolo ?? "Segnalazione",
            style: GoogleFonts.manrope(
              fontSize: 34,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Colors.white),
          color: const Color(0xFF0F4F45),
          onSelected: (value) {
            if (value == "modifica") {
              _modificaEnte(s);
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: "modifica",
              child: Text("Modifica", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _glassContainer({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.03),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white.withOpacity(0.06)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 30,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _mainGlass(SegnalazioneOutput s) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle("Descrizione:"),
          const SizedBox(height: 12),
          _glassContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s.descrizione ?? "Nessuna descrizione",
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.6,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          _commentiGlass(s),
          const SizedBox(height: 40),
          _allegatiGlass(s),
        ],
      ),
    );
  }

  Widget _commentiGlass(SegnalazioneOutput s) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle("Commenti:"),
        const SizedBox(height: 18),

        // main container for comments
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.02),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.04)),
          ),
          child: Column(
            children: [
              if (s.commenti == null || s.commenti!.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 18),
                  child: Text(
                    "Nessun commento",
                    style: TextStyle(color: Color(0xFF8E8E93)),
                  ),
                ),

              if (s.commenti != null)
                ...s.commenti!.map(
                  (c) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _commentItem(c),
                  ),
                ),

              const SizedBox(height: 8),
              _commentInput(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _commentItem(CommentoOutput c) {
    final isEnte = c.nomeEnte != null && c.nomeEnte!.isNotEmpty;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // left accent for ente comments
          Container(
            width: 6,
            height: 72,
            decoration: BoxDecoration(
              color: isEnte
                  ? Colors.greenAccent.withOpacity(0.9)
                  : Colors.transparent,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                bottomLeft: Radius.circular(10),
              ),
            ),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.02),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.03)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.white.withOpacity(0.06),
                    child: Text(
                      (c.nome?.isNotEmpty == true)
                          ? c.nome![0].toUpperCase()
                          : (c.nomeEnte?.isNotEmpty == true
                                ? c.nomeEnte![0].toUpperCase()
                                : '?'),
                      style: const TextStyle(
                        height: 1.0,
                        color: Colors.white70,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              "${c.nome ?? ""} ${c.cognome ?? ""}",
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            if (isEnte) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade50.withOpacity(0.06),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'Ente',
                                  style: TextStyle(
                                    color: Colors.green.shade200,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                            const Spacer(),
                            if (c.dataCommento != null)
                              Text(
                                _formatDate(c.dataCommento!),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF8E8E93),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          c.descrizione ?? "",
                          style: const TextStyle(
                            height: 1.6,
                            color: Color(0xFFF5F5F7),
                          ),
                        ),
                      ],
                    ),
                  ),

                  if (c.idUtente == widget.userId)
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      color: Colors.redAccent,
                      onPressed: () => _deleteCommento(c.id!),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _commentInput() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          TextField(
            style: const TextStyle(color: Colors.white),
            controller: _commentoController,
            decoration: const InputDecoration(
              hintText: "Scrivi un commento...",
              border: InputBorder.none,
              hintStyle: TextStyle(color: Colors.white),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: _loadingComment ? null : _creaCommento,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 0, 116, 44),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
              ),
              child: _loadingComment
                  ? const SizedBox(
                      width: 18,
                      height: 18,
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
    );
  }

  Widget _allegatiGlass(SegnalazioneOutput s) {
    if (s.allegati == null || s.allegati!.isEmpty) {
      return const SizedBox();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle("Allegati:"),
        const SizedBox(height: 20),

        ...s.allegati!.map((a) => _allegatoItem(a)),
      ],
    );
  }

  Widget _allegatoItem(AllegatoOutput a) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.02),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.06)),
        ),
        child: Row(
          children: [
            const Icon(Icons.insert_drive_file_rounded, color: Colors.white70),
            const SizedBox(width: 14),

            Expanded(
              child: Text(
                a.nomeFile ?? "Allegato",
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.white70,
                ),
              ),
            ),

            IconButton(
              icon: const Icon(Icons.open_in_new_rounded, color: Colors.white),
              onPressed: _loadingAperturaAllegato
                  ? null
                  : () => _apriAllegato(a.id!),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sideGlass(SegnalazioneOutput s) {
    return Column(
      children: [
        _glassContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionTitle("Stato:"),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(_statoIcon(s.stato), color: _statoColor(s.stato)),
                  const SizedBox(width: 10),
                  Text(
                    s.stato?.name ?? "-",
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              if (s.ditta != null)
                Text(
                  "Ditta: ${s.ditta}",
                  style: const TextStyle(color: Colors.white),
                ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        if (s.latitudine != null)
          // show map without extra glass card so it can expand fully
          _mappa(s.latitudine!, s.longitudine!),
      ],
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.manrope(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    );
  }

  Widget _mappa(double lat, double lon) {
    final screen = MediaQuery.of(context).size;
    final isWide = screen.width > 1000;
    final height = isWide ? min(screen.height * 0.6, 760.0) : 480.0;

    return ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(20)),
      child: SizedBox(
        height: height,
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
                  width: 60,
                  height: 60,
                  child: const Icon(
                    Icons.location_on_rounded,
                    color: Color(0xFF00BFA5),
                    size: 52,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/"
        "${date.month.toString().padLeft(2, '0')}/"
        "${date.year} "
        "${date.hour.toString().padLeft(2, '0')}:"
        "${date.minute.toString().padLeft(2, '0')}";
  }

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
