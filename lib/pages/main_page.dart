import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ridefromobd/controllers/globals/storage_controller.dart';
import 'package:ridefromobd/routes/app_pages.dart';
import 'package:ridefromobd/styles/ride_theme.dart';


class MainPage extends StatelessWidget {
  const MainPage({Key? key}) : super(key: key);
  

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: Size(360, 800),
      builder: (BuildContext c, widget) => GetMaterialApp(
        debugShowCheckedModeBanner: false,
        theme: rideTheme(context),
        initialRoute: GetStorage().read('MEMBER_SEQ') == null ? AppRoutes.PERMISSION : AppRoutes.INTRO,
        initialBinding: BindingsBuilder(() {
          Get.put(StorageController());
        }),
        getPages: AppPages.routes,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en'),
          Locale('ko'),
        ],
        builder: (context, widget) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
            child: widget!,
          );
        },
      ),
    );
  }
}