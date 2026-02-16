# KiddyFrame 功能索引

> **最后更新**: 2026-02-14 | **版本**: v1.0.0-beta

本文档记录所有可复用组件、工具方法、数据库实体和服务类，开发前必读。

---

## 📚 目录

- [通用组件](#通用组件)
- [工具方法](#工具方法)
- [数据库实体](#数据库实体)
- [数据库服务](#数据库服务)
- [页面模块](#页面模块)

---

## 通用组件

### 类名：`MyTextField`

**路径：** `lib/components/text_field.dart`  
**功能：** 统一样式的文本输入框

**参数：**
- `controller`：TextEditingController
- `hintText`：提示文本
- `maxLength`：最大长度
- `obscureText`：是否隐藏文本

**示例：**
```dart
MyTextField(
  controller: nameController,
  hintText: 'Enter name',
  maxLength: 30,
)
```

---

### 类名：`Calendar`

**路径：** `lib/components/calendar.dart`  
**功能：** 日历选择组件

**示例：**
```dart
Calendar(
  onDateSelected: (date) {
    print('Selected: $date');
  },
)
```

---

## 工具方法

### 类名：`successToast` / `errorToast`

**路径：** `lib/utils/index.dart`  
**功能：** 显示成功/错误提示消息

**示例：**
```dart
successToast('Saved successfully');
errorToast('Failed to save');
```

---

### 类名：`getDateString` / `extractDateFromDateTime`

**路径：** `lib/utils/index.dart`  
**功能：** 日期格式化工具

---

## 数据库实体

### 类名：`WorkEntity`

**路径：** `lib/db_kiddy_frame/db_kiddy_frame_entity.dart`  
**功能：** 作品数据实体

**字段：**
- `id`：主键
- `filePath`：文件路径
- `createdAt`：创建时间
- `fileSize`：文件大小
- `originalPhotoPath`：原图路径
- `decorationConfig`：装饰配置JSON
- `studentId`：关联学生ID ⭐ NEW

---

### 类名：`StudentEntity` ⭐ NEW

**路径：** `lib/db_kiddy_frame/db_kiddy_frame_entity.dart`  
**功能：** 学生信息实体

**字段：**
- `id`：主键
- `studentId`：UUID唯一标识
- `name`：学生姓名
- `age`：年龄
- `className`：班级名称
- `photoPath`：照片路径
- `notes`：备注
- `createdAt`：创建时间
- `updatedAt`：更新时间

---

### 类名：`FramingPresetEntity` ⭐ NEW

**路径：** `lib/db_kiddy_frame/db_kiddy_frame_entity.dart`  
**功能：** 装裱预设实体

**字段：**
- `id`：主键
- `presetId`：UUID唯一标识
- `name`：预设名称
- `description`：预设描述
- `thumbnailPath`：缩略图路径
- `configJson`：配置JSON
- `usageCount`：使用次数
- `createdAt`：创建时间
- `updatedAt`：更新时间
- `isDefault`：是否系统预设

---

### 类名：`FrameEntity`

**路径：** `lib/db_kiddy_frame/db_kiddy_frame_entity.dart`  
**功能：** 相框数据实体

**字段：**
- `frameId`：相框ID
- `name`：相框名称
- `category`：分类
- `filePath`：文件路径
- `innerPadding`：内边距
- `hasShadow`：是否有阴影

---

### 类名：`BackgroundEntity`

**路径：** `lib/db_kiddy_frame/db_kiddy_frame_entity.dart`  
**功能：** 背景数据实体

---

### 类名：`StickerEntity`

**路径：** `lib/db_kiddy_frame/db_kiddy_frame_entity.dart`  
**功能：** 贴纸数据实体

---

## 数据库服务

### 类名：`KiddyFrameDatabase`

**路径：** `lib/db_kiddy_frame/data.dart`  
**功能：** 数据库操作服务

**作品相关：**
- `getWorks()`：获取所有作品
- `getWorkById(id)`：获取单个作品
- `insertWork(work)`：插入作品
- `deleteWork(id)`：删除作品

**学生相关：** ⭐ NEW
- `getStudents({className})`：获取学生列表
- `getStudentById(studentId)`：获取单个学生
- `searchStudents(keyword)`：搜索学生
- `getStudentWorkCount(studentId)`：获取作品数量
- `insertStudent(student)`：添加学生
- `updateStudent(student)`：更新学生
- `deleteStudent(studentId, {deleteWorks})`：删除学生
- `assignWorkToStudent(workId, studentId)`：关联作品
- `assignWorksToStudent(workIds, studentId)`：批量关联
- `getWorksByStudent(studentId)`：获取学生作品
- `unassignWorkFromStudent(workId)`：取消关联

**预设相关：** ⭐ NEW
- `getPresets({orderBy})`：获取预设列表
- `getPresetById(presetId)`：获取单个预设
- `getRecentlyUsedPresets({limit})`：获取最近使用
- `insertPreset(preset)`：添加预设
- `updatePreset(preset)`：更新预设
- `deletePreset(presetId)`：删除预设
- `incrementPresetUsage(presetId)`：增加使用次数

**相框相关：**
- `getFrames()`：获取所有相框
- `getFramesByCategory(category)`：按分类获取
- `getFrameCategories()`：获取分类列表

**背景相关：**
- `getBackgrounds()`：获取所有背景
- `getBackgroundsByType(type)`：按类型获取

**贴纸相关：**
- `getStickers()`：获取所有贴纸
- `getStickersByCategory(category)`：按分类获取

---

## 页面模块

### 首页
**路径：** `lib/pages/kiddy_frame_home/`  
**功能：** 应用首页,功能入口

---

### 照片选择页
**路径：** `lib/pages/kiddy_frame_photo_select/`  
**功能：** 从相册选择照片

---

### 图片预处理页
**路径：** `lib/pages/kiddy_frame_photo_preprocess/`  
**功能：** 裁剪和旋转图片

---

### 图片编辑页
**路径：** `lib/pages/kiddy_frame_photo_edit/`  
**功能：** 添加相框/背景/文字/贴纸

**新增功能：** ⭐
- 保存为预设(菜单→Save as Preset)
- 加载预设(菜单→Load Preset)
- 自动提取配置JSON
- 生成缩略图

---

### 作品详情页
**路径：** `lib/pages/kiddy_frame_gallery_detail/`  
**功能：** 查看作品详情,分享/删除

---

### 设置页
**路径：** `lib/pages/kiddy_frame_settings/`  
**功能：** 应用设置和信息

**新增功能：** ⭐
- Features卡片(预设管理/学生管理入口)

---

### 装裱预设管理页 ⭐ NEW
**路径：** `lib/pages/kiddy_frame_preset_management/`  
**功能：** 管理装裱预设

**主要方法：**
- `loadPresets()`：加载预设列表
- `deletePreset(preset)`：删除预设
- `viewPresetDetail(preset)`：查看详情

**路由：** `/kiddy_frame_preset_management`

---

### 预设预览页 ⭐ NEW
**路径：** `lib/pages/kiddy_frame_preset_preview/`  
**功能：** 预设详情和应用

**主要方法：**
- `deletePreset()`：删除预设
- `applyToNewWork()`：应用到新作品
- `getFrameName()`：获取相框名称
- `getTextCount()`：获取文字数量

**路由：** `/kiddy_frame_preset_preview`

---

### 学生管理页 ⭐ NEW
**路径：** `lib/pages/kiddy_frame_student_management/`  
**功能：** 管理学生档案

**主要方法：**
- `loadStudents()`：加载学生列表
- `searchStudents(keyword)`：搜索学生
- `filterByClass(className)`：按班级筛选
- `addStudent(name, age, className, notes)`：添加学生
- `updateStudent(student, ...)`：更新学生
- `executeDeleteStudent(student, deleteWorks)`：删除学生
- `viewStudentDetail(student)`：查看详情

**路由：** `/kiddy_frame_student_management`

---

### 学生详情页 ⭐ NEW
**路径：** `lib/pages/kiddy_frame_student_detail/`  
**功能：** 学生作品时间线

**主要方法：**
- `loadWorks()`：加载学生作品
- `viewWork(work)`：查看作品
- `createWork()`：创建新作品
- `executeDeleteStudent(deleteWorks)`：删除学生

**路由：** `/kiddy_frame_student_detail`

---

### 作品对比页 ⭐ NEW
**路径：** `lib/pages/kiddy_frame_work_compare/`  
**功能：** 2/4/9宫格作品对比

**主要方法：**
- `switchMode(mode)`：切换对比模式
- `toggleSyncZoom()`：切换同步缩放
- `toggleSplitDirection()`：切换分割方向
- `markWork(index, type)`：标记作品
- `previousGroup()`：上一组
- `nextGroup()`：下一组
- `getMarkedIndices(type)`：获取标记列表

**路由：** `/kiddy_frame_work_compare`

---

## 🔧 常用工具类

### 类名：`ImageProcessor`

**路径：** `lib/utils/image_processor.dart`  
**功能：** 图片处理工具

---

## 📝 使用规范

### 新增组件时
1. 在对应分类下添加文档
2. 包含：类名、路径、功能、方法、示例
3. 使用标准格式

### 查找组件时
1. 先查看本文档
2. 使用 Ctrl+F 搜索关键词
3. 优先使用已有组件

---

**维护人**: 开发团队  
**更新频率**: 每次新增组件时更新
