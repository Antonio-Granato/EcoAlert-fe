import 'dart:async';
import 'package:flutter/material.dart';
import 'package:openapi/openapi.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';

class DettaglioSegnalazionePage extends StatefulWidget {
  final UtentiApi utentiApi;
  final AuthApi authApi;
  final Dio dio;
  final int userId;
  final int segnalazioneId;
  final SegnalazioniApi segnalazioniApi;
  final EntiApi entiApi;
  final CommentiApi commentiApi;
  final AllegatiApi allegatiApi;

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
    required this.allegatiApi,
  });

  @override
  State<DettaglioSegnalazionePage> createState() =>
      _DettaglioSegnalazionePageState();
}

class _DettaglioSegnalazionePageState extends State<DettaglioSegnalazionePage> {
  late Future<SegnalazioneOutput?> futureSegnalazione;

  final TextEditingController _commentoController = TextEditingController();
  final TextEditingController _editTitoloController = TextEditingController();
  final TextEditingController _editDescrizioneController =
      TextEditingController();
  final TextEditingController _editSearchController = TextEditingController();
  final MapController _editMapController = MapController();

  LatLng? _editSelectedPosition;
  List<dynamic> _editSearchResults = [];
  Timer? _editDebounce;
  double _editZoom = 15;
  // ignore: unused_field
  bool _loadingAperturaAllegato = false;
  Error? error;
  void Function(void Function())? _modalSetState;

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

  @override
  void dispose() {
    _editDebounce?.cancel();
    super.dispose();
  }

