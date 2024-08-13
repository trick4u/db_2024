import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tushar_db/projectController/page_one_controller.dart';

import '../models/quick_event_model.dart';
import 'event_bottomSheet.dart';

class EventsList extends StatelessWidget {
  final RxList<QuickEventModel> events;
  final String eventType;

  EventsList({
    required this.events,
    required this.eventType,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() => events.isEmpty
        ? Center(child: Text('No $eventType events'))
        : ListView.builder(
            itemCount: events.length,
            itemBuilder: (context, index) {
              QuickEventModel event = events[index];
              return ListTile(
                title: Text(event.title),
                subtitle:
                    Text('${event.description} - ${_formatDate(event.date)}'),
                leading: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: event.color,
                  ),
                ),
                onTap: () {
                  showEventBottomSheet(context, event);
                },
              );
            },
          ));
  }

  void showEventBottomSheet(BuildContext context, QuickEventModel event) {
    final pageOneController = Get.find<PageOneController>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: EventBottomSheet(
          event: event,
          initialDate: event.date,
          onSave: (title, description, date, startTime, endTime, color,
              hasReminder, reminderTime) {
            // Convert TimeOfDay to DateTime
            Map<String, dynamic> updatedData = {
              'title': title,
              'description': description,
              'date': Timestamp.fromDate(date),
              'color': color.value,
              'hasReminder': hasReminder,
              'isCompleted':
                  event.isCompleted, // Preserve the current completion status
            };

            if (startTime != null) {
              updatedData['startTime'] = Timestamp.fromDate(
                DateTime(date.year, date.month, date.day, startTime.hour,
                    startTime.minute),
              );
            }

            if (endTime != null) {
              updatedData['endTime'] = Timestamp.fromDate(
                DateTime(date.year, date.month, date.day, endTime.hour,
                    endTime.minute),
              );
            }

            if (reminderTime != null) {
              updatedData['reminderTime'] = Timestamp.fromDate(reminderTime);
            }

            // Update the event
            pageOneController.updateEvent(event.id, updatedData);

            // Close the bottom sheet
          },
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
