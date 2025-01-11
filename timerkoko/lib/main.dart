import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'dart:math' as math;
import 'screens/timer_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: GoogleFonts.spaceGroteskTextTheme(),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.red,
          brightness: Brightness.light,
        ),
      ),
      home: const TimerScreen(),
    );
  }
}

class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _spinAnimationController;

  @override
  void initState() {
    super.initState();
    _spinAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 60),
    );
  }

  @override
  void dispose() {
    _spinAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: GetBuilder<TimerController>(
        init:
            TimerController(spinAnimationController: _spinAnimationController),
        builder: (controller) {
          return SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${controller.selectedMinutes}',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 96,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    'MIN',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 2,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'SETUP TIME',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1,
                      color: Colors.black38,
                    ),
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    height: 300,
                    width: 300,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CustomPaint(
                          painter: CustomTimerPainter(
                            progress: controller.progress,
                            isRunning: controller.isRunning,
                            isSettingTime: controller.isSettingTime,
                            spinAnimation: _spinAnimationController,
                            setupRotation: controller.setupRotation,
                          ),
                          size: const Size(300, 300),
                        ),
                        GestureDetector(
                          onPanStart: controller.onPanStart,
                          onPanEnd: controller.onPanEnd,
                          onPanUpdate: controller.onPanUpdate,
                          child: Container(
                            height: 300,
                            width: 300,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            controller.isRunning
                                ? Icons.pause
                                : Icons.play_arrow,
                            size: 32,
                            color: Colors.white,
                          ),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.black,
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(48, 48),
                          ),
                          onPressed: controller.toggleTimer,
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

class CustomTimerPainter extends CustomPainter {
  final double progress;
  final bool isRunning;
  final bool isSettingTime;
  final Animation<double> spinAnimation;
  final double setupRotation;

  CustomTimerPainter({
    required this.progress,
    required this.isRunning,
    required this.isSettingTime,
    required this.spinAnimation,
    required this.setupRotation,
  }) : super(repaint: spinAnimation);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final rotationAngle =
        isRunning ? -spinAnimation.value * 2 * math.pi : setupRotation;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotationAngle);
    canvas.translate(-center.dx, -center.dy);

    // Only draw progress arc if setting time or running
    if (isSettingTime || isRunning) {
      final progressPaint = Paint()
        ..color = isRunning ? Colors.red : Colors.red[400]!
        ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - 15),
        -math.pi / 2,
        2 * math.pi * progress,
        true,
        progressPaint,
      );
    }

    // Draw numbers
    for (var i = 0; i < 12; i++) {
      final angle = i * (2 * math.pi / 12) - math.pi / 2;
      final number = (i * 5).toString();
      final textPainter = TextPainter(
        text: TextSpan(
          text: number,
          style: TextStyle(
            color:
                (isSettingTime || isRunning) && _isOverProgress(angle, progress)
                    ? Colors.white
                    : Colors.black87,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();

      final numberRadius = radius - 35;
      final x =
          center.dx + numberRadius * math.cos(angle) - textPainter.width / 2;
      final y =
          center.dy + numberRadius * math.sin(angle) - textPainter.height / 2;

      textPainter.paint(canvas, Offset(x, y));
    }

    canvas.restore();

    // Draw center circle
    final centerDotPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 15, centerDotPaint);
  }

  bool _isOverProgress(double angle, double progress) {
    final normalizedAngle = (angle + math.pi / 2) / (2 * math.pi);
    return normalizedAngle <= progress;
  }

  @override
  bool shouldRepaint(CustomTimerPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.isRunning != isRunning ||
        oldDelegate.isSettingTime != isSettingTime ||
        oldDelegate.spinAnimation.value != spinAnimation.value ||
        oldDelegate.setupRotation != setupRotation;
  }
}

class TimerController extends GetxController {
  int selectedMinutes = 0;
  bool isRunning = false;
  double progress = 0.0;
  int remainingSeconds = 0;
  late AnimationController spinAnimationController;
  double setupRotation = 0.0;
  bool isSettingTime = false;

  TimerController({required AnimationController spinAnimationController}) {
    this.spinAnimationController = spinAnimationController;
  }

  void onPanStart(DragStartDetails details) {
    if (!isRunning) {
      isSettingTime = true;
      update();
    }
  }

  void onPanEnd(DragEndDetails details) {
    if (!isRunning) {
      isSettingTime = false;
      update();
    }
  }

  void onPanUpdate(DragUpdateDetails details) {
    if (isRunning) return;

    final box = Get.context!.findRenderObject() as RenderBox;
    final center = Offset(box.size.width / 2, box.size.height / 2);
    final touchPoint = details.localPosition;

    // Calculate angle from center to touch point
    final angle = math.atan2(
      touchPoint.dy - center.dy,
      touchPoint.dx - center.dx,
    );

    // Convert angle to progress (0 to 1), reversed for counter-clockwise
    double newProgress = 1.0 - ((angle + math.pi) / (2 * math.pi));
    // Adjust for starting from top (+ 0.25 for counter-clockwise)
    newProgress = (newProgress + 0.25) % 1.0;

    // Update rotation for setup animation (negative for counter-clockwise)
    setupRotation = -newProgress * 2 * math.pi;

    // Calculate minutes (0 to 60)
    selectedMinutes = (newProgress * 60).round();
    if (selectedMinutes == 0 && newProgress > 0.99) {
      selectedMinutes = 60;
    }

    remainingSeconds = selectedMinutes * 60;
    progress = newProgress;

    update();
  }

  void startTimer() {
    if (remainingSeconds > 0) {
      isRunning = true;
      spinAnimationController.repeat();
      Timer.periodic(const Duration(seconds: 1), (timer) {
        if (remainingSeconds > 0 && isRunning) {
          remainingSeconds--;
          progress = 1 - (remainingSeconds / (selectedMinutes * 60));
          update();
        } else {
          timer.cancel();
          isRunning = false;
          spinAnimationController.stop();
          spinAnimationController.reset();
          update();
        }
      });
    }
  }

  void toggleTimer() {
    if (isRunning) {
      isRunning = false;
      spinAnimationController.stop();
    } else {
      startTimer();
    }
    update();
  }
}
