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
  bool _isTitleEmpty = true;
  bool _isDescriptionVisible = false;

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
                //  crossAxisAlignment: CrossAxisAlignment.stretch,

                children: [
                  Row(
                    children: [
                      Text(
                        widget.event == null ? 'Add Event' : 'Edit Event',
                        style: appTheme.titleLarge,
                      ),
                      Spacer(),
                      _buildReminderWidget(context, appTheme),
                      // ElevatedButton(
                      //   onPressed: () {
                      //     showColorPickerDialog();
                      //   },
                      //   child: Text('Select Color'),
                      //   style: ElevatedButton.styleFrom(
                      //     backgroundColor: _selectedColor,
                      //     foregroundColor:
                      //         _selectedColor.computeLuminance() > 0.5
                      //             ? Colors.black
                      //             : Colors.white,
                      //   ),
                      // ),
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
                    borderRadius: BorderRadius.all(Radius.circular(10)),
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
                      onChanged: (value) => _updateTitleState(),
                    ),
                  ),

                  SizedBox(height: 16),
                  if (_isDescriptionVisible) ...[
                    SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.all(
                        Radius.circular(10),
                      ),
                      child: TextField(
                        controller: _descriptionController,
                        style: appTheme.bodyMedium,
                        decoration: InputDecoration(
                          labelText: 'Description',

                          filled: true,
                          fillColor: appTheme.textFieldFillColor,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          // ... (other decoration properties)
                        ),
                        maxLines: 3,
                      ),
                    ),
                  ],

                  SizedBox(
                    height: ScaleUtil.height(10),
                  ),
                  // Row(
                  //   children: [
                  //     // Expanded(
                  //     //   child: ElevatedButton(
                  //     //     onPressed: () async {
                  //     //       final DateTime? picked = await showDatePicker(
                  //     //         context: context,
                  //     //         initialDate: _selectedDate,
                  //     //         firstDate: DateTime.now(),
                  //     //         lastDate: DateTime(2101),
                  //     //         builder: (BuildContext context, Widget? child) {
                  //     //           return Theme(
                  //     //             data: ThemeData.light().copyWith(
                  //     //               colorScheme: ColorScheme.light(
                  //     //                 primary: appTheme.colorScheme.primary,
                  //     //                 onPrimary: appTheme.colorScheme.onPrimary,
                  //     //                 surface: appTheme.colorScheme.surface,
                  //     //                 onSurface: appTheme.colorScheme.onSurface,
                  //     //               ),
                  //     //             ),
                  //     //             child: child!,
                  //     //           );
                  //     //         },
                  //     //       );
                  //     //       if (picked != null && picked != _selectedDate) {
                  //     //         setState(() {
                  //     //           _selectedDate = picked;
                  //     //         });
                  //     //       }
                  //     //     },
                  //     //     style: appTheme.primaryButtonStyle,
                  //     //     child: Text('Select Date'),
                  //     //   ),
                  //     // ),
                  //     // SizedBox(width: 16),
                  //     Expanded(
                  //       child: TimePickerSpinnerPopUp(
                  //         mode: CupertinoDatePickerMode.time,
                  //         initTime: _startTime ?? DateTime.now(),
                  //         onChange: (dateTime) {
                  //           setState(() {
                  //             _startTime = dateTime;
                  //           });
                  //         },
                  //         barrierColor: Colors.black26,
                  //         minuteInterval: 1,
                  //         padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                  //         cancelText: 'Cancel',
                  //         confirmText: 'OK',
                  //         pressType: PressType.singlePress,
                  //         timeFormat: 'HH:mm',
                  //       ),
                  //     ),
                  //     SizedBox(
                  //       width: 10,
                  //     ),
                  //     Expanded(
                  //       child: TimePickerSpinnerPopUp(
                  //         mode: CupertinoDatePickerMode.time,
                  //         initTime: _endTime ?? DateTime.now(),
                  //         onChange: (dateTime) {
                  //           setState(() {
                  //             _endTime = dateTime;
                  //           });
                  //         },
                  //         barrierColor: Colors.black26,
                  //         minuteInterval: 1,
                  //         padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                  //         cancelText: 'Cancel',
                  //         confirmText: 'OK',
                  //         pressType: PressType.singlePress,
                  //         timeFormat: 'HH:mm',
                  //       ),
                  //     ),
                  //   ],
                  // ),

                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.center,
                  //   children: [
                  //     ReminderButton(
                  //       isReminderSet: _isReminderSet,
                  //       reminderTime: _reminderTime,
                  //       onPressed: () {
                  //         setState(() {
                  //           _isReminderSet = !_isReminderSet;
                  //           if (_isReminderSet) {
                  //             _reminderTime = _reminderTime ?? DateTime.now();
                  //           } else {
                  //             _reminderTime = null;
                  //           }
                  //         });
                  //       },
                  //     ),
                  //     SizedBox(
                  //       width: ScaleUtil.width(10),
                  //     ),
                  //     TimePickerSpinnerPopUp(
                  //       mode: CupertinoDatePickerMode.time,
                  //       initTime: _reminderTime ?? DateTime.now(),
                  //       onChange: (dateTime) {
                  //         if (_isReminderSet) {
                  //           setState(() {
                  //             _reminderTime = dateTime;
                  //           });
                  //         }
                  //       },
                  //       barrierColor: Colors.black26,
                  //       minuteInterval: 1,
                  //       padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                  //       cancelText: 'Cancel',
                  //       confirmText: 'OK',
                  //       pressType: PressType.singlePress,
                  //       timeFormat: 'HH:mm',
                  //     ),
                  //   ],
                  // ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      _buildDescriptionToggleButton(context, appTheme),
                      SizedBox(width: 16),
                      _buildColorIconButton(context, appTheme),
                      SizedBox(width: 16),
                      _buildSaveIconButton(context, appTheme),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ));
  }

  Widget _buildDescriptionToggleButton(
      BuildContext context, AppTheme appTheme) {
    return FadeIn(
      child: Container(
        decoration: BoxDecoration(
          color: _isDescriptionVisible
              ? appTheme.colorScheme.primary
              : appTheme.colorScheme.surface,
          shape: BoxShape.circle,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              setState(() {
                _isDescriptionVisible = !_isDescriptionVisible;
              });
            },
            child: Padding(
              padding: EdgeInsets.all(10),
              child: FaIcon(
                _isDescriptionVisible
                    ? FontAwesomeIcons.listUl
                    : FontAwesomeIcons.list,
                color: _isDescriptionVisible ? Colors.white : Colors.black,
                size: 20,
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
          borderRadius: BorderRadius.circular(20),
          onTap: () => showColorPickerDialog(context),
          child: Padding(
            padding: EdgeInsets.all(10),
            child: FaIcon(
              FontAwesomeIcons.palette,
              color: _selectedColor.computeLuminance() > 0.5
                  ? Colors.black
                  : Colors.white,
              size: 20,
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
          borderRadius: BorderRadius.circular(20),
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
                  );
                  Navigator.pop(context);
                },
          child: Padding(
            padding: EdgeInsets.all(10),
            child: Icon(
              FontAwesomeIcons.check,
              color: Colors.white,
              size: 20,
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

  Widget _buildSaveButton(BuildContext context, AppTheme appTheme) {
    return Container(
      decoration: BoxDecoration(
        color: _isTitleEmpty ? Colors.grey : appTheme.colorScheme.primary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
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
                  );
                  Navigator.pop(context);
                },
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            child: Text(
              'Save',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReminderWidget(BuildContext context, AppTheme appTheme) {
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
      padding: EdgeInsets.symmetric(vertical: 0, horizontal: 5),
      decoration: BoxDecoration(
        color: Colors.green,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.alarm_on, color: Colors.white),
              SizedBox(width: 8),
              Text(
                ' ${_formatTime(_reminderTime!)}',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
          IconButton(
            icon: Icon(Icons.close, color: Colors.white),
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

  // void showColorPickerDialog() {
  //   final appTheme = Get.find<AppTheme>();
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title:
  //             Text('Pick a color', style: TextStyle(color: appTheme.textColor)),
  //         backgroundColor: appTheme.cardColor,
  //         content: SingleChildScrollView(
  //           child: ColorPicker(
  //             color: _selectedColor,
  //             onColorChanged: (Color color) {
  //               setState(() => _selectedColor = color);
  //             },
  //             heading: Text('Select color',
  //                 style: TextStyle(color: appTheme.textColor)),
  //             subheading: Text('Select color shade',
  //                 style: TextStyle(color: appTheme.textColor)),
  //             wheelSubheading: Text('Selected color and its shades',
  //                 style: TextStyle(color: appTheme.textColor)),
  //             pickersEnabled: const <ColorPickerType, bool>{
  //               ColorPickerType.both: false,
  //               ColorPickerType.primary: true,
  //               ColorPickerType.accent: true,
  //               ColorPickerType.bw: false,
  //               ColorPickerType.custom: true,
  //               ColorPickerType.wheel: true,
  //             },
  //           ),
  //         ),
  //         actions: <Widget>[
  //           TextButton(
  //             child: Text('OK',
  //                 style: TextStyle(color: appTheme.colorScheme.primary)),
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //             },
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

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
