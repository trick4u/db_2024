import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/quick_event_mode.dart';
import '../projectController/calendar_controller.dart';
import '../services/app_text_style.dart';
import '../services/app_theme.dart';

class EventBottomSheet extends StatefulWidget {
  final QuickEventModel? event;
  final DateTime initialDate;
  final Function(String, String, DateTime, TimeOfDay?, TimeOfDay?, Color)
      onSave;

  EventBottomSheet(
      {this.event, required this.initialDate, required this.onSave});

  @override
  _EventBottomSheetState createState() => _EventBottomSheetState();
}

class _EventBottomSheetState extends State<EventBottomSheet> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late DateTime _selectedDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  late Color _selectedColor;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.event?.title ?? '');
    _descriptionController =
        TextEditingController(text: widget.event?.description ?? '');
    _selectedDate = widget.event?.date ?? widget.initialDate;
    _selectedColor = widget.event?.color ?? Get.theme.primaryColor;
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appTheme = Get.find<AppTheme>();
    return Obx(() => Padding(
      padding: const EdgeInsets.all(20.0),
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
                  IconButton(
                    icon: Icon(Icons.close, color: appTheme.textColor),
                    onPressed: () {
                      Get.back();
                    },
                  ),
                ],
              ),
              SizedBox(height: 16),
              TextField(
                controller: _titleController,
                style: appTheme.bodyMedium,
                decoration: InputDecoration(
                  labelText: 'Event Title',
                  border: OutlineInputBorder(),
                  labelStyle: appTheme.bodyMedium.copyWith(
                    color: appTheme.secondaryTextColor,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: appTheme.secondaryTextColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: appTheme.colorScheme.primary),
                  ),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _descriptionController,
                style: appTheme.bodyMedium,
                decoration: InputDecoration(
                  labelText: 'Event Description',
                  border: OutlineInputBorder(),
                  labelStyle: appTheme.bodyMedium.copyWith(
                    color: appTheme.secondaryTextColor,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: appTheme.secondaryTextColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: appTheme.colorScheme.primary),
                  ),
                ),
                maxLines: 3,
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2101),
                          builder: (BuildContext context, Widget? child) {
                            return Theme(
                              data: ThemeData.light().copyWith(
                                colorScheme: ColorScheme.light(
                                  primary: appTheme.colorScheme.primary,
                                  onPrimary: appTheme.colorScheme.onPrimary,
                                  surface: appTheme.colorScheme.surface,
                                  onSurface: appTheme.colorScheme.onSurface,
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (picked != null && picked != _selectedDate) {
                          setState(() {
                            _selectedDate = picked;
                          });
                        }
                      },
                      style: appTheme.primaryButtonStyle,
                      child: Text('Select Date'),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        final TimeOfDay? picked = await showTimePicker(
                          context: context,
                          initialTime: _startTime ?? TimeOfDay.now(),
                          builder: (BuildContext context, Widget? child) {
                            return Theme(
                              data: ThemeData.light().copyWith(
                                colorScheme: ColorScheme.light(
                                  primary: appTheme.colorScheme.primary,
                                  onPrimary: appTheme.colorScheme.onPrimary,
                                  surface: appTheme.colorScheme.surface,
                                  onSurface: appTheme.colorScheme.onSurface,
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (picked != null) {
                          setState(() {
                            _startTime = picked;
                          });
                        }
                      },
                      style: appTheme.primaryButtonStyle,
                      child: Text('Start Time'),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  final TimeOfDay? picked = await showTimePicker(
                    context: context,
                    initialTime: _endTime ?? TimeOfDay.now(),
                    builder: (BuildContext context, Widget? child) {
                      return Theme(
                        data: ThemeData.light().copyWith(
                          colorScheme: ColorScheme.light(
                            primary: appTheme.colorScheme.primary,
                            onPrimary: appTheme.colorScheme.onPrimary,
                            surface: appTheme.colorScheme.surface,
                            onSurface: appTheme.colorScheme.onSurface,
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (picked != null) {
                    setState(() {
                      _endTime = picked;
                    });
                  }
                },
                style: appTheme.primaryButtonStyle,
                child: Text('End Time'),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  showColorPickerDialog();
                },
                child: Text('Select Color'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _selectedColor,
                  foregroundColor: _selectedColor.computeLuminance() > 0.5 ? Colors.black : Colors.white,
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  widget.onSave(
                    _titleController.text,
                    _descriptionController.text,
                    _selectedDate,
                    _startTime,
                    _endTime,
                    _selectedColor,
                  );
                  Navigator.pop(context);
                },
                style: appTheme.primaryButtonStyle,
                child: Text('Save Event'),
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
          title: Text('Pick a color', style: TextStyle(color: appTheme.textColor)),
          backgroundColor: appTheme.cardColor,
          content: SingleChildScrollView(
            child: ColorPicker(
              color: _selectedColor,
              onColorChanged: (Color color) {
                setState(() => _selectedColor = color);
              },
              heading: Text('Select color', style: TextStyle(color: appTheme.textColor)),
              subheading: Text('Select color shade', style: TextStyle(color: appTheme.textColor)),
              wheelSubheading: Text('Selected color and its shades', style: TextStyle(color: appTheme.textColor)),
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
              child: Text('OK', style: TextStyle(color: appTheme.colorScheme.primary)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}