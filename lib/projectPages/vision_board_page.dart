import 'package:carousel_slider/carousel_slider.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';

import '../projectController/vsion_board_controller.dart';
import '../services/scale_util.dart';

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
              child: Text('No vision board items yet',
                  style: TextStyle(fontSize: ScaleUtil.fontSize(16))));
        } else {
          return ListView.builder(
            itemCount: controller.visionBoardItems.length,
            itemBuilder: (context, index) {
              final item = controller.visionBoardItems[index];
              return VisionBoardItemCard(item: item);
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
      builder: (context) => SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: AddVisionBoardItemSheet(),
        ),
      ),
    );
  }
}

class VisionBoardItemCard extends StatefulWidget {
  final VisionBoardItem item;

  VisionBoardItemCard({required this.item});

  @override
  _VisionBoardItemCardState createState() => _VisionBoardItemCardState();
}

class _VisionBoardItemCardState extends State<VisionBoardItemCard> {
  int _currentImageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: ScaleUtil.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CarouselSlider(
            options: CarouselOptions(
              aspectRatio: 1,
              viewportFraction: 1,
              onPageChanged: (index, reason) {
                setState(() {
                  _currentImageIndex = index;
                });
              },
            ),
            items: widget.item.imageUrls.map((imageUrl) {
              return Builder(
                builder: (BuildContext context) {
                  return Container(
                    width: MediaQuery.of(context).size.width,
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                    ),
                  );
                },
              );
            }).toList(),
          ),
          if (widget.item.imageUrls.length > 1)
            Padding(
              padding: ScaleUtil.all(8),
              child: Center(
                child: DotsIndicator(
                  dotsCount: widget.item.imageUrls.length,
                  position: _currentImageIndex,
                  decorator: DotsDecorator(
                    size: Size.square(ScaleUtil.width(9)),
                    activeSize: Size(ScaleUtil.width(18), ScaleUtil.height(9)),
                    activeShape: RoundedRectangleBorder(
                        borderRadius: ScaleUtil.circular(5)),
                  ),
                ),
              ),
            ),
          Padding(
            padding: ScaleUtil.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.item.title,
                  style: TextStyle(
                    fontSize: ScaleUtil.fontSize(18),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ScaleUtil.sizedBox(height: 8),
                Text(
                  'Created on ${_formatDate(widget.item.date)}',
                  style: TextStyle(
                    fontSize: ScaleUtil.fontSize(14),
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class AddVisionBoardItemSheet extends GetWidget<VisionBoardController> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: ScaleUtil.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildDatePicker(context),
          ScaleUtil.sizedBox(height: 16),
          TextField(
            controller: controller.titleController,
            decoration: InputDecoration(
              labelText: 'Vision Board Item Title',
              border: OutlineInputBorder(),
              labelStyle: TextStyle(fontSize: ScaleUtil.fontSize(16)),
            ),
            style: TextStyle(fontSize: ScaleUtil.fontSize(16)),
            onChanged: (_) => controller.update(),
          ),
          ScaleUtil.sizedBox(height: 16),
          _buildImageList(),
          ScaleUtil.sizedBox(height: 16),
          _buildBottomButtons(),
        ],
      ),
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    return InkWell(
      onTap: () async {
        final DateTime? pickedDate = await showOmniDateTimePicker(
          context: context,
          initialDate: controller.selectedDate.value,
          firstDate: DateTime.now(),
          lastDate: DateTime(2101),
        );
        if (pickedDate != null) {
          controller.updateSelectedDate(pickedDate);
        }
      },
      child: Obx(() => Row(
            children: [
              Icon(Icons.calendar_today, size: ScaleUtil.iconSize(24)),
              ScaleUtil.sizedBox(width: 8),
              Text(
                '${controller.selectedDate.value.day}/${controller.selectedDate.value.month}/${controller.selectedDate.value.year}',
                style: TextStyle(fontSize: ScaleUtil.fontSize(16)),
              ),
            ],
          )),
    );
  }

  Widget _buildImageList() {
    return Obx(() => Column(
          children: [
            if (controller.isPickingImages.value)
              CircularProgressIndicator()
            else if (controller.selectedImages.isEmpty)
              Text('No images selected',
                  style: TextStyle(fontSize: ScaleUtil.fontSize(16)))
            else
              Wrap(
                spacing: ScaleUtil.width(8),
                runSpacing: ScaleUtil.height(8),
                children: controller.selectedImages
                    .map((image) => Image.file(
                          image,
                          width: ScaleUtil.width(80),
                          height: ScaleUtil.height(80),
                          fit: BoxFit.cover,
                        ))
                    .toList(),
              ),
          ],
        ));
  }

  Widget _buildBottomButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        IconButton(
          icon: Icon(Icons.image, size: ScaleUtil.iconSize(24)),
          onPressed:
              controller.isPickingImages.value ? null : controller.pickImages,
        ),
        ScaleUtil.sizedBox(width: 16),
        Obx(() => ElevatedButton(
              onPressed: controller.canSave &&
                      !controller.isPickingImages.value &&
                      !controller.isSaving.value
                  ? controller.saveNote
                  : null,
              child: controller.isSaving.value
                  ? CircularProgressIndicator()
                  : Text('Save',
                      style: TextStyle(fontSize: ScaleUtil.fontSize(16))),
            )),
      ],
    );
  }
}
