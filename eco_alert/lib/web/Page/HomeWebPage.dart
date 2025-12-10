import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:openapi/openapi.dart';
import 'package:dio/dio.dart';

import 'welcomeWebPage.dart';

class HomeWebPage extends StatefulWidget {
  final Dio dio;
  final UtentiApi utentiApi;
  final AuthApi authApi;
  final int userId;
  final SegnalazioniApi segnalazioniApi;
  final EntiApi entiApi;
  final CommentiApi commentiApi;

  const HomeWebPage({
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
  State<HomeWebPage> createState() => _HomeWebPageState();
}

class _HomeWebPageState extends State<HomeWebPage>
    with SingleTickerProviderStateMixin {
  Future<List<SegnalazioneOutput>> futureReports = Future.value([]);
  Error? error;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  final Random _random = Random();
  final List<_CircleData> _circles = [];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshReports(initial: true);
      final size = MediaQuery.of(context).size;
      for (int i = 0; i < 40; i++) {
        _circles.add(
          _CircleData(
            size: 30 + _random.nextDouble() * 60,
            left: _random.nextDouble() * size.width,
            top: _random.nextDouble() * size.height,
            opacity: 0.03 + _random.nextDouble() * 0.05,
            speedX: (_random.nextDouble() - 0.5) * 0.25,
            speedY: (_random.nextDouble() - 0.5) * 0.25,
          ),
        );
      }
      _animateCircles();
    });

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
  }

  void _animateCircles() {
    final size = MediaQuery.of(context).size;
    _controller.addListener(() {
      setState(() {
        for (final c in _circles) {
          c.left += c.speedX;
          c.top += c.speedY;
          if (c.left < 0 || c.left > size.width - c.size) c.speedX *= -1;
          if (c.top < 0 || c.top > size.height - c.size) c.speedY *= -1;
        }
      });
    });
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
              ..message = "Non ci sono ancora segnalazioni.",
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
        builder: (_) => WelcomeWebPage(
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
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 650;
    final titleSize = isMobile ? 32.0 : 48.0;

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF00BFA5),
        onPressed: () {},
        child: const Icon(Icons.add, color: Colors.white),
        /*onPressed: () async {
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
        },*/
      ),
      body: Stack(
        children: [
          // Sfondo gradiente dark
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
          // Cerchi ambientali
          ..._circles.map(
            (c) => Positioned(
              left: c.left,
              top: c.top,
              child: Container(
                width: c.size,
                height: c.size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.white.withOpacity(c.opacity),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Contenuto principale
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.logout, color: Colors.white),
                          tooltip: "Logout",
                          onPressed: _logout,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            "Le tue segnalazioni",
                            style: GoogleFonts.manrope(
                              fontSize: titleSize,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        CircleAvatar(
                          backgroundColor: const Color(0xFF00BFA5),
                          child: IconButton(
                            icon: const Icon(Icons.person, color: Colors.white),
                            onPressed: () {},
                            /*onPressed: () {
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
                            },*/
                          ),
                        ),
                      ],
                    ),
                  ),
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
                                color: Color(0xFF00BFA5),
                              ),
                            );
                          }
                          if (error != null) {
                            return Center(
                              child: Text(
                                error!.message ??
                                    "Errore durante il caricamento",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            );
                          }
                          final items = snapshot.data ?? [];
                          if (items.isEmpty) {
                            return const Center(
                              child: Text(
                                "Non ci sono segnalazioni da mostrare",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            );
                          }
                          return ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: items.length,
                            itemBuilder: (context, i) => Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: _SegnalazioneCardWeb(
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
        ],
      ),
    );
  }
}

// Card segnalazione Web
class _SegnalazioneCardWeb extends StatelessWidget {
  final SegnalazioneOutput segnalazione;
  final UtentiApi utentiApi;
  final AuthApi authApi;
  final Dio dio;
  final int userId;
  final SegnalazioniApi segnalazioniApi;
  final EntiApi entiApi;
  final CommentiApi commentiApi;
  final Future<void> Function()? onRefresh;

  const _SegnalazioneCardWeb({
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
      shadowColor: Colors.black.withOpacity(0.3),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: () async {
          /* if (s.id != null) {
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
            if (result == true && onRefresh != null) await onRefresh?.call();
          }*/
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF0B3D35),
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
                  color: Colors.white.withOpacity(0.8),
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
                  size: 28,
                  color: Colors.white70,
                ),
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
          StatoEnum.INSERITO: Colors.green.shade700,
          StatoEnum.PRESO_IN_CARICO: Colors.blue.shade700,
          StatoEnum.SOSPESO: Colors.yellow.shade700,
          StatoEnum.CHIUSO: Colors.red.shade700,
        }[stato] ??
        Colors.grey.shade600;

    final colorText = Colors.white;
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

class _CircleData {
  double size;
  double left;
  double top;
  double opacity;
  double speedX;
  double speedY;

  _CircleData({
    required this.size,
    required this.left,
    required this.top,
    required this.opacity,
    required this.speedX,
    required this.speedY,
  });
}
