import 'package:test/test.dart';
import 'package:openapi/openapi.dart';


/// tests for UtentiApi
void main() {
  final instance = Openapi().getUtentiApi();

  group(UtentiApi, () {
    // Ottiene il dettaglio di una segnalazione
    //
    // Restituisce una segnalazione specifica. - Un cittadino può vedere solo le proprie segnalazioni. - Un ente può vedere solo le segnalazioni associate a sé. 
    //
    //Future<SegnalazioneOutput> getSegnalazioneById(int id, int idSegnalazione) async
    test('test getSegnalazioneById', () async {
      // TODO
    });

    // Ottiene le segnalazioni associate all’utente
    //
    //Future<BuiltList<SegnalazioneOutput>> getSegnalazioniByUserId(int id) async
    test('test getSegnalazioniByUserId', () async {
      // TODO
    });

    // Ottiene i dettagli di un utente
    //
    //Future<UtenteDettaglioOutput> getUserById(int id) async
    test('test getUserById', () async {
      // TODO
    });

  });
}
