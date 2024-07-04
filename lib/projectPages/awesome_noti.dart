import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:workmanager/workmanager.dart';

import '../services/notification_service.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';

// class AwesomeNoti extends StatefulWidget {
//   const AwesomeNoti({super.key});

//   @override
//   State<AwesomeNoti> createState() => _AwesomeNotiState();
// }

// class _AwesomeNotiState extends State<AwesomeNoti> {
//   OmniDateTimePicker omniDateTimePicker = OmniDateTimePicker(
//     onDateTimeChanged: (DateTime dateTime) {
//       print(dateTime);
//     },
//   );
//   @override
//   void initState() {
//     AwesomeNotifications().setListeners(
//       onActionReceivedMethod: NotificationService.onActionReceivedMethod,
//       onNotificationCreatedMethod:
//           NotificationService.onNotificationCreatedMethod,
//       onNotificationDisplayedMethod:
//           NotificationService.onNotificationDisplayedMethod,
//       onDismissActionReceivedMethod:
//           NotificationService.onDismissActionReceivedMethod,
//     );

//     AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
//       if (!isAllowed) {
//         AwesomeNotifications().requestPermissionToSendNotifications();
//       } else {
//         print('Notification Allowed');
//       }
//     });
//     //listen for notification

//     super.initState();
//   }

//   void dispose() {
//     AwesomeNotifications().dispose();
//     super.dispose();
//   }

//   Future<void> scheduleNotification(
//       DateTime scheduledDateTime, String message) async {
//     await AwesomeNotifications().createNotification(
//       content: NotificationContent(
//         id: scheduledDateTime.hashCode, // Unique ID
//         channelKey: 'basic_channel',
//         title: 'Scheduled Reminder 📅',
//         body: message,
//         notificationLayout: NotificationLayout.BigPicture,
//         color: Color(0xFF00FF00),
//         backgroundColor: Colors.blue,
//         bigPicture:
//             'https://cdn.pixabay.com/photo/2024/03/24/17/10/background-8653526_1280.jpg',
//       ),
//       schedule: NotificationCalendar(
//         weekday: scheduledDateTime.weekday,
//         hour: scheduledDateTime.hour,
//         minute: scheduledDateTime.minute,
//         second: 0,
//         millisecond: 0,
//         allowWhileIdle: true,
//         timeZone: AwesomeNotifications.localTimeZoneIdentifier,
//       ),
//     );
//   }

//   Future<void> schedulePeriodicNotifications() async {
//     AwesomeNotifications().createNotification(
//       content: NotificationContent(
//         id: 10,
//         channelKey: 'basic_channel',
//         title: 'DoBoara Reminder 📅',
//         body: 'Get ahead of your schedule',
//         largeIcon: 'https://cdn.pixabay.com/photo/2024/03/24/17/10/background-8653526_1280.jpg',
//       //  icon: "https://cdn.pixabay.com/photo/2023/06/11/01/24/flowers-8055013_1280.jpg",
//       ),
//         schedule: NotificationCalendar(
//         hour: 10,
//         minute: 30,
//         second: 0,
//         millisecond: 0,
//         repeats: true,
//         timeZone: await AwesomeNotifications().getLocalTimeZoneIdentifier(),
//       ),
//       // actionButtons: [
//       //   NotificationActionButton(
//       //     key: 'ACTION1',
//       //     label: 'Action 1',
//       //     actionType: ActionType.Default,
//       //   ),
//       //   NotificationActionButton(
//       //     key: 'ACTION2',
//       //     label: 'Action 2',
//       //   ),
//       // ],
      
      
    
//       // schedule: NotificationInterval(
//       //     interval: 5 * 60,
//       //     timeZone: await AwesomeNotifications().getLocalTimeZoneIdentifier(),
//       //     repeats: true),
          
//     );
   
//   }

//   void pickDateTime() async {
//     DateTime? dateTime = await showOmniDateTimePicker(
//       context: context,
//       initialDate: DateTime.now(),
//       firstDate: DateTime(2020),
//       lastDate: DateTime(2099),
//     );

