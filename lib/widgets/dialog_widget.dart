import 'package:flutter/material.dart';

import 'package:ridefromobd/widgets/custom_text_style.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

class DialogWidget {
  static TextStyle dialogTitleStyle() {
    return customTextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w700,
    );
  }

  static EdgeInsetsGeometry dialogTitlePadding() {
    return EdgeInsets.only(
      top: 26.h,
    );
  }

  static EdgeInsetsGeometry dialogContentPadding() {
    return EdgeInsets.only(
      left: 20.w,
      top: 16.h,
      right: 20.w,
      bottom: 2.h,
    );
  }
}
