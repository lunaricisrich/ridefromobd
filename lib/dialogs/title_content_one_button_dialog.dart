import 'package:flutter/material.dart';



import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ridefromobd/styles/ride_color.dart';
import 'package:ridefromobd/widgets/custom_text_style.dart';
import 'package:ridefromobd/widgets/dialog_widget.dart';

Future<dynamic> titleContentOneButtonDialog(String title, String content, {bool contentCenter = true, String button = '확인'}) {
  return Get.defaultDialog(
    barrierDismissible: false,
    title: title,
    titleStyle: DialogWidget.dialogTitleStyle(),
    titlePadding: DialogWidget.dialogTitlePadding(),
    contentPadding: DialogWidget.dialogContentPadding(),
    content: Container(
      width: 320.w,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            content,
            style: customTextStyle(fontSize: 14, height: 1.5),
            textAlign: contentCenter ? TextAlign.center : TextAlign.start,
          ),
          SizedBox(
            height: 20.h,
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            child: Text(
              button,
              style: customTextStyle(
                color: RideColor.BUTTON_FONT_COLOR,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    ),
    radius: 20.w,
  );
}
