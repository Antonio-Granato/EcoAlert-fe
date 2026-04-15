# EcoAlert - Frontend

Applicazione mobile sviluppata in Flutter per la segnalazione di problematiche ambientali da parte dei cittadini.

Il progetto è stato realizzato come tesi di laurea in Informatica con l’obiettivo di migliorare la comunicazione tra cittadini e amministrazioni locali.

---

## Descrizione

EcoAlert consente agli utenti di segnalare problemi ambientali in modo semplice e rapido, includendo posizione geografica, descrizioni e immagini.

L'applicazione è progettata per incentivare la partecipazione civica e supportare una gestione più efficiente del territorio.

---

## Tecnologie utilizzate

* Flutter (Dart)
* Material Design
* REST API (Spring Boot)
* OpenAPI Generator (dart-dio)

---

## Struttura del progetto

```text
eco_alert/
 ├── lib/                # Codice principale dell'applicazione
 ├── assets/images/      # Risorse statiche (immagini)
 ├── api/                # Client API generato tramite OpenAPI
 ├── android/            # Configurazione Android
 ├── ios/                # Configurazione iOS
 ├── web/                # Supporto web
 ├── windows/            # Supporto Windows
 ├── macos/              # Supporto macOS
 ├── test/               # Test
 ├── pubspec.yaml        # Dipendenze progetto
```

---

## Backend

Il backend del progetto è disponibile al seguente repository:

https://github.com/Antonio1373/EcoAlert-be

---

## Generazione del client API

Il client per la comunicazione con il backend viene generato automaticamente a partire dalla specifica OpenAPI.

### Generazione del client

```bash
cd eco_alert/api
java -jar openapi-generator-cli.jar generate \
  -i eco-alert-openapi.yaml \
  -g dart-dio \
  -o api \
  --additional-properties=nullSafety=true
```

### Generazione dei file aggiuntivi

```bash
cd eco_alert/api
flutter pub run build_runner build --delete-conflicting-outputs
```

Nota: i file generati non devono essere modificati manualmente, in quanto verranno sovrascritti.

---

## Installazione e avvio

Clonare il repository:

```bash
git clone https://github.com/Antonio-Granato/EcoAlert-fe.git
```

Accedere alla cartella del progetto:

```bash
cd EcoAlert-fe/eco_alert
```

Installare le dipendenze:

```bash
flutter pub get
```

Avviare l’applicazione:

```bash
flutter run
```

---

## Funzionalità principali

* Invio di segnalazioni geolocalizzate
* Inserimento di descrizioni dettagliate
* Upload di immagini
* Autenticazione utente
* Visualizzazione delle segnalazioni

---

## Obiettivo

L’obiettivo del progetto è fornire uno strumento digitale che faciliti la collaborazione tra cittadini e pubblica amministrazione nella gestione delle problematiche ambientali.

---

## Autore

Antonio Granato
Laureando in Informatica

---

## Licenza

Progetto sviluppato a scopo didattico.
