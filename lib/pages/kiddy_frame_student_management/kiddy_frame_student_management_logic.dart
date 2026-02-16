import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../../db_kiddy_frame/db_kiddy_frame_service.dart';
import '../../db_kiddy_frame/db_kiddy_frame_entity.dart';
import '../../utils/index.dart';
class KiddyFrameStudentManagementLogic extends GetxController {
  final _dbService = Get.find<KiddyFrameDatabaseService>();
  final students = <StudentEntity>[].obs;
  final isLoading = false.obs;
  final searchKeyword = ''.obs;
  final filterClassName = Rx<String?>(null);
  @override
  void onInit() {
    super.onInit();
    loadStudents();
  }
  Future<void> loadStudents() async {
    try {
      isLoading.value = true;
      List<StudentEntity> result;
      if (searchKeyword.value.isNotEmpty) {
        result = await _dbService.database.searchStudents(searchKeyword.value);
      } else if (filterClassName.value != null) {
        result = await _dbService.database.getStudents(className: filterClassName.value);
      } else {
        result = await _dbService.database.getStudents();
      }
      students.value = result;
    } catch (e) {
      errorToast('Failed to load students: $e');
    } finally {
      isLoading.value = false;
    }
  }
  void searchStudents(String keyword) {
    searchKeyword.value = keyword;
    loadStudents();
  }
  void filterByClass(String? className) {
    filterClassName.value = className;
    loadStudents();
  }
  void clearFilter() {
    searchKeyword.value = '';
    filterClassName.value = null;
    loadStudents();
  }
  Future<void> addStudent(
    String name,
    int? age,
    String? className,
    String? notes,
  ) async {
    await _addStudent(name, age, className, notes);
  }
  Future<void> updateStudent(
    StudentEntity student,
    String name,
    int? age,
    String? className,
    String? notes,
  ) async {
    await _updateStudent(student, name, age, className, notes);
  }
  Future<void> _addStudent(
    String name,
    int? age,
    String? className,
    String? notes,
  ) async {
    try {
      final now = DateTime.now().toIso8601String();
      final student = StudentEntity(
        studentId: const Uuid().v4(),
        name: name,
        age: age,
        className: className,
        notes: notes,
        createdAt: now,
        updatedAt: now,
      );
      final result = await _dbService.database.insertStudent(student);
      if (result > 0) {
        successToast('Student added successfully');
        loadStudents();
      } else {
        errorToast('Failed to add student');
      }
    } catch (e) {
      errorToast('Error: $e');
    }
  }
  Future<void> _updateStudent(
    StudentEntity oldStudent,
    String name,
    int? age,
    String? className,
    String? notes,
  ) async {
    try {
      final updatedStudent = StudentEntity(
        id: oldStudent.id,
        studentId: oldStudent.studentId,
        name: name,
        age: age,
        className: className,
        photoPath: oldStudent.photoPath,
        notes: notes,
        createdAt: oldStudent.createdAt,
        updatedAt: DateTime.now().toIso8601String(),
      );
      final result = await _dbService.database.updateStudent(updatedStudent);
      if (result > 0) {
        successToast('Student updated');
        loadStudents();
      } else {
        errorToast('Failed to update student');
      }
    } catch (e) {
      errorToast('Error: $e');
    }
  }
  Future<int> getStudentWorkCount(String studentId) async {
    return await _dbService.database.getStudentWorkCount(studentId);
  }
  Future<void> executeDeleteStudent(
    StudentEntity student,
    bool deleteWorks,
  ) async {
    try {
      final deleteResult = await _dbService.database.deleteStudent(
        student.studentId,
        deleteWorks: deleteWorks,
      );
      if (deleteResult > 0) {
        successToast('Student deleted');
        loadStudents();
      } else {
        errorToast('Failed to delete student');
      }
    } catch (e) {
      errorToast('Error: $e');
    }
  }
  void viewStudentDetail(StudentEntity student) {
    Get.toNamed(
      '/kiddy_frame_student_detail',
      arguments: {'student': student},
    );
  }
  Future<void> refresh() async {
    await loadStudents();
  }
}
