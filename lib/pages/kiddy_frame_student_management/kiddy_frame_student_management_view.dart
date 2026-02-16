import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'kiddy_frame_student_management_logic.dart';
class KiddyFrameStudentManagementPage
    extends GetView<KiddyFrameStudentManagementLogic> {
  const KiddyFrameStudentManagementPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Student Management'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _showSearchDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.students.isEmpty) {
                return _buildEmptyState();
              }
              return RefreshIndicator(
                onRefresh: controller.refresh,
                child: GridView.builder(
                  padding: EdgeInsets.all(16.w),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12.w,
                    mainAxisSpacing: 12.h,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: controller.students.length,
                  itemBuilder: (context, index) {
                    final student = controller.students[index];
                    return _buildStudentCard(student);
                  },
                ),
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddStudentDialog,
        backgroundColor: const Color(0xFFFF4081),
        child: const Icon(Icons.add),
      ),
    );
  }
  Widget _buildFilterBar() {
    return Obx(() {
      if (controller.searchKeyword.value.isEmpty &&
          controller.filterClassName.value == null) {
        return const SizedBox.shrink();
      }
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        color: Colors.grey[100],
        child: Row(
          children: [
            if (controller.searchKeyword.value.isNotEmpty)
              Chip(
                label: Text('Search: ${controller.searchKeyword.value}'),
                onDeleted: () => controller.searchStudents(''),
                deleteIcon: const Icon(Icons.close, size: 18),
              ),
            if (controller.filterClassName.value != null)
              Chip(
                label: Text('Class: ${controller.filterClassName.value}'),
                onDeleted: () => controller.filterByClass(null),
                deleteIcon: const Icon(Icons.close, size: 18),
              ),
            const Spacer(),
            TextButton(
              onPressed: controller.clearFilter,
              child: const Text('Clear All'),
            ),
          ],
        ),
      );
    });
  }
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 80.w, color: Colors.grey[300]),
          SizedBox(height: 16.h),
          Text(
            'No students yet',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Tap + to add your first student',
            style: TextStyle(fontSize: 14.sp, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
  Widget _buildStudentCard(dynamic student) {
    return GestureDetector(
      onTap: () => controller.viewStudentDetail(student),
      onLongPress: () => _showStudentMenu(student),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _getColorFromName(student.name),
                      _getColorFromName(student.name).withOpacity(0.7),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(16.r),
                  ),
                ),
                child: Center(
                  child: Text(
                    _getInitials(student.name),
                    style: TextStyle(
                      fontSize: 36.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(12.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    student.name,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      if (student.className != null) ...[
                        Icon(Icons.school, size: 14.w, color: Colors.grey[600]),
                        SizedBox(width: 4.w),
                        Expanded(
                          child: Text(
                            student.className!,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                      if (student.age != null) ...[
                        if (student.className != null) SizedBox(width: 8.w),
                        Text(
                          '${student.age}岁',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: 8.h),
                  FutureBuilder<int>(
                    future: controller.getStudentWorkCount(student.studentId),
                    builder: (context, snapshot) {
                      final count = snapshot.data ?? 0;
                      return Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF4081).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Text(
                          '$count works',
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: const Color(0xFFFF4081),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  void _showStudentMenu(dynamic student) {
    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.all(16.w),
                child: Text(
                  student.name,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.visibility_outlined),
                title: const Text('View Details'),
                onTap: () {
                  Get.back();
                  controller.viewStudentDetail(student);
                },
              ),
              ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: const Text('Edit'),
                onTap: () {
                  Get.back();
                  _showEditStudentDialog(student);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Get.back();
                  _showDeleteStudentDialog(student);
                },
              ),
              ListTile(
                leading: const Icon(Icons.close),
                title: const Text('Cancel'),
                onTap: () => Get.back(),
              ),
              SizedBox(height: 8.h),
            ],
          ),
        ),
      ),
    );
  }
  void _showSearchDialog() {
    final searchController = TextEditingController();
    Get.dialog(
      AlertDialog(
        title: const Text('Search Students'),
        content: TextField(
          controller: searchController,
          decoration: const InputDecoration(
            hintText: 'Enter student name or class',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.search),
          ),
          autofocus: true,
          onSubmitted: (value) {
            Get.back();
            controller.searchStudents(value);
          },
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.searchStudents(searchController.text);
            },
            child: const Text('Search'),
          ),
        ],
      ),
    );
  }
  Color _getColorFromName(String name) {
    final colors = [
      const Color(0xFFE91E63),
      const Color(0xFF9C27B0),
      const Color(0xFF673AB7),
      const Color(0xFF3F51B5),
      const Color(0xFF2196F3),
      const Color(0xFF00BCD4),
      const Color(0xFF009688),
      const Color(0xFF4CAF50),
      const Color(0xFFFF9800),
      const Color(0xFFFF5722),
    ];
    final hash = name.hashCode.abs();
    return colors[hash % colors.length];
  }
  String _getInitials(String name) {
    if (name.isEmpty) return '?';
    final words = name.trim().split(' ');
    if (words.length >= 2) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    }
    return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
  }
  void _showAddStudentDialog() {
    final nameController = TextEditingController();
    final ageController = TextEditingController();
    final classController = TextEditingController();
    final notesController = TextEditingController();
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Container(
          width: 400.w,
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.person_add,
                    size: 24.sp,
                    color: const Color(0xFF2196F3),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'Add Student',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24.h),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildInputField(
                        controller: nameController,
                        label: 'Student Name',
                        hint: 'Enter student name',
                        icon: Icons.person,
                        isRequired: true,
                        maxLength: 30,
                      ),
                      SizedBox(height: 16.h),
                      _buildInputField(
                        controller: ageController,
                        label: 'Age',
                        hint: '1-18',
                        icon: Icons.cake,
                        keyboardType: TextInputType.number,
                      ),
                      SizedBox(height: 16.h),
                      _buildInputField(
                        controller: classController,
                        label: 'Class',
                        hint: 'e.g., Grade 1-A',
                        icon: Icons.class_,
                        maxLength: 50,
                      ),
                      SizedBox(height: 16.h),
                      _buildInputField(
                        controller: notesController,
                        label: 'Notes',
                        hint: 'Additional information',
                        icon: Icons.notes,
                        maxLength: 200,
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 24.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.w,
                        vertical: 12.h,
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  ElevatedButton(
                    onPressed: () {
                      final name = nameController.text.trim();
                      if (name.isEmpty) {
                        Get.snackbar(
                          'Error',
                          'Student name is required',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.red,
                          colorText: Colors.white,
                        );
                        return;
                      }
                      final ageText = ageController.text.trim();
                      int? age;
                      if (ageText.isNotEmpty) {
                        age = int.tryParse(ageText);
                        if (age == null || age < 1 || age > 18) {
                          Get.snackbar(
                            'Error',
                            'Age should be between 1-18',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.red,
                            colorText: Colors.white,
                          );
                          return;
                        }
                      }
                      Get.back();
                      controller.addStudent(
                        name,
                        age,
                        classController.text.trim().isEmpty
                            ? null
                            : classController.text.trim(),
                        notesController.text.trim().isEmpty
                            ? null
                            : notesController.text.trim(),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2196F3),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: 24.w,
                        vertical: 12.h,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    child: Text(
                      'Add',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  void _showEditStudentDialog(dynamic student) {
    final nameController = TextEditingController(text: student.name);
    final ageController = TextEditingController(text: student.age?.toString());
    final classController = TextEditingController(text: student.className);
    final notesController = TextEditingController(text: student.notes);
    Get.dialog(
      AlertDialog(
        title: const Text('Edit Student'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Student Name *',
                  hintText: 'Enter student name',
                  border: OutlineInputBorder(),
                ),
                maxLength: 30,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: ageController,
                decoration: const InputDecoration(
                  labelText: 'Age (Optional)',
                  hintText: '1-18',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: classController,
                decoration: const InputDecoration(
                  labelText: 'Class (Optional)',
                  hintText: 'e.g., Grade 1-A',
                  border: OutlineInputBorder(),
                ),
                maxLength: 50,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes (Optional)',
                  hintText: 'Additional information',
                  border: OutlineInputBorder(),
                ),
                maxLength: 200,
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final name = nameController.text.trim();
              if (name.isEmpty) {
                Get.snackbar(
                  'Error',
                  'Student name is required',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
                return;
              }
              final ageText = ageController.text.trim();
              int? age;
              if (ageText.isNotEmpty) {
                age = int.tryParse(ageText);
                if (age == null || age < 1 || age > 18) {
                  Get.snackbar(
                    'Error',
                    'Age should be between 1-18',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.red,
                    colorText: Colors.white,
                  );
                  return;
                }
              }
              Get.back();
              controller.updateStudent(
                student,
                name,
                age,
                classController.text.trim().isEmpty
                    ? null
                    : classController.text.trim(),
                notesController.text.trim().isEmpty
                    ? null
                    : notesController.text.trim(),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
  void _showDeleteStudentDialog(dynamic student) async {
    final workCount = await controller.getStudentWorkCount(student.studentId);
    final result = await Get.dialog<String>(
      AlertDialog(
        title: const Text('Delete Student'),
        content: workCount > 0
            ? Text(
                'Delete "${student.name}"?\nThis student has $workCount work(s).\n\nWhat do you want to do?',
              )
            : Text('Delete "${student.name}"?\nThis action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          if (workCount > 0) ...[
            TextButton(
              onPressed: () => Get.back(result: 'keep_works'),
              child: const Text('Delete student only'),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              onPressed: () => Get.back(result: 'delete_all'),
              child: const Text('Delete student and works'),
            ),
          ] else
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              onPressed: () => Get.back(result: 'delete'),
              child: const Text('Delete'),
            ),
        ],
      ),
    );
    if (result == null) return;
    final deleteWorks = result == 'delete_all' || result == 'delete';
    controller.executeDeleteStudent(student, deleteWorks);
  }
  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isRequired = false,
    int? maxLength,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            if (isRequired) ...[
              SizedBox(width: 4.w),
              Text(
                '*',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
        SizedBox(height: 8.h),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLength: maxLength,
          maxLines: maxLines,
          style: TextStyle(fontSize: 14.sp, color: Colors.black87),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(fontSize: 14.sp, color: Colors.grey[400]),
            prefixIcon: Icon(icon, size: 20.sp, color: Colors.grey[600]),
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: const BorderSide(color: Color(0xFF2196F3), width: 2),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 12.w,
              vertical: 12.h,
            ),
            counterText: maxLength != null ? null : '',
          ),
        ),
      ],
    );
  }
}
