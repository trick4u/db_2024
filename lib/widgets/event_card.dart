import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tushar_db/projectController/calendar_controller.dart';

import '../models/quick_event_model.dart';
import '../projectPages/page_two_calendar.dart';
import '../services/app_text_style.dart';
import '../services/scale_util.dart';

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
      child: _buildEventCardContent(context),
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
        width: ScaleUtil.width(80),
        height: ScaleUtil.height(60),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(ScaleUtil.scale(10)),
          color: color,
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              spreadRadius: ScaleUtil.scale(1),
              blurRadius: ScaleUtil.scale(3),
              offset: Offset(0, ScaleUtil.scale(2)),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: ScaleUtil.scale(30),
            ),
            SizedBox(height: ScaleUtil.height(4)),
            Text(
              label,
              style: AppTextTheme.textTheme.labelSmall!.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventCardContent(BuildContext context) {
    return Container(
      margin: ScaleUtil.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        children: [
          _buildTimeColumn(context),
          SizedBox(width: ScaleUtil.width(8)),
          Expanded(child: _buildCardContent(context)),
          _buildCompleteButton(),
        ],
      ),
    );
  }

  Widget _buildTimeColumn(BuildContext context) {
    return Container(
      width: ScaleUtil.width(60),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            DateFormat('MMM d').format(event.createdAt),
            style: AppTextTheme.textTheme.labelMedium!.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: ScaleUtil.height(4)),
          Text(
            event.startTime != null
                ? DateFormat('h:mm a').format(event.startTime!)
                : DateFormat('h:mm a').format(event.createdAt),
            style: AppTextTheme.textTheme.labelSmall!.copyWith(
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          if (event.isCompleted == true && event.editedAfterCompletion == true)
            Padding(
              padding: ScaleUtil.only(top: 4),
              child: Text(
                'Edited',
                style: AppTextTheme.textTheme.labelSmall!.copyWith(
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
        size: ScaleUtil.scale(24),
      ),
      onPressed: () => onComplete(event),
    );
  }

  Widget _buildCardContent(BuildContext context) {
    return GetBuilder<CalendarController>(
      builder: (controller) => GestureDetector(
        onTap: () => controller.toggleEventExpansion(event.id),
        child: Stack(
          children: [
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(ScaleUtil.scale(10)),
              ),
              child: IntrinsicHeight(
                child: Row(
                  children: [
                    Container(
                      width: ScaleUtil.width(20),
                      decoration: BoxDecoration(
                        color: event.color,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(ScaleUtil.scale(10)),
                          bottomLeft: Radius.circular(ScaleUtil.scale(10)),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: ScaleUtil.all(10.0),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                event.title,
                                style: AppTextTheme.textTheme.titleMedium!
                                    .copyWith(
                                  fontWeight: FontWeight.bold,
                                  decoration: event.isCompleted == true
                                      ? TextDecoration.lineThrough
                                      : TextDecoration.none,
                                ),
                              ),
                              SizedBox(height: ScaleUtil.height(4)),
                              AnimatedCrossFade(
                                firstChild: Text(
                                  event.description,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextTheme.textTheme.bodyMedium!
                                      .copyWith(
                                    decoration: event.isCompleted == true
                                        ? TextDecoration.lineThrough
                                        : TextDecoration.none,
                                  ),
                                ),
                                secondChild: Text(
                                  event.description,
                                  style: AppTextTheme.textTheme.bodyMedium!
                                      .copyWith(
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
                        width: ScaleUtil.width(20),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(ScaleUtil.scale(10)),
                            bottomRight: Radius.circular(ScaleUtil.scale(10)),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            if (event.hasReminder && _shouldShowNotificationIcon())
              Positioned(
                top: ScaleUtil.height(15),
                right: event.isCompleted == true
                    ? ScaleUtil.width(40)
                    : ScaleUtil.width(20),
                child: GestureDetector(
                  onTap: () {
                    final calendarController = Get.find<CalendarController>();
                    calendarController.toggleEventReminder(event.id);
                  },
                  child: Icon(
                    Icons.notifications_active,
                    size: ScaleUtil.scale(18),
                    color: Colors.blue,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  bool _shouldShowNotificationIcon() {
    if (event.isCompleted == true) return false;

    if (event.lastNotificationDisplayed == null) {
      return true;
    }

    // Show the icon if the last notification was displayed more than 5 minutes ago
    return DateTime.now().difference(event.lastNotificationDisplayed!) >
        Duration(minutes: 5);
  }
}
