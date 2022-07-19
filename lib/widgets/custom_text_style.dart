import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ridefromobd/styles/ride_color.dart';

TextStyle customTextStyle({
  Color color = RideColor.FONT_BASIC_COLOR,
  double fontSize = 16,
  FontWeight fontWeight = FontWeight.w500,
  double height = 1.3,
}) {
  return TextStyle(
    fontFamily: 'NotoSans',
    color: color,
    fontSize: fontSize.sp,
    fontWeight: fontWeight,
    letterSpacing: fontSize == 24
        ? -1
        : fontSize == 20
            ? -0.8
            : fontSize == 18
                ? -0.7
                : fontSize == 16
                    ? -0.6
                    : fontSize == 14
                        ? -0.6
                        : -0.5,
    height: height,
  );
}
