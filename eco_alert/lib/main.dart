import 'package:eco_alert/web/Page/HomeWebPage.dart';
import 'package:eco_alert/web/Page/LoginWebPage.dart';
import 'package:eco_alert/web/Page/SignInWebPage.dart';
import 'package:eco_alert/web/Page/DettaglioSegnalazioneWeb.dart';
import 'package:flutter/foundation.dart';

import '../../mobile/Page/homePage.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'utils/web_storage.dart';
import 'package:openapi/openapi.dart';

// PAGINE MOBILE
import '../../mobile/Page/welcomePage.dart';
import '../../mobile/Page/loginPage.dart';
import '../../mobile/Page/signInPage.dart';

import '../../web/Page/WelcomeWebPage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    // Dopo il primo frame, se siamo su web e c'è un hash (/...) o ultima route salvata,
    // tentiamo di navigare verso quella route. Usiamo retry perché il Navigator
    // potrebbe non essere ancora inizializzato immediatamente.
    if (kIsWeb) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _attemptRestoreRoute(retries: 8, delayMs: 60);
      });
    }
  }

  void _attemptRestoreRoute({int retries = 5, int delayMs = 100}) async {
    // Se già non siamo su web, nothing to do
    if (!kIsWeb) return;

    final fragment = Uri.base.fragment;
    String? target;
    if (fragment.isNotEmpty) {
      target = fragment.startsWith('/') ? fragment : '/$fragment';
    } else {
      final last = WebStorage.getLastRoute();
      final storedUser = WebStorage.getUserId();
      if (last != null &&
          last.isNotEmpty &&
          (last.contains('userId=') || storedUser != null)) {
        target = last;
      }
    }

    if (target == null) return;

    for (int i = 0; i < retries; i++) {
      final nav = _navigatorKey.currentState;
      if (nav != null) {
        try {
          nav.pushReplacementNamed(target);
        } catch (_) {
          // ignore and continue
        }
        return;
      }
      await Future.delayed(Duration(milliseconds: delayMs));
    }
    // last effort: try without navigatorState (will be ignored if not ready)
    _navigatorKey.currentState?.pushReplacementNamed(target);
  }

  @override
  Widget build(BuildContext context) {
    final apiUrl = dotenv.env['API_URL'];

    if (apiUrl == null || apiUrl.isEmpty) {
      return const MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text(
              "Errore: API_URL non trovata nel file .env",
              style: TextStyle(fontSize: 18, color: Colors.red),
            ),
          ),
        ),
      );
    }

    final dio = Dio(
      BaseOptions(
        baseUrl: apiUrl,
        connectTimeout: const Duration(seconds: 6),
        receiveTimeout: const Duration(seconds: 6),
      ),
    );

    final authApi = AuthApi(dio, standardSerializers);
    final utentiApi = UtentiApi(dio, standardSerializers);
    final segnalazioniApi = SegnalazioniApi(dio, standardSerializers);
    final entiApi = EntiApi(dio, standardSerializers);
    final commentiApi = CommentiApi(dio, standardSerializers);
    final allegatiApi = AllegatiApi(dio, standardSerializers);

    // Calcola la initialRoute corretta: su web preferisci il fragment (#/...) se presente
    final initialRouteStr = kIsWeb
        ? (() {
            final fragment = Uri.base.fragment;
            final path = Uri.base.path;
            if (fragment.isNotEmpty) {
              return fragment.startsWith('/') ? fragment : '/$fragment';
            } else if (path.isNotEmpty &&
                path != '/' &&
                !path.contains('index.html')) {
              return path;
            } else {
              return '/WelcomeWeb';
            }
          })()
        : '/welcomeMobile';

    return MaterialApp(
      navigatorKey: _navigatorKey,
      title: 'EcoAlert',
      debugShowCheckedModeBanner: false,
      navigatorObservers: [_RouteSaverObserver()],
      // usa onGenerateRoute per poter passare `arguments` (es. userId)
      onGenerateRoute: (settings) {
        WidgetBuilder builder;
        // settings.name può contenere query parameters, es. '/HomeWeb?userId=123'
        final rawName = settings.name ?? '';
        final uri = Uri.parse(rawName);
        final route = uri.path; // es. '/HomeWeb'
        final query = uri.queryParameters;
        switch (route) {
          case '/welcomeMobile':
            builder = (_) => WelcomePage(
              authApi: authApi,
              utentiApi: utentiApi,
              dio: dio,
              segnalazioniApi: segnalazioniApi,
              entiApi: entiApi,
              commentiApi: commentiApi,
              allegatiApi: allegatiApi,
            );
            break;
          case '/loginMobile':
            builder = (_) => LoginPage(
              authApi: authApi,
              utentiApi: utentiApi,
              dio: dio,
              segnalazioniApi: segnalazioniApi,
              entiApi: entiApi,
              commentiApi: commentiApi,
              allegatiApi: allegatiApi,
            );
            break;
          case '/signupMobile':
            builder = (_) => SignInPage(authApi: authApi);
            break;
          case '/homeMobile':
            builder = (_) => HomePage(
              authApi: authApi,
              utentiApi: utentiApi,
              dio: dio,
              userId: 0,
              segnalazioniApi: segnalazioniApi,
              entiApi: entiApi,
              commentiApi: commentiApi,
              allegatiApi: allegatiApi,
            );
            break;
          case '/WelcomeWeb':
            builder = (_) => WelcomeWebPage(
              authApi: authApi,
              utentiApi: utentiApi,
              dio: dio,
              segnalazioniApi: segnalazioniApi,
              entiApi: entiApi,
              commentiApi: commentiApi,
              allegatiApi: allegatiApi,
            );
            break;
          case '/LoginWeb':
            builder = (_) => LoginWebPage(
              authApi: authApi,
              utentiApi: utentiApi,
              dio: dio,
              segnalazioniApi: segnalazioniApi,
              entiApi: entiApi,
              commentiApi: commentiApi,
              allegatiApi: allegatiApi,
            );
            break;
          case '/SignInWeb':
            builder = (_) => SignInWebPage(
              authApi: authApi,
              utentiApi: utentiApi,
              dio: dio,
              segnalazioniApi: segnalazioniApi,
              entiApi: entiApi,
              commentiApi: commentiApi,
              allegatiApi: allegatiApi,
            );
            break;
          case '/HomeWeb':
            // Priorità: settings.arguments (int) -> query param userId -> default 0
            int userId = 0;
            final args = settings.arguments;
            if (args is int) {
              userId = args;
            } else if (args is Map && args['userId'] is int) {
              userId = args['userId'];
            } else if (query.containsKey('userId')) {
              userId = int.tryParse(query['userId'] ?? '') ?? 0;
            }
            builder = (_) => HomeWebPage(
              utentiApi: utentiApi,
              dio: dio,
              authApi: authApi,
              segnalazioniApi: segnalazioniApi,
              entiApi: entiApi,
              commentiApi: commentiApi,
              allegatiApi: allegatiApi,
              userId: userId,
            );
            break;
          case '/DettaglioWeb':
            // legge userId e segnalazioneId dalla query
            final sid = int.tryParse(query['segnalazioneId'] ?? '0') ?? 0;
            int userIdDet = 0;
            if (query.containsKey('userId'))
              userIdDet = int.tryParse(query['userId'] ?? '0') ?? 0;
            builder = (_) => DettaglioSegnalazioneWebPage(
              utentiApi: utentiApi,
              dio: dio,
              authApi: authApi,
              segnalazioneId: sid,
              userId: userIdDet,
              segnalazioniApi: segnalazioniApi,
              entiApi: entiApi,
              commentiApi: commentiApi,
              allegatiApi: allegatiApi,
            );
            break;
          default:
            builder = (_) => WelcomeWebPage(
              authApi: authApi,
              utentiApi: utentiApi,
              dio: dio,
              segnalazioniApi: segnalazioniApi,
              entiApi: entiApi,
              commentiApi: commentiApi,
              allegatiApi: allegatiApi,
            );
        }
        return MaterialPageRoute(builder: builder, settings: settings);
      },

      // ✅ initialRoute: usa l'URL corrente su web per preservare la pagina dopo refresh
      initialRoute: initialRouteStr,
    );
  }
}

class _RouteSaverObserver extends NavigatorObserver {
  void _saveRoute(Route<dynamic>? route) {
    if (route == null) return;
    final name = route.settings.name;
    if (name != null && name.isNotEmpty && name.startsWith('/')) {
      // salva solo su web
      if (kIsWeb) WebStorage.setLastRoute(name);
    }
  }

  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);
    _saveRoute(route);
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    _saveRoute(newRoute);
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);
    _saveRoute(previousRoute);
  }
}
