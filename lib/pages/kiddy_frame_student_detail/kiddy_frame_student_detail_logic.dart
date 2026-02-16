import 'package:get/get.dart';
import '../../db_kiddy_frame/db_kiddy_frame_service.dart';
import '../../db_kiddy_frame/db_kiddy_frame_entity.dart';
import '../../utils/index.dart';
class KiddyFrameStudentDetailLogic extends GetxController {
  final _dbService = Get.find<KiddyFrameDatabaseService>();
  late final StudentEntity student;
  final works = <WorkEntity>[].obs;
  final isLoading = false.obs;
  final workCount = 0.obs;
  @override
  void onInit() {
    super.onInit();
    student = Get.arguments['student'] as StudentEntity;
    loadWorks();
  }
  Future<void> loadWorks() async {
    try {
      isLoading.value = true;
      final result = await _dbService.database.getWorksByStudent(student.studentId);
      works.value = result;
      workCount.value = result.length;
    } catch (e) {
      errorToast('Failed to load works: $e');
    } finally {
      isLoading.value = false;
    }
  }
  void editStudent() {
    Get.back(result: 'edit');
  }
  Future<void> executeDeleteStudent(bool deleteWorks) async {
    try {
      final deleteResult = await _dbService.database.deleteStudent(
        student.studentId,
        deleteWorks: deleteWorks,
      );
      if (deleteResult > 0) {
        successToast('Student deleted');
        Get.back(result: 'deleted');
      } else {
        errorToast('Failed to delete student');
      }
    } catch (e) {
      errorToast('Error: $e');
    }
  }
  void viewWork(WorkEntity work) {
    Get.toNamed(
      '/kiddy_frame_gallery_detail',
      arguments: {'work': work},
    );
  }
  Future<void> createWork() async {
    await Get.toNamed(
      '/kiddy_frame_photo_select',
      arguments: {'studentId': student.studentId},
    );
    print('🔄 Refreshing works after returning from photo edit...');
    await loadWorks();
  }
  Future<void> refresh() async {
    await loadWorks();
  }
  Future<void> compareWorks() async {
    if (works.length < 2) {
      errorToast('Need at least 2 works for comparison');
      return;
    }
    try {
      final workPaths = works.map((work) => work.filePath).toList();
      await Get.toNamed(
        '/kiddy_frame_work_compare',
        arguments: {
          'workPaths': workPaths,
        },
      );
    } catch (e) {
      errorToast('Failed to open compare mode: $e');
    }
  }
}
