import 'package:eco_alert/presentation/mobile/Page/homePage.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:openapi/openapi.dart';

// PAGINE
import 'package:eco_alert/presentation/mobile/Page/welcomePage.dart';
import 'package:eco_alert/presentation/mobile/Page/loginPage.dart';
import 'package:eco_alert/presentation/mobile/Page/signInPage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Carica variabili d'ambiente
  await dotenv.load(fileName: ".env");

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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

    // Configurazione Dio
    final dio = Dio(
      BaseOptions(
        baseUrl: apiUrl,
        connectTimeout: const Duration(seconds: 6),
        receiveTimeout: const Duration(seconds: 6),
      ),
    );

    // API generate da OpenAPI
    final authApi = AuthApi(dio, standardSerializers);
    final utentiApi = UtentiApi(dio, standardSerializers);
    final segnalazioniApi = SegnalazioniApi(dio, standardSerializers);
    final entiApi = EntiApi(dio, standardSerializers);
    final commentiApi = CommentiApi(dio, standardSerializers);

    return MaterialApp(
      title: 'EcoAlert',
      debugShowCheckedModeBanner: false,

      // 🔥 ROUTER
      routes: {
        '/welcome': (_) => WelcomePage(
          authApi: authApi,
          utentiApi: utentiApi,
          dio: dio,
          segnalazioniApi: segnalazioniApi,
          entiApi: entiApi,
          commentiApi: commentiApi,
        ),
        '/login': (_) => LoginPage(
          authApi: authApi,
          utentiApi: utentiApi,
          dio: dio,
          segnalazioniApi: segnalazioniApi,
          entiApi: entiApi,
          commentiApi: commentiApi,
        ),
        '/signup': (_) => SignInPage(authApi: authApi),
        '/home': (_) => HomePage(
          authApi: authApi,
          utentiApi: utentiApi,
          dio: dio,
          userId: 0,
          segnalazioniApi: segnalazioniApi,
          entiApi: entiApi,
          commentiApi: commentiApi,
        ), // Aggiungi questa riga con userId appropriato
      },

      // 🔥 Pagina iniziale
      initialRoute: '/welcome',
    );
  }
}
