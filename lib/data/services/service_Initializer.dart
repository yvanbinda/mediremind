import 'package:get/get.dart';
import 'package:mediremind/app/theme/themecontroller.dart';
import 'package:mediremind/features/app/controllers/homeController.dart';

class ServiceInitializer {
  static Future<void> init() async{
    Get.put(ThemeController());
    Get.put(HomeController());
  }
}