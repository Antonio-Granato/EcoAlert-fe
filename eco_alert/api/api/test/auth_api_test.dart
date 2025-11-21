import 'package:test/test.dart';
import 'package:openapi/openapi.dart';


/// tests for AuthApi
void main() {
  final instance = Openapi().getAuthApi();

  group(AuthApi, () {
    // Effettua il login dell'utente
    //
    //Future<LoginOutput> login(LoginInput loginInput) async
    test('test login', () async {
      // TODO
    });

    // Registra un nuovo utente
    //
    //Future<UtenteOutput> signIn(UtenteInput utenteInput) async
    test('test signIn', () async {
      // TODO
    });

  });
}
