import 'package:get/get.dart';
import 'package:mediremind/features/home.dart';

part 'app_routes.dart';
class AppPages {
  static final routes = [

    GetPage(
        name: Routes.HOME,
        page: () => HomePage(),
    )
  ];
}