//     if (dateTime != null) {
//       scheduleNotification(dateTime, 'This is your custom scheduled reminder!');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         Container(
//           alignment: Alignment.center,
//           child: ElevatedButton(
//             onPressed: () {
//               // Awesome Notifications
//               pickDateTime();
//             },
//             child: Text('Awesome Notification'),
//           ),
//         ),
//         Container(
//           alignment: Alignment.center,
//           child: ElevatedButton(
//             onPressed: () {
//               // Awesome Notifications

//               schedulePeriodicNotifications();
//             },
//             child: Text('Periodic Notification'),
//           ),
//         ),
//         // Container(
//         //   alignment: Alignment.center,
//         //   child: ElevatedButton(
//         //     onPressed: () {
//         //       // Awesome Notifications
//         //       // schedulePeriodicNotifications();
//         //       Workmanager().registerPeriodicTask(
//         //         "1",
//         //         "periodicNotification ok",
//         //         frequency: Duration(minutes: 10),
//         //         inputData: {"data": "TusharPeriodicTaskAwesome"},
//         //       );

//         //       print('Periodic Notification Scheduled');
//         //     },
//         //     child: Text(' Schedule Periodic Notification'),
//         //   ),
//         // ),
//       ],
//     );
//   }
// }


class GoalsScreenOne extends StatelessWidget {
  final GoalsController controller = Get.put(GoalsController());
  final TextEditingController goalController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Goals'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: goalController,
              decoration: InputDecoration(
                labelText: 'Goal',
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (goalController.text.isNotEmpty) {
                controller.addGoal(goalController.text);
                goalController.clear();
              }
            },
            child: Text('Add Goal'),
          ),
          Expanded(
            child: Obx(() {
              return ListView.builder(
                itemCount: controller.goalsList.length,
                itemBuilder: (context, index) {
                  var goal = controller.goalsList[index];
                  return ListTile(
                    title: Text(goal.goal),
                    subtitle: Text(goal.createdTime.toDate().toString()),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () {
                            goalController.text = goal.goal;
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Text('Update Goal'),
                                  content: TextField(
                                    controller: goalController,
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        controller.updateGoal(
                                          goal.id,
                                          goalController.text,
                                        );
                                        goalController.clear();
                                        Navigator.of(context).pop();
                                      },
                                      child: Text('Update'),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            controller.deleteGoal(goal.id);
                          },
                        ),
                      ],
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}


class GoalsController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  var goalsList = <Goals>[].obs;

  User? get currentUser => _auth.currentUser;

  @override
  void onInit() {
    super.onInit();
    fetchGoals();
  }

  void fetchGoals() async {
    if (currentUser != null) {
      var snapshot = await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .collection('goals')
          .get();
      goalsList.value = snapshot.docs
          .map((doc) => Goals.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    }
  }

  void addGoal(String goal) async {
    if (currentUser != null) {
      var docRef = await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .collection('goals')
          .add({
        'goal': goal,
        'createdTime': Timestamp.now(),
      });
      goalsList.add(Goals(id: docRef.id, goal: goal, createdTime: Timestamp.now()));
    }
  }

  void updateGoal(String id, String newGoal) async {
    if (currentUser != null) {
      await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .collection('goals')
          .doc(id)
          .update({'goal': newGoal});
      var index = goalsList.indexWhere((goal) => goal.id == id);
      if (index != -1) {
        goalsList[index] = Goals(id: id, goal: newGoal, createdTime: goalsList[index].createdTime);
        goalsList.refresh(); // Notify GetX to update the UI
      }
    }
  }

  void deleteGoal(String id) async {
    if (currentUser != null) {
      await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .collection('goals')
          .doc(id)
          .delete();
      goalsList.removeWhere((goal) => goal.id == id);
    }
  }
}


class Goals {
  String id;
  String goal;
  Timestamp createdTime;

  Goals({required this.id, required this.goal, required this.createdTime});

  factory Goals.fromMap(Map<String, dynamic> map, String id) {
    return Goals(
      id: id,
      goal: map['goal'],
      createdTime: map['createdTime'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'goal': goal,
      'createdTime': createdTime,
    };
  }
}