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
  });

  @override
  State<DettaglioSegnalazioneWebPage> createState() =>
      _DettaglioSegnalazioneWebPageState();
}

class _DettaglioSegnalazioneWebPageState
    extends State<DettaglioSegnalazioneWebPage> {
  late Future<SegnalazioneOutput?> futureSegnalazione;

  double? latitudine;
  double? longitudine;
  StatoEnum? _statoSelezionato;

  final TextEditingController _dittaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    setState(() {
      futureSegnalazione = _loadDettaglio();
    });
  }

  Future<SegnalazioneOutput?> _loadDettaglio() async {
    final res = await widget.utentiApi.getSegnalazioneById(
      id: widget.userId,
      idSegnalazione: widget.segnalazioneId,
    );
    return res.data;
  }

  // ======= MODIFICA ENTE =======
  Future<void> _modificaEnte(SegnalazioneOutput segnalazione) async {
    _statoSelezionato = segnalazione.stato;
    _dittaController.text = segnalazione.ditta ?? "";

    final conferma = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Aggiorna Segnalazione"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<StatoEnum>(
              value: _statoSelezionato,
              decoration: const InputDecoration(labelText: "Stato"),
              items: StatoEnum.values
                  .map(
                    (s) => DropdownMenuItem(
                      value: s,
                      child: Text(s.name.replaceAll("_", " ")),
                    ),
                  )
                  .toList(),
              onChanged: (v) => _statoSelezionato = v,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _dittaController,
              decoration: const InputDecoration(labelText: "Ditta (opzionale)"),
            ),
          ],
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

    if (conferma != true) return;

    final input = SegnalazioneUpdateInputEnte(
      (b) => b
        ..stato = _statoSelezionato
        ..ditta = _dittaController.text.trim().isEmpty
            ? null
            : _dittaController.text,
    );

    await widget.segnalazioniApi.updateSegnalazioneEnte(
      idSegnalazione: widget.segnalazioneId,
      idEnte: segnalazione.idEnte!,
      segnalazioneUpdateInputEnte: input,
    );

    _refresh();
  }

  // ======= UI =======
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 900;
    final contentWidth = isMobile ? size.width * 0.9 : 720.0;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B3D35),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          tooltip: "Torna alla Home",
          onPressed: () {
            Navigator.pop(context, true); // true = trigger refresh home
          },
        ),
        title: const Text(
          "Dettaglio Segnalazione",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),

      body: Stack(
        children: [
          // ===== SFONDO =====
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0B3D35), Color(0xFF0A4A40)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // ===== CONTENUTO =====
          Center(
            child: FutureBuilder<SegnalazioneOutput?>(
              future: futureSegnalazione,
              builder: (_, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator(color: Colors.green);
                }

                final s = snapshot.data;
                if (s == null) {
                  return const Text(
                    "Segnalazione non trovata",
                    style: TextStyle(color: Colors.white),
                  );
                }

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeOutCubic,
                  width: contentWidth,
                  padding: const EdgeInsets.all(36),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.07),
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
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ===== HEADER =====
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 26,
                            backgroundColor: _statoColor(s.stato),
                            child: Icon(
                              _statoIcon(s.stato),
                              color: Colors.black87,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  s.titolo ?? "Segnalazione",
                                  style: GoogleFonts.manrope(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                _badge(s.stato),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),
                      _divider(),

                      // ===== DESCRIZIONE =====
                      Text(
                        "Descrizione",
                        style: GoogleFonts.manrope(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        s.descrizione ?? "Nessuna descrizione",
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                          height: 1.6,
                        ),
                      ),

                      if (s.latitudine != null && s.longitudine != null) ...[
                        const SizedBox(height: 24),
                        _divider(),
                        const SizedBox(height: 16),
                        Text(
                          "Posizione",
                          style: GoogleFonts.manrope(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _mappa(s.latitudine!, s.longitudine!),
                      ],

                      // ===== DITTA =====
                      if (s.ditta != null && s.ditta!.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        _divider(),
                        const SizedBox(height: 16),
                        Text(
                          "Ditta assegnata",
                          style: GoogleFonts.manrope(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.apartment_rounded,
                                color: Color(0xFF00BFA5),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  s.ditta!,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.white70,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 36),

                      // ===== AZIONI =====
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.edit_rounded),
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
                            elevation: 8,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _badge(StatoEnum? stato) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white24,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        stato?.name.replaceAll("_", " ") ?? "",
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _divider() => Container(
    margin: const EdgeInsets.symmetric(vertical: 16),
    height: 1,
    color: Colors.white24,
  );

  Widget _mappa(double lat, double lon) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Container(
        height: 260,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white24),
          borderRadius: BorderRadius.circular(18),
        ),
        child: FlutterMap(
          options: MapOptions(
            initialCenter: LatLng(lat, lon),
            initialZoom: 15,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
            ),
          ),
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
  }

  Color _statoColor(StatoEnum? stato) {
    switch (stato) {
      case StatoEnum.INSERITO:
        return Colors.greenAccent;
      case StatoEnum.PRESO_IN_CARICO:
        return Colors.blueAccent;
      case StatoEnum.SOSPESO:
        return Colors.orangeAccent;
      case StatoEnum.CHIUSO:
        return Colors.redAccent;
      default:
        return Colors.grey;
    }
  }

  IconData _statoIcon(StatoEnum? stato) {
    switch (stato) {
      case StatoEnum.INSERITO:
        return Icons.new_releases_rounded;
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
}
