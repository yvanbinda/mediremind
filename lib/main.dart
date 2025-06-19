import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mediremind/app/routes/app_pages.dart';
import 'package:mediremind/app/theme/darkTheme.dart';
import 'package:mediremind/app/theme/lightTheme.dart';
import 'package:mediremind/app/theme/themecontroller.dart';
import 'package:mediremind/core/localization/localization.dart';
import 'package:mediremind/data/services/service_Initializer.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await ServiceInitializer.init();
  } catch (e) {
    print('ServiceInitializer failed: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.find();
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Oasis Eclat',
      theme: lightMode,
      darkTheme: darkMode,
      themeMode: themeController.isDarkMode.value
          ? ThemeMode.dark
          : ThemeMode.light,
      locale: const Locale('en', 'US'),
      fallbackLocale: const Locale('en', 'US'),
      translations: Languages(),
      initialRoute: Routes.HOME,
      getPages: AppPages.routes,
      builder: (context, child) {
        return ResponsiveSizer(
          builder: (context, orientation, screenType) {
            return child!;
          },
        );
      },
    );
  }
}