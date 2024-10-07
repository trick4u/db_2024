import 'package:animate_do/animate_do.dart';
import 'package:animate_gradient/animate_gradient.dart';
import 'package:dough/dough.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bouncing_text/flutter_bouncing_text.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:tushar_db/app_routes.dart';
import 'package:tushar_db/constants/colors.dart';
import 'package:tushar_db/services/app_text_style.dart';
import 'package:tushar_db/services/scale_util.dart';
import 'package:tushar_db/widgets/pomodoro.dart';

import '../projectController/page_one_controller.dart';

import '../projectController/pomodoro_controller.dart';
import '../services/app_theme.dart';
import '../services/quotes_service.dart';

import '../widgets/AllSixWidgets.dart';

import '../widgets/event_sheet.dart';

import '../widgets/reminder_list.dart';
import 'pomodoro_setup_screen.dart';

class PageOneScreen extends GetWidget<PageOneController> {
  final appTheme = Get.find<AppTheme>();

  final RxBool _isDialogOpen = false.obs;
  final RxBool _isChangingBackground = false.obs;
  final RxInt _backgroundChangeCount = 0.obs;

  Future<void> _showQuoteDialog(BuildContext context) async {
    if (_isDialogOpen.value) return;

    _isDialogOpen.value = true;

    String quote = await QuoteService.getRandomQuote();
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Daily Inspiration'),
          content: Text(quote),
          actions: <Widget>[
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Get.back();
              },
            ),
          ],
        );
      },
    );
    _isDialogOpen.value = false;
  }

  Future<void> _changeBackground() async {
    if (_isChangingBackground.value || _backgroundChangeCount.value >= 10)
      return;

    _isChangingBackground.value = true;

    final PomodoroController networkController = Get.find<PomodoroController>();
    await networkController.fetchRandomBackgroundImage();

    _backgroundChangeCount.value++;
    _isChangingBackground.value = false;
  }

  @override
  Widget build(BuildContext context) {
    ScaleUtil.init(context);
    return SafeArea(
      child: Container(
        margin: ScaleUtil.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Tooltip(
                  message: 'Tap for daily inspiration!',
                  child: PressableDough(
                    onReleased: (d) async {
                      await _showQuoteDialog(context);
                    },
                    child: GestureDetector(
                      onTap: () async {
                        await _showQuoteDialog(context);
                        controller.toggleGradientDirection();
                      },
                      child: PressableDough(
                        onReleased: (s) async {
                          await _showQuoteDialog(context);
                          controller.toggleGradientDirection();
                        },
                        child: Row(
                          children: [
                            Icon(FontAwesomeIcons.handPeace, size: 25),
                            SizedBox(width: 8),
                            AnimatedBouncingText(
                              text: 'doBoard',
                              textStyle: TextStyle(
                                fontFamily: GoogleFonts.pacifico().fontFamily,
                                fontSize: 30,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                            SizedBox(
                              width: 50,
                            ),
                            GestureDetector(
                              onTap: () {
                                Get.toNamed(AppRoutes.NOTIFICAION);
                              },
                              child: Text("Noti",
                                  style: AppTextTheme.textTheme.bodySmall),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            ScaleUtil.sizedBox(height: 10),
            Expanded(
              child: FadeIn(
                child: AllSixCards(
                  useFixedHeight: true,
                  onListTypeSelected: (listType) {
                    controller.setSelectedListType(listType);
                  },
                ),
              ),
            ),
            Expanded(
              child: Obx(() => controller.selectedListType.value.isNotEmpty
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: ScaleUtil.symmetric(horizontal: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  if (controller.selectedListType.value ==
                                      "pomodoro") {
                                    _changeBackground();
                                  }
                                },
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    _getListTitle(
                                        controller.selectedListType.value),
                                    style: AppTextTheme.textTheme.titleLarge
                                        ?.copyWith(
                                      fontSize: ScaleUtil.fontSize(18),
                                    ),
                                  ),
                                ),
                              ),
                              Text(
                                _getTaskCount(
                                    controller.selectedListType.value),
                                style:
                                    AppTextTheme.textTheme.bodyMedium?.copyWith(
                                  color: appTheme.secondaryTextColor,
                                  fontSize: ScaleUtil.fontSize(12),
                                ),
                              ),
                            ],
                          ),
                        ),
                        ScaleUtil.sizedBox(height: 0),
                        Expanded(
                          child: _buildSelectedList(),
                        ),
                      ],
                    )
                  : SizedBox.shrink()),
            ),
            ScaleUtil.sizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  String _getListTitle(String listType) {
    final pomodoroController = Get.find<PomodoroController>();
    switch (listType) {
      case 'upcoming':
        return 'Upcoming Tasks'.toLowerCase();
      case 'pending':
        return 'Pending Tasks'.toLowerCase();
      case 'completed tasks':
        return 'Completed Tasks'.toLowerCase();
      case 'all reminders':
        return 'all reminders'.toLowerCase();
      case 'pomodoro':
        return pomodoroController.isSetupComplete.value
            ? 'pomodoro'
            : 'pomodoro setup';
      default:
        return '';
    }
  }

  String _getTaskCount(String listType) {
    switch (listType) {
      case 'upcoming':
        return 'total upcoming tasks: ${controller.upcomingEvents.length}';
      case 'pending':
        return 'total pending tasks: ${controller.pendingEvents.length}';
      case 'completed tasks':
        return 'total completed tasks: ${controller.completedEvents.length}';
      case 'all reminders':
        return 'total reminders: ${controller.allReminders.length}';
      default:
        return '';
    }
  }

  Widget _buildSelectedList() {
    switch (controller.selectedListType.value) {
      case 'pomodoro':
        return _buildPomodoroSection();
      case 'all reminders':
        return RemindersList();
      default:
        return FadeInRight(
          child: EventsList(
            events: controller.getSelectedEvents(),
            eventType: controller.selectedListType.value,
          ),
        );
    }
  }

  Widget _buildPomodoroSection() {
    // Ensure PomodoroController is initialized
    if (!Get.isRegistered<PomodoroController>()) {
      Get.put(PomodoroController());
    }

    final pomodoroController = Get.find<PomodoroController>();

    return Obx(() => pomodoroController.isSetupComplete.value
        ? PomodoroMusicPlayer()
        : PomodoroSetupScreen(
            onStart: () {
              pomodoroController.startPomodoroSession();
            },
          ));
  }
}
