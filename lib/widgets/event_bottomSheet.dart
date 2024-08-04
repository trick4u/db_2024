import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
      DateTime?) onSave;

  EventBottomSheet(
      {this.event, required this.initialDate, required this.onSave});

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

  @override
  void initState() {
    super.initState();
    _reminderController = TimePickerSpinnerController();
    _titleController = TextEditingController(text: widget.event?.title ?? '');
    _descriptionController =
        TextEditingController(text: widget.event?.description ?? '');
    _selectedDate = widget.event?.date ?? widget.initialDate;
    _selectedColor = widget.event?.color ?? Get.theme.primaryColor;
    _isReminderSet = widget.event?.reminderTime != null;
    _reminderTime = widget.event?.reminderTime;
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

  @override
  Widget build(BuildContext context) {
    final appTheme = Get.find<AppTheme>();
    return Obx(() => Padding(
          padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
          child: Card(
            elevation: 8,
            color: appTheme.cardColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Text(
                        widget.event == null ? 'Add Event' : 'Edit Event',
                        style: appTheme.titleLarge,
                      ),
                      Spacer(),
                      ElevatedButton(
                        onPressed: () {
                          showColorPickerDialog();
                        },
                        child: Text('Select Color'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _selectedColor,
                          foregroundColor:
                              _selectedColor.computeLuminance() > 0.5
                                  ? Colors.black
                                  : Colors.white,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: appTheme.textColor),
                        onPressed: () {
                          Get.back();
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.all(
                      Radius.circular(10),
                    ),
                    child: TextField(
                      controller: _titleController,
                      style: appTheme.bodyMedium,
                      decoration: InputDecoration(
                        labelText: 'Event Title',
                        filled: true,
                        fillColor: appTheme.textFieldFillColor,
                        labelStyle: appTheme.bodyMedium.copyWith(
                          color: appTheme.secondaryTextColor,
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.all(
                      Radius.circular(10),
                    ),
                    child: TextField(
                      controller: _descriptionController,
                      style: appTheme.bodyMedium,
                      decoration: InputDecoration(
                        labelText: 'Event Description',
                        filled: true,
                        fillColor: appTheme.textFieldFillColor,
                        labelStyle: appTheme.bodyMedium.copyWith(
                          color: appTheme.secondaryTextColor,
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      maxLines: 3,
                    ),
                  ),
                  SizedBox(
                    height: ScaleUtil.height(10),
                  ),
                  Row(
                    children: [
                      // Expanded(
                      //   child: ElevatedButton(
                      //     onPressed: () async {
                      //       final DateTime? picked = await showDatePicker(
                      //         context: context,
                      //         initialDate: _selectedDate,
                      //         firstDate: DateTime.now(),
                      //         lastDate: DateTime(2101),
                      //         builder: (BuildContext context, Widget? child) {
                      //           return Theme(
                      //             data: ThemeData.light().copyWith(
                      //               colorScheme: ColorScheme.light(
                      //                 primary: appTheme.colorScheme.primary,
                      //                 onPrimary: appTheme.colorScheme.onPrimary,
                      //                 surface: appTheme.colorScheme.surface,
                      //                 onSurface: appTheme.colorScheme.onSurface,
                      //               ),
                      //             ),
                      //             child: child!,
                      //           );
                      //         },
                      //       );
                      //       if (picked != null && picked != _selectedDate) {
                      //         setState(() {
                      //           _selectedDate = picked;
                      //         });
                      //       }
                      //     },
                      //     style: appTheme.primaryButtonStyle,
                      //     child: Text('Select Date'),
                      //   ),
                      // ),
                      // SizedBox(width: 16),
                      Expanded(
                        child: TimePickerSpinnerPopUp(
                          mode: CupertinoDatePickerMode.time,
                          initTime: _startTime ?? DateTime.now(),
                          onChange: (dateTime) {
                            setState(() {
                              _startTime = dateTime;
                            });
                          },
                          barrierColor: Colors.black26,
                          minuteInterval: 1,
                          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                          cancelText: 'Cancel',
                          confirmText: 'OK',
                          pressType: PressType.singlePress,
                          timeFormat: 'HH:mm',
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: TimePickerSpinnerPopUp(
                          mode: CupertinoDatePickerMode.time,
                          initTime: _endTime ?? DateTime.now(),
                          onChange: (dateTime) {
                            setState(() {
                              _endTime = dateTime;
                            });
                          },
                          barrierColor: Colors.black26,
                          minuteInterval: 1,
                          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                          cancelText: 'Cancel',
                          confirmText: 'OK',
                          pressType: PressType.singlePress,
                          timeFormat: 'HH:mm',
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TimePickerSpinnerPopUp(
                          mode: CupertinoDatePickerMode.time,
                          initTime: _reminderTime ?? DateTime.now(),
                          onChange: (dateTime) {
                            if (_isReminderSet) {
                              setState(() {
                                _reminderTime = dateTime;
                              });
                            }
                          },
                          barrierColor: Colors.black26,
                          minuteInterval: 1,
                          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                          cancelText: 'Cancel',
                          confirmText: 'OK',
                          pressType: PressType.singlePress,
                          timeFormat: 'HH:mm',
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  ReminderButton(
                    isReminderSet: _isReminderSet,
                    reminderTime: _reminderTime,
                    onPressed: () {
                      setState(() {
                        _isReminderSet = !_isReminderSet;
                        if (_isReminderSet) {
                          _reminderTime = _reminderTime ?? DateTime.now();
                        } else {
                          _reminderTime = null;
                        }
                      });
                    },
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            widget.onSave(
                                _titleController.text,
                                _descriptionController.text,
                                _selectedDate,
                                _startTime != null
                                    ? TimeOfDay.fromDateTime(_startTime!)
                                    : null,
                                _endTime != null
                                    ? TimeOfDay.fromDateTime(_endTime!)
                                    : null,
                                _selectedColor,
                                _isReminderSet,
                                _isReminderSet ? _reminderTime : null);
                            Navigator.pop(context);
                          },
                          style: appTheme.primaryButtonStyle,
                          child: Text('Save Event'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ));
  }

  void showColorPickerDialog() {
    final appTheme = Get.find<AppTheme>();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title:
              Text('Pick a color', style: TextStyle(color: appTheme.textColor)),
          backgroundColor: appTheme.cardColor,
          content: SingleChildScrollView(
            child: ColorPicker(
              color: _selectedColor,
              onColorChanged: (Color color) {
                setState(() => _selectedColor = color);
              },
              heading: Text('Select color',
                  style: TextStyle(color: appTheme.textColor)),
              subheading: Text('Select color shade',
                  style: TextStyle(color: appTheme.textColor)),
              wheelSubheading: Text('Selected color and its shades',
                  style: TextStyle(color: appTheme.textColor)),
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
              child: Text('OK',
                  style: TextStyle(color: appTheme.colorScheme.primary)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showReminderTimePicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Container(
            height: 100,
            child: TimePickerSpinnerPopUp(
              mode: CupertinoDatePickerMode.time,
              initTime: _reminderTime ?? DateTime.now(),
              onChange: (dateTime) {
                setState(() {
                  _reminderTime = dateTime;
                });
              },
              barrierColor: Colors.black26,
              minuteInterval: 1,
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
              cancelText: 'Cancel',
              confirmText: 'OK',
              pressType: PressType.singlePress,
              timeFormat: 'HH:mm',
            ),
          ),
        );
      },
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
