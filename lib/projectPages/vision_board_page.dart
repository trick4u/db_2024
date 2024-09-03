import 'dart:ui';

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
  @override
  Widget build(BuildContext context) {
    ScaleUtil.init(context);
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
          return ListView.builder(
            padding: EdgeInsets.only(top: kToolbarHeight + 20),
            itemCount: controller.visionBoardItems.length,
            itemBuilder: (context, index) {
              final item = controller.visionBoardItems[index];
              return VisionBoardItemCard(
                item: item,
                onEdit: () =>
                    controller.showAddEditBottomSheet(context, item: item),
              );
            },
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
          filter: ImageFilter.blur(sigmaX: 0, sigmaY: 10),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text(
              'vision',
              style: AppTextTheme.textTheme.displaySmall?.copyWith(
                color: Colors.white,
              ),
            ),
            actions: [
              Obx(() {
                if (controller.visionBoardItems.length < 20) {
                  return IconButton(
                    onPressed: () => _showAddItemSheet(context),
                    icon: Icon(FontAwesomeIcons.plus, color: Colors.white),
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
