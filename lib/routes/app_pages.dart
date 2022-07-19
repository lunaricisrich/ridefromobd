import 'package:get/get.dart';
import 'package:ridefromobd/controllers/pages/intro_page_controller.dart';
import 'package:ridefromobd/controllers/pages/permission_page_controller.dart';
import 'package:ridefromobd/pages/intro_page.dart';
import 'package:ridefromobd/pages/permission_page.dart';

part 'app_routes.dart';

class AppPages {
  static final List<GetPage> routes = [
    GetPage(
      name: AppRoutes.PERMISSION,
      page: () => PermissionPage(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => PermissionPageController());
      }),
    ),
    GetPage(
      name: AppRoutes.INTRO,
      page: () => IntroPage(),
      binding: BindingsBuilder(() {
        Get.put(IntroPageController());
        // Get.lazyPut(() => LoginController());
        // Get.lazyPut(() => AgencyMeController());
      }),
    ),
  ];
}