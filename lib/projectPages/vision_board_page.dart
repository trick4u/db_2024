import 'package:carousel_slider/carousel_slider.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';

import '../projectController/vsion_board_controller.dart';
import '../services/scale_util.dart';
import '../widgets/vision_board_card.dart';
import '../widgets/vision_bottom_sheet.dart';

class VisionBoardPage extends GetWidget<VisionBoardController> {
  @override
  Widget build(BuildContext context) {
    ScaleUtil.init(context); // Initialize ScaleUtil
    return Scaffold(
      appBar: AppBar(
        title: Text('Vision Board',
            style: TextStyle(fontSize: ScaleUtil.fontSize(20))),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        } else if (controller.visionBoardItems.isEmpty) {
          return Center(
            child: Text(
              'No vision board items yet',
              style: TextStyle(
                fontSize: ScaleUtil.fontSize(16),
              ),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddItemSheet(context),
        child: Icon(Icons.add, size: ScaleUtil.iconSize(24)),
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
