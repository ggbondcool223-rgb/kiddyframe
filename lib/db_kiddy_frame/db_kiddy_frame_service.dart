import 'package:get/get.dart';
import 'data.dart';
import 'db_kiddy_frame_init_data.dart';
import 'db_kiddy_frame_helper.dart';
import 'db_kiddy_frame_backup.dart';
class KiddyFrameDatabaseService extends GetxService {
  late final KiddyFrameDatabase database;
  late final KiddyFrameInitData initData;
  late final KiddyFrameDatabaseHelper helper;
  late final KiddyFrameBackup backup;
  Future<KiddyFrameDatabaseService> init() async {
    database = KiddyFrameDatabase();
    await database.database;
    initData = KiddyFrameInitData(database);
    await initData.initializeDefaultData();
    helper = KiddyFrameDatabaseHelper(database);
    backup = KiddyFrameBackup(database);
    return this;
  }
}
