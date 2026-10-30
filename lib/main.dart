import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:sportik_player/controller/playercontroller.dart';
import 'package:sportik_player/view/screen/player.dart';
import 'package:sportik_player/view/screen/library.dart';

const _launchChannel = MethodChannel('sportik/player_launch');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Map<String, dynamic> args = {};
  try {
    final data = await _launchChannel.invokeMapMethod<String, dynamic>('getLaunchData');
    if (data != null) args = data;
  } catch (_) {}
  runApp(SportikPlayerApp(args: args));
}

class SportikPlayerApp extends StatefulWidget {
  const SportikPlayerApp({super.key, required this.args});
  final Map<String, dynamic> args;
  @override
  State<SportikPlayerApp> createState() => _SportikPlayerAppState();
}
class _SportikPlayerAppState extends State<SportikPlayerApp> {
  late Map<String, dynamic> args = widget.args;
  @override
  void initState() {
    super.initState();
    _launchChannel.setMethodCallHandler((call) async {
      if (call.method == 'launchDataChanged' && call.arguments is Map) {
        final data = Map<String, dynamic>.from(call.arguments as Map);
        setState(() => args = data);
        Get.delete<Playercontroller>(force: true);
        Get.put(Playercontroller(data));
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    if (args['displayname'] == null && args['localFilePath'] == null) {
      return GetMaterialApp(debugShowCheckedModeBanner: false, theme: ThemeData.dark(useMaterial3: true), home: const VideoLibraryPage());
    }
    if (!Get.isRegistered<Playercontroller>()) Get.put(Playercontroller(args));
    return GetMaterialApp(debugShowCheckedModeBanner: false, home: const Player(), theme: ThemeData.dark(useMaterial3: true));
  }
}
