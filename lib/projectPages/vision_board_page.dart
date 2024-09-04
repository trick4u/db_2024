import 'dart:ui';

import 'package:animate_do/animate_do.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';
import 'package:tushar_db/services/app_text_style.dart';
import 'package:tushar_db/services/app_theme.dart';

import '../projectController/vsion_board_controller.dart';
import '../services/scale_util.dart';
import '../widgets/vision_board_card.dart';
import '../widgets/vision_bottom_sheet.dart';

class VisionBoardPage extends GetWidget<VisionBoardController> {
   final appTheme = Get.find<AppTheme>();
  @override
  Widget build(BuildContext context) {
      appTheme.updateStatusBarColor();
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _buildFrostedGlassAppBar(context),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        } else if (controller.visionBoardItems.isEmpty) {
          return Center(
            child: Text(
              'Create your vision..',
              style: AppTextTheme.textTheme.bodyMedium,
            ),
          );
        } else {
          return Stack(
            children: [
              ListView.builder(
                padding: EdgeInsets.zero, // Remove any padding
                itemCount: controller.visionBoardItems.length,
                itemBuilder: (context, index) {
                  final item = controller.visionBoardItems[index];
                  return SlideInUp(
                    child: VisionBoardItemCard(
                      item: item,
                      onEdit: () => controller.showAddEditBottomSheet(context,
                          item: item),
                    ),
                  );
                },
              ),
              // Add a top gradient to ensure text readability when scrolling
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: kToolbarHeight + MediaQuery.of(context).padding.top,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.7),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        }
      }),
    );
  }

  PreferredSizeWidget _buildFrostedGlassAppBar(BuildContext context) {
    return PreferredSize(
      preferredSize: Size.fromHeight(kToolbarHeight),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text(
              'vision',
              style: AppTextTheme.textTheme.displaySmall?.copyWith(
                color: Colors.white,
              ),
            ),
            leading: _buildAppBarIcon(
              icon: Icons.arrow_back,
              onPressed: () => Navigator.of(context).pop(),
            ),
            actions: [
              Obx(() {
                if (controller.visionBoardItems.length < 20) {
                  return _buildAppBarIcon(
                    icon: FontAwesomeIcons.plus,
                    onPressed: () => _showAddItemSheet(context),
                  );
                } else {
                  return SizedBox.shrink();
                }
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBarIcon({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: IconButton(
          icon: Icon(
            icon,
            color: Colors.white,
            size: ScaleUtil.iconSize(15),
          ),
          onPressed: onPressed,
        ),
      ),
    );
  }

  void _showAddItemSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: VisionBottomSheet(),
      ),
    );
  }
}
