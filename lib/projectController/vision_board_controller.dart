import 'dart:async';
import 'dart:io';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import 'package:path/path.dart' as path;
import 'package:image/image.dart' as img;
import 'package:http/http.dart' as http;
import 'package:tushar_db/constants/colors.dart';

import '../services/toast_util.dart';
import '../widgets/vision_bottom_sheet.dart';
import 'dart:isolate';

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
  final RxSet<String> _selectedImagePaths = <String>{}.obs;

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
    // _optimizeMemoryUsage();
    if (isMorning && !canScheduleMorningNotification()) {
      ToastUtil.showToast(
        'Morning Notification Limit Reached',
        'You can only have 5 active morning notifications. Please cancel an existing morning notification to schedule a new one.',
      );
      return;
    }
    if (!isMorning && !canScheduleNightNotification()) {
      ToastUtil.showToast(
        'Night Notification Limit Reached',
        'You can only have 5 active night notifications. Please cancel an existing night notification to schedule a new one.',
      );
      return;
    }

    int notificationId = item.id.hashCode;
    String title = 'Vision Board Reminder';
    String body = item.title;
    String imageUrl = item.imageUrls.isNotEmpty ? item.imageUrls[0] : '';

    DateTime scheduledTime = _getNextAvailableTime(isMorning);
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          autoDismissible: false,
          id: notificationId,
          channelKey: 'vision_board_reminders',
          title: title,
          body: body,
          bigPicture: imageUrl,
          notificationLayout: NotificationLayout.BigPicture,
          category: NotificationCategory.Reminder,
          payload: {'time': isMorning ? 'morning' : 'night'},
          criticalAlert: true,
          wakeUpScreen: true,
          largeIcon: 'resource://drawable/notification_icon',
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
          preciseAlarm: true,
          allowWhileIdle: true,
        ),
      );
    });

    // await AwesomeNotifications().createNotification(
    //   content: NotificationContent(
    //     autoDismissible: false,
    //     id: notificationId,
    //     channelKey: 'quickschedule',
    //     title: title,
    //     body: body,
    //     bigPicture: imageUrl,
    //     notificationLayout: NotificationLayout.BigPicture,
    //     category: NotificationCategory.Reminder,
    //     payload: {'time': isMorning ? 'morning' : 'night'},
    //     criticalAlert: true,
    //     wakeUpScreen: true,
    //   ),
    //   schedule: NotificationCalendar(
    //     year: scheduledTime.year,
    //     month: scheduledTime.month,
    //     day: scheduledTime.day,
    //     hour: scheduledTime.hour,
    //     minute: scheduledTime.minute,
    //     second: 0,
    //     millisecond: 0,
    //     repeats: false,
    //     preciseAlarm: true,
    //     allowWhileIdle: true,
    //   ),
    // );

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

    ToastUtil.showToast(
      'Notification Scheduled',
      'You will be reminded at ${scheduledTime.hour}:${scheduledTime.minute.toString().padLeft(2, '0')}',
    );
  }

  DateTime _getNextAvailableTime(bool isMorning) {
    DateTime now = DateTime.now();
    DateTime baseTime = isMorning
        ? DateTime(now.year, now.month, now.day, 08, 00)
        : DateTime(now.year, now.month, now.day, 22, 00);

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

    ToastUtil.showToast(
      'Notification Cancelled',
      'The reminder for this item has been cancelled',
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
    _initializeSelectedImagePaths();
    isEditing.value = false;
    editingItem.value = null;
    _originalTitle = null;
    _originalDate = null;
    _originalImageUrls = null;
    _checkForChanges();
    _imageHashes.clear();
    _selectedImagePaths.clear();
    onImagesChanged();
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
    onImagesChanged();
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
      onImagesChanged();

      // Update the local state while maintaining the order
      int index =
          visionBoardItems.indexWhere((item) => item.id == updatedItem.id);
      if (index != -1) {
        visionBoardItems[index] = updatedItem;
        visionBoardItems.refresh();
      }

      Get.back();
      ToastUtil.showToast(
        'Success',
        'Vision board item updated successfully',
      );
    } catch (e) {
      print("Error updating item: $e");
      ToastUtil.showToast(
        'Error',
        'Failed to update vision board item',
      );
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
      selectedNetworkImages.removeAt(index);
      onImagesChanged();
    }
  }

  void removeImage(int index) {
    if (index >= 0 && index < selectedImages.length) {
      selectedImages.removeAt(index);
      onImagesChanged();
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
      Set<String> itemIds = Set<String>(); // To keep track of unique items

      for (var doc in querySnapshot.docs) {
        VisionBoardItem item = VisionBoardItem.fromFirestore(doc);

        // Check if the item is already in the list
        if (!itemIds.contains(item.id)) {
          allItems.add(item);
          itemIds.add(item.id);
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
    isSaving.value = true;

    try {
      // Compress images in parallel
      List<Future<File>> compressionFutures = selectedImages
          .map((image) => compressImageInBackground(image))
          .toList();
      List<File> compressedImages = await Future.wait(compressionFutures);

      // Upload images in parallel
      List<Future<String>> uploadFutures =
          compressedImages.map((image) => uploadSingleImage(image)).toList();
      List<String> imageUrls = await Future.wait(uploadFutures);

      // Filter out any failed uploads
      imageUrls = imageUrls.where((url) => url.isNotEmpty).toList();

      // Save to Firestore
      await saveToFirestore(imageUrls, user.uid);

      ToastUtil.showToast(
          'Success', 'New vision board item added successfully');
    } catch (e) {
      print('Error saving new item: $e');
      ToastUtil.showToast('Error', 'Failed to save vision board item');
    } finally {
      isSaving.value = false;
    }
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
      final List<XFile> pickedImages = await picker.pickMultiImage();

      if (pickedImages.isNotEmpty) {
        for (var image in pickedImages) {
          File compressedImage = await compressImageInBackground(
            File(image.path),
          );
          selectedImages.add(compressedImage);
        }

        // Ensure uniqueness after adding all images
        ensureUniqueImages();
        onImagesChanged();

        update();
      }
    } catch (e) {
      print('Error picking images: $e');
      ToastUtil.showToast('Error', 'Failed to pick images');
    } finally {
      isPickingImages.value = false;
    }
  }

  Future<File> compressImageInBackground(File file) async {
    final Completer<File> completer = Completer();

    final ReceivePort receivePort = ReceivePort();
    await Isolate.spawn(_isolateCompress, {
      'sendPort': receivePort.sendPort,
      'path': file.path,
    });

    receivePort.listen((dynamic message) {
      if (message is String) {
        completer.complete(File(message));
      } else {
        completer.completeError('Compression failed');
      }
      receivePort.close();
    });

    return completer.future;
  }

  static void _isolateCompress(Map<String, dynamic> message) {
    String imagePath = message['path'];
    SendPort sendPort = message['sendPort'];

    try {
      final File file = File(imagePath);
      final img.Image? image = img.decodeImage(file.readAsBytesSync());
      if (image == null) {
        sendPort.send(imagePath); // If decoding fails, return original path
        return;
      }

      final img.Image compressedImage = img.copyResize(image, width: 800);
      final String dir = path.dirname(imagePath);
      final String newPath =
          path.join(dir, 'compressed_${path.basename(imagePath)}');
      final File result = File(newPath)
        ..writeAsBytesSync(img.encodeJpg(compressedImage, quality: 70));

      sendPort.send(result.path);
    } catch (e) {
      print('Error in isolate: $e');
      sendPort.send(imagePath); // If compression fails, return original path
    }
  }

  void ensureUniqueImages() {
    // Create a map to store unique images
    Map<String, File> uniqueImages = {};

    // Process selected images
    for (var image in selectedImages) {
      String baseName = path.basename(image.path);
      uniqueImages[baseName] = image;
    }

    // Process network images
    for (var networkImage in selectedNetworkImages) {
      String baseName = path.basename(networkImage);
      // If a network image with the same name exists, we keep it and remove any local duplicate
      uniqueImages.remove(baseName);
    }

    // Update selectedImages with unique local images
    selectedImages.value = uniqueImages.values.toList();

    // Limit total images to 8
    if (selectedImages.length + selectedNetworkImages.length > 8) {
      int localImagesToKeep = 8 - selectedNetworkImages.length;
      if (localImagesToKeep > 0) {
        selectedImages.value = selectedImages.sublist(0, localImagesToKeep);
      } else {
        selectedImages.clear();
      }
    }

    update();
  }

  void onImagesChanged() {
    ensureUniqueImages();
  }

  Future<bool> isDuplicateImage(XFile image) async {
    // Check if the image path is already in _selectedImagePaths
    if (_selectedImagePaths.contains(image.path)) {
      return true;
    }

    // Compare with existing selected images
    for (var existingImage in selectedImages) {
      if (await _areImagesIdentical(File(image.path), existingImage)) {
        return true;
      }
    }

    // Compare with network images (this is a basic check, might need improvement)
    for (var networkImageUrl in selectedNetworkImages) {
      if (path.basename(image.path) == path.basename(networkImageUrl)) {
        return true;
      }
    }

    return false;
  }

  Future<bool> _areImagesIdentical(File image1, File image2) async {
    // This is a basic comparison using file size and last modified date
    // For a more accurate comparison, consider using image hashing techniques
    if (image1.lengthSync() != image2.lengthSync()) {
      return false;
    }

    DateTime lastModified1 = await image1.lastModified();
    DateTime lastModified2 = await image2.lastModified();

    return lastModified1 == lastModified2;
  }

  void _initializeSelectedImagePaths() {
    _selectedImagePaths.clear();
    for (var image in selectedImages) {
      _selectedImagePaths.add(image.path);
    }
    for (var imageUrl in selectedNetworkImages) {
      _selectedImagePaths.add(imageUrl);
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
      ToastUtil.showToast(
          'Success',
          isEditing.value
              ? 'Vision board item updated successfully'
              : 'New vision board item added successfully');
    } catch (e) {
      print('Error saving/updating note: $e');
      ToastUtil.showToast('Error', 'Failed to save/update vision board item');
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

    try {
      final String fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${path.basename(image.path)}';
      final Reference ref = FirebaseStorage.instance
          .ref()
          .child('users/${user.uid}/vision_board_images/$fileName');

      final UploadTask uploadTask = ref.putFile(image);
      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
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

    // Use a batched write for better performance
    final batch = FirebaseFirestore.instance.batch();
    final docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('vision_board')
        .doc();

    batch.set(docRef, newItem.toMap());

    // Commit the batch
    await batch.commit();

    // Clear the form
    resetForm();

    // The new item will be added by the Firestore listener
  }

  Future<void> deleteItem(String itemId) async {
    if (currentUser == null) return;
    try {
      // First, get the item to delete its images
      DocumentSnapshot doc = await visionBoardCollection.doc(itemId).get();
      VisionBoardItem item = VisionBoardItem.fromFirestore(doc);

      // Cancel the notification if it exists
      if (item.hasNotification) {
        await cancelNotification(itemId);
      }

      // Delete images from storage
      for (String imageUrl in item.imageUrls) {
        await FirebaseStorage.instance.refFromURL(imageUrl).delete();
      }

      // Delete the document from Firestore
      await visionBoardCollection.doc(itemId).delete();

      // Remove the item from the local list
      visionBoardItems.removeWhere((element) => element.id == itemId);
      _updateDisplayedItems();

      print('Vision board item deleted: $itemId');
    } catch (e) {
      print('Error deleting vision board item: $e');
      ToastUtil.showToast(
        'Error',
        'Failed to delete vision board item',
      );
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
