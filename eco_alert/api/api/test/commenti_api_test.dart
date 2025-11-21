import 'package:test/test.dart';
import 'package:openapi/openapi.dart';


/// tests for CommentiApi
void main() {
  final instance = Openapi().getCommentiApi();

  group(CommentiApi, () {
    // Aggiunge un commento a una segnalazione
    //
    // Cittadini o enti possono aggiungere commenti solo alle segnalazioni associate ai loro ID.
    //
    //Future<CommentoOutput> createCommento(int id, int idSegnalazione, CommentoInput commentoInput) async
    test('test createCommento', () async {
      // TODO
    });

    // Elimina un commento da una segnalazione
    //
    // L'utente può eliminare solo i propri commenti sotto la segnalazione. 
    //
    //Future deleteCommento(int id, int idSegnalazione, int idCommento) async
    test('test deleteCommento', () async {
      // TODO
    });

  });
}
