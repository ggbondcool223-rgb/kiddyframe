import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kiddy_frame/pages/kiddy_frame_home/kiddy_frame_home_view.dart';
import 'package:kiddy_frame/pages/kiddy_frame_home/kiddy_frame_home_binding.dart';
import 'package:kiddy_frame/pages/kiddy_frame_photo_select/kiddy_frame_photo_select_view.dart';
import 'package:kiddy_frame/pages/kiddy_frame_photo_select/kiddy_frame_photo_select_binding.dart';
import 'package:kiddy_frame/pages/kiddy_frame_photo_preprocess/kiddy_frame_photo_preprocess_view.dart';
import 'package:kiddy_frame/pages/kiddy_frame_photo_preprocess/kiddy_frame_photo_preprocess_binding.dart';
import 'package:kiddy_frame/pages/kiddy_frame_photo_edit/kiddy_frame_photo_edit_view.dart';
import 'package:kiddy_frame/pages/kiddy_frame_photo_edit/kiddy_frame_photo_edit_binding.dart';
import 'package:kiddy_frame/pages/kiddy_frame_gallery_detail/kiddy_frame_gallery_detail_view.dart';
import 'package:kiddy_frame/pages/kiddy_frame_gallery_detail/kiddy_frame_gallery_detail_binding.dart';
import 'package:kiddy_frame/pages/kiddy_frame_settings/kiddy_frame_settings_view.dart';
import 'package:kiddy_frame/pages/kiddy_frame_settings/kiddy_frame_settings_binding.dart';
import 'package:kiddy_frame/pages/kiddy_frame_preset_management/kiddy_frame_preset_management_view.dart';
import 'package:kiddy_frame/pages/kiddy_frame_preset_management/kiddy_frame_preset_management_binding.dart';
import 'package:kiddy_frame/pages/kiddy_frame_preset_preview/kiddy_frame_preset_preview_view.dart';
import 'package:kiddy_frame/pages/kiddy_frame_preset_preview/kiddy_frame_preset_preview_binding.dart';
import 'package:kiddy_frame/pages/kiddy_frame_student_management/kiddy_frame_student_management_view.dart';
import 'package:kiddy_frame/pages/kiddy_frame_student_management/kiddy_frame_student_management_binding.dart';
import 'package:kiddy_frame/pages/kiddy_frame_student_detail/kiddy_frame_student_detail_view.dart';
import 'package:kiddy_frame/pages/kiddy_frame_student_detail/kiddy_frame_student_detail_binding.dart';
import 'package:kiddy_frame/pages/kiddy_frame_work_compare/kiddy_frame_work_compare_view.dart';
import 'package:kiddy_frame/pages/kiddy_frame_work_compare/kiddy_frame_work_compare_binding.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kiddy_frame/db_kiddy_frame/db_kiddy_frame_service.dart';
Color primaryColor = const Color(0xFFFF9500);
Color accentColor1 = const Color(0xFFFFDD00);
Color accentColor2 = const Color(0xFF4CC9F0);
Color bgColor = const Color(0xFFFFF8F0);
Color textColor = const Color(0xFF333333);
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  await Get.putAsync(() => KiddyFrameDatabaseService().init());
  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          getPages: Kiddy,
          initialRoute: '/kiddy_frame_home',
          theme: ThemeData(
            useMaterial3: true,
            primaryColor: primaryColor,
            scaffoldBackgroundColor: bgColor,
            colorScheme: ColorScheme.light(
              primary: primaryColor,
              secondary: accentColor2,
              surface: const Color(0xFFFFFFFF),
            ),
            appBarTheme: AppBarTheme(
              elevation: 0,
              scrolledUnderElevation: 0,
              centerTitle: true,
              titleTextStyle: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.sp,
                color: textColor,
              ),
              backgroundColor: Colors.white,
              iconTheme: IconThemeData(size: 22.w, color: textColor),
            ),
            bottomNavigationBarTheme: BottomNavigationBarThemeData(
              selectedLabelStyle: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 12.sp,
              ),
              unselectedLabelStyle: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 12.sp,
              ),
              showSelectedLabels: true,
              showUnselectedLabels: true,
              selectedItemColor: primaryColor,
              unselectedItemColor: const Color(0xFF999999),
              elevation: 0,
              backgroundColor: const Color(0xFFFFFFFF),
            ),
            inputDecorationTheme: InputDecorationTheme(
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.all(Radius.circular(10.w)),
              ),
            ),
            dividerTheme: DividerThemeData(
              thickness: 1,
              color: Colors.grey[200],
            ),
          ),
        );
      },
    );
  }
}
List<GetPage<dynamic>> Kiddy = [
  GetPage(
    name: '/kiddy_frame_home',
    page: () => const KiddyFrameHomeView(),
    binding: KiddyFrameHomeBinding(),
    transition: Transition.cupertino,
    popGesture: true,
    preventDuplicates: false,
  ),
  GetPage(
    name: '/kiddy_frame_photo_select',
    page: () => const KiddyFramePhotoSelectView(),
    binding: KiddyFramePhotoSelectBinding(),
    transition: Transition.cupertino,
    popGesture: true,
    preventDuplicates: false,
  ),
  GetPage(
    name: '/kiddy_frame_photo_preprocess',
    page: () => const KiddyFramePhotoPreprocessView(),
    binding: KiddyFramePhotoPreprocessBinding(),
    transition: Transition.cupertino,
    popGesture: true,
    preventDuplicates: false,
  ),
  GetPage(
    name: '/kiddy_frame_photo_edit',
    page: () => const KiddyFramePhotoEditView(),
    binding: KiddyFramePhotoEditBinding(),
    transition: Transition.cupertino,
    popGesture: true,
    preventDuplicates: false,
  ),
  GetPage(
    name: '/kiddy_frame_gallery_detail',
    page: () => const KiddyFrameGalleryDetailView(),
    binding: KiddyFrameGalleryDetailBinding(),
    transition: Transition.cupertino,
    popGesture: true,
    preventDuplicates: false,
  ),
  GetPage(
    name: '/kiddy_frame_settings',
    page: () => const KiddyFrameSettingsView(),
    binding: KiddyFrameSettingsBinding(),
    transition: Transition.cupertino,
    popGesture: true,
    preventDuplicates: false,
  ),
  GetPage(
    name: '/kiddy_frame_preset_management',
    page: () => const KiddyFramePresetManagementPage(),
    binding: KiddyFramePresetManagementBinding(),
    transition: Transition.cupertino,
    popGesture: true,
    preventDuplicates: false,
  ),
  GetPage(
    name: '/kiddy_frame_preset_preview',
    page: () => const KiddyFramePresetPreviewPage(),
    binding: KiddyFramePresetPreviewBinding(),
    transition: Transition.cupertino,
    popGesture: true,
    preventDuplicates: false,
  ),
  GetPage(
    name: '/kiddy_frame_student_management',
    page: () => const KiddyFrameStudentManagementPage(),
    binding: KiddyFrameStudentManagementBinding(),
    transition: Transition.cupertino,
    popGesture: true,
    preventDuplicates: false,
  ),
  GetPage(
    name: '/kiddy_frame_student_detail',
    page: () => const KiddyFrameStudentDetailPage(),
    binding: KiddyFrameStudentDetailBinding(),
    transition: Transition.cupertino,
    popGesture: true,
    preventDuplicates: false,
  ),
  GetPage(
    name: '/kiddy_frame_work_compare',
    page: () => const KiddyFrameWorkComparePage(),
    binding: KiddyFrameWorkCompareBinding(),
    transition: Transition.cupertino,
    popGesture: true,
    preventDuplicates: false,
  ),
];