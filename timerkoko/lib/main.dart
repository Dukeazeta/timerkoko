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
                          ),
                          size: const Size(300, 300),
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
                        IconButton(
                          icon: Icon(
                            controller.isRunning ? Icons.pause : Icons.play_arrow,
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

  CustomTimerPainter({
    required this.progress,
    required this.isRunning,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw progress arc
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

    // Draw minute markers
    final markerPaint = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    for (var i = 0; i < 60; i++) {
      final angle = i * (2 * math.pi / 60) - math.pi / 2;
      final markerLength = i % 5 == 0 ? 20.0 : 10.0;
      final markerStart = radius - markerLength;
      final markerEnd = radius;
      
      final startX = center.dx + markerStart * math.cos(angle);
      final startY = center.dy + markerStart * math.sin(angle);
      final endX = center.dx + markerEnd * math.cos(angle);
      final endY = center.dy + markerEnd * math.sin(angle);
      
      // Use white color for markers over the red progress area
      final markerAngle = (angle + math.pi / 2) / (2 * math.pi);
      final isOverProgress = markerAngle <= progress;
      markerPaint.color = isOverProgress ? Colors.white : Colors.black87;
      
      canvas.drawLine(
        Offset(startX, startY),
        Offset(endX, endY),
        markerPaint..strokeWidth = i % 5 == 0 ? 3.0 : 2.5,
      );

      // Draw minute numbers
      if (i % 5 == 0) {
        final number = (i / 5).toInt();
        final textPainter = TextPainter(
          text: TextSpan(
            text: number.toString(),
            style: TextStyle(
              color: isOverProgress ? Colors.white : Colors.black87,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();
        
        final numberRadius = radius - 45;
        final x = center.dx + numberRadius * math.cos(angle) - textPainter.width / 2;
        final y = center.dy + numberRadius * math.sin(angle) - textPainter.height / 2;
        
        textPainter.paint(canvas, Offset(x, y));
      }
    }

    // Draw center circle
    final centerDotPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 15, centerDotPaint);
  }

  @override
  bool shouldRepaint(CustomTimerPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.isRunning != isRunning;
  }
}

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
