import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dio/dio.dart';
import 'package:openapi/openapi.dart';

import 'DettaglioSegnalazioneWeb.dart';
import 'ProfiloWebPage.dart';
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

class _HomeWebPageState extends State<HomeWebPage> {
  Future<List<SegnalazioneOutput>> futureReports = Future.value([]);

  late final isMobile = MediaQuery.of(context).size.width < 900;
  Error? error;

  @override
  void initState() {
    super.initState();
    _refreshReports();
  }

  Future<void> _refreshReports() async {
    try {
      final res = await widget.utentiApi.getSegnalazioniByUserId(
        id: widget.userId,
      );
      setState(() {
        futureReports = Future.value(
          List<SegnalazioneOutput>.from(res.data ?? []),
        );
        error = null;
      });
    } on DioException catch (ex) {
      setState(() {
        error = Error(
          (b) => b
            ..code = ex.response?.statusCode ?? 0
            ..message =
                (ex.response?.data as Map?)?['message'] ??
                "Errore caricamento segnalazioni",
        );
        futureReports = Future.value([]);
      });
    } catch (_) {
      setState(() {
        error = Error((b) => b..message = "Errore imprevisto");
        futureReports = Future.value([]);
      });
    }
  }

  void _logout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => WelcomeWebPage(
          dio: widget.dio,
          authApi: widget.authApi,
          utentiApi: widget.utentiApi,
          segnalazioniApi: widget.segnalazioniApi,
          entiApi: widget.entiApi,
          commentiApi: widget.commentiApi,
        ),
      ),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 900;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0B3D35), Color(0xFF0F2F2B)],
          ),
        ),
        child: SafeArea(
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
                            foreground: Paint()
                              ..shader = LinearGradient(
                                colors: [Color(0xFF00BFA5), Color(0xFF00FFC1)],
                              ).createShader(Rect.fromLTWH(0, 0, 300, 0)),
                            shadows: [
                              Shadow(
                                offset: Offset(2, 2),
                                blurRadius: 4,
                                color: Colors.black38,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    // qui il resto del Row: logout e avatar
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: _logout,
                          icon: const Icon(Icons.logout),
                          label: const Text("Logout"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            foregroundColor: Colors.white,
                            elevation: 3,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
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
                                  segnalazioniApi: widget.segnalazioniApi,
                                  entiApi: widget.entiApi,
                                  commentiApi: widget.commentiApi,
                                ),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(50),
                          child: CircleAvatar(
                            radius: 24,
                            backgroundColor: Colors.white,
                            child: const Icon(
                              Icons.person,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // CONTENT
                Expanded(
                  child: FutureBuilder<List<SegnalazioneOutput>>(
                    future: futureReports,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
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

                      final reports = snapshot.data ?? [];

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
                              flex: 2,
                              child: FlutterMapWidget(
                                segnalazioni: reports,
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
                            const SizedBox(width: 24),
                            Expanded(
                              flex: 1,
                              child: ListView.builder(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                                itemCount: reports.length,
                                itemBuilder: (context, i) => Padding(
                                  padding: const EdgeInsets.only(
                                    bottom: 16,
                                  ), // spazio tra card
                                  child: _SegnalazioneCardWeb(
                                    segnalazione: reports[i],
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
                            child: FlutterMapWidget(
                              segnalazioni: reports,
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
                          const SizedBox(height: 16),
                          Expanded(
                            flex: 1,
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              itemCount: reports.length,
                              itemBuilder: (context, i) => _SegnalazioneCardWeb(
                                segnalazione: reports[i],
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

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
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
                width: 40,
                height: 40,
                child: IconButton(
                  icon: const Icon(Icons.location_on, color: Colors.red),
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DettaglioSegnalazioneWebPage(
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
                    if (result == true) await onRefresh?.call();
                  },
                ),
              );
            }).toList(),
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
      elevation: 10,
      shadowColor: Colors.black.withOpacity(0.3),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: () async {
          if (s.id != null) {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => DettaglioSegnalazioneWebPage(
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
          }
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(20),
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
