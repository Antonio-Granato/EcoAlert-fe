import 'dart:math';
import 'dart:ui';
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

  Widget _topBar(UtenteDettaglioOutput utente) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Profilo',
                style: GoogleFonts.manrope(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Le tue informazioni personali',
                style: const TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Colors.white),
          color: const Color(0xFF0F4F45),
          onSelected: (value) {
            if (value == 'delete') _confirmDeleteUser();
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'delete',
              child: Text(
                'Elimina account',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _glassContainer({required Widget child, double? height}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.03),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white.withOpacity(0.06)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 30,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: height != null
              ? SizedBox(height: height, child: child)
              : child,
        ),
      ),
    );
  }

  Future<void> _confirmDeleteUser() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Conferma eliminazione'),
        content: const Text(
          'Sei sicuro di voler eliminare il tuo account? Questa azione è irreversibile.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annulla'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Elimina', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) await _deleteUser();
  }

  Future<void> _deleteUser() async {
    try {
      await widget.utentiApi.deleteUser(id: widget.userId);

      if (!mounted) return;

      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.green.shade50,
          title: const Text(
            'Account eliminato',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text('Il tuo account è stato eliminato con successo.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );

      _redirectToWelcome();
    } on DioException catch (e) {
      String message = 'Errore durante l\'eliminazione';
      if (e.response?.data is Map<String, dynamic>) {
        message =
            (e.response?.data as Map<String, dynamic>)['message']?.toString() ??
            message;
      }
      await _showErrorDialog(message);
    } catch (_) {
      await _showErrorDialog('Errore imprevisto durante l\'eliminazione.');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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

                  return ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1400),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 22,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _topBar(utente),
                          const SizedBox(height: 28),
                          Expanded(
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                if (constraints.maxWidth < 1000) {
                                  return SingleChildScrollView(
                                    child: Column(
                                      children: [
                                        _glassContainer(
                                          child: Column(
                                            children: [
                                              _profileHeader(utente),
                                              const SizedBox(height: 18),
                                              _infoCard(utente),
                                              const SizedBox(height: 18),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  OutlinedButton.icon(
                                                    onPressed: () {
                                                      Navigator.pushReplacement(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (_) => HomeWebPage(
                                                            authApi:
                                                                widget.authApi,
                                                            utentiApi: widget
                                                                .utentiApi,
                                                            dio: widget.dio,
                                                            segnalazioniApi: widget
                                                                .segnalazioniApi,
                                                            entiApi:
                                                                widget.entiApi,
                                                            commentiApi: widget
                                                                .commentiApi,
                                                            userId:
                                                                widget.userId,
                                                            allegatiApi: widget
                                                                .allegatiApi,
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                    style: OutlinedButton.styleFrom(
                                                      side: BorderSide(
                                                        color: Colors.white
                                                            .withOpacity(0.12),
                                                      ),
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              20,
                                                            ),
                                                      ),
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 22,
                                                            vertical: 12,
                                                          ),
                                                    ),
                                                    icon: const Icon(
                                                      Icons.home_rounded,
                                                      color: Colors.white,
                                                      size: 18,
                                                    ),
                                                    label: Text(
                                                      'Home',
                                                      style: GoogleFonts.inter(
                                                        color: Colors.white,
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 12),
                                                  ElevatedButton.icon(
                                                    onPressed:
                                                        _confirmDeleteUser,
                                                    icon: const Icon(
                                                      Icons.delete_outline,
                                                      size: 18,
                                                    ),
                                                    label: Text(
                                                      'Elimina account',
                                                      style: GoogleFonts.inter(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor:
                                                          Colors.red.shade600,
                                                      foregroundColor:
                                                          Colors.white,
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 22,
                                                            vertical: 12,
                                                          ),
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              20,
                                                            ),
                                                      ),
                                                      elevation: 6,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }

                                return Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      flex: 8,
                                      child: _glassContainer(
                                        height: 460,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            _profileHeader(utente),
                                            const SizedBox(height: 18),
                                            _infoCard(utente),
                                          ],
                                        ),
                                      ),
                                    ),
                                    // Right-side actions card removed per user request
                                  ],
                                );
                              },
                            ),
                          ),
                        ],
                      ),
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _infoRow(Icons.email, "Email", utente.email),
          const Divider(color: Colors.white24),
          _infoRow(Icons.business_outlined, "Nome Ente", utente.nomeEnte),
          const Divider(color: Colors.white24),
          _infoRow(Icons.flag, "Nazione", utente.nazione),
        ],
      ),
    );
  }

  Widget _profileHeader(UtenteDettaglioOutput utente) {
    return Center(
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 55,
              backgroundColor: Colors.white.withOpacity(0.1),
              child: Text(
                (utente.nome?.isNotEmpty ?? false)
                    ? utente.nome![0].toUpperCase()
                    : (utente.nomeEnte?.isNotEmpty ?? false)
                    ? utente.nomeEnte![0].toUpperCase()
                    : "?",
                style: const TextStyle(
                  fontSize: 42,
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            (utente.nomeEnte?.isNotEmpty == true)
                ? utente.nomeEnte!
                : "${utente.nome ?? ""} ${utente.cognome ?? ""}".trim(),
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: Colors.green.shade900.withOpacity(0.35),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.green.shade200, size: 18),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 110,
            child: Text(
              "$label",
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value ?? "-",
              style: const TextStyle(fontSize: 14, color: Colors.white70),
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
