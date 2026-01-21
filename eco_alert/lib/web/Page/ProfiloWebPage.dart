import 'dart:math';
import 'package:eco_alert/web/Page/HomeWebPage.dart';
import 'package:eco_alert/web/Page/WelcomeWebPage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dio/dio.dart';
import 'package:openapi/openapi.dart';

class ProfiloWebPage extends StatefulWidget {
  final Dio dio;
  final UtentiApi utentiApi;
  final AuthApi authApi;
  final int userId;
  final SegnalazioniApi segnalazioniApi;
  final EntiApi entiApi;
  final CommentiApi commentiApi;
  final AllegatiApi allegatiApi;

  const ProfiloWebPage({
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
  State<ProfiloWebPage> createState() => _ProfiloWebPageState();
}

class _ProfiloWebPageState extends State<ProfiloWebPage>
    with SingleTickerProviderStateMixin {
  late Future<UtenteDettaglioOutput?> futureUser;
  late AnimationController _controller;
  late Animation<double> _fade;
  final Random _random = Random();
  final List<_CircleData> _circles = [];

  @override
  void initState() {
    super.initState();
    futureUser = _loadUser();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _controller.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final size = MediaQuery.of(context).size;
      for (int i = 0; i < 50; i++) {
        _circles.add(
          _CircleData(
            size: 15 + _random.nextDouble() * 35,
            left: _random.nextDouble() * size.width,
            top: _random.nextDouble() * size.height,
            opacity: 0.02 + _random.nextDouble() * 0.05,
            speedX: (_random.nextDouble() - 0.5) * 0.2,
            speedY: (_random.nextDouble() - 0.5) * 0.2,
          ),
        );
      }
      _animate();
    });
  }

  void _animate() {
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

  Future<UtenteDettaglioOutput?> _loadUser() async {
    try {
      final res = await widget.utentiApi.getUserById(id: widget.userId);
      return res.data;
    } on DioException catch (e) {
      String msg = "Errore imprevisto.";
      if (e.response?.statusCode == 404 || e.response?.statusCode == 500) {
        msg = "Utente non trovato o errore del server.";
      }
      await _showErrorDialog(msg);
      _redirectToWelcome();
      return null;
    } catch (_) {
      await _showErrorDialog("Errore imprevisto.");
      _redirectToWelcome();
      return null;
    }
  }

  void _redirectToWelcome() {
    if (mounted) {
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
            allegatiApi: widget.allegatiApi,
          ),
        ),
        (route) => false,
      );
    }
  }

  Future<void> _showErrorDialog(String message) async {
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 900;
    final contentWidth = isMobile ? size.width * 0.9 : 600.0;

    return Scaffold(
      body: Stack(
        children: [
          // Sfondo gradient con particelle
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0B3D35), Color(0xFF0A4A40)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
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
          Center(
            child: FadeTransition(
              opacity: _fade,
              child: FutureBuilder<UtenteDettaglioOutput?>(
                future: futureUser,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator(color: Colors.green);
                  }
                  final utente = snapshot.data;
                  if (utente == null) return const SizedBox();
                  return Container(
                    width: contentWidth,
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: const Color(0xFF00BFA5),
                          child: (utente.nome?.isNotEmpty ?? false)
                              ? Text(
                                  utente.nome![0].toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 44,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(
                                  Icons.apartment,
                                  size: 44,
                                  color: const Color(0xFF00332F),
                                ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          "${utente.nome ?? ""} ${utente.cognome ?? ""}".trim(),
                          style: GoogleFonts.manrope(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 24),
                        _infoCard(utente),

                        const SizedBox(height: 48),
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 22,
                          runSpacing: 16,
                          children: [
                            _actionButton(
                              label: "Home",
                              icon: Icons.home_rounded,
                              background: Colors.transparent,
                              foreground: Colors.white,
                              borderColor: Colors.white30,
                              onTap: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => HomeWebPage(
                                      authApi: widget.authApi,
                                      utentiApi: widget.utentiApi,
                                      dio: widget.dio,
                                      segnalazioniApi: widget.segnalazioniApi,
                                      entiApi: widget.entiApi,
                                      commentiApi: widget.commentiApi,
                                      userId: widget.userId,
                                      allegatiApi: widget.allegatiApi,
                                    ),
                                  ),
                                );
                              },
                            ),
                            _actionButton(
                              label: "Logout",
                              icon: Icons.logout_rounded,
                              background: const Color(0xFF00BFA5),
                              foreground: const Color(0xFF00332F),
                              onTap: _redirectToWelcome,
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoCard(UtenteDettaglioOutput utente) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _infoRow(Icons.email, "Email", utente.email),
          const Divider(color: Colors.white24),
          _infoRow(Icons.person_outline, "Nome", utente.nome),
          const Divider(color: Colors.white24),
          _infoRow(Icons.location_city, "Paese", utente.paese),
          const Divider(color: Colors.white24),
          _infoRow(Icons.flag, "Nazione", utente.nazione),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.green.shade300, size: 26),
          const SizedBox(width: 12),
          SizedBox(
            width: 100,
            child: Text(
              "$label:",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value ?? "-",
              style: const TextStyle(fontSize: 16, color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color background = Colors.transparent,
    Color foreground = Colors.white,
    Color? borderColor,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 22),
        label: Text(
          label,
          style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: background,
          foregroundColor: foreground,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: borderColor != null
                ? BorderSide(color: borderColor)
                : BorderSide.none,
          ),
          elevation: background == Colors.transparent ? 0 : 6,
        ),
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
