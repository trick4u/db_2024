import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../projectController/page_one_controller.dart';
import '../services/app_text_style.dart';
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
      padding: ScaleUtil.only(left: 10, right: 10, bottom: 10),
      child: Card(
        elevation: 8,
        color: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ScaleUtil.scale(20)),
        ),
        child: Container(
          padding: ScaleUtil.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(context),
              SizedBox(height: ScaleUtil.height(16)),
              _buildTextField(context),
              SizedBox(height: ScaleUtil.height(16)),
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
          style: AppTextTheme.textTheme.titleLarge,
        ),
        Obx(() => IconButton(
              icon: Icon(
                widget.reminderController.repeat.value
                    ? Icons.repeat_one_outlined
                    : Icons.repeat,
                color: widget.reminderController.repeat.value
                    ? widget.appTheme.colorScheme.primary
                    : widget.appTheme.colorScheme.onSurface.withOpacity(0.5),
                size: ScaleUtil.scale(24),
              ),
              onPressed: () {
                widget.reminderController
                    .toggleSwitch(!widget.reminderController.repeat.value);
              },
            )),
        _buildTimeSelectionPopup(context),
        SizedBox(width: ScaleUtil.width(8)),
        IconButton(
          icon: Icon(Icons.close,
              color: Theme.of(context).iconTheme.color,
              size: ScaleUtil.scale(24)),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }

  Widget _buildTimeSelectionPopup(BuildContext context) {
    return Obx(() => PopupMenuButton<int>(
          child: Chip(
            label: Text(
              '${_getMinutesFromValue(widget.reminderController.timeSelected.value)} min',
              style: AppTextTheme.textTheme.bodyMedium,
            ),
            backgroundColor: Theme.of(context).chipTheme.backgroundColor,
            padding: ScaleUtil.symmetric(horizontal: 8, vertical: 4),
          ),
          onSelected: (int value) {
            widget.reminderController.timeSelected.value = value;
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<int>>[
            PopupMenuItem<int>(
              value: 1,
              child:
                  Text('15 minutes', style: AppTextTheme.textTheme.bodyMedium),
            ),
            PopupMenuItem<int>(
              value: 2,
              child:
                  Text('30 minutes', style: AppTextTheme.textTheme.bodyMedium),
            ),
            PopupMenuItem<int>(
              value: 3,
              child:
                  Text('60 minutes', style: AppTextTheme.textTheme.bodyMedium),
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
        borderRadius: BorderRadius.circular(ScaleUtil.scale(10)),
        child: TextField(
          controller: widget.reminderController.reminderTextController,
          style: AppTextTheme.textTheme.bodyMedium,
          decoration: InputDecoration(
            labelText: 'Reminder Title',
            labelStyle: AppTextTheme.textTheme.bodyMedium,
            filled: true,
            fillColor: Theme.of(context).inputDecorationTheme.fillColor ??
                Theme.of(context).hoverColor,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: ScaleUtil.all(16),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        SizedBox(width: ScaleUtil.width(16)),
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
          borderRadius: BorderRadius.circular(ScaleUtil.scale(20)),
          onTap: _isTitleEmpty ? null : _handleSave,
          child: Padding(
            padding: ScaleUtil.all(10),
            child: Icon(
              FontAwesomeIcons.check,
              color: Theme.of(context).colorScheme.onPrimary,
              size: ScaleUtil.scale(20),
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
