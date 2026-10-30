import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:better_player_plus/better_player_plus.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:io';
import 'package:get/get.dart';
import 'package:sportik_player/core/services/proxyservice.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class Playercontroller extends GetxController {
  Playercontroller(this.args);
  final Map<String, dynamic> args;
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
  String sdurl = '';
  String hdurl = '';
  String sdname = '';
  String hdname = '';
  String displayname = '';
  String gettoken = 'no';
  String key = '';
  String host = '';
  BetterPlayerController? controller;
  late BetterPlayerDataSource dataSource;
  bool autoRefresh = true;
  bool wantRefresh = false;
  Timer? time;
  Timer? hideTimer;
  String fit = 'fill';
  bool isplaying = true;
  String quality = 'sd';
  String name = '';
  String url = '';
  bool showControls = false;
  int showProgresscount = 0;
  bool isLoadingAds = false;
  bool _proxyStarted = false;
  bool isLocalVideo = false;
  String localFilePath = '';
  String localTitle = '';
  bool get _hasNetworkChannel => sdurl.isNotEmpty || sdname.isNotEmpty;

  @override
  void onInit() {
    super.onInit();
    sdurl = _str('sdurl'); hdurl = _str('hdurl');
    sdname = _str('sdname'); hdname = _str('hdname');
    displayname = _str('displayname'); gettoken = _str('gettoken').toLowerCase();
    host = _str('host');
    localFilePath = _str('localFilePath');
    localTitle = _str('localTitle');
    isLocalVideo = localFilePath.isNotEmpty;
    if (isLocalVideo) { displayname = localTitle; hdname = 'empty'; sdname = ''; }
    key = _str('key');
    name = sdname; url = sdurl;
    if (isLocalVideo) { _startLocalPlayback(); return; }
    if (key.isNotEmpty) {
      secureStorage.write(key: 'key', value: key);
    } else {
      secureStorage.read(key: 'key').then((saved) { if (saved != null) key = saved; });
    }
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _startPlayback();
    showControlAfterTime();
    autohideControl();
    WakelockPlus.enable();
  }

  Future<void> _startLocalPlayback() async {
    final file = File(localFilePath);
    if (!await file.exists()) { Get.snackbar('تعذر فتح الفيديو', 'الملف غير موجود أو لم يعد متاحًا'); return; }
    autoRefresh = false;
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    dataSource = BetterPlayerDataSource(BetterPlayerDataSourceType.file, localFilePath);
    initPlayer();
    isLoadingAds = false;
    showControlAfterTime();
    autohideControl();
    await WakelockPlus.enable();
    update();
  }

  String _str(String key) => (args[key] ?? '').toString();

  Future<void> _startPlayback() async {
    if (gettoken == 'yes') {
      if (host.isEmpty || key.isEmpty || name.isEmpty) {
        isLoadingAds = false;
        update();
        Get.snackbar('تعذر التشغيل', 'بيانات القناة أو الخادم غير مكتملة');
        return;
      }
      Proxyservice().sethost(host);
      try {
        await Proxyservice().start();
        _proxyStarted = true;
      } catch (_) {
        // If already listening, keep the current local proxy instance.
        _proxyStarted = true;
      }
    }
    initDataSource();
    isLoadingAds = false;
    update();
  }

  @override
  void onClose() {
    autoRefresh = false;
    time?.cancel(); hideTimer?.cancel();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom]);
    if (!isTv()) SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    controller?.dispose();
    if (_proxyStarted) Proxyservice().stop();
    WakelockPlus.disable();
    super.onClose();
  }

  // Preserves the token format used by the existing Sportik player.
  String generateToken(String name, String key) {
    const String ip = 'no_check_ip';
    final start = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final end = start + 600;
    final salt = List.generate(16, (_) => Random.secure().nextInt(256)).map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    final hash = sha1.convert(utf8.encode(name + ip + start.toString() + end.toString() + key + salt)).toString();
    return '?token=$hash-$salt-$end-$start&expire=600s';
  }

  void initDataSource() {
    if (isLocalVideo) { _startLocalPlayback(); return; }
    if (controller != null && !wantRefresh) controller!.dispose();
    wantRefresh = false;
    if (gettoken == 'yes') {
      final token = generateToken(name, key);
      Proxyservice().updateToken(token);
      dataSource = BetterPlayerDataSource(BetterPlayerDataSourceType.network, 'http://127.0.0.1:8087/$name/index.m3u8', videoFormat: BetterPlayerVideoFormat.hls);
      initPlayer(); timerToRenewToken();
    } else {
      dataSource = BetterPlayerDataSource(BetterPlayerDataSourceType.network, url, videoFormat: BetterPlayerVideoFormat.hls);
      initPlayer();
    }
  }

  void initPlayer() {
    controller = BetterPlayerController(BetterPlayerConfiguration(autoPlay: true, fit: BoxFit.fill, allowedScreenSleep: false, placeholder: const Center(child: CircularProgressIndicator(color: Colors.white)), controlsConfiguration: const BetterPlayerControlsConfiguration(showControls: false)), betterPlayerDataSource: dataSource);
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft]);
    controller!.addEventsListener((event) {
      if (event.betterPlayerEventType == BetterPlayerEventType.exception || event.betterPlayerEventType == BetterPlayerEventType.finished) {
        if (!autoRefresh) return;
        wantRefresh = true;
        initDataSource(); update();
      }
    });
  }

  void timerToRenewToken() {
    time?.cancel();
    time = Timer.periodic(const Duration(seconds: 580), (_) {
      if (gettoken == 'yes') Proxyservice().updateToken(generateToken(name, key));
    });
  }
  void playpause() async { if (controller == null) return; if (isplaying) { await controller!.pause(); isplaying = false; } else { await controller!.play(); isplaying = true; } update(); }
  void changeScale() { if (controller == null) return; if (fit == 'fill') { controller!.setOverriddenFit(BoxFit.cover); fit = 'cover'; } else if (fit == 'cover') { controller!.setOverriddenFit(BoxFit.contain); fit = 'contain'; } else { controller!.setOverriddenFit(BoxFit.fill); fit = 'fill'; } update(); }
  void changeQuality(String newquality) { if (isLocalVideo) return; if (newquality == quality) return; quality = newquality; if (quality == 'sd') { name = sdname; url = sdurl; } else { name = hdname; url = hdurl; } initDataSource(); update(); }
  void showAndhideControl() { showControls = !showControls; update(); }
  void autohideControl() { hideTimer?.cancel(); hideTimer = Timer.periodic(const Duration(seconds: 10), (_) { if (showControls) { showControls = false; update(); } }); }
  void showControlAfterTime() { Future.delayed(const Duration(milliseconds: 1500), () { showControls = true; update(); }); }
  void changeProgressVisibility() { showProgresscount = showProgresscount == 3 ? 0 : showProgresscount + 1; update(); }
  bool isTv() { final view = WidgetsFlutterBinding.ensureInitialized().window; final size = view.physicalSize; final ratio = view.devicePixelRatio; final w = size.width / ratio; final h = size.height / ratio; return sqrt(w*w+h*h) > 15; }
}
