import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:openapi/openapi.dart';

import 'presentation/mobile/Page/loginPage.dart';
import 'presentation/mobile/Page/signInPage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final dio = Dio(
      BaseOptions(
        baseUrl: "http://localhost:3000/api",
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 5),
      ),
    );

    final authApi = AuthApi(dio, standardSerializers);

    return MaterialApp(
      title: 'EcoAlert',
      debugShowCheckedModeBanner: false,

      // ROUTING CONFIGURATO
      routes: {
        '/login': (_) => LoginPage(authApi: authApi),
        '/signup': (_) => SignInPage(authApi: authApi),
      },

      // PAGINA INIZIALE
      initialRoute: '/login',
    );
  }
}
