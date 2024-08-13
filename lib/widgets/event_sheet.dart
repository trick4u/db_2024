import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tushar_db/projectController/page_one_controller.dart';

import '../models/quick_event_model.dart';
import 'event_bottomSheet.dart';
import 'event_card.dart';

class EventsList extends StatelessWidget {
  final RxList<QuickEventModel> events;
  final String eventType;

  EventsList({
    required this.events,
    required this.eventType,
  });

  @override
  Widget build(BuildContext context) {
     final PageOneController controller = Get.find<PageOneController>();
    return Obx(() => events.isEmpty
        ? Center(child: Text('No $eventType events'))
        : ListView.builder(
            itemCount: events.length,
            itemBuilder: (context, index) {
              QuickEventModel event = events[index];
              return EventCard(
                event: event,
             onDelete: (event) => controller.deleteEvent(event.id),
                onEdit: (event) => _showEventBottomSheet(context, event),
                onArchive: (event) => controller.archiveEvent(event.id),
                onComplete: (event) => controller.toggleEventCompletion(event.id, event.isCompleted != true),
              );
            },
          ));
  }

  

void _showEventBottomSheet(BuildContext context, QuickEventModel event) {
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
            Map<String, dynamic> updatedData = {
              'title': title,
              'description': description,
              'date': date,
              'color': color.value,
              'hasReminder': hasReminder,
              'isCompleted': event.isCompleted,
              'startTime': startTime != null
                  ? DateTime(date.year, date.month, date.day, startTime.hour, startTime.minute)
                  : null,
              'endTime': endTime != null
                  ? DateTime(date.year, date.month, date.day, endTime.hour, endTime.minute)
                  : null,
              'reminderTime': reminderTime,
            };

            pageOneController.updateEvent(event.id, updatedData);
          },
        ),
      ),
    );
  }
}