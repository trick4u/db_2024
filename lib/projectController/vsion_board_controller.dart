import 'dart:io';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
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

  final isEditing = false.obs;
  final editingItem = Rx<VisionBoardItem?>(null);
  final selectedNetworkImages = <String>[].obs;
  final _imageHashes = <String>{};
  final RxMap<String, bool> _scheduledNotifications = <String, bool>{}.obs;
  final RxList<VisionBoardItem> visionBoardItems = <VisionBoardItem>[].obs;
  final RxBool isLoading = true.obs;
  final RxMap<String, bool> _notificationActiveStates = <String, bool>{}.obs;
  final RxInt activeMorningNotificationsCount = 0.obs;
  final RxInt activeNightNotificationsCount = 0.obs;
  final int maxNotificationsPerTime = 5;
  static const int maxEditCount = 4;
  final RxMap<String, bool> _expandedStates = <String, bool>{}.obs;

  DocumentSnapshot? lastDocument;

  final RxList<VisionBoardItem> displayedItems = <VisionBoardItem>[].obs;
  final RxBool isLoadingMore = false.obs;
  final int pageSize = 5;
  int currentPage = 0;
  bool hasMoreItems = true;

  String? _originalTitle;
  DateTime? _originalDate;
  List<String>? _originalImageUrls;

  final _canSave = false.obs;
  bool get canSave => _canSave.value;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? currentUser = FirebaseAuth.instance.currentUser;
  final RxList<String> itemOrder = <String>[].obs;
  final RxBool isReversed = false.obs;

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
    _loadScheduledNotifications();
    _loadActiveNotificationsCount();
  }

  @override
  void onClose() {
    titleController.removeListener(_checkForChanges);
    titleController.dispose();
    super.onClose();
  }

  void _loadActiveNotificationsCount() async {
    List<NotificationModel> notifications =
        await AwesomeNotifications().listScheduledNotifications();
    activeMorningNotificationsCount.value = 0;
    activeNightNotificationsCount.value = 0;

    for (var notification in notifications) {
      if (notification.content?.payload?['time'] == 'morning') {
        activeMorningNotificationsCount.value++;
      } else if (notification.content?.payload?['time'] == 'night') {
        activeNightNotificationsCount.value++;
      }
    }
  }

  bool isItemExpanded(String itemId) {
    return _expandedStates[itemId] ?? false;
  }

  void toggleItemExpansion(String itemId) {
    _expandedStates[itemId] = !(_expandedStates[itemId] ?? false);
    update();
  }

  bool canScheduleMorningNotification() {
    return activeMorningNotificationsCount.value < maxNotificationsPerTime;
  }

  bool canScheduleNightNotification() {
    return activeNightNotificationsCount.value < maxNotificationsPerTime;
  }

  bool canScheduleAnyNotification() {
    return canScheduleMorningNotification() || canScheduleNightNotification();
  }

  bool isNotificationActive(String itemId) {
    return _notificationActiveStates[itemId] ?? false;
  }

  void reverseOrder() {
    isReversed.value = !isReversed.value;
    visionBoardItems.value = visionBoardItems.reversed.toList();
    _updateDisplayedItems();
  }

  void _updateDisplayedItems() {
    int endIndex = (currentPage + 1) * pageSize;
    if (endIndex > visionBoardItems.length) {
      endIndex = visionBoardItems.length;
    }
    displayedItems.value = visionBoardItems.sublist(0, endIndex);
    hasMoreItems = endIndex < visionBoardItems.length;
  }

  void _loadScheduledNotifications() async {
    List<NotificationModel> notifications =
        await AwesomeNotifications().listScheduledNotifications();
    for (var notification in notifications) {
      _scheduledNotifications[notification.content!.id.toString()] = true;
    }
  }

  bool hasScheduledNotification(String itemId) {
    return _scheduledNotifications[itemId] ?? false;
  }

  Future<void> scheduleNotification(
      VisionBoardItem item, bool isMorning) async {
    if (isMorning && !canScheduleMorningNotification()) {
      Get.snackbar(
        'Morning Notification Limit Reached',
        'You can only have 5 active morning notifications. Please cancel an existing morning notification to schedule a new one.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    if (!isMorning && !canScheduleNightNotification()) {
      Get.snackbar(
        'Night Notification Limit Reached',
        'You can only have 5 active night notifications. Please cancel an existing night notification to schedule a new one.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    int notificationId = item.id.hashCode;
    String title = 'Vision Board Reminder';
    String body = item.title;
    String imageUrl = item.imageUrls.isNotEmpty ? item.imageUrls[0] : '';

    DateTime scheduledTime = _getNextAvailableTime(isMorning);

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        autoDismissible: false,
        id: notificationId,
        channelKey: 'event_reminders',
        title: title,
        body: body,
        bigPicture: imageUrl,
        notificationLayout: NotificationLayout.BigPicture,
        category: NotificationCategory.Reminder,
        payload: {'time': isMorning ? 'morning' : 'night'},
      ),
      schedule: NotificationCalendar(
        year: scheduledTime.year,
        month: scheduledTime.month,
        day: scheduledTime.day,
        hour: scheduledTime.hour,
        minute: scheduledTime.minute,
        second: 0,
        millisecond: 0,
        repeats: false,
        allowWhileIdle: true,
      ),
    );

    // Update local state and Firestore
    _notificationActiveStates[item.id] = true;
    if (isMorning) {
      activeMorningNotificationsCount.value++;
    } else {
      activeNightNotificationsCount.value++;
    }

    await visionBoardCollection.doc(item.id).update({
      'hasNotification': true,
      'notificationTime': isMorning ? 'morning' : 'night',
      'scheduledNotificationTime': Timestamp.fromDate(scheduledTime),
    });

    // Update local item
    int index = visionBoardItems.indexWhere((i) => i.id == item.id);
    if (index != -1) {
      visionBoardItems[index] = visionBoardItems[index].copyWith(
        hasNotification: true,
        notificationTime: isMorning ? 'morning' : 'night',
        scheduledNotificationTime: scheduledTime,
      );
      visionBoardItems.refresh();
    }

    _scheduleNotificationStateUpdate(item.id, scheduledTime);

    Get.snackbar(
      'Notification Scheduled',
      'You will be reminded at ${scheduledTime.hour}:${scheduledTime.minute.toString().padLeft(2, '0')}',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  DateTime _getNextAvailableTime(bool isMorning) {
    DateTime now = DateTime.now();
    DateTime baseTime = isMorning
        ? DateTime(now.year, now.month, now.day, 12, 20)
        : DateTime(now.year, now.month, now.day, 22, 0);

    if (baseTime.isBefore(now)) {
      baseTime = baseTime.add(Duration(days: 1));
    }

    // Check for existing notifications and adjust time if necessary
    List<DateTime> existingTimes = visionBoardItems
        .where((item) =>
            item.hasNotification && item.scheduledNotificationTime != null)
        .map((item) => item.scheduledNotificationTime!)
        .toList();

    while (existingTimes
        .any((time) => time.difference(baseTime).inMinutes.abs() < 10)) {
      baseTime = baseTime.add(Duration(minutes: 10));
    }

    return baseTime;
  }


  void _scheduleNotificationStateUpdate(String itemId, DateTime scheduledTime) {
    Future.delayed(scheduledTime.difference(DateTime.now()), () {
      _updateNotificationStateAfterFiring(itemId);
    });
  }

  Future<void> _updateNotificationStateAfterFiring(String itemId) async {
    // Update the local state
    _notificationActiveStates[itemId] = false;

    // Update the item's notification state in Firestore
    await visionBoardCollection.doc(itemId).update({
      'hasNotification': false,
      'notificationTime': null,
      'scheduledNotificationTime': null,
    });

    // Update the local item
    int index = visionBoardItems.indexWhere((i) => i.id == itemId);
    if (index != -1) {
      visionBoardItems[index] = visionBoardItems[index].copyWith(
        hasNotification: false,
        notificationTime: null,
        scheduledNotificationTime: null,
      );
      visionBoardItems.refresh();
    }
  }

  Future<void> cancelNotification(String itemId) async {
    VisionBoardItem? item = visionBoardItems.firstWhere((i) => i.id == itemId);
    await AwesomeNotifications().cancel(itemId.hashCode);

    _notificationActiveStates[itemId] = false;
    if (item.notificationTime == 'morning') {
      activeMorningNotificationsCount.value--;
    } else if (item.notificationTime == 'night') {
      activeNightNotificationsCount.value--;
    }

    await visionBoardCollection.doc(itemId).update({
      'hasNotification': false,
      'notificationTime': null,
      'scheduledNotificationTime': null,
    });

    int index = visionBoardItems.indexWhere((i) => i.id == itemId);
    if (index != -1) {
      visionBoardItems[index] = visionBoardItems[index].copyWith(
        hasNotification: false,
        notificationTime: null,
        scheduledNotificationTime: null,
      );
      visionBoardItems.refresh();
    }

    Get.snackbar(
      'Notification Cancelled',
      'The reminder for this item has been cancelled',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  DateTime _getNextMorningTime() {
    DateTime now = DateTime.now();
    DateTime scheduledTime = DateTime(now.year, now.month, now.day, 8, 0);
    if (scheduledTime.isBefore(now)) {
      scheduledTime = scheduledTime.add(Duration(days: 1));
    }
    return scheduledTime;
  }

  DateTime _getNextNightTime() {
    DateTime now = DateTime.now();
    DateTime scheduledTime = DateTime(now.year, now.month, now.day, 22, 0);
    if (scheduledTime.isBefore(now)) {
      scheduledTime = scheduledTime.add(Duration(days: 1));
    }
    return scheduledTime;
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
    _imageHashes.clear();
  }

  Future<String> computeImageHash(File image) async {
    // Implement a simple hash function based on file path and modification time
    // For a more robust solution, consider using a proper image hashing algorithm
    String filePath = image.path;
    DateTime lastModified = await image.lastModified();
    return '$filePath|${lastModified.millisecondsSinceEpoch}';
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

      _canSave.value = (titleChanged || dateChanged || imagesChanged) &&
          titleController.text.trim().isNotEmpty;
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
    _imageHashes.clear();
    // Store original values
    _originalTitle = item.title.trim();
    _originalDate = item.date;
    _originalImageUrls = List<String>.from(item.imageUrls);
    for (String url in item.imageUrls) {
      _imageHashes.add(url); // Use URL as a simple hash for network images
    }

    // Preserve notification state
    _scheduledNotifications[item.id] = item.hasNotification;

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

      bool imagesChanged =
          !listEquals(updatedImageUrls, editingItem.value!.imageUrls);
      int newEditCount = imagesChanged
          ? editingItem.value!.editCount + 1
          : editingItem.value!.editCount;

      final updatedItem = VisionBoardItem(
        id: editingItem.value!.id,
        title: titleController.text,
        date: selectedDate.value,
        imageUrls: updatedImageUrls,
        userId: editingItem.value!.userId,
        hasNotification: hasScheduledNotification(editingItem.value!.id),
        notificationTime: editingItem.value!.notificationTime,
        createdAt: editingItem.value!.createdAt,
        editCount: newEditCount,
      );

      await updateItem(updatedItem);

      // Update the local state while maintaining the order
      int index =
          visionBoardItems.indexWhere((item) => item.id == updatedItem.id);
      if (index != -1) {
        visionBoardItems[index] = updatedItem;
        visionBoardItems.refresh();
      }

      Get.back();
      Get.snackbar('Success', 'Vision board item updated successfully',
          snackPosition: SnackPosition.TOP);
    } catch (e) {
      print("Error updating item: $e");
      Get.snackbar('Error', 'Failed to update vision board item',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  bool canEditItem(String itemId) {
    VisionBoardItem item = visionBoardItems.firstWhere((i) => i.id == itemId);
    return item.editCount < maxEditCount;
  }

  void clearForm() {
    titleController.clear();
    selectedImages.clear();
    selectedDate.value = DateTime.now();
    _updateCanSave();
  }

  void removeNetworkImage(int index) {
    if (index >= 0 && index < selectedNetworkImages.length) {
      String removedUrl = selectedNetworkImages.removeAt(index);
      _imageHashes.remove(removedUrl);
      _updateCanSave();
      update();
    }
  }

  void removeImage(int index) {
    if (index >= 0 && index < selectedImages.length) {
      File removedImage = selectedImages.removeAt(index);
      _imageHashes.remove(computeImageHash(removedImage));
      _updateCanSave();
      update();
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
        .orderBy('createdAt', descending: !isReversed.value)
        .snapshots()
        .listen((querySnapshot) {
      List<VisionBoardItem> allItems = [];

      for (var doc in querySnapshot.docs) {
        VisionBoardItem item = VisionBoardItem.fromFirestore(doc);
        allItems.add(item);
        _notificationActiveStates[item.id] = item.hasNotification;
        if (!_expandedStates.containsKey(item.id)) {
          _expandedStates[item.id] = false;
        }

        // Schedule state update for future notifications
        if (item.hasNotification && item.scheduledNotificationTime != null) {
          if (item.scheduledNotificationTime!.isAfter(DateTime.now())) {
            _scheduleNotificationStateUpdate(
                item.id, item.scheduledNotificationTime!);
          } else {
            // If the scheduled time has passed, update the state immediately
            _updateNotificationStateAfterFiring(item.id);
          }
        }
      }

      visionBoardItems.value = allItems;
      _updateDisplayedItems();
      isLoading.value = false;
      update();
    }, onError: (error) {
      print('Error fetching vision board items: $error');
      isLoading.value = false;
      update();
    });
    _updateNotificationIcons();
  }

  void _updateNotificationIcons() {
    for (var item in visionBoardItems) {
      bool canNotify = canScheduleAnyNotification() || item.hasNotification;
      _notificationActiveStates[item.id] = canNotify;
    }
    update();
  }

  Future<void> saveNewItem() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('You must be logged in to save a vision board item');
    }
    final List<String> imageUrls = await uploadImages();
    await saveToFirestore(imageUrls, user.uid);
  }

  void loadMoreItems() {
    if (isLoadingMore.value || !hasMoreItems) return;

    isLoadingMore.value = true;
    currentPage++;
    _updateDisplayedItems();
    isLoadingMore.value = false;
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
        for (var image in images
            .take(8 - selectedImages.length - selectedNetworkImages.length)) {
          File compressedImage = await compressImage(File(image.path));
          String imageHash = await computeImageHash(compressedImage);

          if (!_imageHashes.contains(imageHash)) {
            selectedImages.add(compressedImage);
            _imageHashes.add(imageHash);
          }
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
      ..writeAsBytesSync(
        img.encodeJpg(compressedImage, quality: 70),
      );
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
      title: titleController.text.trim(),
      date: selectedDate.value,
      imageUrls: imageUrls,
      userId: userId,
      createdAt: DateTime.now(),
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
  bool hasNotification;
  String? notificationTime;
  final DateTime createdAt;
  final DateTime? scheduledNotificationTime;
  final int editCount;

  VisionBoardItem({
    required this.id,
    required this.title,
    required this.date,
    required this.imageUrls,
    required this.userId,
    this.hasNotification = false,
    this.notificationTime,
    required this.createdAt,
    this.scheduledNotificationTime,
    this.editCount = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'date': Timestamp.fromDate(date),
      'imageUrls': imageUrls,
      'userId': userId,
      'hasNotification': hasNotification,
      'notificationTime': notificationTime,
      'createdAt': Timestamp.fromDate(createdAt),
      'scheduledNotificationTime': scheduledNotificationTime != null
          ? Timestamp.fromDate(scheduledNotificationTime!)
          : null,
      'editCount': editCount,
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
      hasNotification: data['hasNotification'] ?? false,
      notificationTime: data['notificationTime'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      scheduledNotificationTime:
          (data['scheduledNotificationTime'] as Timestamp?)?.toDate(),
      editCount: data['editCount'] ?? 0,
    );
  }

  VisionBoardItem copyWith({
    String? id,
    String? title,
    DateTime? date,
    List<String>? imageUrls,
    String? userId,
    bool? hasNotification,
    String? notificationTime,
    DateTime? createdAt,
    DateTime? scheduledNotificationTime,
    int? editCount,
  }) {
    return VisionBoardItem(
      id: id ?? this.id,
      title: title ?? this.title,
      date: date ?? this.date,
      imageUrls: imageUrls ?? this.imageUrls,
      userId: userId ?? this.userId,
      hasNotification: hasNotification ?? this.hasNotification,
      notificationTime: notificationTime ?? this.notificationTime,
      createdAt: createdAt ?? this.createdAt,
      scheduledNotificationTime:
          scheduledNotificationTime ?? this.scheduledNotificationTime,
      editCount: editCount ?? this.editCount,
    );
  }
}
