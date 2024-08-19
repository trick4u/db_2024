import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tushar_db/projectController/calendar_controller.dart';

import '../models/quick_event_model.dart';
import '../projectPages/page_two_calendar.dart';

class EventCard extends StatelessWidget {
  final QuickEventModel event;
  final Function(QuickEventModel) onDelete;
  final Function(QuickEventModel) onEdit;
  final Function(QuickEventModel) onArchive;
  final Function(QuickEventModel) onComplete;

  EventCard({
    Key? key,
    required this.event,
    required this.onDelete,
    required this.onEdit,
    required this.onArchive,
    required this.onComplete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Get.put(CalendarController());
    return Slidable(
      key: ValueKey(event.id),
      startActionPane: ActionPane(
        motion: const BehindMotion(),
        extentRatio: 0.25,
        children: [
          _buildActionButton(
            icon: Icons.archive,
            label: 'Archive',
            color: Colors.green,
            onTap: () {
              onArchive(event);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Archive action')),
              );
            },
          ),
        ],
      ),
      endActionPane: ActionPane(
        motion: const BehindMotion(),
        extentRatio: 0.5,
        children: [
          _buildActionButton(
            icon: Icons.edit,
            label: 'Edit',
            color: Colors.blue,
            onTap: () => onEdit(event),
          ),
          _buildActionButton(
            icon: Icons.delete,
            label: 'Delete',
            color: Colors.red,
            onTap: () => onDelete(event),
          ),
        ],
      ),
      child: _buildEventCardContent(),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return CustomSlidableAction(
      onPressed: (_) => onTap(),
      padding: EdgeInsets.zero,
      backgroundColor: Colors.transparent,
      child: Container(
        width: 80,
        height: 60,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: color,
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 3,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 30,
            ),
            SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventCardContent() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        children: [
          _buildTimeColumn(),
          SizedBox(width: 8),
          Expanded(child: _buildCardContent()),
          _buildCompleteButton(),
        ],
      ),
    );
  }

   Widget _buildTimeColumn() {
    return Container(
      width: 60,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            DateFormat('MMM d').format(event.date),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          SizedBox(height: 4),
          Text(
            event.startTime != null
                ? DateFormat('h:mm a').format(event.startTime!)
                : DateFormat('h:mm a').format(event.date),
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          if (event.isCompleted == true && event.editedAfterCompletion == true)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'Edited',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.blue,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
        ],
      ),
    );
  }


  Widget _buildCompleteButton() {
    return IconButton(
      icon: Icon(
        event.isCompleted == true
            ? Icons.check_circle
            : Icons.check_circle_outline,
        color: event.isCompleted == true ? Colors.green : Colors.grey,
      ),
      onPressed: () => onComplete(event),
    );
  }


  Widget _buildCardContent() {
    return GetBuilder<CalendarController>(
      builder: (controller) => GestureDetector(
        onTap: () => controller.toggleEventExpansion(event.id),
        child: Stack(
          children: [
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: IntrinsicHeight(
                child: Row(
                  children: [
                    Container(
                      width: 20,
                      decoration: BoxDecoration(
                        color: event.color,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10),
                          bottomLeft: Radius.circular(10),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                event.title,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  decoration: event.isCompleted == true
                                      ? TextDecoration.lineThrough
                                      : TextDecoration.none,
                                ),
                              ),
                              SizedBox(height: 4),
                              AnimatedCrossFade(
                                firstChild: Text(
                                  event.description,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    decoration: event.isCompleted == true
                                        ? TextDecoration.lineThrough
                                        : TextDecoration.none,
                                  ),
                                ),
                                secondChild: Text(
                                  event.description,
                                  style: TextStyle(
                                    decoration: event.isCompleted == true
                                        ? TextDecoration.lineThrough
                                        : TextDecoration.none,
                                  ),
                                ),
                                crossFadeState:
                                    controller.isEventExpanded(event.id)
                                        ? CrossFadeState.showSecond
                                        : CrossFadeState.showFirst,
                                duration: Duration(milliseconds: 300),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (event.isCompleted == true)
                      Container(
                        width: 20,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(10),
                            bottomRight: Radius.circular(10),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            if (event.hasReminder)
              Positioned(
                top: 15,
                right: event.isCompleted == true ? 40 : 20,
                child: GestureDetector(
                  onTap: () {
                    final calendarController = Get.find<CalendarController>();
                    calendarController.toggleEventReminder(event.id);
                  },
                  child: Icon(
                    event.hasReminder
                        ? Icons.notifications_active
                        : Icons.notifications_off,
                    size: 18,
                    color: event.hasReminder ? Colors.blue : Colors.grey,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
