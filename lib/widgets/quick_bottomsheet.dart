import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../projectController/page_one_controller.dart';
import '../services/app_theme.dart';
import '../services/scale_util.dart';

class QuickReminderBottomSheet extends StatefulWidget {
  final PageOneController reminderController;
  final AppTheme appTheme;

  const QuickReminderBottomSheet({
    Key? key,
    required this.reminderController,
    required this.appTheme,
  }) : super(key: key);

  @override
  _QuickReminderBottomSheetState createState() =>
      _QuickReminderBottomSheetState();
}

class _QuickReminderBottomSheetState extends State<QuickReminderBottomSheet> {
  bool _isDescriptionVisible = false;
  bool _isTitleEmpty = true;

  @override
  void initState() {
    super.initState();
    _isTitleEmpty =
        widget.reminderController.reminderTextController.text.isEmpty;
    widget.reminderController.reminderTextController
        .addListener(_updateTitleState);
    if (widget.reminderController.timeSelected.value == 0) {
      widget.reminderController.timeSelected.value = 1; // Default to 15 minutes
    }
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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
      child: Card(
        elevation: 8,
        color: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(context),
              SizedBox(height: 16),
              _buildTextField(context),
              SizedBox(height: 16),
              _buildActionButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Text(
          'Add Reminder',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        Obx(() => IconButton(
              icon: Icon(
                widget.reminderController.repeat.value
                    ? Icons.repeat_one_outlined
                    : Icons.repeat,
                color: widget.reminderController.repeat.value
                    ? widget.appTheme.colorScheme.primary
                    : widget.appTheme.colorScheme.onSurface.withOpacity(0.5),
              ),
              onPressed: () {
                widget.reminderController
                    .toggleSwitch(!widget.reminderController.repeat.value);
              },
            )),
        _buildTimeSelectionPopup(context),
        SizedBox(width: 8),
        IconButton(
          icon: Icon(Icons.close, color: Theme.of(context).iconTheme.color),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }

  Widget _buildTimeSelectionPopup(BuildContext context) {
    return Obx(() => PopupMenuButton<int>(
          child: Chip(
            label: Text(
                '${_getMinutesFromValue(widget.reminderController.timeSelected.value)} min'),
            backgroundColor: Theme.of(context).chipTheme.backgroundColor,
          ),
          onSelected: (int value) {
            widget.reminderController.timeSelected.value = value;
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<int>>[
            PopupMenuItem<int>(
              value: 1,
              child: Text('15 minutes'),
            ),
            PopupMenuItem<int>(
              value: 2,
              child: Text('30 minutes'),
            ),
            PopupMenuItem<int>(
              value: 3,
              child: Text('60 minutes'),
            ),
          ],
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
        return 15; // Default to 15 minutes if an invalid value is somehow set
    }
  }

  Widget _buildTextField(BuildContext context) {
    return FadeIn(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: TextField(
          controller: widget.reminderController.reminderTextController,
          style: Theme.of(context).textTheme.bodyMedium,
          decoration: InputDecoration(
            labelText: 'Reminder Title',
            filled: true,
            fillColor: Theme.of(context).inputDecorationTheme.fillColor ??
                Theme.of(context).hoverColor,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        SizedBox(width: 16),
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
          borderRadius: BorderRadius.circular(20),
          onTap: _isTitleEmpty ? null : _handleSave,
          child: Padding(
            padding: EdgeInsets.all(10),
            child: Icon(
              FontAwesomeIcons.check,
              color: Theme.of(context).colorScheme.onPrimary,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }

  void _handleSave() {
    if (widget.reminderController.reminderTextController.text.isEmpty) {
      Get.snackbar('Error', 'Reminder text cannot be empty');
      return;
    }

    int minutes =
        _getMinutesFromValue(widget.reminderController.timeSelected.value);

    // Ensure timeSelected has a valid value
    if (widget.reminderController.timeSelected.value == 0) {
      widget.reminderController.timeSelected.value = 1; // Default to 15 minutes
    }

    widget.reminderController.schedulePeriodicNotifications(
      widget.reminderController.reminderTextController.text,
      minutes,
      widget.reminderController.repeat.value,
    );

    widget.reminderController
        .saveReminder(widget.reminderController.repeat.value);
  }
}
