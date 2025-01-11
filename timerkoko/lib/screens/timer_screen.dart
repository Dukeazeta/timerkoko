import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../widgets/timer_painter.dart';
import '../controllers/timer_controller.dart';

class TimerScreen extends StatelessWidget {
  const TimerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: GetBuilder<TimerController>(
        init: TimerController(),
        builder: (controller) {
          return SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${controller.selectedMinutes}',
                    style: const TextStyle(
                      fontSize: 72,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'MIN',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'SETUP TIME',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    height: 300,
                    width: 300,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        TimerPainter(
                          progress: controller.progress,
                          isRunning: controller.isRunning,
                        ),
                        GestureDetector(
                          onPanUpdate: controller.onPanUpdate,
                          child: Container(
                            height: 300,
                            width: 300,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        Container(
                          height: 50,
                          width: 50,
                          decoration: BoxDecoration(
                            color: Colors.black,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: IconButton(
                            icon: Icon(
                              controller.isRunning ? Icons.pause : Icons.play_arrow,
                              size: 24,
                              color: Colors.white,
                            ),
                            onPressed: controller.toggleTimer,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
