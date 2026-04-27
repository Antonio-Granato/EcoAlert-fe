import 'creaSegnalazionePage.dart';
import 'profiloPage.dart';
import 'package:flutter/material.dart';
import 'package:openapi/openapi.dart';
import 'package:dio/dio.dart';
import 'dettaglioSegnalazionePage.dart';
import 'welcomePage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class HomePage extends StatefulWidget {
  final Dio dio;
  final UtentiApi utentiApi;
  final AuthApi authApi;
  final SegnalazioniApi segnalazioniApi;
  final EntiApi entiApi;
  final CommentiApi commentiApi;
  final AllegatiApi allegatiApi;

  const HomePage({
    super.key,
    required this.utentiApi,
    required this.dio,
    required this.authApi,
    required this.segnalazioniApi,
    required this.entiApi,
    required this.commentiApi,
    required this.allegatiApi,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late Future<List<SegnalazioneOutput>> futureReports;
  Error? error;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _controller.forward();

    futureReports = Future.value([]);
    _refreshReports();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<List<SegnalazioneOutput>> _loadReports() async {
    final res = await widget.segnalazioniApi.getMySegnalazioni();

    if (res.data == null || res.data!.isEmpty) {
      return [];
    }

    return res.data!.toList();
  }

  Future<void> _refreshReports() async {
    try {
      final data = await _loadReports();

      if (!mounted) return;

      setState(() {
        futureReports = Future.value(data);
        error = null;
      });
    } on DioException catch (ex) {
      if (ex.response?.statusCode == 401) {
        await _logout();
        return;
      }

      setState(() {
        error = Error(
          (b) => b
            ..code = ex.response?.statusCode ?? 0
            ..message =
                (ex.response?.data as Map<String, dynamic>?)?['message']
                    ?.toString() ??
                "Errore durante il caricamento",
        );
        futureReports = Future.value([]);
      });
    }
  }

  final storage = const FlutterSecureStorage();

  Future<void> _logout() async {
    await storage.deleteAll();

    if (!mounted) return;

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
          allegatiApi: widget.allegatiApi,
        ),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.white.withOpacity(0.12),
        elevation: 0,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text(
          "Crea una nuova segnalazione",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CreaSegnalazionePage(
                utentiApi: widget.utentiApi,
                dio: widget.dio,
                authApi: widget.authApi,
                segnalazioniApi: widget.segnalazioniApi,
                entiApi: widget.entiApi,
                allegatiApi: widget.allegatiApi,
              ),
            ),
          );
          if (result == true) await _refreshReports();
        },
      ),
      body: Stack(
        children: [
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
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // HEADER
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 20,
                    ),
                    child: Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.logout,
                              color: Colors.white70,
                            ),
                            onPressed: _logout,
                          ),
                        ),

                        const SizedBox(width: 16),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                "Le tue segnalazioni",
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                "Tieni tutto sotto controllo",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => profiloPage(
                                  utentiApi: widget.utentiApi,
                                  dio: widget.dio,
                                  authApi: widget.authApi,
                                  segnalazioniApi: widget.segnalazioniApi,
                                  entiApi: widget.entiApi,
                                  commentiApi: widget.commentiApi,
                                  allegatiApi: widget.allegatiApi,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.08),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.person,
                              color: Colors.white,
                            ),
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
                                dio: widget.dio,
                                authApi: widget.authApi,
                                segnalazioniApi: widget.segnalazioniApi,
                                entiApi: widget.entiApi,
                                commentiApi: widget.commentiApi,
                                allegatiApi: widget.allegatiApi,
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
        ],
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
  final SegnalazioniApi segnalazioniApi;
  final EntiApi entiApi;
  final CommentiApi commentiApi;
  final AllegatiApi allegatiApi;
  final Future<void> Function()? onRefresh;

  const _SegnalazioneCard({
    required this.segnalazione,
    required this.utentiApi,
    required this.dio,
    required this.authApi,
    required this.segnalazioniApi,
    required this.entiApi,
    required this.commentiApi,
    required this.allegatiApi,
    this.onRefresh,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final s = segnalazione;

    return Material(
      color: Colors.transparent,
      elevation: 0,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: () async {
          if (s.id != null) {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => DettaglioSegnalazionePage(
                  utentiApi: utentiApi,
                  segnalazioneId: s.id!,
                  dio: dio,
                  authApi: authApi,
                  segnalazioniApi: segnalazioniApi,
                  entiApi: entiApi,
                  commentiApi: commentiApi,
                  allegatiApi: allegatiApi,
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
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.06),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.12)),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      s.titolo ?? "Segnalazione",
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
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
                  color: Colors.white,
                  fontSize: 15,
                  fontFamily: "Poppins",
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              const Align(
                alignment: Alignment.centerRight,
                child: Icon(
                  Icons.chevron_right,
                  size: 22,
                  color: Colors.white30,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(StatoEnum? stato) {
    final label = stato?.name.toUpperCase() ?? "SCONOSCIUTO";

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 11,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
