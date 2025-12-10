import 'package:eco_alert/web/Page/HomeWebPage.dart';
import 'package:eco_alert/web/Page/LoginWebPage.dart';
import 'package:eco_alert/web/Page/SignInWebPage.dart';
import 'package:flutter/foundation.dart';

import '../../mobile/Page/homePage.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
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

    return MaterialApp(
      title: 'EcoAlert',
      debugShowCheckedModeBanner: false,

      routes: {
        '/welcomeMobile': (_) => WelcomePage(
          authApi: authApi,
          utentiApi: utentiApi,
          dio: dio,
          segnalazioniApi: segnalazioniApi,
          entiApi: entiApi,
          commentiApi: commentiApi,
        ),
        '/loginMobile': (_) => LoginPage(
          authApi: authApi,
          utentiApi: utentiApi,
          dio: dio,
          segnalazioniApi: segnalazioniApi,
          entiApi: entiApi,
          commentiApi: commentiApi,
        ),
        '/signupMobile': (_) => SignInPage(authApi: authApi),
        '/homeMobile': (_) => HomePage(
          authApi: authApi,
          utentiApi: utentiApi,
          dio: dio,
          userId: 0,
          segnalazioniApi: segnalazioniApi,
          entiApi: entiApi,
          commentiApi: commentiApi,
        ),

        // ✅ ROUTE WEB
        '/WelcomeWeb': (_) => WelcomeWebPage(
          authApi: authApi,
          utentiApi: utentiApi,
          dio: dio,
          segnalazioniApi: segnalazioniApi,
          entiApi: entiApi,
          commentiApi: commentiApi,
        ),
        '/LoginWeb': (_) => LoginWebPage(
          authApi: authApi,
          utentiApi: utentiApi,
          dio: dio,
          segnalazioniApi: segnalazioniApi,
          entiApi: entiApi,
          commentiApi: commentiApi,
        ),
        '/SignInWeb': (_) => SignInWebPage(
          authApi: authApi,
          utentiApi: utentiApi,
          dio: dio,
          segnalazioniApi: segnalazioniApi,
          entiApi: entiApi,
          commentiApi: commentiApi,
        ),
        '/HomeWeb': (_) => HomeWebPage(
          utentiApi: utentiApi,
          dio: dio,
          authApi: authApi,
          segnalazioniApi: segnalazioniApi,
          entiApi: entiApi,
          commentiApi: commentiApi,
          userId: 0,
        ),
      },

      // ✅ UNA SOLA initialRoute
      initialRoute: kIsWeb ? '/WelcomeWeb' : '/welcomeMobile',
    );
  }
}
