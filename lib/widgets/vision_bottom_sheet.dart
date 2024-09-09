import 'dart:io';

import 'package:animate_do/animate_do.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dough/dough.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';

import '../projectController/vsion_board_controller.dart';
import '../services/app_theme.dart';
import '../services/scale_util.dart';

class VisionBottomSheet extends GetWidget<VisionBoardController> {
  final AppTheme appTheme = Get.find<AppTheme>();

  @override
  Widget build(BuildContext context) {
    ScaleUtil.init(context);
    return PressableDough(
      onReleased: (d) {
        Get.back();
      },
      child: SlideInUp(
        child: Padding(
          padding: ScaleUtil.only(left: 10, right: 10, bottom: 10),
          child: Card(
            color: appTheme.cardColor,
            shape: RoundedRectangleBorder(
              borderRadius: ScaleUtil.circular(20),
            ),
            child: Container(
              padding: ScaleUtil.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Obx(() => Text(
                            controller.isEditing.value
                                ? 'Edit Vision'
                                : 'Add Vision',
                            style: appTheme.titleLarge.copyWith(
                              fontSize: ScaleUtil.fontSize(15),
                            ),
                          )),
                      Spacer(),
                      _buildDatePicker(context),
                      IconButton(
                        icon: Icon(Icons.close,
                            color: appTheme.textColor,
                            size: ScaleUtil.iconSize(15),),
                        onPressed: () => Get.back(),
                      ),
                    ],
                  ),
                  ScaleUtil.sizedBox(height: 10),
                  ClipRRect(
                    borderRadius: ScaleUtil.circular(10),
                    child: TextField(
                      controller: controller.titleController,
                      style: appTheme.bodyMedium,
                      decoration: InputDecoration(
                        labelText: 'Vision Board Item Title',
                        filled: true,
                        fillColor: appTheme.textFieldFillColor,
                        labelStyle: appTheme.bodyMedium.copyWith(
                          color: appTheme.secondaryTextColor,
                          fontSize: ScaleUtil.fontSize(12),
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        contentPadding:
                            ScaleUtil.symmetric(horizontal: 16, vertical: 6),
                      ),
                      onChanged: (_) => controller.update(),
                    ),
                  ),
                  ScaleUtil.sizedBox(height: 16),
                  _buildImageList(),
                  ScaleUtil.sizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SlideInRight(
                        child: Row(
                          children: [
                            _buildImagePickerButton(),
                            ScaleUtil.sizedBox(width: 16),
                            _buildSaveIconButton(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    return InkWell(
      onTap: () async {
        DateTime? pickedDate = await showOmniDateTimePicker(
          context: context,
          initialDate: controller.selectedDate.value,
          firstDate: DateTime.now(),
          lastDate: DateTime(2101),
          is24HourMode: true,
          isShowSeconds: false,
          minutesInterval: 1,
          secondsInterval: 1,
          borderRadius: ScaleUtil.circular(16),
          constraints: BoxConstraints(
            maxWidth: ScaleUtil.width(200),
            maxHeight: ScaleUtil.height(400),
          ),
          transitionBuilder: (context, anim1, anim2, child) {
            return FadeTransition(
              opacity: anim1.drive(
                Tween(
                  begin: 0,
                  end: 1,
                ),
              ),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 200),
          barrierDismissible: true,
          selectableDayPredicate: (dateTime) {
            return true;
          },
        );

        if (pickedDate != null && pickedDate != controller.selectedDate.value) {
          controller.updateSelectedDate(pickedDate);
        }
      },
      child: Container(
        padding: ScaleUtil.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: appTheme.colorScheme.primary,
          borderRadius: ScaleUtil.circular(8),
        ),
        child: Obx(() => Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.calendar_today,
                    color: Colors.white, size: ScaleUtil.iconSize(16)),
                ScaleUtil.sizedBox(width: 8),
                Text(
                  '${controller.selectedDate.value.day}/${controller.selectedDate.value.month}/${controller.selectedDate.value.year}',
                  style: TextStyle(
                      color: Colors.white, fontSize: ScaleUtil.fontSize(14)),
                ),
              ],
            )),
      ),
    );
  }

  Widget _buildImageList() {
    return Obx(() {
      int totalImages = controller.selectedNetworkImages.length +
          controller.selectedImages.length;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (controller.isPickingImages.value)
            Center(child: CircularProgressIndicator())
          else if (totalImages == 0)
            Text(
              'No images selected',
              style: appTheme.bodyMedium.copyWith(
                color: appTheme.secondaryTextColor,
                fontSize: ScaleUtil.fontSize(14),
              ),
            )
          else
            Wrap(
              spacing: ScaleUtil.width(8),
              runSpacing: ScaleUtil.height(8),
              children: [
                ...controller.selectedNetworkImages
                    .asMap()
                    .entries
                    .map((entry) {
                  int index = entry.key;
                  String imageUrl = entry.value;
                  return _buildImageItem(
                      networkImage: imageUrl,
                      index: index,
                      isNetworkImage: true);
                }),
                ...controller.selectedImages.asMap().entries.map((entry) {
                  int index = entry.key;
                  var image = entry.value;
                  return _buildImageItem(
                      file: image, index: index, isNetworkImage: false);
                }),
              ],
            ),
        ],
      );
    });
  }

  Widget _buildImageItem({
    File? file,
    String? networkImage,
    required int index,
    required bool isNetworkImage,
  }) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: isNetworkImage
              ? CachedNetworkImage(
                  imageUrl: networkImage!,
                  width: ScaleUtil.width(80),
                  height: ScaleUtil.height(80),
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    width: ScaleUtil.width(80),
                    height: ScaleUtil.height(80),
                    color: appTheme.textFieldFillColor,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (context, url, error) => Container(
                    width: ScaleUtil.width(80),
                    height: ScaleUtil.height(80),
                    color: appTheme.textFieldFillColor,
                    child: Icon(Icons.error, color: appTheme.cardColor),
                  ),
                )
              : Image.file(
                  file!,
                  width: ScaleUtil.width(80),
                  height: ScaleUtil.height(80),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    print("Error loading local image: $error");
                    return Container(
                      width: ScaleUtil.width(80),
                      height: ScaleUtil.height(80),
                      color: appTheme.textFieldFillColor,
                      child: Icon(Icons.error, color: appTheme.cardColor),
                    );
                  },
                ),
        ),
        Positioned(
          top: 0,
          right: 0,
          child: GestureDetector(
            onTap: () {
              if (isNetworkImage) {
                controller.removeNetworkImage(index);
              } else {
                controller.removeImage(index);
              }
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.close,
                color: Colors.white,
                size: ScaleUtil.iconSize(18),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImagePickerButton() {
    return Obx(() {
      int totalImages = controller.selectedNetworkImages.length +
          controller.selectedImages.length;

      if (totalImages >= 8) {
        return SizedBox
            .shrink(); // Return an empty widget when 8 images are selected
      }

      return Container(
        decoration: BoxDecoration(
          color: appTheme.colorScheme.primary,
          shape: BoxShape.circle,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: ScaleUtil.circular(20),
            onTap:
                controller.isPickingImages.value ? null : controller.pickImages,
            child: Padding(
              padding: ScaleUtil.all(10),
              child: Icon(
                FontAwesomeIcons.image,
                color: Colors.white,
                size: ScaleUtil.iconSize(15),
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildSaveIconButton() {
    return Obx(() => Container(
          decoration: BoxDecoration(
            color: controller.canSave &&
                    controller.titleController.text.trim().isNotEmpty
                ? appTheme.colorScheme.primary
                : Colors.grey,
            shape: BoxShape.circle,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: ScaleUtil.circular(20),
              onTap: controller.canSave &&
                      controller.titleController.text.trim().isNotEmpty &&
                      !controller.isPickingImages.value &&
                      !controller.isSaving.value
                  ? () {
                      print("Save button pressed");
                      controller.saveNote();
                    }
                  : null,
              child: Padding(
                padding: ScaleUtil.all(10),
                child: controller.isSaving.value
                    ? SizedBox(
                        width: ScaleUtil.width(15),
                        height: ScaleUtil.height(15),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Icon(
                        FontAwesomeIcons.check,
                        color: Colors.white,
                        size: ScaleUtil.iconSize(15),
                      ),
              ),
            ),
          ),
        ));
  }
}
