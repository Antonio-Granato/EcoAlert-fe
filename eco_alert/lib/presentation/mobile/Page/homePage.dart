import 'package:eco_alert/presentation/mobile/Page/creaSegnalazionePage.dart';
import 'package:eco_alert/presentation/mobile/Page/profiloPage.dart';
import 'package:flutter/material.dart';
import 'package:openapi/openapi.dart';
import 'package:dio/dio.dart';
import 'package:eco_alert/presentation/mobile/Page/dettaglioSegnalazionePage.dart';
import 'package:eco_alert/presentation/mobile/Page/welcomePage.dart';

class HomePage extends StatefulWidget {
  final Dio dio;
  final UtentiApi utentiApi;
  final AuthApi authApi;
  final int userId;
  final SegnalazioniApi segnalazioniApi;
  final EntiApi entiApi;
  final CommentiApi commentiApi;

  const HomePage({
    super.key,
    required this.utentiApi,
    required this.userId,
    required this.dio,
    required this.authApi,
    required this.segnalazioniApi,
    required this.entiApi,
    required this.commentiApi,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  Future<List<SegnalazioneOutput>> futureReports = Future.value([]);
  Error? error;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshReports(initial: true);
    });

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

  Future<void> _refreshReports({bool initial = false}) async {
    try {
      final res = await widget.utentiApi.getSegnalazioniByUserId(
        id: widget.userId,
      );

      setState(() {
        futureReports = Future.value(res.data?.toList() ?? []);
        error = null;
        if (res.data == null || res.data!.isEmpty) {
          error = Error(
            (b) => b
              ..code = 404
              ..message = "Non hai ancora effettuato segnalazioni.",
          );
        }
      });
    } on DioException catch (ex) {
      setState(() {
        error = Error(
          (b) => b
            ..code = ex.response?.statusCode ?? 0
            ..message =
                (ex.response?.data as Map<String, dynamic>?)?['message']
                    ?.toString() ??
                "Errore durante il caricamento delle segnalazioni",
        );
        futureReports = Future.value([]);
      });
    } catch (_) {
      setState(() {
        error = Error((b) => b..message = "Errore imprevisto. Riprova.");
        futureReports = Future.value([]);
      });
    }
  }

  void _logout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => WelcomePage(
          authApi: widget.authApi,
          utentiApi: widget.utentiApi,
          dio: widget.dio,
          segnalazioniApi: widget.segnalazioniApi,
          entiApi: widget.entiApi,
          commentiApi: widget.commentiApi,
        ),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CreaSegnalazionePage(
                utentiApi: widget.utentiApi,
                userId: widget.userId,
                dio: widget.dio,
                authApi: widget.authApi,
                segnalazioniApi: widget.segnalazioniApi,
                entiApi: widget.entiApi,
              ),
            ),
          );
          if (result == true) await _refreshReports();
        },
      ),
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
                                  segnalazioniApi: widget.segnalazioniApi,
                                  entiApi: widget.entiApi,
                                  commentiApi: widget.commentiApi,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                // LISTA SEGNALAZIONI
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _refreshReports,
                    child: FutureBuilder<List<SegnalazioneOutput>>(
                      future: futureReports,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(
                              color: Colors.green,
                              strokeWidth: 3,
                            ),
                          );
                        }

                        if (error != null && error!.code == 404) {
                          return Center(
                            child: Text(
                              error!.message ?? "Nessuna segnalazione creata",
                              style: const TextStyle(
                                color: Colors.black,
                                fontFamily: "Poppins",
                                fontWeight: FontWeight.w600,
                                fontSize: 18,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          );
                        }

                        if (error != null) {
                          return Center(
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              margin: const EdgeInsets.symmetric(
                                horizontal: 32,
                              ),
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

                        if (items.isEmpty) {
                          return const Center(
                            child: Text(
                              "Non ci sono segnalazioni da mostrare",
                              style: TextStyle(
                                fontFamily: "Poppins",
                                fontWeight: FontWeight.w600,
                                fontSize: 18,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          );
                        }

                        return ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(16),
                          itemCount: items.length,
                          itemBuilder: (context, i) => Padding(
                            padding: const EdgeInsets.only(
                              bottom: 16,
                            ), // spazio tra le card
                            child: _SegnalazioneCard(
                              segnalazione: items[i],
                              utentiApi: widget.utentiApi,
                              userId: widget.userId,
                              dio: widget.dio,
                              authApi: widget.authApi,
                              segnalazioniApi: widget.segnalazioniApi,
                              entiApi: widget.entiApi,
                              commentiApi: widget.commentiApi,
                              onRefresh: _refreshReports,
                            ),
                          ),
                        );
                      },
                    ),
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
// CARD SEGNALAZIONE
// -----------------------------
class _SegnalazioneCard extends StatelessWidget {
  final SegnalazioneOutput segnalazione;
  final UtentiApi utentiApi;
  final AuthApi authApi;
  final Dio dio;
  final int userId;
  final SegnalazioniApi segnalazioniApi;
  final EntiApi entiApi;
  final CommentiApi commentiApi;
  final Future<void> Function()? onRefresh;

  const _SegnalazioneCard({
    required this.segnalazione,
    required this.utentiApi,
    required this.userId,
    required this.dio,
    required this.authApi,
    required this.segnalazioniApi,
    required this.entiApi,
    required this.commentiApi,
    this.onRefresh,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final s = segnalazione;

    return Material(
      elevation: 6,
      shadowColor: Colors.grey.withOpacity(0.2),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: () async {
          if (s.id != null) {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => DettaglioSegnalazionePage(
                  utentiApi: utentiApi,
                  userId: userId,
                  segnalazioneId: s.id!,
                  dio: dio,
                  authApi: authApi,
                  segnalazioniApi: segnalazioniApi,
                  entiApi: entiApi,
                  commentiApi: commentiApi,
                ),
              ),
            );

            if (result == true && onRefresh != null) {
              await onRefresh?.call();
            }
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

  Widget _buildBadge(StatoEnum? stato) {
    final colorBg =
        {
          StatoEnum.INSERITO: Colors.green.shade100,
          StatoEnum.PRESO_IN_CARICO: Colors.blue.shade100,
          StatoEnum.SOSPESO: Colors.yellow.shade100,
          StatoEnum.CHIUSO: Colors.red.shade300,
        }[stato] ??
        Colors.grey.shade200;

    final colorText = Colors.black;

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
