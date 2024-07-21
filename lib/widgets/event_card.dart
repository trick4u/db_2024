import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:tushar_db/projectController/calendar_controller.dart';

import '../projectPages/page_two_calendar.dart';

class EventCard extends StatelessWidget {
  final EventModel event;
  final Function(EventModel) onDelete;
  final Function(EventModel) onEdit;

  EventCard({
    Key? key,
    required this.event,
    required this.onDelete,
    required this.onEdit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
              // Implement archive functionality
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
            event.startTime != null
                ? DateFormat('h:mm a').format(event.startTime!)
                : DateFormat('h:mm a').format(event.date),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          SizedBox(height: 4),
          Text(
            event.endTime != null
                ? DateFormat('h:mm a').format(event.endTime!)
                : DateFormat('h:mm a').format(event.date),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardContent() {
    return Card(
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
                gradient: LinearGradient(
                  colors: [event.color, Colors.white],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  bottomLeft: Radius.circular(10),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(event.description),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
