import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


import 'package:get_storage/get_storage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:ridefromobd/pages/main_page.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

class RideHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)..maxConnectionsPerHost = 5;
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  // HttpOverrides.global = RideHttpOverrides();

  await Firebase.initializeApp();
  // await GetStorage.init();
  // await Obd.init(); // 2022.07.15 Lunaric : ObdInit

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // KakaoSdk.init(nativeAppKey: ApiUrl.KAKAO_API_KEY);

  runZonedGuarded(() {
    runApp(MainPage());
  }, FirebaseCrashlytics.instance.recordError);
}