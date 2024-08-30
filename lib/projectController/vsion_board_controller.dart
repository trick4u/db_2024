import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  final isLoading = true.obs;

  final _canSave = false.obs;
  bool get canSave => _canSave.value;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? currentUser = FirebaseAuth.instance.currentUser;

  CollectionReference get visionBoardCollection {
    return _firestore
        .collection('users')
        .doc(currentUser?.uid)
        .collection('vision_board');
  }

  @override
  void onInit() {
    super.onInit();
    ever(titleController.obs, (_) => _updateCanSave());
    ever(selectedImages, (_) => _updateCanSave());
    fetchVisionBoardItems();
  }

  void _updateCanSave() {
    _canSave.value = titleController.text.isNotEmpty && selectedImages.isNotEmpty;
  }

  void fetchVisionBoardItems() {
    if (currentUser == null) return;

    isLoading.value = true;
    visionBoardCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((querySnapshot) {
      List<VisionBoardItem> newItems = [];

      for (var doc in querySnapshot.docs) {
        VisionBoardItem item = VisionBoardItem.fromFirestore(doc);
        newItems.add(item);
      }

      visionBoardItems.value = newItems;
      isLoading.value = false;
      update();
    }, onError: (error) {
      print('Error fetching vision board items: $error');
      isLoading.value = false;
      update();
    });
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
          images.take(8).map((image) => compressImage(File(image.path),),),
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
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final List<String> imageUrls = await uploadImages();
        await saveToFirestore(imageUrls, user.uid);
        Get.back();
        Get.snackbar('Success', 'Vision board item saved successfully');
      } else {
        Get.snackbar('Error', 'You must be logged in to save a vision board item');
      }
    } catch (e) {
      print('Error saving note: $e');
      Get.snackbar('Error', 'Failed to save vision board item');
    } finally {
      isSaving.value = false;
    }
  }

  Future<List<String>> uploadImages() async {
    final List<String> imageUrls = [];
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return imageUrls;

    for (File image in selectedImages) {
      final String fileName = '${DateTime.now().millisecondsSinceEpoch}_${path.basename(image.path)}';
      final Reference ref = FirebaseStorage.instance.ref().child('users/${user.uid}/vision_board_images/$fileName');
      final UploadTask uploadTask = ref.putFile(image);
      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      imageUrls.add(downloadUrl);
    }
    return imageUrls;
  }

  Future<void> saveToFirestore(List<String> imageUrls, String userId) async {
    final newItem = VisionBoardItem(
      id: '',
      title: titleController.text,
      date: selectedDate.value,
      imageUrls: imageUrls,
      userId: userId,
    );

    final docRef = await visionBoardCollection.add(newItem.toMap());
    newItem.id = docRef.id;

    // Clear the form
    titleController.clear();
    selectedImages.clear();
    selectedDate.value = DateTime.now();
    _updateCanSave();
  }

  Future<void> deleteItem(String itemId) async {
    if (currentUser == null) return;
    try {
      // First, get the item to delete its images
      DocumentSnapshot doc = await visionBoardCollection.doc(itemId).get();
      VisionBoardItem item = VisionBoardItem.fromFirestore(doc);
      
      // Delete images from storage
      for (String imageUrl in item.imageUrls) {
        await FirebaseStorage.instance.refFromURL(imageUrl).delete();
      }
      
      // Delete the document from Firestore
      await visionBoardCollection.doc(itemId).delete();
      print('Vision board item deleted: $itemId');
    } catch (e) {
      print('Error deleting vision board item: $e');
    }
  }

  Future<void> updateItem(VisionBoardItem item) async {
    if (currentUser == null) return;
    try {
      await visionBoardCollection.doc(item.id).update(item.toMap());
      print('Vision board item updated: ${item.id}');
    } catch (e) {
      print('Error updating vision board item: $e');
    }
  }
}

class VisionBoardItem {
  String id;
  final String title;
  final DateTime date;
  final List<String> imageUrls;
  final String userId;

  VisionBoardItem({
    required this.id,
    required this.title,
    required this.date,
    required this.imageUrls,
    required this.userId,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'date': Timestamp.fromDate(date),
      'imageUrls': imageUrls,
      'userId': userId,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  static VisionBoardItem fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return VisionBoardItem(
      id: doc.id,
      title: data['title'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
      userId: data['userId'] ?? '',
    );
  }
}