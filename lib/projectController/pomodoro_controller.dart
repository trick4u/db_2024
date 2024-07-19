import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:math' as math;

// class PomodoroController extends GetxController {
//   var isRunning = false.obs;
//   var isBreak = false.obs;
//   var timeLeft = (25 * 60).obs;
 
  

//   void startTimer() {
//     isRunning.value = true;
//     _startCountdown();
//   }

//   void stopTimer() {
//     isRunning.value = false;
//   }

//   void resetTimer() {
//     isRunning.value = false;
//     timeLeft = (isBreak.value ? 5 * 60 : 25 * 60) as RxInt;

//      // Reset to 5 minutes for break, 25 minutes for work

//   }

//   void _startCountdown() {
//     if (isRunning.value) {
//       Future.delayed(Duration(seconds: 1), () {
//         if (isRunning.value && timeLeft > 0) {
//           timeLeft--;
//           _startCountdown();
//         } else {
//           isRunning.value = false;
//           isBreak.value = !isBreak.value; // Switch between work and break
//           timeLeft = (isBreak.value ? 5 * 60 : 25 * 60) as RxInt; // Set next timer
//         }
//       });
//     }
//   }
// }

class PomodoroController extends GetxController {
  var  timeLeft = (25* 60).obs; // 25 minutes in seconds
  final RxBool isRunning = false.obs;
  final RxString currentMode = 'FOCUS'.obs;
  final RxInt currentRound = 1.obs;

  void startTimer() {
    isRunning.value = true;
    _runTimer();
  }

  void pauseTimer() {
    isRunning.value = false;
  }

  void _runTimer() {
    Future.delayed(Duration(seconds: 1), () {
      if (isRunning.value) {
        if (timeLeft.value > 0) {
          timeLeft.value--;
          _runTimer();
        } else {
          _switchMode();
        }
      }
    });
  }

  void _switchMode() {
    if (currentMode.value == 'FOCUS') {
      currentMode.value = 'BREAK';
      timeLeft.value = 5 * 60; // 5 minutes break
    } else {
      currentMode.value = 'FOCUS';
      timeLeft.value = 25 * 60; // 25 minutes focus
      currentRound.value++;
    }
    startTimer();
  }
}
class TimerPainter extends CustomPainter {
  final double percentage;
  final Color color;

  TimerPainter({required this.percentage, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = color.withOpacity(0.3)
      ..strokeWidth = 10.0
      ..style = PaintingStyle.stroke;

    Paint progressPaint = Paint()
      ..color = color
      ..strokeWidth = 10.0
      ..style = PaintingStyle.stroke;

    double progressAngle = 2 * 3.141592653589793 * (percentage / 100);

    Offset center = Offset(size.width / 2, size.height / 2);
    double radius = size.width / 2 - 10;

    canvas.drawCircle(center, radius, paint);
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), -3.141592653589793 / 2, progressAngle, false, progressPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class CircleProgressPainter extends CustomPainter {
  final double progress;
  final Color color;

  CircleProgressPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = color
      ..strokeWidth = 10.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    double radius = size.width / 2;
    Offset center = Offset(size.width / 2, size.height / 2);
    double sweepAngle = 2 * math.pi * progress;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}