import 'dart:async';
import 'package:eco_alert/utils/web_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dio/dio.dart';
import 'package:openapi/openapi.dart';
import 'dart:ui';

import 'ProfiloWebPage.dart';

class HomeWebPage extends StatefulWidget {
  final Dio dio;
  final UtentiApi utentiApi;
  final AuthApi authApi;
  final int userId;
  final SegnalazioniApi segnalazioniApi;
  final EntiApi entiApi;
  final CommentiApi commentiApi;
  final AllegatiApi allegatiApi;

  const HomeWebPage({
    super.key,
    required this.utentiApi,
    required this.userId,
    required this.dio,
    required this.authApi,
    required this.segnalazioniApi,
    required this.entiApi,
    required this.commentiApi,
    required this.allegatiApi,
  });

  @override
  State<HomeWebPage> createState() => _HomeWebPageState();
}

class _HomeWebPageState extends State<HomeWebPage> {
  Future<List<SegnalazioneOutput>> futureReports = Future.value([]);

  late Future<UtenteDettaglioOutput?> futureUser;
  int inserite = 0;
  int ricevute = 0;
  int sospese = 0;
  int chiuse = 0;
  StatoEnum? filtroStato;
  Error? error;

  @override
  void initState() {
    super.initState();
    futureUser = _loadUser();
    _refreshReports();
  }

  Future<UtenteDettaglioOutput?> _loadUser() async {
    try {
      final res = await widget.utentiApi.getMe();
      return res.data;
    } catch (_) {
      return null;
    }
  }

  Future<List<SegnalazioneOutput>> _loadReports() async {
    final res = await widget.entiApi.getSegnalazioniByEnteAndStato(
      idEnte: widget.userId,
    );

    return List<SegnalazioneOutput>.from(res.data ?? []);
  }

  Future<void> _refreshReports() async {
    try {
      final reports = await _loadReports();

      final stats = await widget.entiApi.getSegnalazioniStatsByEnte(
        idEnte: widget.userId,
      );

      final data = stats.data;

      setState(() {
        inserite = data?.INSERITO ?? 0;
        ricevute = data?.RICEVUTO ?? 0;
        sospese = data?.SOSPESO ?? 0;
        chiuse = data?.CHIUSO ?? 0;

        futureReports = Future.value(reports);
        error = null;
      });
    } catch (e) {
      setState(() {
        futureReports = Future.value([]);
        error = Error((b) => b..message = "Errore caricamento segnalazioni");
      });
    }
  }

  Widget _statsCard(
    String title,
    int value,
    Color color,
    IconData icon,
    StatoEnum stato,
  ) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          if (value == 0) return; // non fare nulla se non ci sono segnalazioni

