import 'package:test/test.dart';
import 'package:openapi/openapi.dart';


/// tests for EntiApi
void main() {
  final instance = Openapi().getEntiApi();

  group(EntiApi, () {
    // Ottiene la lista di tutti gli enti
    //
    //Future<BuiltList<EnteOutput>> getAllEnti() async
    test('test getAllEnti', () async {
      // TODO
    });

  });
}
