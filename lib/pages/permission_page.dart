import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ridefromobd/controllers/pages/permission_page_controller.dart';

class PermissionPage extends GetView<PermissionPageController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Column(
          
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            // SizedBox(height: 100,),
            Text('PERMISSION PAGE'),
            ElevatedButton(onPressed: () => controller.click(context), child: const Text('OBD 불러와봐 ~'),)
          ],
        ),
      ),
    );
  }
}