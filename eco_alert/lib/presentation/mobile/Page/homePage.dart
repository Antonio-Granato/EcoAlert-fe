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

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late Future<List<SegnalazioneOutput>?> futureReports;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    futureReports = _loadReports();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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

  // -------------------------------------------------------------
  // STATO → TESTO, COLORI E ICONE
  // -------------------------------------------------------------
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
        return Icons.fiber_new_rounded; // Nuova segnalazione
      case StatoEnum.PRESO_IN_CARICO:
        return Icons.work_rounded; // In lavorazione
      case StatoEnum.SOSPESO:
        return Icons.pause_circle_filled_rounded; // Sospeso
      case StatoEnum.CHIUSO:
        return Icons.check_circle_rounded; // Chiuso
      default:
        return Icons.help_outline; // Stato sconosciuto
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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ---------------- HEADER ----------------
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Le tue segnalazioni",
                              style: TextStyle(
                                fontFamily: "Poppins",
                                fontWeight: FontWeight.bold,
                                fontSize: 28,
                                color: Colors.green.shade800,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Tienile sotto controllo facilmente!",
                              style: TextStyle(
                                fontFamily: "Poppins",
                                fontSize: 16,
                                color: Colors.green.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      CircleAvatar(
                        backgroundColor: Colors.green.shade700,
                        child: IconButton(
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
                      ),
                    ],
                  ),
                ),

                // ---------------- LISTA CARDS ----------------
                Expanded(
                  child: FutureBuilder<List<SegnalazioneOutput>?>(
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
                              fontFamily: "Poppins",
                            ),
                          ),
                        );
                      }

                      final segnalazioni = snapshot.data ?? [];

                      if (segnalazioni.isEmpty) {
                        return Center(
                          child: Text(
                            "Non hai ancora fatto segnalazioni.",
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey.shade700,
                              fontWeight: FontWeight.w500,
                              fontFamily: "Poppins",
                            ),
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        itemCount: segnalazioni.length,
                        itemBuilder: (context, index) {
                          final segnal = segnalazioni[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: AnimatedScale(
                              duration: Duration(
                                milliseconds: 400 + index * 100,
                              ),
                              scale: 1.0,
                              child: Material(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                elevation: 6,
                                shadowColor: Colors.grey.withOpacity(0.2),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(20),
                                  onTap: () {
                                    if (segnal.id == null) return;
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            DettaglioSegnalazionePage(
                                              utentiApi: widget.utentiApi,
                                              userId: widget.userId,
                                              segnalazioneId: segnal.id!,
                                            ),
                                      ),
                                    );
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Titolo + Badge stato
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                segnal.titolo ?? "Segnalazione",
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily: "Poppins",
                                                ),
                                              ),
                                            ),
                                            // Badge con icona
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 4,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: _badgeColor(
                                                  segnal.stato,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    _statoIcon(segnal.stato),
                                                    size: 16,
                                                    color: _badgeTextColor(
                                                      segnal.stato,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    _statoToString(
                                                      segnal.stato,
                                                    ),
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: _badgeTextColor(
                                                        segnal.stato,
                                                      ),
                                                      fontFamily: "Poppins",
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        // Descrizione
                                        Text(
                                          segnal.descrizione ?? "",
                                          style: TextStyle(
                                            fontSize: 15,
                                            color: Colors.grey.shade700,
                                            fontFamily: "Poppins",
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 12),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: const [
                                            Icon(
                                              Icons.chevron_right,
                                              color: Colors.grey,
                                              size: 28,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
