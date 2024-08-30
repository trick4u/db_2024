

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';
import 'package:path/path.dart' as path;
import 'package:image/image.dart' as img;

class VisionBoardController extends GetxController {
  final titleController = TextEditingController();
  final selectedDate = DateTime.now().obs;
  final selectedImages = <File>[].obs;
  final isSaving = false.obs;
  final isPickingImages = false.obs;
  final visionBoardItems = <VisionBoardItem>[].obs;

  // Make canSave observable
  final _canSave = false.obs;
  bool get canSave => _canSave.value;

  @override
  void onInit() {
    super.onInit();
    // Listen to changes in the title and update canSave
    ever(titleController.obs, (_) => _updateCanSave());
    ever(selectedImages, (_) => _updateCanSave());
  }

  void _updateCanSave() {
    _canSave.value = titleController.text.isNotEmpty && selectedImages.isNotEmpty;
  }

  void updateSelectedDate(DateTime date) {
    selectedDate.value = date;
  }

  Future<void> pickImages() async {
    isPickingImages.value = true;
    try {
      final ImagePicker picker = ImagePicker();
      final List<XFile> images = await picker.pickMultiImage();
      if (images.isNotEmpty) {
        final List<File> compressedImages = await Future.wait(
          images.take(8).map((image) => compressImage(File(image.path))),
        );
        selectedImages.addAll(compressedImages);
        if (selectedImages.length > 8) {
          selectedImages.removeRange(8, selectedImages.length);
        }
      }
    } catch (e) {
      print('Error picking images: $e');
      Get.snackbar('Error', 'Failed to pick images');
    } finally {
      isPickingImages.value = false;
    }
  }

  Future<File> compressImage(File file) async {
    final img.Image? image = img.decodeImage(file.readAsBytesSync());
    if (image == null) return file;

    final img.Image compressedImage = img.copyResize(image, width: 800);
    final String dir = path.dirname(file.path);
    final String newPath = path.join(dir, 'compressed_${path.basename(file.path)}');
    final File result = File(newPath)..writeAsBytesSync(img.encodeJpg(compressedImage, quality: 85));
    return result;
  }

  Future<void> saveNote() async {
    if (!canSave) return;
    isSaving.value = true;

    try {
      final List<String> imageUrls = await uploadImages();
      await saveToFirestore(imageUrls);
      Get.back();
      Get.snackbar('Success', 'Vision board item saved successfully');
    } catch (e) {
      print('Error saving note: $e');
      Get.snackbar('Error', 'Failed to save vision board item');
    } finally {
      isSaving.value = false;
    }
  }

  Future<List<String>> uploadImages() async {
    final List<String> imageUrls = [];
    for (File image in selectedImages) {
      final String fileName = '${DateTime.now().millisecondsSinceEpoch}_${path.basename(image.path)}';
      final Reference ref = FirebaseStorage.instance.ref().child('vision_board_images/$fileName');
      final UploadTask uploadTask = ref.putFile(image);
      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      imageUrls.add(downloadUrl);
    }
    return imageUrls;
  }

  Future<void> saveToFirestore(List<String> imageUrls) async {
    final newItem = VisionBoardItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: titleController.text,
      date: selectedDate.value,
      imageUrls: imageUrls,
    );

    await FirebaseFirestore.instance.collection('vision_board').add(newItem.toMap());
    visionBoardItems.add(newItem);
    
    // Clear the form
    titleController.clear();
    selectedImages.clear();
    selectedDate.value = DateTime.now();
    _updateCanSave(); // Update canSave after clearing
  }
}

class VisionBoardItem {
  final String id;
  final String title;
  final DateTime date;
  final List<String> imageUrls;

  VisionBoardItem({
    required this.id,
    required this.title,
    required this.date,
    required this.imageUrls,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'date': date.toIso8601String(),
      'imageUrls': imageUrls,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}