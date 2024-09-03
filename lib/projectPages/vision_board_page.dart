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
    ScaleUtil.init(context); // Initialize ScaleUtil
    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        title: Text(
          'vision',
          style: AppTextTheme.textTheme.displaySmall,
        ),
        actions: [
          Obx(() {
            if (controller.visionBoardItems.length < 20) {
              return IconButton(
                onPressed: () {
                  _showAddItemSheet(context);
                },
                icon: Icon(FontAwesomeIcons.plus),
              );
            } else {
              return SizedBox
                  .shrink(); // Return an empty widget when items >= 10
            }
          }),
        ],
      ),
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
