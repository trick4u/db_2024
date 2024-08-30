import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';

import '../projectController/vsion_board_controller.dart';

class VisionBoardPage extends GetWidget<VisionBoardController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Vision Board'),
      ),
      body: Obx(() => GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: controller.visionBoardItems.length,
            itemBuilder: (context, index) {
              final item = controller.visionBoardItems[index];
              return Card(
                child: Column(
                  children: [
                    Expanded(
                      child: Image.network(item.imageUrls.first,
                          fit: BoxFit.cover),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(item.title),
                    ),
                  ],
                ),
              );
            },
          )),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddItemSheet(context),
        child: Icon(Icons.add),
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

class AddVisionBoardItemSheet extends GetWidget<VisionBoardController> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildDatePicker(context),
          const SizedBox(height: 16),
          TextField(
            controller: controller.titleController,
            decoration: InputDecoration(
              labelText: 'Vision Board Item Title',
              border: OutlineInputBorder(),
            ),
            onChanged: (_) => controller.update(),
          ),
          const SizedBox(height: 16),
          _buildImageList(),
          const SizedBox(height: 16),
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
          Icon(Icons.calendar_today),
          const SizedBox(width: 8),
          Text(
            '${controller.selectedDate.value.day}/${controller.selectedDate.value.month}/${controller.selectedDate.value.year}',
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
          Text('No images selected')
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: controller.selectedImages
                .map((image) => Image.file(
              image,
              width: 80,
              height: 80,
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
          icon: Icon(Icons.image),
          onPressed: controller.isPickingImages.value ? null : controller.pickImages,
        ),
        const SizedBox(width: 16),
        Obx(() => ElevatedButton(
          onPressed: controller.canSave && !controller.isPickingImages.value && !controller.isSaving.value
              ? controller.saveNote
              : null,
          child: controller.isSaving.value
              ? CircularProgressIndicator()
              : Text('Save'),
        )),
      ],
    );
  }
}