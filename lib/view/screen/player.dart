import 'package:better_player_plus/better_player_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:sportik_player/controller/playercontroller.dart';
import 'package:sportik_player/core/constant/appImages.dart';
import 'package:sportik_player/view/screen/customplayerBtn.dart';

class Player extends StatefulWidget {
  const Player({super.key});

  @override
  State<Player> createState() => _PlayerState();
}

class _PlayerState extends State<Player> {
  late FocusNode backFocusNode;
  late FocusNode playPauseFocusNode;
  late FocusNode scaleFocusNode;
  late FocusNode hdFocusNode;
  late FocusNode sdFocusNode;
  late FocusNode logoFocusNode;
  late FocusNode keyboardFocusNode;

  @override
  void initState() {
    super.initState();
    backFocusNode = FocusNode();
    playPauseFocusNode = FocusNode();
    scaleFocusNode = FocusNode();
    hdFocusNode = FocusNode();
    sdFocusNode = FocusNode();
    logoFocusNode = FocusNode();
    keyboardFocusNode = FocusNode();
  }

  @override
  void dispose() {
    backFocusNode.dispose();
    playPauseFocusNode.dispose();
    scaleFocusNode.dispose();
    hdFocusNode.dispose();
    sdFocusNode.dispose();
    logoFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<Playercontroller>(
      builder: (controller) => Scaffold(
        body: Center(
          child: controller.isLoadingAds
              ? Container(
                  alignment: Alignment.center,
                  width: double.infinity,
                  height: double.infinity,
                  color: const Color(0xFF131313),
                  child: Text(
                    "جارٍ تشغيل القناة...",
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                )
              : KeyboardListener(
                  focusNode: keyboardFocusNode,

                  onKeyEvent: (value) {
                    if (value.logicalKey == LogicalKeyboardKey.enter ||
                        value.logicalKey == LogicalKeyboardKey.arrowUp ||
                        value.logicalKey == LogicalKeyboardKey.arrowDown ||
                        value.logicalKey == LogicalKeyboardKey.mediaTopMenu ||
                        value.logicalKey == LogicalKeyboardKey.contextMenu ||
                        value.logicalKey == LogicalKeyboardKey.tvContentsMenu) {
                      controller.showAndhideControl();
                    }
                  },
                  child: Stack(
                    children: [
                      BetterPlayer(controller: controller.controller!),
                      InkWell(
                        onTap: () => controller.showAndhideControl(),
                        child: controller.showControls
                            ? Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          const Color.fromARGB(200, 0, 0, 0),
                                          Colors.transparent,
                                        ],
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        TvIconButton(
                                          icon: Icons.arrow_back_ios_new,
                                          onPressed: () {
                                            Get.back();
                                          },
                                          node: backFocusNode,
                                          autofocus: false,
                                        ),
                                        const SizedBox(width: 20),
                                        Text(
                                          controller.displayname.isEmpty ? controller.localTitle : controller.displayname,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: "Cairo",
                                          ),
                                        ),
                                        Spacer(),
                                        GestureDetector(
                                          onTap: () => controller
                                              .changeProgressVisibility(),
                                          child: Container(
                                            padding: const EdgeInsets.all(10),
                                            child: Image.asset(
                                              AppImages().logo,
                                              width: 54,
                                              height: 54,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Spacer(),
                                  Column(
                                    children: [
                                      controller.showProgresscount == 3
                                          ? Container(
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 40,
                                                  ),

                                              child: ValueListenableBuilder<VideoPlayerValue?>(
                                                valueListenable: controller
                                                    .controller!
                                                    .videoPlayerController!,
                                                builder: (context, value, child) {
                                                  if (value == null ||
                                                      !value.initialized) {
                                                    return Container(
                                                      margin:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 10,
                                                          ),
                                                      width:
                                                          MediaQuery.of(
                                                            context,
                                                          ).size.width -
                                                          100,
                                                      child: LinearProgressIndicator(
                                                        value: 100,
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              10,
                                                            ),
                                                        valueColor:
                                                            const AlwaysStoppedAnimation<
                                                              Color
                                                            >(Colors.grey),
                                                        backgroundColor:
                                                            Colors.grey,
                                                      ),
                                                    );
                                                  }

                                                  final duration =
                                                      value.duration!;
                                                  final position =
                                                      value.position;
                                                  final buffered =
                                                      value.buffered;
                                                  final progress =
                                                      position.inMicroseconds /
                                                      duration.inMicroseconds;
                                                  final bufferedProgress =
                                                      buffered
                                                          .last
                                                          .end
                                                          .inSeconds /
                                                      duration.inSeconds;

                                                  return Container(
                                                    margin:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 30,
                                                        ),
                                                    width:
                                                        MediaQuery.of(
                                                          context,
                                                        ).size.width -
                                                        100,
                                                    child: Stack(
                                                      children: [
                                                        LinearProgressIndicator(
                                                          value:
                                                              bufferedProgress,
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                10,
                                                              ),
                                                          valueColor:
                                                              const AlwaysStoppedAnimation<
                                                                Color
                                                              >(
                                                                Colors
                                                                    .deepOrange,
                                                              ),
                                                          backgroundColor:
                                                              Colors.grey,
                                                        ),

                                                        LinearProgressIndicator(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                10,
                                                              ),
                                                          value: progress,
                                                          valueColor:
                                                              const AlwaysStoppedAnimation<
                                                                Color
                                                              >(Colors.white),
                                                          backgroundColor:
                                                              Colors
                                                                  .transparent,
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                },
                                              ),
                                            )
                                          : SizedBox(),

                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 30,
                                          vertical: 10,
                                        ),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.bottomCenter,
                                            end: Alignment.topCenter,
                                            colors: [
                                              const Color.fromARGB(
                                                200,
                                                0,
                                                0,
                                                0,
                                              ),
                                              Colors.transparent,
                                            ],
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            TvIconButton(
                                              icon: controller.isplaying
                                                  ? Icons.pause
                                                  : Icons.play_arrow_rounded,
                                              onPressed: () {
                                                controller.playpause();
                                              },
                                              node: playPauseFocusNode,
                                              autofocus: false,
                                            ),
                                            const SizedBox(width: 5),
                                            Text(
                                              "live".tr,
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: "Cairo",
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            CircleAvatar(
                                              radius: 6,
                                              backgroundColor: Colors.red,
                                            ),

                                            Spacer(),

                                            TvIconButton(
                                              icon: controller.fit == "fill"
                                                  ? Icons.crop
                                                  : controller.fit == "cover"
                                                  ? Icons.aspect_ratio
                                                  : Icons.fit_screen,
                                              onPressed: () {
                                                controller.changeScale();
                                              },
                                              node: scaleFocusNode,
                                              autofocus: false,
                                            ),
                                            const SizedBox(width: 40),
                                            if (!controller.isLocalVideo) controller.hdname != "empty"
                                                ? TvIconButton(
                                                    icon: Icons.hd_outlined,
                                                    onPressed: () => controller
                                                        .changeQuality("hd"),
                                                    node: hdFocusNode,
                                                    color:
                                                        controller.quality ==
                                                            "hd"
                                                        ? Colors.red
                                                        : Colors.white,
                                                    autofocus:
                                                        controller.quality ==
                                                            "hd"
                                                        ? true
                                                        : false,
                                                  )
                                                : const SizedBox(),
                                            if (!controller.isLocalVideo) const SizedBox(width: 20),

                                            if (!controller.isLocalVideo) TvIconButton(
                                              icon: Icons.sd_outlined,
                                              onPressed: () => controller
                                                  .changeQuality("sd"),
                                              node: sdFocusNode,
                                              color: controller.quality == "sd"
                                                  ? Colors.red
                                                  : Colors.white,
                                              autofocus:
                                                  controller.quality == "sd"
                                                  ? true
                                                  : false,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              )
                            : const SizedBox(
                                width: double.infinity,
                                height: double.infinity,
                              ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
