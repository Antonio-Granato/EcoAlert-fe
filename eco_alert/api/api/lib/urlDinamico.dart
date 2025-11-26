import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

String getBaseUrl() {
  if (kIsWeb) {
    return 'http://localhost:3000/api';
  } else if (Platform.isAndroid) {
    return 'http://10.0.2.2:3000/api'; // Android Emulator
  } else if (Platform.isIOS) {
    return 'http://localhost:3000/api'; // iOS Simulator
  } else {
    return 'http://localhost:3000/api';
  }
}
