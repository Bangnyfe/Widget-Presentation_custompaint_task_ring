import 'dart:math' as math;

import 'package:flutter/material.dart';

void main() => runApp(const TaskRingApp());

class TaskRingApp extends StatelessWidget {
  const TaskRingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CustomPaint Task Ring',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.teal),
      home: const SprintProgressScreen(),
    );
  }
}

//shows the task-completion ring
class SprintProgressScreen extends StatelessWidget {
  const SprintProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sprint Progress')),
      body: Center(
        // CustomPaint gives us a canvas; the painter does the drawing
        child: CustomPaint(
          painter: TaskRingPainter(done: 7, total: 10),
          size: const Size(220, 220),
        ),
      ),
    );
  }
}

// Draws a grey track circle and a coloured arc for completed tasks
class TaskRingPainter extends CustomPainter {
  TaskRingPainter({required this.done, required this.total});

  final int done;
  final int total;

  @override
  void paint(Canvas canvas, Size size) {
    const strokeWidth = 18.0;
    final center = size.center(Offset.zero);
    // Shrink the radius so the thick stroke stays inside the canvas
    final radius = (size.shortestSide - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final trackPaint = Paint()
      ..color = Colors.grey.shade300
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final progressPaint = Paint()
      ..color = Colors.teal
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Full grey circle = all tasks
    canvas.drawCircle(center, radius, trackPaint);

    // Turn the fraction of tasks done into an angle (radians)
    final fraction = total == 0 ? 0.0 : done / total;
    final sweep = 2 * math.pi * fraction;

    // Start from the top or North, then move the completion clock wise
    canvas.drawArc(rect, -math.pi / 2, sweep, false, progressPaint);
  }

  // Only repaint when the numbers actually change
  @override
  bool shouldRepaint(covariant TaskRingPainter oldDelegate) =>
      oldDelegate.done != done || oldDelegate.total != total;
}