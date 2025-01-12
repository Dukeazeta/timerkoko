import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'dart:math' as math;
import 'package:url_launcher/url_launcher.dart';
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
      darkTheme: ThemeData(
        textTheme: GoogleFonts.spaceGroteskTextTheme(),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.red,
          brightness: Brightness.dark,
        ),
      ),
      themeMode: ThemeMode.system,
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
  bool isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _spinAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 60),
    );
  }

  void _openSettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.grey[900] : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Settings',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.close,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: Icon(
                isDarkMode ? Icons.dark_mode : Icons.light_mode,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
              title: Text(
                'Dark Mode',
                style: GoogleFonts.spaceGrotesk(
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              trailing: Switch(
                value: isDarkMode,
                onChanged: (value) {
                  setState(() {
                    isDarkMode = value;
                  });
                  Navigator.pop(context);
                },
              ),
            ),
            ListTile(
              leading: const Icon(Icons.code),
              title: Text(
                'Source Code',
                style: GoogleFonts.spaceGrotesk(),
              ),
              onTap: () {
                launchUrl(Uri.parse(
                    'https://github.com/yourusername/timerkoko'));
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDarkMode ? Colors.grey[900] : Colors.grey[50],
      body: GetBuilder<TimerController>(
        init: TimerController(spinAnimationController: _spinAnimationController),
        builder: (controller) {
          return SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: _openSettings,
                    child: Column(
                      children: [
                        Text(
                          '${controller.selectedMinutes}',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 96,
                            fontWeight: FontWeight.w700,
                            color: isDarkMode ? Colors.white : Colors.black87,
                          ),
                        ),
                        Text(
                          'MIN',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 2,
                            color: isDarkMode ? Colors.white : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'SETUP TIME',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1,
                      color: isDarkMode ? Colors.white54 : Colors.black38,
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
                            isDarkMode: isDarkMode,
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
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                          style: IconButton.styleFrom(
                            backgroundColor: isDarkMode ? Colors.grey[800] : Colors.black,
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
  final bool isDarkMode;

  CustomTimerPainter({
    required this.progress,
    required this.isRunning,
    required this.isSettingTime,
    required this.spinAnimation,
    required this.setupRotation,
    required this.isDarkMode,
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

    // Draw minute marks
    final minuteMarkPaint = Paint()
      ..color = isDarkMode ? Colors.white12 : Colors.black12
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (var i = 0; i < 60; i++) {
      final angle = i * (2 * math.pi / 60) - math.pi / 2;
      final outerRadius = radius - 15;
      final innerRadius = radius - 25;
      
      final startX = center.dx + innerRadius * math.cos(angle);
      final startY = center.dy + innerRadius * math.sin(angle);
      final endX = center.dx + outerRadius * math.cos(angle);
      final endY = center.dy + outerRadius * math.sin(angle);
      
      final isOverProgress = (isSettingTime || isRunning) && 
          _isOverProgress(angle, progress);
      minuteMarkPaint.color = isOverProgress ? Colors.white54 : 
          (isDarkMode ? Colors.white12 : Colors.black12);
      
      canvas.drawLine(
        Offset(startX, startY),
        Offset(endX, endY),
        minuteMarkPaint,
      );
    }

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
            color: (isSettingTime || isRunning) && _isOverProgress(angle, progress)
                ? Colors.white
                : (isDarkMode ? Colors.white70 : Colors.black87),
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
      ..color = isDarkMode ? Colors.white : Colors.black
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
        oldDelegate.setupRotation != setupRotation ||
        oldDelegate.isDarkMode != isDarkMode;
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
