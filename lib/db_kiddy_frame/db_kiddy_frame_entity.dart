class WorkEntity {
  final int? id;
  final String filePath;
  final String createdAt;
  final int fileSize;
  final String? originalPhotoPath;
  final String? decorationConfig;
  final String? studentId;
  const WorkEntity({
    this.id,
    required this.filePath,
    required this.createdAt,
    required this.fileSize,
    this.originalPhotoPath,
    this.decorationConfig,
    this.studentId,
  });
  factory WorkEntity.fromMap(Map<String, dynamic> map) {
    return WorkEntity(
      id: map['id'] as int?,
      filePath: map['file_path'] as String,
      createdAt: map['created_at'] as String,
      fileSize: map['file_size'] as int,
      originalPhotoPath: map['original_photo_path'] as String?,
      decorationConfig: map['decoration_config'] as String?,
      studentId: map['student_id'] as String?,
    );
  }
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'file_path': filePath,
      'created_at': createdAt,
      'file_size': fileSize,
      'original_photo_path': originalPhotoPath,
      'decoration_config': decorationConfig,
      'student_id': studentId,
    };
  }
}
class FrameEntity {
  final int? id;
  final String frameId;
  final String name;
  final String category;
  final String filePath;
  final String thumbnailPath;
  final int isPro;
  final int supportColorChange;
  final String? defaultColors;
  final int innerPaddingTop;
  final int innerPaddingRight;
  final int innerPaddingBottom;
  final int innerPaddingLeft;
  final String? aspectRatioSupport;
  final int hasShadow;
  final String? shadowConfig;
  final int adjustableOpacity;
  final String? decorations;
  const FrameEntity({
    this.id,
    required this.frameId,
    required this.name,
    required this.category,
    required this.filePath,
    required this.thumbnailPath,
    required this.isPro,
    required this.supportColorChange,
    this.defaultColors,
    required this.innerPaddingTop,
    required this.innerPaddingRight,
    required this.innerPaddingBottom,
    required this.innerPaddingLeft,
    this.aspectRatioSupport,
    required this.hasShadow,
    this.shadowConfig,
    required this.adjustableOpacity,
    this.decorations,
  });
  factory FrameEntity.fromMap(Map<String, dynamic> map) {
    return FrameEntity(
      id: map['id'] as int?,
      frameId: map['frame_id'] as String,
      name: map['name'] as String,
      category: map['category'] as String,
      filePath: map['file_path'] as String,
      thumbnailPath: map['thumbnail_path'] as String,
      isPro: map['is_pro'] as int,
      supportColorChange: map['support_color_change'] as int,
      defaultColors: map['default_colors'] as String?,
      innerPaddingTop: map['inner_padding_top'] as int,
      innerPaddingRight: map['inner_padding_right'] as int,
      innerPaddingBottom: map['inner_padding_bottom'] as int,
      innerPaddingLeft: map['inner_padding_left'] as int,
      aspectRatioSupport: map['aspect_ratio_support'] as String?,
      hasShadow: map['has_shadow'] as int,
      shadowConfig: map['shadow_config'] as String?,
      adjustableOpacity: map['adjustable_opacity'] as int,
      decorations: map['decorations'] as String?,
    );
  }
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'frame_id': frameId,
      'name': name,
      'category': category,
      'file_path': filePath,
      'thumbnail_path': thumbnailPath,
      'is_pro': isPro,
      'support_color_change': supportColorChange,
      'default_colors': defaultColors,
      'inner_padding_top': innerPaddingTop,
      'inner_padding_right': innerPaddingRight,
      'inner_padding_bottom': innerPaddingBottom,
      'inner_padding_left': innerPaddingLeft,
      'aspect_ratio_support': aspectRatioSupport,
      'has_shadow': hasShadow,
      'shadow_config': shadowConfig,
      'adjustable_opacity': adjustableOpacity,
      'decorations': decorations,
    };
  }
}
class FrameCategoryEntity {
  final int? id;
  final String categoryId;
  final String name;
  final int orderIndex;
  final int isDefault;
  const FrameCategoryEntity({
    this.id,
    required this.categoryId,
    required this.name,
    required this.orderIndex,
    required this.isDefault,
  });
  factory FrameCategoryEntity.fromMap(Map<String, dynamic> map) {
    return FrameCategoryEntity(
      id: map['id'] as int?,
      categoryId: map['category_id'] as String,
      name: map['name'] as String,
      orderIndex: map['order_index'] as int,
      isDefault: map['is_default'] as int,
    );
  }
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'category_id': categoryId,
      'name': name,
      'order_index': orderIndex,
      'is_default': isDefault,
    };
  }
}
class BatchRecordEntity {
  final int? id;
  final String batchId;
  final String createdAt;
  final int photoCount;
  final String? globalFrameConfig;
  final String? individualFramesConfig;
  const BatchRecordEntity({
    this.id,
    required this.batchId,
    required this.createdAt,
    required this.photoCount,
    this.globalFrameConfig,
    this.individualFramesConfig,
  });
  factory BatchRecordEntity.fromMap(Map<String, dynamic> map) {
    return BatchRecordEntity(
      id: map['id'] as int?,
      batchId: map['batch_id'] as String,
      createdAt: map['created_at'] as String,
      photoCount: map['photo_count'] as int,
      globalFrameConfig: map['global_frame_config'] as String?,
      individualFramesConfig: map['individual_frames_config'] as String?,
    );
  }
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'batch_id': batchId,
      'created_at': createdAt,
      'photo_count': photoCount,
      'global_frame_config': globalFrameConfig,
      'individual_frames_config': individualFramesConfig,
    };
  }
}
class ArtistCardEntity {
  final int? id;
  final int workId;
  final String workTitle;
  final String? creationDate;
  final String? workDescription;
  final String artistName;
  final int? artistAge;
  final String? artistPhotoPath;
  final String? schoolInfo;
  final String templateId;
  final int showArtistPhoto;
  final int showCreationDate;
  final int showSchoolInfo;
  final String? watermarkPath;
  final String cardFilePath;
  final String createdAt;
  const ArtistCardEntity({
    this.id,
    required this.workId,
    required this.workTitle,
    this.creationDate,
    this.workDescription,
    required this.artistName,
    this.artistAge,
    this.artistPhotoPath,
    this.schoolInfo,
    required this.templateId,
    required this.showArtistPhoto,
    required this.showCreationDate,
    required this.showSchoolInfo,
    this.watermarkPath,
    required this.cardFilePath,
    required this.createdAt,
  });
  factory ArtistCardEntity.fromMap(Map<String, dynamic> map) {
    return ArtistCardEntity(
      id: map['id'] as int?,
      workId: map['work_id'] as int,
      workTitle: map['work_title'] as String,
      creationDate: map['creation_date'] as String?,
      workDescription: map['work_description'] as String?,
      artistName: map['artist_name'] as String,
      artistAge: map['artist_age'] as int?,
      artistPhotoPath: map['artist_photo_path'] as String?,
      schoolInfo: map['school_info'] as String?,
      templateId: map['template_id'] as String,
      showArtistPhoto: map['show_artist_photo'] as int,
      showCreationDate: map['show_creation_date'] as int,
      showSchoolInfo: map['show_school_info'] as int,
      watermarkPath: map['watermark_path'] as String?,
      cardFilePath: map['card_file_path'] as String,
      createdAt: map['created_at'] as String,
    );
  }
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'work_id': workId,
      'work_title': workTitle,
      'creation_date': creationDate,
      'work_description': workDescription,
      'artist_name': artistName,
      'artist_age': artistAge,
      'artist_photo_path': artistPhotoPath,
      'school_info': schoolInfo,
      'template_id': templateId,
      'show_artist_photo': showArtistPhoto,
      'show_creation_date': showCreationDate,
      'show_school_info': showSchoolInfo,
      'watermark_path': watermarkPath,
      'card_file_path': cardFilePath,
      'created_at': createdAt,
    };
  }
}
class SettingEntity {
  final int? id;
  final String settingKey;
  final String settingValue;
  final String updatedAt;
  const SettingEntity({
    this.id,
    required this.settingKey,
    required this.settingValue,
    required this.updatedAt,
  });
  factory SettingEntity.fromMap(Map<String, dynamic> map) {
    return SettingEntity(
      id: map['id'] as int?,
      settingKey: map['setting_key'] as String,
      settingValue: map['setting_value'] as String,
      updatedAt: map['updated_at'] as String,
    );
  }
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'setting_key': settingKey,
      'setting_value': settingValue,
      'updated_at': updatedAt,
    };
  }
}
class StickerEntity {
  final int? id;
  final String stickerId;
  final String name;
  final String category;
  final String filePath;
  final String thumbnailPath;
  final int isPro;
  const StickerEntity({
    this.id,
    required this.stickerId,
    required this.name,
    required this.category,
    required this.filePath,
    required this.thumbnailPath,
    required this.isPro,
  });
  factory StickerEntity.fromMap(Map<String, dynamic> map) {
    return StickerEntity(
      id: map['id'] as int?,
      stickerId: map['sticker_id'] as String,
      name: map['name'] as String,
      category: map['category'] as String,
      filePath: map['file_path'] as String,
      thumbnailPath: map['thumbnail_path'] as String,
      isPro: map['is_pro'] as int,
    );
  }
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'sticker_id': stickerId,
      'name': name,
      'category': category,
      'file_path': filePath,
      'thumbnail_path': thumbnailPath,
      'is_pro': isPro,
    };
  }
}
class BackgroundEntity {
  final int? id;
  final String backgroundId;
  final String name;
  final String type;
  final String? colorValue;
  final String? filePath;
  final String? thumbnailPath;
  final int isPro;
  const BackgroundEntity({
    this.id,
    required this.backgroundId,
    required this.name,
    required this.type,
    this.colorValue,
    this.filePath,
    this.thumbnailPath,
    required this.isPro,
  });
  factory BackgroundEntity.fromMap(Map<String, dynamic> map) {
    return BackgroundEntity(
      id: map['id'] as int?,
      backgroundId: map['background_id'] as String,
      name: map['name'] as String,
      type: map['type'] as String,
      colorValue: map['color_value'] as String?,
      filePath: map['file_path'] as String?,
      thumbnailPath: map['thumbnail_path'] as String?,
      isPro: map['is_pro'] as int,
    );
  }
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'background_id': backgroundId,
      'name': name,
      'type': type,
      'color_value': colorValue,
      'file_path': filePath,
      'thumbnail_path': thumbnailPath,
      'is_pro': isPro,
    };
  }
}
class StudentEntity {
  final int? id;
  final String studentId;
  final String name;
  final int? age;
  final String? className;
  final String? photoPath;
  final String? notes;
  final String createdAt;
  final String updatedAt;
  const StudentEntity({
    this.id,
    required this.studentId,
    required this.name,
    this.age,
    this.className,
    this.photoPath,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });
  factory StudentEntity.fromMap(Map<String, dynamic> map) {
    return StudentEntity(
      id: map['id'] as int?,
      studentId: map['student_id'] as String,
      name: map['name'] as String,
      age: map['age'] as int?,
      className: map['class_name'] as String?,
      photoPath: map['photo_path'] as String?,
      notes: map['notes'] as String?,
      createdAt: map['created_at'] as String,
      updatedAt: map['updated_at'] as String,
    );
  }
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'student_id': studentId,
      'name': name,
      'age': age,
      'class_name': className,
      'photo_path': photoPath,
      'notes': notes,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
class FramingPresetEntity {
  final int? id;
  final String presetId;
  final String name;
  final String? description;
  final String? thumbnailPath;
  final String configJson;
  final int usageCount;
  final String createdAt;
  final String updatedAt;
  final int isDefault;
  const FramingPresetEntity({
    this.id,
    required this.presetId,
    required this.name,
    this.description,
    this.thumbnailPath,
    required this.configJson,
    required this.usageCount,
    required this.createdAt,
    required this.updatedAt,
    required this.isDefault,
  });
  factory FramingPresetEntity.fromMap(Map<String, dynamic> map) {
    return FramingPresetEntity(
      id: map['id'] as int?,
      presetId: map['preset_id'] as String,
      name: map['name'] as String,
      description: map['description'] as String?,
      thumbnailPath: map['thumbnail_path'] as String?,
      configJson: map['config_json'] as String,
      usageCount: map['usage_count'] as int,
      createdAt: map['created_at'] as String,
      updatedAt: map['updated_at'] as String,
      isDefault: map['is_default'] as int,
    );
  }
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'preset_id': presetId,
      'name': name,
      'description': description,
      'thumbnail_path': thumbnailPath,
      'config_json': configJson,
      'usage_count': usageCount,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'is_default': isDefault,
    };
  }
}
