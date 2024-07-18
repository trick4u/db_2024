import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


import '../projectPages/page_two_calendar.dart';

class EventFormController extends GetxController {
  final formKey = GlobalKey<FormState>();
  late TextEditingController titleController;
  late TextEditingController detailsController;
  late Rx<TimeOfDay> startTime;
  late Rx<TimeOfDay> endTime;
  late Rx<Color> selectedColor;
  final DateTime selectedDate;
  final Event? event;
  final bool isEditing;

  EventFormController(this.selectedDate, {this.event, this.isEditing = false}) {
    if (isEditing && event != null) {
      titleController = TextEditingController(text: event!.title);
      detailsController = TextEditingController(text: event!.details);
      startTime = TimeOfDay.fromDateTime(event!.start).obs;
      endTime = TimeOfDay.fromDateTime(event!.end).obs;
      selectedColor = event!.color.obs;
    } else {
      titleController = TextEditingController();
      detailsController = TextEditingController();
      startTime = TimeOfDay.now().obs;
      endTime = TimeOfDay.now().obs;
      selectedColor = const Color.fromARGB(255, 44, 112, 168).obs;
    }
  }

  void pickTime(BuildContext context, {required bool isStartTime}) async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStartTime ? startTime.value : endTime.value,
    );
    if (picked != null) {
      if (isStartTime) {
        startTime.value = picked;
      } else {
        endTime.value = picked;
      }
    }
  }

  void pickColor(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Pick a color'),
        content: SingleChildScrollView(
          child: ColorPicker(
            borderColor: selectedColor.value,
            onColorChanged: (color) {
              selectedColor.value = color;
              Navigator.of(context).pop();
            },
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: Text('Select'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  void addEvent(BuildContext context, Function onEventAdded) {
    if (_validateForm()) {
      final newEvent = _createEventFromForm();
      FirebaseFirestore.instance.collection('events').add(newEvent.toMap()).then((_) {
        onEventAdded();
        Navigator.of(context).pop();
      });
    }
  }

  void editEvent(BuildContext context, Function onEventEdited) {
    if (_validateForm() && event != null) {
      final updatedEvent = _createEventFromForm(id: event!.id);
      FirebaseFirestore.instance.collection('events').doc(updatedEvent.id).update(updatedEvent.toMap()).then((_) {
        onEventEdited();
        Navigator.of(context).pop();
      });
    }
  }

  bool _validateForm() {
    if (formKey.currentState!.validate()) {
      final start = _createDateTime(startTime.value);
      final end = _createDateTime(endTime.value);

      if (start.isBefore(end)) {
        return true;
      } else {
        Get.snackbar('Invalid Time', 'End time should be after start time');
      }
    }
    return false;
  }

  Event _createEventFromForm({String id = ''}) {
    final start = _createDateTime(startTime.value);
    final end = _createDateTime(endTime.value);

    return Event(
      id: id,
      title: titleController.text,
      details: detailsController.text,
      start: start,
      end: end,
      color: selectedColor.value,
    );
  }

  DateTime _createDateTime(TimeOfDay time) {
    return DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      time.hour,
      time.minute,
    );
  }

  @override
  void onClose() {
    titleController.dispose();
    detailsController.dispose();
    super.onClose();
  }
}