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
        child: PressableDough(
          onReleased: (r) {
            controller.fetchRandomBackgroundImage();
          },
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
              Container(
                width: double.infinity,
                height: double.infinity,
                color: appTheme.colorScheme.surface.withOpacity(0.3),
              ),

              // Content
              Obx(
                () => Center(
                  child: Text(
                    controller.tracks.isNotEmpty
                        ? 'by ${controller.tracks[controller.currentTrackIndex.value]['artist_name']}'
                        : 'Loading...',
                    style: appTheme.titleLarge.copyWith(
                      color: appTheme.colorScheme.onSurface,
                      fontSize: ScaleUtil.fontSize(20),
                    ),
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
                      controller.isMuted.value
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
            ],
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
