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
import 'package:http/http.dart' as http;

import '../widgets/vision_bottom_sheet.dart';

class VisionBoardController extends GetxController {
  final titleController = TextEditingController();
  final selectedDate = DateTime.now().obs;
  final selectedImages = <File>[].obs;
  final isSaving = false.obs;
  final isPickingImages = false.obs;
  final visionBoardItems = <VisionBoardItem>[].obs;
  final isLoading = true.obs;
  final isEditing = false.obs;
  final editingItem = Rx<VisionBoardItem?>(null);
  final selectedNetworkImages = <String>[].obs;

   String? _originalTitle;
  DateTime? _originalDate;
  List<String>? _originalImageUrls;


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
    titleController.addListener(_checkForChanges);
    ever(selectedDate, (_) => _checkForChanges());
    ever(selectedImages, (_) => _checkForChanges());
    ever(selectedNetworkImages, (_) => _checkForChanges());
    fetchVisionBoardItems();
  }
    @override
  void onClose() {
    titleController.removeListener(_checkForChanges);
    titleController.dispose();
    super.onClose();
  }

 void resetForm() {
    titleController.clear();
    selectedImages.clear();
    selectedNetworkImages.clear();
    selectedDate.value = DateTime.now();
    isEditing.value = false;
    editingItem.value = null;
    _originalTitle = null;
    _originalDate = null;
    _originalImageUrls = null;
    _checkForChanges();
  }

  bool _haveImagesChanged() {
    if (_originalImageUrls == null) return false;
    if (selectedNetworkImages.length != _originalImageUrls!.length) return true;
    for (int i = 0; i < selectedNetworkImages.length; i++) {
      if (selectedNetworkImages[i] != _originalImageUrls![i]) return true;
    }
    return selectedImages.isNotEmpty;
  }

   void _checkForChanges() {
    if (isEditing.value) {
      bool titleChanged = titleController.text.trim() != _originalTitle;
      bool dateChanged = selectedDate.value != _originalDate;
      bool imagesChanged = _haveImagesChanged();

      _canSave.value = titleChanged || dateChanged || imagesChanged;
    } else {
      _canSave.value = titleController.text.trim().isNotEmpty &&
          (selectedImages.isNotEmpty || selectedNetworkImages.isNotEmpty);
    }
  }

 void showAddEditBottomSheet(BuildContext context, {VisionBoardItem? item}) {
    if (item != null) {
      isEditing.value = true;
      editingItem.value = item;
      titleController.text = item.title;
      selectedDate.value = item.date;
      selectedNetworkImages.value = List<String>.from(item.imageUrls);
      selectedImages.clear();

      _originalTitle = item.title.trim();
      _originalDate = item.date;
      _originalImageUrls = List<String>.from(item.imageUrls);
    } else {
      resetForm();
    }
    _checkForChanges();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: VisionBottomSheet(),
        );
      },
    ).then((_) => resetForm());
  }

  void editItem(VisionBoardItem item, BuildContext context) {
    isEditing.value = true;
    editingItem.value = item;
    titleController.text = item.title;
    selectedDate.value = item.date;
    selectedNetworkImages.value = List<String>.from(item.imageUrls);
    selectedImages.clear();

    // Store original values
    _originalTitle = item.title.trim();
    _originalDate = item.date;
    _originalImageUrls = List<String>.from(item.imageUrls);

    _checkForChanges();
    showAddEditBottomSheet(context, item: item);
  }

 Future<void> updateEditedItem() async {
    if (editingItem.value == null) return;

    try {
      List<String> updatedImageUrls = [];
      
      // Keep existing network images
      updatedImageUrls.addAll(selectedNetworkImages);
      
      // Upload new local images
      for (File image in selectedImages) {
        String url = await uploadSingleImage(image);
        if (url.isNotEmpty) {
          updatedImageUrls.add(url);
        }
      }

      final updatedItem = VisionBoardItem(
        id: editingItem.value!.id,
        title: titleController.text,
        date: selectedDate.value,
        imageUrls: updatedImageUrls,
        userId: editingItem.value!.userId,
      );

      await updateItem(updatedItem);
      
      // Update the local state immediately
      int index = visionBoardItems.indexWhere((item) => item.id == updatedItem.id);
      if (index != -1) {
        visionBoardItems[index] = updatedItem;
        visionBoardItems.refresh(); // This triggers a UI update
      }

      Get.back(); // Close the bottom sheet
      Get.snackbar('Success', 'Vision board item updated successfully',
          snackPosition: SnackPosition.TOP);
    } catch (e) {
      print("Error updating item: $e");
      Get.snackbar('Error', 'Failed to update vision board item',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  void clearForm() {
    titleController.clear();
    selectedImages.clear();
    selectedDate.value = DateTime.now();
    _updateCanSave();
  }

 void removeNetworkImage(int index) {
    try {
      if (index >= 0 && index < selectedNetworkImages.length) {
        selectedNetworkImages.removeAt(index);
        _updateCanSave();
        update(); // Ensure the UI updates
      }
    } catch (e) {
      print("Error removing network image: $e");
      Get.snackbar('Error', 'Failed to remove image',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  void removeImage(int index) {
    try {
      if (index >= 0 && index < selectedImages.length) {
        selectedImages.removeAt(index);
        _updateCanSave();
        update(); // Ensure the UI updates
      }
    } catch (e) {
      print("Error removing local image: $e");
      Get.snackbar('Error', 'Failed to remove image',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  void _updateCanSave() {
    _canSave.value = titleController.text.isNotEmpty && 
                     (selectedImages.isNotEmpty || selectedNetworkImages.isNotEmpty);
    update();
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
          images.take(8).map(
                (image) => compressImage(
                  File(image.path),
                ),
              ),
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
    final String newPath =
        path.join(dir, 'compressed_${path.basename(file.path)}');
    final File result = File(newPath)
      ..writeAsBytesSync(img.encodeJpg(compressedImage, quality: 70),);
    return result;
  }


  Future<void> saveNote() async {
    if (!canSave) {
      print("Cannot save: No changes or invalid input");
      return;
    }
    isSaving.value = true;

    try {
      if (isEditing.value) {
        print("Updating existing item");
        await updateEditedItem();
      } else {
        print("Saving new item");
        await saveNewItem();
      }
      Get.back();
      Get.snackbar(
          'Success',
          isEditing.value
              ? 'Vision board item updated successfully'
              : 'New vision board item added successfully');
    } catch (e) {
      print('Error saving/updating note: $e');
      Get.snackbar('Error', 'Failed to save/update vision board item');
    } finally {
      isSaving.value = false;
      isEditing.value = false;
      editingItem.value = null;
      resetForm();
    }
  }

Future<void> saveNewItem() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('You must be logged in to save a vision board item');
    }
    final List<String> imageUrls = await uploadImages();
    await saveToFirestore(imageUrls, user.uid);
  }

  Future<List<String>> updateImages(List<String> oldImageUrls) async {
    final List<String> updatedImageUrls = [];
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return updatedImageUrls;

    // Remove old images that are not in the new selection
    for (String oldUrl in oldImageUrls) {
      if (!selectedImages.any((file) => file.path == oldUrl)) {
        await FirebaseStorage.instance.refFromURL(oldUrl).delete();
      } else {
        updatedImageUrls.add(oldUrl);
      }
    }

    // Upload new images
    for (File image in selectedImages) {
      if (!oldImageUrls.contains(image.path)) {
        final String downloadUrl = await uploadSingleImage(image);
        if (downloadUrl.isNotEmpty) {
          updatedImageUrls.add(downloadUrl);
        }
      }
    }

    return updatedImageUrls;
  }

  Future<String> uploadSingleImage(File image) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return '';

    final String fileName =
        '${DateTime.now().millisecondsSinceEpoch}_${path.basename(image.path)}';
    final Reference ref = FirebaseStorage.instance
        .ref()
        .child('users/${user.uid}/vision_board_images/$fileName');
    final UploadTask uploadTask = ref.putFile(image);
    final TaskSnapshot snapshot = await uploadTask;
    final String downloadUrl = await snapshot.ref.getDownloadURL();

    if (await _isValidImageUrl(downloadUrl)) {
      return downloadUrl;
    } else {
      print('Invalid image URL: $downloadUrl');
      return '';
    }
  }

  Future<List<String>> uploadImages() async {
    final List<String> imageUrls = [];
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return imageUrls;

    for (File image in selectedImages) {
      final String fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${path.basename(image.path)}';
      final Reference ref = FirebaseStorage.instance
          .ref()
          .child('users/${user.uid}/vision_board_images/$fileName');
      final UploadTask uploadTask = ref.putFile(image);
      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      // Validate the URL
      if (await _isValidImageUrl(downloadUrl)) {
        imageUrls.add(downloadUrl);
      } else {
        print('Invalid image URL: $downloadUrl');
      }
    }
    return imageUrls;
  }

  Future<bool> _isValidImageUrl(String url) async {
    try {
      final response = await http.head(Uri.parse(url));
      return response.statusCode == 200 &&
          response.headers['content-type']?.startsWith('image/') == true;
    } catch (e) {
      print('Error validating image URL: $e');
      return false;
    }
  }

   Future<void> saveToFirestore(List<String> imageUrls, String userId) async {
    final newItem = VisionBoardItem(
      id: '',
      title: titleController.text.trim(), // Trim the title before saving
      date: selectedDate.value,
      imageUrls: imageUrls,
      userId: userId,
    );

    final docRef = await visionBoardCollection.add(newItem.toMap());
    newItem.id = docRef.id;

    // Clear the form
    resetForm();
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
      throw e; // Rethrow the error to be caught in updateEditedItem
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
