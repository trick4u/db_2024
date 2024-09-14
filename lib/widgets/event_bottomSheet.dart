import 'package:animate_do/animate_do.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:time_picker_spinner_pop_up/time_picker_spinner_pop_up.dart';
import 'package:tushar_db/services/scale_util.dart';

import '../models/quick_event_model.dart';
import '../projectController/calendar_controller.dart';
import '../services/app_text_style.dart';
import '../services/app_theme.dart';

class EventBottomSheet extends StatefulWidget {
  final QuickEventModel? event;
  final DateTime initialDate;
  final Function(String, String, DateTime, TimeOfDay?, TimeOfDay?, Color, bool,
      DateTime?, String?) onSave;

  EventBottomSheet({
    this.event,
    required this.initialDate,
    required this.onSave,
  });

  @override
  _EventBottomSheetState createState() => _EventBottomSheetState();
}

class _EventBottomSheetState extends State<EventBottomSheet> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late DateTime _selectedDate;
  DateTime? _startTime;
  DateTime? _endTime;
  late Color _selectedColor;
  bool _isReminderSet = false;

  late TimePickerSpinnerController _reminderController;
  DateTime? _reminderTime;
  bool _isTitleEmpty = true;
  bool _isDescriptionVisible = false;
  bool _isEventCompleted = false;
  String? _selectedRepetition;

  @override
  void initState() {
    super.initState();
    _reminderController = TimePickerSpinnerController();
    _titleController = TextEditingController(text: widget.event?.title ?? '');
    _isTitleEmpty = _titleController.text.isEmpty;
    _titleController.addListener(_updateTitleState);
    _descriptionController =
        TextEditingController(text: widget.event?.description ?? '');
    _selectedDate = widget.event?.date ?? widget.initialDate;
    _selectedColor = widget.event?.color ?? Get.theme.primaryColor;
    _isReminderSet = widget.event?.reminderTime != null;
    _reminderTime = widget.event?.reminderTime;
    _isEventCompleted = widget.event?.isCompleted ?? false;
    _selectedRepetition = widget.event?.repetition;
    if (widget.event != null) {
      // Assume you have start and end time in your EventModel
      // _startTime = TimeOfDay.fromDateTime(widget.event!.startTime);
      // _endTime = TimeOfDay.fromDateTime(widget.event!.endTime);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _reminderController.dispose();
    super.dispose();
  }

  void _updateTitleState() {
    setState(() {
      _isTitleEmpty = _titleController.text.isEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    final appTheme = Get.find<AppTheme>();
    return Obx(() => Padding(
          padding: ScaleUtil.only(left: 10, right: 10, bottom: 10),
          child: Card(
            elevation: 8,
            color: appTheme.cardColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(ScaleUtil.scale(20)),
            ),
            child: Container(
              padding: ScaleUtil.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Text(
                        widget.event == null ? 'Add Event' : 'Edit Event',
                        style: appTheme.titleLarge.copyWith(
                          fontSize: ScaleUtil.fontSize(15),
                        ),
                      ),
                      Spacer(),
                      _buildReminderWidget(context, appTheme),
                      IconButton(
                        icon: Icon(
                          Icons.close,
                          color: appTheme.textColor,
                          size: ScaleUtil.iconSize(15),
                        ),
                        onPressed: () {
                          Get.back();
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: ScaleUtil.height(16)),
                  ClipRRect(
                    borderRadius: ScaleUtil.circular(10),
                    child: TextField(
                      controller: _titleController,
                      style: appTheme.bodyMedium,
                      decoration: InputDecoration(
                        labelText: 'Event Title',
                        filled: true,
                        fillColor: appTheme.textFieldFillColor,
                        labelStyle: appTheme.bodyMedium.copyWith(
                          color: appTheme.secondaryTextColor,
                          fontSize: ScaleUtil.fontSize(12),
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        contentPadding:
                            ScaleUtil.symmetric(horizontal: 16, vertical: 6),
                      ),
                      onChanged: (value) => _updateTitleState(),
                    ),
                  ),
                  SizedBox(height: ScaleUtil.height(16)),
                  if (_isDescriptionVisible) ...[
                    SizedBox(height: ScaleUtil.height(8)),
                    ClipRRect(
                      borderRadius: ScaleUtil.circular(10),
                      child: TextField(
                        controller: _descriptionController,
                        style: appTheme.bodyMedium.copyWith(
                          fontSize:
                              ScaleUtil.fontSize(appTheme.bodyMedium.fontSize!),
                        ),
                        decoration: InputDecoration(
                          labelText: 'Description',
                          filled: true,
                          fillColor: appTheme.textFieldFillColor,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          contentPadding:
                              ScaleUtil.symmetric(horizontal: 16, vertical: 12),
                        ),
                        maxLines: 3,
                      ),
                    ),
                  ],
                  SizedBox(height: ScaleUtil.height(10)),
                  SlideInLeft(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        _buildRepetitionButton(context, appTheme),
                        SizedBox(width: ScaleUtil.width(10)),
                        _buildDescriptionToggleButton(context, appTheme),
                        SizedBox(width: ScaleUtil.width(10)),
                        _buildColorIconButton(context, appTheme),
                        SizedBox(width: ScaleUtil.width(10)),
                        _buildSaveIconButton(context, appTheme),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }

  Widget _buildRepetitionButton(BuildContext context, AppTheme appTheme) {
    return PopupMenuButton<String>(
      child: Container(
        decoration: BoxDecoration(
          color: _selectedRepetition != null
              ? appTheme.colorScheme.primary
              : appTheme.colorScheme.surface,
          borderRadius: ScaleUtil.circular(20),
        ),
        padding: ScaleUtil.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            FaIcon(
              FontAwesomeIcons.repeat,
              color: _selectedRepetition != null ? Colors.white : Colors.black,
              size: ScaleUtil.iconSize(10),
            ),
            SizedBox(width: ScaleUtil.width(2)),
            Text(
              _getRepetitionText(),
              style: AppTextTheme.textTheme.bodySmall!.copyWith(
                fontSize: ScaleUtil.fontSize(10),
              ),
            ),
          ],
        ),
      ),
      onSelected: (String value) {
        setState(() {
          _selectedRepetition = value;
        });
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        PopupMenuItem<String>(
          value: 'week',
          child: Text('This Week'),
        ),
        PopupMenuItem<String>(
          value: 'month',
          child: Text('This Month'),
        ),
      ],
    );
  }

  String _getRepetitionText() {
    switch (_selectedRepetition) {
      case 'week':
        return 'This Week';
      case 'month':
        return 'This Month';
      default:
        return '';
    }
  }

  Widget _buildDescriptionToggleButton(
      BuildContext context, AppTheme appTheme) {
    return FadeIn(
      child: Container(
        decoration: BoxDecoration(
          color: _isTitleEmpty ? Colors.grey : appTheme.colorScheme.primary,
          shape: BoxShape.circle,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: ScaleUtil.circular(20),
            onTap: _isTitleEmpty
                ? null
                : () {
                    setState(() {
                      _isDescriptionVisible = !_isDescriptionVisible;
                    });
                  },
            child: Padding(
              padding: ScaleUtil.all(10),
              child: FaIcon(
                _isDescriptionVisible
                    ? FontAwesomeIcons.listUl
                    : FontAwesomeIcons.list,
                color: Colors.white,
                size: ScaleUtil.iconSize(10),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildColorIconButton(BuildContext context, AppTheme appTheme) {
    return Container(
      decoration: BoxDecoration(
        color: _selectedColor,
        shape: BoxShape.circle,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: ScaleUtil.circular(20),
          onTap: () => showColorPickerDialog(context),
          child: Padding(
            padding: ScaleUtil.all(10),
            child: FaIcon(
              FontAwesomeIcons.palette,
              color: _selectedColor.computeLuminance() > 0.5
                  ? Colors.black
                  : Colors.white,
              size: ScaleUtil.iconSize(10),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSaveIconButton(BuildContext context, AppTheme appTheme) {
    return Container(
      decoration: BoxDecoration(
        color: _isTitleEmpty ? Colors.grey : appTheme.colorScheme.primary,
        shape: BoxShape.circle,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: ScaleUtil.circular(20),
          onTap: _isTitleEmpty
              ? null
              : () {
                  widget.onSave(
                    _titleController.text.trim(),
                    _descriptionController.text.trim(),
                    _selectedDate,
                    _startTime != null
                        ? TimeOfDay.fromDateTime(_startTime!)
                        : null,
                    _endTime != null ? TimeOfDay.fromDateTime(_endTime!) : null,
                    _selectedColor,
                    _isReminderSet,
                    _isReminderSet ? _reminderTime : null,
                    _selectedRepetition,
                  );
                  Navigator.pop(context);
                },
          child: Padding(
            padding: ScaleUtil.all(10),
            child: Icon(
              FontAwesomeIcons.check,
              color: Colors.white,
              size: ScaleUtil.iconSize(10),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectColorButton(BuildContext context, AppTheme appTheme) {
    return Container(
      decoration: BoxDecoration(
        color: _selectedColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => showColorPickerDialog(context),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            child: Text(
              'Color',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _selectedColor.computeLuminance() > 0.5
                    ? Colors.black
                    : Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void showColorPickerDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pick a color'),
          content: SingleChildScrollView(
            child: ColorPicker(
              color: _selectedColor,
              onColorChanged: (Color color) {
                setState(() => _selectedColor = color);
              },
              heading: Text('Select color'),
              subheading: Text('Select color shade'),
              pickersEnabled: const <ColorPickerType, bool>{
                ColorPickerType.both: false,
                ColorPickerType.primary: true,
                ColorPickerType.accent: true,
                ColorPickerType.bw: false,
                ColorPickerType.custom: true,
                ColorPickerType.wheel: true,
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildReminderWidget(BuildContext context, AppTheme appTheme) {
    if (_isEventCompleted) {
      return SizedBox
          .shrink(); // Don't show reminder widget for completed events
    }
    return _isReminderSet
        ? _buildReminderInfo(appTheme)
        : _buildTimePickerButton(context, appTheme);
  }

  Widget _buildTimePickerButton(BuildContext context, AppTheme appTheme) {
    return TimePickerSpinnerPopUp(
      mode: CupertinoDatePickerMode.time,
      initTime: DateTime.now(),
      onChange: (dateTime) {
        setState(() {
          _reminderTime = dateTime;
          _isReminderSet = true;
        });
      },
      barrierColor: Colors.black26,
      minuteInterval: 1,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      cancelText: 'Cancel',
      confirmText: 'OK',
      pressType: PressType.singlePress,
      timeFormat: 'HH:mm',
    );
  }

  Widget _buildReminderInfo(AppTheme appTheme) {
    return Container(
      width: ScaleUtil.width(125),
      padding: ScaleUtil.symmetric(vertical: 0, horizontal: 0),
      decoration: BoxDecoration(
        color: Colors.green,
        borderRadius: ScaleUtil.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.alarm_on,
                  color: Colors.white, size: ScaleUtil.iconSize(24)),
              SizedBox(width: ScaleUtil.width(8)),
              Text(
                ' ${_formatTime(_reminderTime!)}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: ScaleUtil.fontSize(14),
                ),
              ),
            ],
          ),
          IconButton(
            icon: Icon(Icons.close,
                color: Colors.white, size: ScaleUtil.iconSize(20)),
            onPressed: () {
              setState(() {
                _isReminderSet = false;
                _reminderTime = null;
              });
            },
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    return "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
  }
}

class ReminderButton extends StatelessWidget {
  final DateTime? reminderTime;
  final VoidCallback onPressed;
  final bool isReminderSet;

  const ReminderButton({
    Key? key,
    required this.reminderTime,
    required this.onPressed,
    required this.isReminderSet,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appTheme = Get.find<AppTheme>();
    return InkWell(
      onTap: onPressed,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        decoration: BoxDecoration(
          color: isReminderSet ? Colors.green : appTheme.colorScheme.secondary,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isReminderSet ? Icons.alarm_on : Icons.alarm_add,
              color: appTheme.colorScheme.onSecondary,
            ),
            SizedBox(width: 8),
            Text(
              isReminderSet && reminderTime != null
                  ? 'Reminder: ${_formatTime(reminderTime!)}'
                  : 'Set Reminder',
              style: TextStyle(color: appTheme.colorScheme.onSecondary),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    return "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
  }
}
