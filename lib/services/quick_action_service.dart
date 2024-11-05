import 'package:get/get.dart';
import 'package:quick_actions/quick_actions.dart';

import '../controller/main_screen_controller.dart';
import '../projectController/calendar_controller.dart';

class QuickActionsService {
  static final QuickActions quickActions = QuickActions();

  static void initialize() {
    quickActions.initialize((shortcutType) {
      handleQuickAction(shortcutType);
    });

    quickActions.setShortcutItems(<ShortcutItem>[
      const ShortcutItem(
        type: 'action_home',
        localizedTitle: 'Home',
        icon: 'house',
      ),
      const ShortcutItem(
          type: 'action_calendar',
          localizedTitle: 'Calendar',
          icon: 'calendar'
          // References calendar.svg in drawable
          ),
      const ShortcutItem(
        type: 'action_stats',
        localizedTitle: 'Statistics',
        icon: 'charts', // References charts.svg in drawable
      ),
      const ShortcutItem(
        type: 'action_add_task',
        localizedTitle: 'Add Task',
        icon: 'task', // References task.svg in drawable
      ),
    ]);
  }

  static void handleQuickAction(String shortcutType) {
    final MainScreenController mainController =
        Get.find<MainScreenController>();

    switch (shortcutType) {
      case 'action_home':
        mainController.changeIndex(0);
        break;
      case 'action_calendar':
        mainController.changeIndex(1);
        break;
      case 'action_stats':
        mainController.changeIndex(2);
        break;
      case 'action_add_task':
        mainController.changeIndex(1);
        // Add a small delay to ensure the calendar page is loaded
        Future.delayed(const Duration(milliseconds: 300), () {
          final calendarController = Get.find<CalendarController>();
          calendarController.showEventBottomSheet(Get.context!);
        });
        break;
    }
  }
}
