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
                    ? Container(
                        width: double.infinity,
                        height: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          
                        ),
                        child: CachedNetworkImage(
                          imageUrl: controller.backgroundImageUrl.value!,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: appTheme.colorScheme.surface,
                            child: Center(child: CircularProgressIndicator()),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: appTheme.colorScheme.surface,
                            child: Icon(Icons.error),
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
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Obx(() => Text(
                          controller.tracks.isNotEmpty
                              ? 'by ${controller.tracks[controller.currentTrackIndex.value]['artist_name']}'
                              : 'Loading...',
                          style: appTheme.titleLarge.copyWith(
                            color: appTheme.colorScheme.onSurface,
                            fontSize: ScaleUtil.fontSize(20),
                          ),
                        )),
                    SizedBox(height: ScaleUtil.height(20)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildCircularButton(
                          onPressed: controller.togglePlayPause,
                          icon: Obx(() => Icon(
                                controller.isPlaying.value
                                    ? Icons.pause
                                    : Icons.play_arrow,
                                color: appTheme.colorScheme.onPrimary,
                                size: ScaleUtil.iconSize(16),
                              )),
                        ),
                        SizedBox(width: ScaleUtil.width(20)),
                        _buildCircularButton(
                          onPressed: controller.playNextTrack,
                          icon: Icon(
                            Icons.skip_next,
                            color: appTheme.colorScheme.onPrimary,
                            size: ScaleUtil.iconSize(16),
                          ),
                        ),
                      ],
                    ),
                  ],
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
        padding: ScaleUtil.all(20),
        backgroundColor: appTheme.colorScheme.primary.withOpacity(0.7),
        elevation: 5,
      ),
    );
  }
}
