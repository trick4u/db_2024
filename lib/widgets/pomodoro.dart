import 'package:cached_network_image/cached_network_image.dart';
import 'package:dough/dough.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:http/http.dart' as http;
import 'package:tushar_db/services/scale_util.dart';
import 'dart:convert';

import '../projectController/pomodoro_controller.dart';
import '../services/app_theme.dart';

class PomodoroMusicPlayer extends GetView<PomodoroController> {
  final AppTheme appTheme = Get.find<AppTheme>();

  @override
  Widget build(BuildContext context) {
    ScaleUtil.init(context);

    return Scaffold(
      body: SafeArea(
        child: GestureDetector(
          onVerticalDragUpdate: (details) {
            if (details.primaryDelta! < 0) {
              // Swipe up - increase volume
              controller.increaseVolume();
            } else if (details.primaryDelta! > 0) {
              // Swipe down - decrease volume
              controller.decreaseVolume();
            }
          },
          child: PressableDough(
            onReleased: (r) {},
            child: Stack(
              children: [
                // Background Image
                Obx(
                  () => controller.backgroundImageUrl.value != null
                      ? ClipRRect(
                          borderRadius: ScaleUtil.circular(20),
                          child: Container(
                            width: double.infinity,
                            height: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: ScaleUtil.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey,
                                  spreadRadius: ScaleUtil.scale(1),
                                  blurRadius: ScaleUtil.scale(3),
                                  offset: Offset(0, ScaleUtil.scale(2)),
                                ),
                              ],
                            ),
                            child: CachedNetworkImage(
                              imageUrl: controller.backgroundImageUrl.value!,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: appTheme.colorScheme.surface,
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: appTheme.colorScheme.surface,
                                child: Icon(Icons.error),
                              ),
                            ),
                          ),
                        )
                      : Container(
                          width: double.infinity,
                          height: double.infinity,
                          color: appTheme.colorScheme.surface,
                          child: Center(child: CircularProgressIndicator()),
                        ),
                ),

                // Overlay for better text readability
               Obx(() => Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: appTheme.colorScheme.surface.withOpacity(controller.overlayOpacity.value),
                )),

                // Timer display
                Positioned(
                  top: ScaleUtil.height(20),
                  left: 0,
                  right: 0,
                  child: Obx(() {
                    final remainingTime = controller.remainingTime.value;
                    final minutes =
                        (remainingTime ~/ 60).toString().padLeft(2, '0');
                    final seconds =
                        (remainingTime % 60).toString().padLeft(2, '0');
                    return Text(
                      '$minutes:$seconds',
                      style: appTheme.titleLarge.copyWith(
                        color: appTheme.colorScheme.onSurface,
                        fontSize: ScaleUtil.fontSize(24),
                      ),
                      textAlign: TextAlign.center,
                    );
                  }),
                ),

                // Content
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Obx(
                        () => Text(
                          'Genre: ${controller.currentGenre.value}',
                          style: appTheme.titleLarge.copyWith(
                            color: appTheme.colorScheme.onSurface,
                            fontSize: ScaleUtil.fontSize(14),
                          ),
                        ),
                      ),
                      SizedBox(height: ScaleUtil.height(10)),
                      Obx(
                        () => Text(
                          controller.tracks.isNotEmpty
                              ? 'by ${controller.tracks[controller.currentTrackIndex.value]['artist_name']}'
                              : 'Loading...',
                          style: appTheme.titleLarge.copyWith(
                            color: appTheme.colorScheme.onSurface,
                            fontSize: ScaleUtil.fontSize(20),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Genre switching button
                Positioned(
                  right: ScaleUtil.width(110),
                  bottom: ScaleUtil.height(10),
                  child: _buildCircularButton(
                    onPressed: controller.switchGenre,
                    icon: Icon(
                      Icons.music_note,
                      color: appTheme.colorScheme.onPrimary,
                      size: ScaleUtil.iconSize(12),
                    ),
                  ),
                ),

                // Track switching button
                Positioned(
                  right: ScaleUtil.width(60),
                  bottom: ScaleUtil.height(10),
                  child: _buildCircularButton(
                    onPressed: controller.switchTrack,
                    icon: Obx(
                      () => Icon(
                        controller.isLimitedMode.value
                            ? Icons.shuffle
                            : Icons.skip_next,
                        color: appTheme.colorScheme.onPrimary,
                        size: ScaleUtil.iconSize(12),
                      ),
                    ),
                  ),
                ),

                // Mute/Play/Pause button in bottom right corner
         Positioned(
                  right: ScaleUtil.width(10),
                  bottom: ScaleUtil.height(10),
                  child: _buildCircularButton(
                    onPressed: controller.toggleMutePlayPause,
                    icon: Obx(
                      () => Icon(
                        controller.isVolumeMuted.value
                            ? Icons.volume_off
                            : (controller.isPlaying.value
                                ? Icons.volume_up
                                : Icons.play_arrow),
                        color: appTheme.colorScheme.onPrimary,
                        size: ScaleUtil.iconSize(12),
                      ),
                    ),
                  ),
                ),
                // Session start button
                Positioned(
                  left: ScaleUtil.width(10),
                  bottom: ScaleUtil.height(10),
                  child: _buildCircularButton(
                    onPressed: controller.startPomodoroSession,
                    icon: Icon(
                      Icons.timer,
                      color: appTheme.colorScheme.onPrimary,
                      size: ScaleUtil.iconSize(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCircularButton({
    required VoidCallback onPressed,
    required Widget icon,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      child: icon,
      style: ElevatedButton.styleFrom(
        shape: CircleBorder(),
        padding: ScaleUtil.all(10),
        backgroundColor: appTheme.colorScheme.primary.withOpacity(0.7),
        elevation: 5,
      ),
    );
  }
}
