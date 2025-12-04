import 'package:flutter/material.dart';
import 'package:openapi/openapi.dart';
import 'package:dio/dio.dart';

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
  });

  @override
  State<CreaSegnalazionePage> createState() => _CreaSegnalazionePageState();
}

class _CreaSegnalazionePageState extends State<CreaSegnalazionePage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _titoloController = TextEditingController();
  final TextEditingController _descrizioneController = TextEditingController();
  final TextEditingController _latController = TextEditingController();
  final TextEditingController _lngController = TextEditingController();
  int? _selectedEnteId;

  bool _loading = false;

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
        ..latitudine = double.tryParse(_latController.text) ?? 0.0
        ..longitudine = double.tryParse(_lngController.text) ?? 0.0
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
              Navigator.pop(context);
              Navigator.pop(context);
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

  @override
  Widget build(BuildContext context) {
    final backgroundColors = [
      const Color(0xFFe0f2f1),
      const Color(0xFFb2dfdb),
      const Color(0xFF80cbc4),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 30, 78, 33),
        title: const Text(
          "Crea Segnalazione",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ), // scritta bianca
        ),
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: backgroundColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: _loading
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.green),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _titoloController,
                              decoration: const InputDecoration(
                                labelText: "Titolo",
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _descrizioneController,
                              decoration: const InputDecoration(
                                labelText: "Descrizione",
                              ),
                              validator: (v) => v == null || v.isEmpty
                                  ? "La descrizione è obbligatoria"
                                  : null,
                              maxLines: 3,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _latController,
                              decoration: const InputDecoration(
                                labelText: "Latitudine",
                              ),
                              keyboardType: TextInputType.number,
                              validator: (v) => v == null || v.isEmpty
                                  ? "Latitudine obbligatoria"
                                  : null,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _lngController,
                              decoration: const InputDecoration(
                                labelText: "Longitudine",
                              ),
                              keyboardType: TextInputType.number,
                              validator: (v) => v == null || v.isEmpty
                                  ? "Longitudine obbligatoria"
                                  : null,
                            ),
                            const SizedBox(height: 12),
                            DropdownButtonFormField<int>(
                              value: _selectedEnteId,
                              items: _enti
                                  .map(
                                    (e) => DropdownMenuItem(
                                      value: e.id,
                                      child: Text(e.nomeEnte ?? 'Ente ${e.id}'),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (v) =>
                                  setState(() => _selectedEnteId = v),
                              decoration: const InputDecoration(
                                labelText: "Ente",
                              ),
                              validator: (v) =>
                                  v == null ? "Seleziona un ente" : null,
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color.fromARGB(
                                  255,
                                  30,
                                  78,
                                  33,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                  horizontal: 24,
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
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
