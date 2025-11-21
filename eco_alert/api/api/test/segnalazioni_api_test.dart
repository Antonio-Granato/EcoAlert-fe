import 'package:test/test.dart';
import 'package:openapi/openapi.dart';


/// tests for SegnalazioniApi
void main() {
  final instance = Openapi().getSegnalazioniApi();

  group(SegnalazioniApi, () {
    // Crea una nuova segnalazione
    //
    //Future<SegnalazioneOutput> createSegnalazione(int id, SegnalazioneInput segnalazioneInput) async
    test('test createSegnalazione', () async {
      // TODO
    });

    // Elimina una segnalazione appartenente al cittadino
    //
    // Un cittadino può eliminare **solo** una sua segnalazione **non in stato di inserito**. Un ente non può eliminare alcuna segnalazione. 
    //
    //Future deleteSegnalazione(int id, int idSegnalazione) async
    test('test deleteSegnalazione', () async {
      // TODO
    });

    // Modifica una segnalazione del cittadino
    //
    // Un cittadino può modificare **solo le proprie segnalazioni non chiuse**. Solo il titolo, la descrizione, la latitudine, la longitudine e l'ente associato possono essere aggiornati. 
    //
    //Future<SegnalazioneOutput> updateSegnalazione(int id, int idSegnalazione, SegnalazioneInput segnalazioneInput) async
    test('test updateSegnalazione', () async {
      // TODO
    });

    // Aggiorna lo stato e/o la ditta di una segnalazione
    //
    // Permette a un ente di aggiornare lo stato di una segnalazione (da INSERITO a PRESO_IN_CARICO, SOSPESO o CHIUSO) e di inserire la ditta che risolve la segnalazione. 
    //
    //Future<SegnalazioneOutput> updateSegnalazioneEnte(int idSegnalazione, int idEnte, SegnalazioneUpdateInputEnte segnalazioneUpdateInputEnte) async
    test('test updateSegnalazioneEnte', () async {
      // TODO
    });

  });
}