          setState(() {
            if (filtroStato == stato) {
              filtroStato = null;
            } else {
              filtroStato = stato;
            }
          });
        },
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: filtroStato == stato
                ? color.withOpacity(0.25)
                : Colors.white.withOpacity(0.04),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 10),
              Text(
                value.toString(),
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 6),
              Text(title, style: const TextStyle(color: Colors.white70)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _mapCard(Widget child) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.07),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.10)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: SizedBox(width: double.infinity, child: child),
        ),
      ),
    );
  }

  void _logout() {
    WebStorage.clearAll();
    Navigator.pushNamedAndRemoveUntil(context, '/WelcomeWeb', (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 900;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          // Base gradient (same used in DettaglioSegnalazione)
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0B3D35), // verde profondo
                  Color(0xFF0F4F45), // leggermente più chiaro
                  Color(0xFF08332C), // profondità
                ],
              ),
            ),
          ),

          // Glow soft superiore
          Positioned(
            top: -250,
            left: -200,
            child: Container(
              width: 600,
              height: 600,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.greenAccent.withOpacity(0.12),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Glow inferiore
          Positioned(
            bottom: -300,
            right: -250,
            child: Container(
              width: 700,
              height: 700,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.tealAccent.withOpacity(0.10),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.dashboard_customize_rounded,
                            color: Colors.white,
                            size: isMobile ? 28 : 36,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "Dashboard Segnalazioni",
                            style: GoogleFonts.manrope(
                              fontSize: isMobile ? 24 : 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      // qui il resto del Row: logout e avatar
                      Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: _logout,
                            icon: const Icon(
                              Icons.logout_outlined,
                              color: Colors.white,
                            ),
                            label: Text(
                              "Logout",
                              style: GoogleFonts.manrope(
                                fontSize: isMobile ? 14 : 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: BorderSide(
                                  color: Colors.white.withOpacity(0.3),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),

                          FutureBuilder<UtenteDettaglioOutput?>(
                            future: futureUser,
                            builder: (context, snap) {
                              final nomeEnte =
                                  (snap.data?.nomeEnte != null &&
                                      snap.data!.nomeEnte!.isNotEmpty)
                                  ? snap.data!.nomeEnte!
                                  : null;

                              return Row(
                                children: [
                                  InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => ProfiloWebPage(
                                            utentiApi: widget.utentiApi,
                                            userId: widget.userId,
                                            dio: widget.dio,
                                            authApi: widget.authApi,
                                            segnalazioniApi:
                                                widget.segnalazioniApi,
                                            entiApi: widget.entiApi,
                                            commentiApi: widget.commentiApi,
                                            allegatiApi: widget.allegatiApi,
                                          ),
                                        ),
                                      );
                                    },
                                    borderRadius: BorderRadius.circular(50),
                                    child: const CircleAvatar(
                                      radius: 24,
                                      backgroundColor: Colors.transparent,
                                      child: Icon(
                                        Icons.account_circle_outlined,
                                        color: Colors.white,
                                        size: 30,
                                      ),
                                    ),
                                  ),
                                  if (nomeEnte != null) ...[
                                    const SizedBox(width: 10),
                                    Text(
                                      nomeEnte,
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // CONTENT
                  Expanded(
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
                              error!.message ?? "Errore",
                              style: const TextStyle(color: Colors.white),
                            ),
                          );
                        }

                        final allReports = snapshot.data ?? [];

                        final reports = filtroStato == null
                            ? allReports
                            : allReports
                                  .where((r) => r.stato == filtroStato)
                                  .toList();

                        if (reports.isEmpty) {
                          return const Center(
                            child: Text(
                              "Nessuna segnalazione disponibile",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 18,
                              ),
                            ),
                          );
                        }

                        // Responsive: due colonne su desktop
                        if (!isMobile && screenWidth > 1200) {
                          return Row(
                            children: [
                              Expanded(
                                flex: 8,
                                child: FutureBuilder<UtenteDettaglioOutput?>(
                                  future: futureUser,
                                  builder: (context, snap) {
                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            _statsCard(
                                              "Inserite",
                                              inserite,
                                              Colors.greenAccent,
                                              Icons.fiber_new_rounded,
                                              StatoEnum.INSERITO,
                                            ),
                                            const SizedBox(width: 12),
                                            _statsCard(
                                              "Ricevute",
                                              ricevute,
                                              Colors.blueAccent,
                                              Icons.work_rounded,
                                              StatoEnum.RICEVUTO,
                                            ),
                                            const SizedBox(width: 12),
                                            _statsCard(
                                              "Sospese",
                                              sospese,
                                              Colors.orangeAccent,
                                              Icons.pause_circle_filled_rounded,
                                              StatoEnum.SOSPESO,
                                            ),
                                            const SizedBox(width: 12),
                                            _statsCard(
                                              "Chiuse",
                                              chiuse,
                                              Colors.redAccent,
                                              Icons.check_circle_rounded,
                                              StatoEnum.CHIUSO,
                                            ),
                                          ],
                                        ),

                                        const SizedBox(height: 15),

                                        AspectRatio(
                                          aspectRatio: 16 / 8,
                                          child: _mapCard(
                                            FlutterMapWidget(
                                              segnalazioni: reports,
                                              utentiApi: widget.utentiApi,
                                              userId: widget.userId,
                                              dio: widget.dio,
                                              authApi: widget.authApi,
                                              segnalazioniApi:
                                                  widget.segnalazioniApi,
                                              entiApi: widget.entiApi,
                                              commentiApi: widget.commentiApi,
                                              allegatiApi: widget.allegatiApi,
                                              onRefresh: _refreshReports,
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(width: 24),
                              Expanded(
                                flex: 4,
                                child: SizedBox(
                                  height: double.infinity,
                                  child: SingleChildScrollView(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8,
                                    ),
                                    child: Container(
                                      padding: const EdgeInsets.all(18),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.03),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: Colors.white.withOpacity(0.04),
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                              0.04,
                                            ),
                                            blurRadius: 12,
                                            offset: const Offset(0, 6),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        children: List.generate(
                                          reports.length,
                                          (i) {
                                            return Padding(
                                              padding: const EdgeInsets.only(
                                                bottom: 12,
                                              ),
                                              child: _SegnalazioneCardWeb(
                                                segnalazione: reports[i],
                                                utentiApi: widget.utentiApi,
                                                userId: widget.userId,
                                                dio: widget.dio,
                                                authApi: widget.authApi,
                                                segnalazioniApi:
                                                    widget.segnalazioniApi,
                                                entiApi: widget.entiApi,
                                                commentiApi: widget.commentiApi,
                                                allegatiApi: widget.allegatiApi,
                                                onRefresh: _refreshReports,
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }

                        // Mobile / tablet layout: colonna unica
                        return Column(
                          children: [
                            Expanded(
                              flex: 1,
                              child: FutureBuilder<UtenteDettaglioOutput?>(
                                future: futureUser,
                                builder: (context, snap) {
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        child: _mapCard(
                                          FlutterMapWidget(
                                            segnalazioni: reports,
                                            utentiApi: widget.utentiApi,
                                            userId: widget.userId,
                                            dio: widget.dio,
                                            authApi: widget.authApi,
                                            segnalazioniApi:
                                                widget.segnalazioniApi,
                                            entiApi: widget.entiApi,
                                            commentiApi: widget.commentiApi,
                                            allegatiApi: widget.allegatiApi,
                                            onRefresh: _refreshReports,
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 16),
                            Expanded(
                              flex: 1,
                              child: SingleChildScrollView(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.03),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.04),
                                    ),
                                  ),
                                  child: Column(
                                    children: List.generate(reports.length, (
                                      i,
                                    ) {
                                      return Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 12,
                                        ),
                                        child: _SegnalazioneCardWeb(
                                          segnalazione: reports[i],
                                          utentiApi: widget.utentiApi,
                                          userId: widget.userId,
                                          dio: widget.dio,
                                          authApi: widget.authApi,
                                          segnalazioniApi:
                                              widget.segnalazioniApi,
                                          entiApi: widget.entiApi,
                                          commentiApi: widget.commentiApi,
                                          allegatiApi: widget.allegatiApi,
                                          onRefresh: _refreshReports,
                                        ),
                                      );
                                    }),
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
            ),
          ),
        ],
      ),
    );
  }
}

class FlutterMapWidget extends StatelessWidget {
  final List<SegnalazioneOutput> segnalazioni;
  final UtentiApi utentiApi;
  final AuthApi authApi;
  final Dio dio;
  final int userId;
  final SegnalazioniApi segnalazioniApi;
  final EntiApi entiApi;
  final CommentiApi commentiApi;
  final AllegatiApi allegatiApi;
  final Future<void> Function()? onRefresh;

  const FlutterMapWidget({
    super.key,
    required this.segnalazioni,
    required this.utentiApi,
    required this.userId,
    required this.dio,
    required this.authApi,
    required this.segnalazioniApi,
    required this.entiApi,
    required this.commentiApi,
    required this.allegatiApi,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final valid = segnalazioni
        .where((s) => s.latitudine != null && s.longitudine != null)
        .toList();

    if (valid.isEmpty) {
      return const Center(
        child: Text(
          "Nessuna segnalazione sulla mappa",
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    final first = valid.first;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.04)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: SizedBox.expand(
          child: FlutterMap(
            options: MapOptions(
              center: LatLng(first.latitudine!, first.longitudine!),
              zoom: 12,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.app',
              ),
              MarkerLayer(
                markers: valid.map((s) {
                  return Marker(
                    point: LatLng(s.latitudine!, s.longitudine!),
                    width: 48,
                    height: 48,
                    child: IconButton(
                      icon: const Icon(
                        Icons.location_on,
                        color: Color(0xFF00BFA5),
                      ),
                      onPressed: () async {
                        final route =
                            '/DettaglioWeb?userId=$userId&segnalazioneId=${s.id}';
                        final result = await Navigator.pushNamed(
                          context,
                          route,
                        );
                        if (result == true) await onRefresh?.call();
                      },
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
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
  final AllegatiApi allegatiApi;
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
            final route = '/DettaglioWeb?userId=$userId&segnalazioneId=${s.id}';
            final result = await Navigator.pushNamed(context, route);
            if (result == true && onRefresh != null) await onRefresh?.call();
          }
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.02),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.04)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 6),
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
                  color: Colors.white70,
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
                  color: Colors.white54,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(StatoEnum? stato) {
    // glass-like soft background colors with white text
    final mapBg = {
      StatoEnum.INSERITO: const Color.fromRGBO(46, 125, 100, 0.14),
      StatoEnum.RICEVUTO: const Color.fromRGBO(13, 71, 161, 0.14),
      StatoEnum.SOSPESO: const Color.fromRGBO(171, 139, 0, 0.12),
      StatoEnum.CHIUSO: const Color.fromRGBO(183, 28, 28, 0.14),
    };

    final mapBorder = {
      StatoEnum.INSERITO: const Color.fromRGBO(46, 125, 100, 0.45),
      StatoEnum.RICEVUTO: const Color.fromRGBO(13, 71, 161, 0.45),
      StatoEnum.SOSPESO: const Color.fromRGBO(171, 139, 0, 0.45),
      StatoEnum.CHIUSO: const Color.fromRGBO(183, 28, 28, 0.45),
    };

    final colorBg = mapBg[stato] ?? Colors.white.withOpacity(0.06);
    final borderColor = mapBorder[stato] ?? Colors.white24;
    final colorText = Colors.white;
    final icon =
        {
          StatoEnum.INSERITO: Icons.fiber_new_rounded,
          StatoEnum.RICEVUTO: Icons.work_rounded,
          StatoEnum.SOSPESO: Icons.pause_circle_filled_rounded,
          StatoEnum.CHIUSO: Icons.check_circle_rounded,
        }[stato] ??
        Icons.help_outline;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: colorBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: colorText),
          const SizedBox(width: 6),
          Text(
            stato?.name.toUpperCase() ?? "SCONOSCIUTO",
            style: TextStyle(
              color: colorText,
              fontWeight: FontWeight.w600,
              fontSize: 12,
              fontFamily: "Poppins",
            ),
          ),
        ],
      ),
    );
  }
}

// ignore: unused_element
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
