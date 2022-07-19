import 'package:get/get.dart';

class IntroPageController extends GetxController {
  static IntroPageController get to => Get.find();

  int deviceKind = 0;

  @override
  void onInit() {
    // PushReceive.startPushReceive();

    // if (Platform.isAndroid) {
    //   deviceKind = 1;
    // } else if (Platform.isIOS) {
    //   deviceKind = 2;
    // }

    // getPackageVersion();
    print('Intro page 들어왔닼ㅋㅋㅋㅋㅋㅋㅋㅋ');
    super.onInit();
  }
}