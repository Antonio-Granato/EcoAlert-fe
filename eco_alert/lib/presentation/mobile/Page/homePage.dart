import 'package:eco_alert/presentation/mobile/Page/profiloPage.dart';
import 'package:eco_alert/presentation/mobile/Page/dettaglioSegnalazionePage.dart';
import 'package:flutter/material.dart';
import 'package:openapi/openapi.dart';
import 'package:dio/dio.dart';

class HomePage extends StatefulWidget {
  final UtentiApi utentiApi;
  final int userId;
  final Dio dio;

  const HomePage({
    super.key,
    required this.utentiApi,
    required this.userId,
    required this.dio,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<SegnalazioneOutput>?> futureReports;

  @override
  void initState() {
    super.initState();
    futureReports = _loadReports();
  }

  Future<List<SegnalazioneOutput>?> _loadReports() async {
    try {
      final res = await widget.utentiApi.getSegnalazioniByUserId(
        id: widget.userId,
      );
      return res.data?.toList();
    } catch (e) {
      print("Errore _loadReports: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 2,
        backgroundColor: Colors.green,
        title: const Text(
          "Le tue segnalazioni",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => profiloPage(
                    utentiApi: widget.utentiApi,
                    userId: widget.userId,
                    dio: widget.dio,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<List<SegnalazioneOutput>?>(
        future: futureReports,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.green,
                strokeWidth: 3,
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Errore nel caricamento delle segnalazioni:\n${snapshot.error}",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.red.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }

          final segnalazioni = snapshot.data ?? [];

          if (segnalazioni.isEmpty) {
            return const Center(
              child: Text(
                "Non hai ancora fatto segnalazioni.",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: segnalazioni.length,
            itemBuilder: (context, index) {
              final segnal = segnalazioni[index];

              return GestureDetector(
                onTap: () {
                  if (segnal.id == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("ID segnalazione mancante 😕"),
                      ),
                    );
                    return;
                  }

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DettaglioSegnalazionePage(
                        utentiApi: widget.utentiApi,
                        userId: widget.userId,
                        segnalazioneId: segnal.id!,
                      ),
                    ),
                  );
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.15),
                        spreadRadius: 2,
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 8,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              segnal.titolo ?? "Segnalazione",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              segnal.descrizione ?? "",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right,
                        color: Colors.grey,
                        size: 28,
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
