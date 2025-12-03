import 'package:flutter/material.dart';
import 'package:openapi/openapi.dart';
import 'package:dio/dio.dart';
import 'package:eco_alert/presentation/mobile/Page/profiloPage.dart';
import 'package:eco_alert/presentation/mobile/Page/dettaglioSegnalazionePage.dart';
import 'package:eco_alert/presentation/mobile/Page/welcomePage.dart';

// -----------------------------
// HOME PAGE
// -----------------------------
class HomePage extends StatefulWidget {
  final Dio dio;
  final UtentiApi utentiApi;
  final AuthApi authApi;
  final int userId;

  const HomePage({
    super.key,
    required this.utentiApi,
    required this.userId,
    required this.dio,
    required this.authApi,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late Future<List<SegnalazioneOutput>?> futureReports;

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  Error? error;

  // -----------------------------
  // INIT
  // -----------------------------
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

  // -----------------------------
  // CARICAMENTO SEGNALAZIONI
  // -----------------------------
  Future<List<SegnalazioneOutput>?> _loadReports() async {
    try {
      final res = await widget.utentiApi.getSegnalazioniByUserId(
        id: widget.userId,
      );

      if (res.data == null || res.data!.isEmpty) {
        setState(() {
          error = Error(
            (b) => b
              ..code = 404
              ..message = "Nessuna segnalazione trovata.",
          );
        });
        return null;
      }

      return res.data!.toList();
    } on DioException catch (ex) {
      // Errore 500 → come loginPage → dialog → redirect
      if (ex.response?.statusCode == 500) {
        Error(
          (b) => b..message = "Errore interno del server. Riprova più tardi.",
        );

        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (_) => WelcomePage(
                authApi: widget.authApi,
                utentiApi: widget.utentiApi,
                dio: widget.dio,
              ),
            ),
            (route) => false,
          );
        }
        return null;
      }

      // Altri errori → messaggio rosso
      String msg = "Errore durante il caricamento delle segnalazioni";
      if (ex.response?.data is Map<String, dynamic>) {
        msg = (ex.response!.data as Map)['message']?.toString() ?? msg;
      }

      setState(() {
        error = Error(
          (b) => b
            ..code = ex.response?.statusCode ?? 0
            ..message = msg,
        );
      });

      return null;
    } catch (_) {
      Error((b) => b..message = "Errore imprevisto. Riprova.");

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => WelcomePage(
              authApi: widget.authApi,
              utentiApi: widget.utentiApi,
              dio: widget.dio,
            ),
          ),
          (route) => false,
        );
      }

      return null;
    }
  }

  // -----------------------------
  // LOGOUT
  // -----------------------------
  void _logout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => WelcomePage(
          authApi: widget.authApi,
          utentiApi: widget.utentiApi,
          dio: widget.dio,
        ),
      ),
      (route) => false,
    );
  }

  // -----------------------------
  // UI
  // -----------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFe0f2f1), Color(0xFFb2dfdb), Color(0xFF80cbc4)],
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
                // HEADER
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.logout, color: Colors.black),
                        tooltip: "Logout",
                        onPressed: _logout,
                      ),
                      const SizedBox(width: 8),
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
                                  authApi: widget.authApi,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                // CONTENUTO
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

                      // ERROR 404 → BOX NERO
                      if (error != null && error!.code == 404) {
                        return Center(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            margin: const EdgeInsets.symmetric(horizontal: 32),
                            decoration: BoxDecoration(
                              color: Colors.black87,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              error!.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontFamily: "Poppins",
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      }

                      // ALTRI ERRORI → ROSSO
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
                                fontFamily: "Poppins",
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      }

                      final items = snapshot.data ?? [];

                      return ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: items.length,
                        itemBuilder: (context, i) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: _SegnalazioneCard(
                              segnalazione: items[i],
                              utentiApi: widget.utentiApi,
                              userId: widget.userId,
                              dio: widget.dio,
                              authApi: widget.authApi,
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

// -----------------------------
// CARD SEGNALAZIONE (immutata)
// -----------------------------
class _SegnalazioneCard extends StatelessWidget {
  final SegnalazioneOutput segnalazione;
  final UtentiApi utentiApi;
  final AuthApi authApi;
  final Dio dio;
  final int userId;

  const _SegnalazioneCard({
    required this.segnalazione,
    required this.utentiApi,
    required this.userId,
    required this.dio,
    required this.authApi,
  });

  @override
  Widget build(BuildContext context) {
    final s = segnalazione;

    return Material(
      elevation: 6,
      shadowColor: Colors.grey.withOpacity(0.2),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: () {
          if (s.id != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => DettaglioSegnalazionePage(
                  utentiApi: utentiApi,
                  userId: userId,
                  segnalazioneId: s.id!,
                  dio: dio,
                  authApi: authApi,
                ),
              ),
            );
          }
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Titolo + badge stato
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      s.titolo ?? "Segnalazione",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: "Poppins",
                      ),
                    ),
                  ),
                  _buildBadge(s.stato),
                ],
              ),

              const SizedBox(height: 8),

              Text(
                s.descrizione ?? "",
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 15,
                  fontFamily: "Poppins",
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 12),
              const Align(
                alignment: Alignment.centerRight,
                child: Icon(Icons.chevron_right, size: 28, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Badge stato
  Widget _buildBadge(StatoEnum? stato) {
    final colorBg =
        {
          StatoEnum.INSERITO: Colors.green.shade100,
          StatoEnum.PRESO_IN_CARICO: Colors.blue.shade100,
          StatoEnum.SOSPESO: Colors.yellow.shade100,
          StatoEnum.CHIUSO: Colors.red.shade300,
        }[stato] ??
        Colors.red.shade100;

    final colorText =
        {
          StatoEnum.INSERITO: Colors.black,
          StatoEnum.PRESO_IN_CARICO: Colors.black,
          StatoEnum.SOSPESO: Colors.black,
          StatoEnum.CHIUSO: Colors.black,
        }[stato] ??
        Colors.black;

    final icon =
        {
          StatoEnum.INSERITO: Icons.fiber_new_rounded,
          StatoEnum.PRESO_IN_CARICO: Icons.work_rounded,
          StatoEnum.SOSPESO: Icons.pause_circle_filled_rounded,
          StatoEnum.CHIUSO: Icons.check_circle_rounded,
        }[stato] ??
        Icons.help_outline;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colorBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: colorText),
          const SizedBox(width: 4),
          Text(
            stato?.name.toUpperCase() ?? "SCONOSCIUTO",
            style: TextStyle(
              color: colorText,
              fontWeight: FontWeight.bold,
              fontSize: 12,
              fontFamily: "Poppins",
            ),
          ),
        ],
      ),
    );
  }
}
