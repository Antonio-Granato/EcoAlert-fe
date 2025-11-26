import 'package:eco_alert/presentation/mobile/Page/welcomePage.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:openapi/openapi.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:openapi/urlDinamico.dart';
import 'presentation/mobile/Page/loginPage.dart';
import 'presentation/mobile/Page/signInPage.dart';

void main() async {
  await dotenv.load(fileName: ".env");

  final apiUrl = dotenv.env['API_URL'] ?? getBaseUrl();
  final dio = Dio(
    BaseOptions(
      baseUrl: apiUrl,
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
    ),
  );

  final authApi = AuthApi(dio, standardSerializers);

  runApp(MyApp(authApi: authApi));
}

class MyApp extends StatelessWidget {
  final AuthApi authApi;
  const MyApp({super.key, required this.authApi});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EcoAlert',
      debugShowCheckedModeBanner: false,
      routes: {
        '/welcome': (_) => WelcomePage(authApi: authApi),
        '/login': (_) => LoginPage(authApi: authApi),
        '/signup': (_) => SignInPage(authApi: authApi),
      },
      initialRoute: '/welcome',
    );
  }
}
