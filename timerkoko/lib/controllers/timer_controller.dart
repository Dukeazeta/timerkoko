import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:math' as math;

class TimerController extends GetxController {
  int selectedMinutes = 0;
  bool isRunning = false;
  double progress = 0.0;
  int remainingSeconds = 0;

  void onPanUpdate(DragUpdateDetails details) {
    if (isRunning) return;

    final box = Get.context!.findRenderObject() as RenderBox;
    final center = Offset(box.size.width / 2, box.size.height / 2);
    final position = details.localPosition;
    
    // Calculate angle from center
    final angle = (math.atan2(position.dy - center.dy, position.dx - center.dx) +
            math.pi / 2) %
        (2 * math.pi);
    
    selectedMinutes = ((angle / (2 * math.pi)) * 60).round();
    progress = angle / (2 * math.pi);
    remainingSeconds = selectedMinutes * 60;
    update();
  }

  void toggleTimer() {
    if (selectedMinutes == 0) return;
    
    isRunning = !isRunning;
    if (isRunning) {
      startTimer();
    }
    update();
  }

  void startTimer() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!isRunning) return false;
      
      remainingSeconds--;
      progress = remainingSeconds / (selectedMinutes * 60);
      
      if (remainingSeconds <= 0) {
        isRunning = false;
        selectedMinutes = 0;
        progress = 0.0;
      }
      
      update();
      return remainingSeconds > 0;
    });
  }
}
