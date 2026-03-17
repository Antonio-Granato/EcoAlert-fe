import 'dart:async';
import 'package:flutter/material.dart';
import 'package:openapi/openapi.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';

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
  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/"
        "${date.month.toString().padLeft(2, '0')}/"
        "${date.year} "
        "${date.hour.toString().padLeft(2, '0')}:"
        "${date.minute.toString().padLeft(2, '0')}";
  }

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
      return;
    }

    try {
      final file = await MultipartFile.fromFile(
        image.path,
        filename: image.name,
      );

      // 2. Carica tramite client OpenAPI
      await widget.allegatiApi.uploadAllegato(
        idSegnalazione: widget.segnalazioneId,
        file: file,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Allegato caricato con successo")),
      );

      _refreshSegnalazione();
    } on DioException catch (ex) {
      int code = ex.response?.statusCode ?? 500;
      String message = "Errore durante il caricamento dell'allegato";
      if (ex.response?.data is Map) {
        message = (ex.response!.data as Map)['message']?.toString() ?? message;
      }
      await _showErrorDialog("Errore $code: $message");
    } catch (_) {
      await _showErrorDialog("Errore imprevisto durante l'upload");
    }
  }

  Future<void> _deleteAllegato(int idAllegato) async {
    final conferma = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Conferma eliminazione allegato"),
        content: const Text("Vuoi davvero eliminare questo allegato?"),
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
      await widget.allegatiApi.deleteAllegato(idAllegato: idAllegato);
      _refreshSegnalazione();
    } on DioException catch (ex) {
      int code = ex.response?.statusCode ?? 500;
      String message = "Errore durante l'eliminazione dell'allegato";
      if (ex.response?.data is Map) {
        message = (ex.response!.data as Map)['message']?.toString() ?? message;
      }
      await _showErrorDialog("Errore $code: $message");
    } catch (_) {
      await _showErrorDialog("Errore imprevisto durante la cancellazione");
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
          child: Stack(
            children: [
              // IMMAGINE ZOOMABILE
              InteractiveViewer(
                child: Image.memory(response.data!, fit: BoxFit.contain),
              ),

              // FRECCIA INDIETRO
              Positioned(
                top: 10,
                left: 10,
                child: SafeArea(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
              ),
            ],
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

  // ======== ALLEGATI INTERATTIVI ========
  Widget _buildAllegatiDarkInteractive(SegnalazioneOutput s) {
    final allegati = s.allegati?.toList() ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Allegati",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add_a_photo, color: Colors.white70),
              onPressed: pickAndUploadImage,
            ),
          ],
        ),

        const SizedBox(height: 10),

        if (allegati.isEmpty)
          const Text("Nessun allegato", style: TextStyle(color: Colors.white38))
        else
          SizedBox(
            height: 110,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: allegati.map((a) {
                return FutureBuilder<Response<Uint8List?>>(
                  future: widget.allegatiApi.downloadAllegato(
                    idAllegato: a.id!,
                  ),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Container(
                        width: 100,
                        margin: const EdgeInsets.only(right: 10),
                        decoration: BoxDecoration(
                          color: Colors.white10,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      );
                    }

                    final bytes = snapshot.data!.data!;

                    return Stack(
                      children: [
                        GestureDetector(
                          onTap: () => _apriAllegato(a.id!),
                          child: Container(
                            width: 100,
                            height: 100,
                            margin: const EdgeInsets.only(right: 10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              image: DecorationImage(
                                image: MemoryImage(bytes),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),

                        // bottone elimina
                        Positioned(
                          right: 6,
                          top: 6,
                          child: GestureDetector(
                            onTap: () => _deleteAllegato(a.id!),
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              child: const Padding(
                                padding: EdgeInsets.all(4),
                                child: Icon(
                                  Icons.close,
                                  size: 18,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  // ======== COMMENTI INTERATTIVI ========
  Widget _buildCommentiDarkInteractive(SegnalazioneOutput s) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Commenti",
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),

        if (s.commenti != null && s.commenti!.isNotEmpty)
          ...s.commenti!.map(
            (c) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.08)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // HEADER COMMENTO
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          "${c.nome ?? ""} ${c.cognome ?? ""}"
                          "${c.nomeEnte != null ? " - ${c.nomeEnte}" : ""}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      if (c.dataCommento != null)
                        Text(
                          _formatDate(c.dataCommento!),
                          style: const TextStyle(
                            color: Colors.white38,
                            fontSize: 11,
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  // TESTO COMMENTO
                  Text(
                    c.descrizione ?? "",
                    style: const TextStyle(color: Colors.white70),
                  ),

                  // DELETE: SOLO SE COMMENTO DELL'UTENTE LOGGATO
                  if (c.idUtente == widget.userId)
                    Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.redAccent),
                        onPressed: () => _deleteCommento(c.id!),
                      ),
                    ),
                ],
              ),
            ),
          ),

        if (s.commenti == null || s.commenti!.isEmpty)
          const Text(
            "Nessun commento",
            style: TextStyle(color: Colors.white38),
          ),

        const SizedBox(height: 12),

        // Barra inserimento commento
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _commentoController,
                style: const TextStyle(color: Colors.white70),
                decoration: InputDecoration(
                  hintText: "Scrivi un commento...",
                  hintStyle: const TextStyle(color: Colors.white38),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  fillColor: Colors.white.withOpacity(0.1),
                  filled: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.send, color: Colors.white70),
              onPressed: _creaCommento,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDarkBadge(StatoEnum? stato) {
    final label = stato?.name.toUpperCase() ?? "SCONOSCIUTO";

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 12,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
        ),
      ),
    );
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
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: Stack(
        children: [
          // -------- BACKGROUND GRADIENT (come Home) --------
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF0F2F2B),
                  Color(0xFF0B3D35),
                  Color(0xFF0A4A40),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          SafeArea(
            child: FutureBuilder<SegnalazioneOutput?>(
              future: futureSegnalazione,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 3,
                    ),
                  );
                }

                if (error != null) {
                  return Center(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.symmetric(horizontal: 32),
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

                final segnalazione = snapshot.data;
                if (segnalazione == null) {
                  return const Center(
                    child: Text(
                      "Segnalazione non trovata",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // -------- HEADER --------
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 20,
                      ),
                      child: Row(
                        children: [
                          // Back button
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.arrow_back,
                                color: Colors.white70,
                              ),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ),

                          const SizedBox(width: 16),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  segnalazione.titolo ?? "Segnalazione",
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  "Dettaglio completo",
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          PopupMenuButton<String>(
                            color: const Color(0xFF0F2F2B),
                            icon: const Icon(
                              Icons.more_vert,
                              color: Colors.white70,
                            ),
                            onSelected: (value) {
                              if (value == 'delete') {
                                _deleteSegnalazione();
                              } else if (value == 'edit') {
                                _modificaSegnalazione();
                              }
                            },
                            itemBuilder: (context) => const [
                              PopupMenuItem(
                                value: 'edit',
                                child: Text(
                                  "Modifica",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                              PopupMenuItem(
                                value: 'delete',
                                child: Text(
                                  "Elimina",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // -------- CONTENUTO --------
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.12),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.35),
                                blurRadius: 25,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // BADGE STATO
                              _buildDarkBadge(segnalazione.stato),

                              const SizedBox(height: 12),

                              // DATE
                              if (segnalazione.dataSegnalazione != null)
                                Text(
                                  "Data segnalazione: ${_formatDate(segnalazione.dataSegnalazione!)}",
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 13,
                                  ),
                                ),

                              if (segnalazione.dataChiusura != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    "Data chiusura: ${_formatDate(segnalazione.dataChiusura!)}",
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),

                              const SizedBox(height: 16),

                              // DESCRIZIONE
                              Text(
                                segnalazione.descrizione ??
                                    "Nessuna descrizione",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                ),
                              ),

                              const SizedBox(height: 20),

                              // MAPPA
                              if (segnalazione.latitudine != null &&
                                  segnalazione.longitudine != null)
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: _buildMappa(
                                    segnalazione.latitudine!,
                                    segnalazione.longitudine!,
                                  ),
                                ),

                              const SizedBox(height: 20),
                              _buildAllegatiDarkInteractive(segnalazione),

                              const SizedBox(height: 20),
                              _buildCommentiDarkInteractive(segnalazione),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
