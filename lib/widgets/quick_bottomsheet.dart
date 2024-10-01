import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../models/reminder_model.dart';
import '../projectController/page_one_controller.dart';
import '../services/app_theme.dart';
import '../services/scale_util.dart';

class QuickReminderBottomSheet extends StatefulWidget {
  final PageOneController reminderController;
  final AppTheme appTheme;
  final ReminderModel? reminderToEdit;

  const QuickReminderBottomSheet({
    Key? key,
    required this.reminderController,
    required this.appTheme,
    this.reminderToEdit,
  }) : super(key: key);

  @override
  _QuickReminderBottomSheetState createState() =>
      _QuickReminderBottomSheetState();
}

class _QuickReminderBottomSheetState extends State<QuickReminderBottomSheet> {
  bool _isTitleEmpty = true;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _initializeFields();
    widget.reminderController.reminderTextController
        .addListener(_updateTitleState);
  }

  void _initializeFields() {
    if (widget.reminderToEdit != null) {
      widget.reminderController.reminderTextController.text =
          widget.reminderToEdit!.reminder;
      widget.reminderController.timeSelected.value =
          _getValueFromMinutes(widget.reminderToEdit!.time);
      widget.reminderController.repeat.value = widget.reminderToEdit!.repeat;
      widget.reminderController.nextNotificationTime.value =
          widget.reminderToEdit!.triggerTime;
    } else {
      widget.reminderController.reminderTextController.clear();
      widget.reminderController.timeSelected.value = 1;
      widget.reminderController.repeat.value = false;
      widget.reminderController.calculateTriggerTime(15);
    }

    _isTitleEmpty =
        widget.reminderController.reminderTextController.text.isEmpty;
  }

  @override
  void dispose() {
    widget.reminderController.reminderTextController
        .removeListener(_updateTitleState);
    super.dispose();
  }

  void _updateTitleState() {
    setState(() {
      _isTitleEmpty =
          widget.reminderController.reminderTextController.text.isEmpty;
    });
  }

  int _getValueFromMinutes(int minutes) {
    switch (minutes) {
      case 15:
        return 1;
      case 30:
        return 2;
      case 60:
        return 3;
      default:
        return 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    ScaleUtil.init(context);
    return Padding(
      padding: ScaleUtil.only(left: 10, right: 10, bottom: 10),
      child: Card(
        elevation: ScaleUtil.scale(8),
        color: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: ScaleUtil.circular(20),
        ),
        child: Form(
          key: _formKey,
          child: Container(
            padding: ScaleUtil.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeader(context),
                ScaleUtil.sizedBox(height: 16),
                _buildTextField(context),
                ScaleUtil.sizedBox(height: 16),
                _buildActionButtons(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          widget.reminderToEdit != null ? 'Edit Reminder' : 'Add Reminder',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontSize: ScaleUtil.fontSize(15),
              ),
        ),
        Row(
          children: [
            Obx(() => IconButton(
                  icon: Icon(
                    widget.reminderController.repeat.value
                        ? Icons.repeat_one_outlined
                        : Icons.repeat,
                    color: widget.reminderController.repeat.value
                        ? widget.appTheme.colorScheme.primary
                        : widget.appTheme.colorScheme.onSurface
                            .withOpacity(0.5),
                    size: ScaleUtil.iconSize(18),
                  ),
                  onPressed: () {
                    widget.reminderController
                        .toggleSwitch(!widget.reminderController.repeat.value);
                  },
                  tooltip: 'Toggle repeat',
                )),
            _buildTimeSelectionPopup(context),
            IconButton(
              icon: Icon(Icons.close,
                  color: Theme.of(context).iconTheme.color,
                  size: ScaleUtil.iconSize(18)),
              onPressed: () => Get.back(),
              tooltip: 'Close',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTimeSelectionPopup(BuildContext context) {
    return Obx(() => PopupMenuButton<int>(
          child: Chip(
            label: Text(
              '${_getMinutesFromValue(widget.reminderController.timeSelected.value)} min',
              style: TextStyle(fontSize: ScaleUtil.fontSize(12)),
            ),
            backgroundColor: Theme.of(context).chipTheme.backgroundColor,
          ),
          onSelected: (int value) {
            widget.reminderController.timeSelected.value = value;
            widget.reminderController
                .calculateTriggerTime(_getMinutesFromValue(value));
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<int>>[
            PopupMenuItem<int>(
              value: 1,
              child: Text('15 minutes',
                  style: TextStyle(fontSize: ScaleUtil.fontSize(12))),
            ),
            PopupMenuItem<int>(
              value: 2,
              child: Text('30 minutes',
                  style: TextStyle(fontSize: ScaleUtil.fontSize(12))),
            ),
            PopupMenuItem<int>(
              value: 3,
              child: Text('60 minutes',
                  style: TextStyle(fontSize: ScaleUtil.fontSize(12))),
            ),
          ],
          tooltip: 'Select reminder time',
        ));
  }

  int _getMinutesFromValue(int value) {
    switch (value) {
      case 1:
        return 15;
      case 2:
        return 30;
      case 3:
        return 60;
      default:
        return 15;
    }
  }

  Widget _buildTextField(BuildContext context) {
    return FadeIn(
      child: ClipRRect(
        borderRadius: ScaleUtil.circular(10),
        child: TextFormField(
          controller: widget.reminderController.reminderTextController,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: ScaleUtil.fontSize(12),
              ),
          decoration: InputDecoration(
            labelText: 'Reminder Title',
            labelStyle: TextStyle(fontSize: ScaleUtil.fontSize(12)),
            filled: true,
            fillColor: Theme.of(context).inputDecorationTheme.fillColor ??
                Theme.of(context).hoverColor,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: ScaleUtil.symmetric(horizontal: 16, vertical: 12),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a reminder title';
            }
            return null;
          },
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Obx(() => Text(
              'Next reminder: ${widget.reminderController.getFormattedNextNotificationTime()}',
              style: TextStyle(fontSize: ScaleUtil.fontSize(12)),
            )),
        _buildSaveButton(context),
      ],
    );
  }

  Widget _buildSaveButton(BuildContext context) {
    return SlideInRight(
      child: Container(
        decoration: BoxDecoration(
          color: _isTitleEmpty
              ? Colors.grey
              : Theme.of(context).colorScheme.primary,
          shape: BoxShape.circle,
        ),
        child: InkWell(
          borderRadius: ScaleUtil.circular(20),
          onTap: _isTitleEmpty ? null : _handleSave,
          child: Padding(
            padding: ScaleUtil.all(10),
            child: Icon(
              FontAwesomeIcons.check,
              color: Theme.of(context).colorScheme.onPrimary,
              size: ScaleUtil.iconSize(15),
            ),
          ),
        ),
      ),
    );
  }

 void _handleSave() async {
    if (_formKey.currentState!.validate()) {
      int interval =
          _getMinutesFromValue(widget.reminderController.timeSelected.value);
      String reminderText =
          widget.reminderController.reminderTextController.text;
      bool repeat = widget.reminderController.repeat.value;

      try {
        if (widget.reminderToEdit != null) {
          await widget.reminderController.updateReminder(
            widget.reminderToEdit!.id ?? "",
            reminderText,
            interval,
            repeat,
          );
          print(
              'Reminder updated: ${widget.reminderToEdit!.id}, Interval: $interval minutes, Repeat: $repeat');
        } else {
          // Create the reminder document first
          String? documentId = await widget.reminderController.createReminder(
            reminderText,
            interval,
            repeat,
          );

          if (documentId != null) {
            // Now schedule the notification with the new documentId
            await widget.reminderController.schedulePeriodicNotifications(
              reminderText,
              interval,
              repeat,
              documentId: documentId,
              triggerCount: 0,
            );
            print(
                'New reminder created and scheduled: $documentId, Interval: $interval minutes, Repeat: $repeat');
          } else {
            throw Exception('Failed to create reminder. Limit may have been reached.');
          }
        }

        Get.back();
        Get.snackbar(
          'Success',
          widget.reminderToEdit != null
              ? 'Reminder updated successfully'
              : 'Reminder added successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: Duration(seconds: 2),
        );
      } catch (e) {
        print('Error saving reminder: $e');
        Get.snackbar(
          'Error',
          'Failed to save reminder. ${e.toString()}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: Duration(seconds: 3),
        );
      }
    }
  }
}