  Future<void> _editSearchAddress(String query) async {
    if (!mounted) return;

    final q = query.trim();
    if (q.isEmpty) {
      _modalSetState?.call(() {
        _editSearchResults.clear();
      });
      return;
    }

    try {
      final response = await Dio().get(
        'https://nominatim.openstreetmap.org/search',
        queryParameters: {
          'q': q,
          'format': 'json',
          'addressdetails': 1,
          'limit': 5,
        },
        options: Options(headers: {'User-Agent': 'com.example.scheletro'}),
      );

      final data = response.data;
      if (data is List) {
        _modalSetState?.call(() {
          _editSearchResults = List<Map<String, dynamic>>.from(data);
        });
      }
    } catch (_) {
      _modalSetState?.call(() {
        _editSearchResults.clear();
      });
    }
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

  Future<void> pickAndUploadImage() async {
    // 1. Seleziona immagine dalla galleria
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null) {
      print("Nessuna immagine selezionata!");
      return;
    }
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

  Future<void> _modificaSegnalazione() async {
    final segnalazione = await futureSegnalazione;
    if (segnalazione == null) return;

    // Precarico i dati
    _editTitoloController.text = segnalazione.titolo ?? "";
    _editDescrizioneController.text = segnalazione.descrizione ?? "";
    _editSelectedPosition = LatLng(
      segnalazione.latitudine ?? 45.4642,
      segnalazione.longitudine ?? 9.1900,
    );

    final conferma = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Modifica Segnalazione"),
        content: StatefulBuilder(
          builder: (ctx, setModalState) {
            _modalSetState = setModalState;
            return SizedBox(
              width: double.maxFinite,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Titolo
                    TextField(
                      controller: _editTitoloController,
                      decoration: const InputDecoration(labelText: "Titolo"),
                    ),
                    const SizedBox(height: 8),

                    // Descrizione
                    TextField(
                      controller: _editDescrizioneController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: "Descrizione",
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Barra di ricerca
                    TextField(
                      controller: _editSearchController,
                      decoration: const InputDecoration(
                        labelText: "Cerca indirizzo",
                        prefixIcon: Icon(Icons.search),
                      ),
                      onChanged: (value) {
                        if (_editDebounce?.isActive ?? false) {
                          _editDebounce!.cancel();
                        }

                        _editDebounce = Timer(
                          const Duration(milliseconds: 400),
                          () {
                            _editSearchAddress(value);
                          },
                        );
                      },
                    ),

                    if (_editSearchResults.isNotEmpty)
                      Container(
                        margin: const EdgeInsets.only(top: 6),
                        constraints: const BoxConstraints(maxHeight: 180),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: _editSearchResults.length,
                          itemBuilder: (context, index) {
                            final item = _editSearchResults[index];
                            final name = item['display_name'] ?? '';

                            return ListTile(
                              title: Text(name),
                              onTap: () {
                                final lat = double.tryParse(item['lat'] ?? '');
                                final lon = double.tryParse(item['lon'] ?? '');

                                if (lat == null || lon == null) return;

                                final pos = LatLng(lat, lon);

                                setState(() {
                                  _editSelectedPosition = pos;
                                  _editSearchResults.clear();
                                  _editSearchController.text = name;
                                });

                                _editMapController.move(pos, 16);
                              },
                            );
                          },
                        ),
                      ),

                    const SizedBox(height: 12),

                    // Mappa
                    SizedBox(
                      height: 200,
                      child: FlutterMap(
                        mapController: _editMapController,
                        options: MapOptions(
                          initialCenter: _editSelectedPosition!,
                          initialZoom: _editZoom,
                          onTap: (tapPosition, latLng) {
                            setModalState(() {
                              _editSelectedPosition = latLng;
                            });
                          },
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                            userAgentPackageName: 'com.example.scheletro',
                          ),
                          MarkerLayer(
                            markers: [
                              Marker(
                                point: _editSelectedPosition!,
                                width: 40,
                                height: 40,
                                child: const Icon(
                                  Icons.location_on,
                                  color: Colors.red,
                                  size: 32,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Annulla"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Salva"),
          ),
        ],
      ),
    );

    if (conferma != true) return;

    try {
      final input = SegnalazioneInput(
        (b) => b
          ..titolo = _editTitoloController.text.trim().isEmpty
              ? null
              : _editTitoloController.text.trim()
          ..descrizione = _editDescrizioneController.text.trim()
          ..latitudine = _editSelectedPosition!.latitude
          ..longitudine = _editSelectedPosition!.longitude
          ..idEnte = segnalazione.idEnte,
      );

      await widget.segnalazioniApi.updateSegnalazione(
        id: widget.userId,
        idSegnalazione: widget.segnalazioneId,
        segnalazioneInput: input,
      );

      _refreshSegnalazione();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Segnalazione modificata con successo")),
      );
    } on DioException catch (ex) {
      int code = ex.response?.statusCode ?? 500;
      String msg = "Errore durante la modifica";

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

      await _showErrorDialog("Errore $code: $msg");
    } catch (_) {
      setState(() {
        error = Error((b) => b..message = "Errore imprevisto");
      });
      await _showErrorDialog("Errore imprevisto durante la modifica");
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

  // Funzione per creare commento
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

  Widget _buildMappa(double lat, double lng) {
    final mapController = MapController();

    return Container(
      height: 250,
      margin: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        children: [
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
              initialCenter: LatLng(lat, lng),
              initialZoom: 15,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                userAgentPackageName: 'com.example.scheletro',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: LatLng(lat, lng),
                    width: 50,
                    height: 50,
                    child: const Icon(
                      Icons.location_on,
                      color: Colors.red,
                      size: 40,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // --------- Pulsanti zoom ----------
          Positioned(
            right: 8,
            bottom: 8,
            child: Column(
              children: [
                FloatingActionButton(
                  mini: true,
                  heroTag: "zoom_in",
                  onPressed: () {
                    mapController.move(
                      mapController.center,
                      mapController.zoom + 1,
                    );
                  },
                  child: const Icon(Icons.add),
                ),
                const SizedBox(height: 8),
                FloatingActionButton(
                  mini: true,
                  heroTag: "zoom_out",
                  onPressed: () {
                    mapController.move(
                      mapController.center,
                      mapController.zoom - 1,
                    );
                  },
                  child: const Icon(Icons.remove),
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) {
              if (value == 'delete') {
                _deleteSegnalazione();
              } else if (value == 'edit') {
                _modificaSegnalazione();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit, color: Colors.blue),
                    SizedBox(width: 8),
                    Text("Modifica segnalazione"),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red),
                    SizedBox(width: 8),
                    Text("Elimina segnalazione"),
                  ],
                ),
              ),
            ],
          ),
        ],
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
                            // ===== MAPPA =====
                            if (segnalazione.latitudine != null &&
                                segnalazione.longitudine != null)
                              _buildMappa(
                                segnalazione.latitudine!,
                                segnalazione.longitudine!,
                              ),

                            const SizedBox(height: 16),
                            if (segnalazione.allegati != null &&
                                segnalazione.allegati!.isNotEmpty) ...[
                              const Text(
                                "Allegati",
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              ...segnalazione.allegati!.map(
                                (c) => Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        "- ${c.nomeFile}",
                                        style: const TextStyle(fontSize: 15),
                                      ),
                                    ),
                                    if (segnalazione.idUtente == widget.userId)
                                      IconButton(
                                        icon: const Icon(
                                          Icons.looks,
                                          color: Colors.green,
                                        ),
                                        onPressed: () => _apriAllegato(c.id!),
                                      ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],

                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerRight,
                              child: ElevatedButton(
                                onPressed: pickAndUploadImage,
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
                                child: const Text("Aggiungi allegato"),
                              ),
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
