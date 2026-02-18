import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:openapi/openapi.dart';
import 'package:dio/dio.dart';
import 'dart:async';

class CreaSegnalazionePage extends StatefulWidget {
  final int userId;
  final UtentiApi utentiApi;
  final AuthApi authApi;
  final Dio dio;
  final SegnalazioniApi segnalazioniApi;
  final EntiApi entiApi;

  const CreaSegnalazionePage({
    super.key,
    required this.userId,
    required this.utentiApi,
    required this.dio,
    required this.authApi,
    required this.segnalazioniApi,
    required this.entiApi,
    s,
  });

  @override
  State<CreaSegnalazionePage> createState() => _CreaSegnalazionePageState();
}

class _CreaSegnalazionePageState extends State<CreaSegnalazionePage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _titoloController = TextEditingController();
  final TextEditingController _descrizioneController = TextEditingController();
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();

  List<dynamic> _searchResults = [];
  LatLng? _selectedPosition;
  double _currentZoom = 15;
  int? _selectedEnteId;
  bool _loading = false;
  Timer? _debounce;

  List<EnteOutput> _enti = [];

  @override
  void initState() {
    super.initState();
    _loadEnti();
  }

  Future<void> _loadEnti() async {
    try {
      final response = await widget.entiApi.getAllEnti();
      final builtEnti = response.data;

      if (builtEnti != null) {
        setState(() {
          _enti = builtEnti.toList();
        });
      } else {
        _showErrorDialog("Nessun ente trovato.");
      }
    } on DioException catch (ex) {
      String msg = "Errore nel caricamento degli enti";
      if (ex.response != null) {
        msg =
            "Errore ${ex.response?.statusCode}: ${ex.response?.data['message'] ?? ''}";
      }
      _showErrorDialog(msg);
    } catch (e) {
      _showErrorDialog("Errore imprevisto: $e");
    }
  }

  Future<void> _searchAddress(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    final dio = Dio();

    try {
      final response = await dio.get(
        'https://nominatim.openstreetmap.org/search',
        queryParameters: {
          'q': query,
          'format': 'json',
          'addressdetails': 1,
          'limit': 5,
        },
        options: Options(
          headers: {
            'User-Agent': 'com.example.scheletro', // richiesto da Nominatim
          },
        ),
      );

      setState(() {
        _searchResults = response.data;
      });
    } on DioException catch (e) {
      if (e.response?.statusCode == 429) {
        // troppe richieste → ignora silenziosamente
        return;
      } else {
        _showErrorDialog("Errore nella ricerca dell'indirizzo");
      }
    } catch (_) {
      // ignora errori transitori
      return;
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedEnteId == null) {
      _showErrorDialog("Seleziona un ente.");
      return;
    }

    setState(() => _loading = true);

    final input = SegnalazioneInput(
      (b) => b
        ..titolo = _titoloController.text.isEmpty
            ? null
            : _titoloController.text
        ..descrizione = _descrizioneController.text
        ..latitudine = _selectedPosition!.latitude
        ..longitudine = _selectedPosition!.longitude
        ..idEnte = _selectedEnteId,
    );

    try {
      await widget.segnalazioniApi.createSegnalazione(
        id: widget.userId,
        segnalazioneInput: input,
      );

      _showSuccessDialog("Segnalazione creata con successo");
    } on DioException catch (ex) {
      String msg = "Errore imprevisto";
      if (ex.response != null) {
        switch (ex.response?.statusCode) {
          case 400:
            msg = "Dati non validi: ${ex.response?.data['message'] ?? ''}";
            break;
          case 404:
            msg = "Utente non trovato";
            break;
          case 500:
            msg = "Errore interno del server";
            break;
          default:
            msg =
                "Errore ${ex.response?.statusCode}: ${ex.response?.data['message'] ?? ''}";
        }
      }
      _showErrorDialog(msg);
    } finally {
      setState(() => _loading = false);
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
            onPressed: () => Navigator.pop(context, true),
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

  Future<void> _showSuccessDialog(String message) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.green.shade50,
        title: Row(
          children: const [
            Icon(Icons.check_circle_outline, color: Colors.green, size: 32),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                "Successo",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Text(message, style: const TextStyle(fontSize: 16)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Chiude il dialog
              Navigator.pop(
                context,
                true,
              ); // Torna alla Home e restituisce true
            },
            child: Text(
              "OK",
              style: TextStyle(
                color: Colors.green.shade800,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMappa() {
    final h = MediaQuery.of(context).size.height;
    final mapHeight = h * 0.28; // responsive height
    final clampHeight = mapHeight.clamp(200.0, 360.0);

    return Container(
      height: clampHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _selectedPosition ?? const LatLng(45.4642, 9.1900),
              initialZoom: _currentZoom,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all,
              ),
              onTap: (tapPosition, latLng) {
                setState(() {
                  _selectedPosition = latLng;
                });
              },
            ),
            children: [
              TileLayer(
                urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                userAgentPackageName: 'com.example.scheletro',
              ),
              if (_selectedPosition != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _selectedPosition!,
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

          // Pulsanti zoom
          Positioned(
            right: 8,
            bottom: 8,
            child: Column(
              children: [
                FloatingActionButton(
                  mini: true,
                  heroTag: "zoom_in_create",
                  onPressed: () {
                    _currentZoom += 1;
                    _mapController.move(_mapController.center, _currentZoom);
                  },
                  child: const Icon(Icons.add),
                ),
                const SizedBox(height: 6),
                FloatingActionButton(
                  mini: true,
                  heroTag: "zoom_out_create",
                  onPressed: () {
                    _currentZoom -= 1;
                    _mapController.move(_mapController.center, _currentZoom);
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
      body: Stack(
        children: [
          // background gradient come Home/Dettaglio
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // header simile a Home/Dettaglio
                  Row(
                    children: [
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
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Crea Segnalazione",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              "Segnala una criticità nel tuo territorio",
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // card contenente form con stile come Dettaglio, centrata e con maxWidth
                  _loading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        )
                      : Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 720),
                            child: Container(
                              padding: const EdgeInsets.all(22),
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
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Titolo
                                    TextFormField(
                                      controller: _titoloController,
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                      decoration: InputDecoration(
                                        labelText: "Titolo",
                                        labelStyle: const TextStyle(
                                          color: Colors.white70,
                                        ),
                                        filled: true,
                                        fillColor: Colors.white.withOpacity(
                                          0.03,
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          borderSide: BorderSide.none,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 14),

                                    // Descrizione
                                    TextFormField(
                                      controller: _descrizioneController,
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                      decoration: InputDecoration(
                                        labelText: "Descrizione",
                                        labelStyle: const TextStyle(
                                          color: Colors.white70,
                                        ),
                                        filled: true,
                                        fillColor: Colors.white.withOpacity(
                                          0.03,
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          borderSide: BorderSide.none,
                                        ),
                                      ),
                                      validator: (v) => v == null || v.isEmpty
                                          ? "La descrizione è obbligatoria"
                                          : null,
                                      maxLines: 3,
                                    ),
                                    const SizedBox(height: 14),

                                    // Search
                                    TextFormField(
                                      controller: _searchController,
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                      decoration: InputDecoration(
                                        labelText: "Cerca indirizzo o via",
                                        labelStyle: const TextStyle(
                                          color: Colors.white70,
                                        ),
                                        prefixIcon: const Icon(
                                          Icons.search,
                                          color: Colors.white70,
                                        ),
                                        suffixIcon:
                                            _searchController.text.isNotEmpty
                                            ? IconButton(
                                                icon: const Icon(
                                                  Icons.clear,
                                                  color: Colors.white70,
                                                ),
                                                onPressed: () {
                                                  _searchController.clear();
                                                  setState(() {
                                                    _searchResults = [];
                                                  });
                                                },
                                              )
                                            : null,
                                        filled: true,
                                        fillColor: Colors.white.withOpacity(
                                          0.03,
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          borderSide: BorderSide.none,
                                        ),
                                      ),
                                      onChanged: (value) {
                                        if (_debounce?.isActive ?? false)
                                          _debounce!.cancel();
                                        _debounce = Timer(
                                          const Duration(milliseconds: 700),
                                          () {
                                            _searchAddress(value);
                                          },
                                        );
                                      },
                                    ),

                                    if (_searchResults.isNotEmpty)
                                      Container(
                                        margin: const EdgeInsets.only(top: 6),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(
                                                0.05,
                                              ),
                                              blurRadius: 5,
                                            ),
                                          ],
                                        ),
                                        child: ListView.builder(
                                          shrinkWrap: true,
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          itemCount: _searchResults.length,
                                          itemBuilder: (context, index) {
                                            final item = _searchResults[index];
                                            return ListTile(
                                              title: Text(item['display_name']),
                                              onTap: () {
                                                final lat = double.parse(
                                                  item['lat'],
                                                );
                                                final lon = double.parse(
                                                  item['lon'],
                                                );
                                                final pos = LatLng(lat, lon);
                                                setState(() {
                                                  _selectedPosition = pos;
                                                  _searchResults = [];
                                                  _searchController.text =
                                                      item['display_name'];
                                                });
                                                _mapController.move(pos, 16);
                                              },
                                            );
                                          },
                                        ),
                                      ),

                                    const SizedBox(height: 14),
                                    const Text(
                                      "Seleziona posizione sulla mappa",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 10),

                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(16),
                                      child: _buildMappa(),
                                    ),

                                    const SizedBox(height: 16),

                                    DropdownButtonFormField<int>(
                                      value: _selectedEnteId,
                                      items: _enti
                                          .map(
                                            (e) => DropdownMenuItem(
                                              value: e.id,
                                              child: Text(
                                                e.nomeEnte ?? 'Ente ${e.id}',
                                              ),
                                            ),
                                          )
                                          .toList(),
                                      onChanged: (v) =>
                                          setState(() => _selectedEnteId = v),
                                      decoration: InputDecoration(
                                        labelText: "Ente",
                                        labelStyle: const TextStyle(
                                          color: Colors.white70,
                                        ),
                                        filled: true,
                                        fillColor: Colors.white.withOpacity(
                                          0.03,
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          borderSide: BorderSide.none,
                                        ),
                                      ),
                                      validator: (v) => v == null
                                          ? "Seleziona un ente"
                                          : null,
                                    ),

                                    const SizedBox(height: 26),

                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color.fromARGB(
                                            255,
                                            30,
                                            78,
                                            33,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 14,
                                          ),
                                        ),
                                        onPressed: _submit,
                                        child: const Text(
                                          "Crea Segnalazione",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
