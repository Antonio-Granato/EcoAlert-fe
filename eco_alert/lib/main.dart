import 'package:eco_alert/presentation/mobile/Page/welcomePage.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:openapi/openapi.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'presentation/mobile/Page/loginPage.dart';
import 'presentation/mobile/Page/signInPage.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final apiUrl = dotenv.env['API_URL'];
    final dio = Dio(
      BaseOptions(
        baseUrl: apiUrl!,
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 5),
      ),
    );

    final authApi = AuthApi(dio, standardSerializers);
    final utentiApi = UtentiApi(dio, standardSerializers);

    return MaterialApp(
      title: 'EcoAlert',
      debugShowCheckedModeBanner: false,

      // ROUTING CONFIGURATO
      routes: {
        '/welcome': (_) =>
            WelcomePage(authApi: authApi, utentiApi: utentiApi, dio: dio),
        '/login': (_) =>
            LoginPage(authApi: authApi, utentiApi: utentiApi, dio: dio),
        '/signup': (_) => SignInPage(authApi: authApi),
      },

      // PAGINA INIZIALE
      initialRoute: '/welcome',
    );
  }
}
