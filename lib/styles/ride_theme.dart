import 'package:flutter/material.dart';


import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ridefromobd/styles/ride_color.dart';
import 'package:ridefromobd/widgets/custom_text_style.dart';

ThemeData rideTheme(BuildContext context) {
  return ThemeData(
    primarySwatch: Colors.yellow,
    fontFamily: 'NotoSans',
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.white,
      centerTitle: true,
      toolbarHeight: 56.h,
      iconTheme: IconThemeData(
        color: Colors.black,
        size: 26.w,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        primary: RideColor.BUTTON_COLOR,
        fixedSize: Size.fromHeight(50.h),
        padding: EdgeInsets.only(
          left: 20.w,
          right: 20.w,
        ),
        textStyle: customTextStyle(fontSize: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.w),
        ),
        elevation: 0,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        backgroundColor: Colors.white,
        fixedSize: Size.fromHeight(40.h),
        padding: EdgeInsets.zero,
        side: BorderSide(
          width: 1.w,
          color: RideColor.BUTTON_COLOR,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.w),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        padding: EdgeInsets.only(
          top: 10.h,
          bottom: 10.h,
        ),
        textStyle: customTextStyle(fontSize: 12),
      ),
    ),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: RideColor.BUTTON_COLOR,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      labelStyle: customTextStyle(color: RideColor.TEXT_FIELD_COLOR, fontSize: 12),
      hintStyle: customTextStyle(
        color: RideColor.TEXT_FIELD_COLOR,
      ),
      errorStyle: customTextStyle(color: RideColor.FONT_RED_COLOR, fontSize: 12),
      enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(
          color: RideColor.TEXT_FIELD_COLOR,
        ),
      ),
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(
          color: RideColor.BUTTON_COLOR,
        ),
      ),
      errorBorder: UnderlineInputBorder(
        borderSide: BorderSide(
          color: RideColor.TEXT_FIELD_COLOR,
        ),
      ),
      focusedErrorBorder: UnderlineInputBorder(
        borderSide: BorderSide(
          color: RideColor.TEXT_FIELD_COLOR,
        ),
      ),
      isDense: true,
      contentPadding: EdgeInsets.only(
        top: 4.h,
        bottom: 8.h,
      ),
    ),
    scaffoldBackgroundColor: Colors.white,
    toggleableActiveColor: RideColor.BUTTON_COLOR,
    unselectedWidgetColor: RideColor.TEXT_FIELD_COLOR,
  );
}
