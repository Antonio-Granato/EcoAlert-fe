# 🦋 EcoAlert Frontend

Frontend mobile e web del progetto **EcoAlert**, sviluppato in **Flutter**.  
Permette ai cittadini di segnalare problemi ambientali e agli enti locali di gestirli tramite una dashboard interattiva.

## ⚙️ Tecnologie utilizzate
- **Flutter 3.x**
- **Dart**
- **Provider / Riverpod** (state management)
- **Google Maps SDK** o **Leaflet**
- **HTTP package** per chiamate REST

## 📁 Struttura del progetto

EcoAlert-fe/

├── lib/

│ ├── main.dart # entry point

│ ├── screens/ # schermate principali

│ ├── models/ # modelli dati (User, Segnalazione, ecc.)

│ ├── services/ # chiamate HTTP al backend

│ └── widgets/ # componenti UI riutilizzabili

├── assets/

│ └── images/

├── pubspec.yaml

└── README.md

## 🚀 Avvio del progetto

### 1️⃣ Clonare il repository
**git clone https://github.com/Antonio1373/EcoAlert-fe.git**

cd EcoAlert-fe

### 2️⃣ Installare le dipendenze
flutter pub get

### 3️⃣ Avviare l’app
flutter run

Puoi testarla su:
- Android Emulator
- iOS Simulator
- Browser Web

#### 📱 Funzionalità principali
Registrazione e login utenti

Creazione di nuove segnalazioni

Visualizzazione delle segnalazioni su mappa

Aggiornamento stato (solo per amministratori)

Upload di immagini o video

### 👩‍💻 Autori

Progetto realizzato da Antonio Granato per il corso di Informatica – EcoAlert Project.
