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

// The demo screen: the ring plus a slider for tasks done
class SprintProgressScreen extends StatefulWidget {
  const SprintProgressScreen({super.key});

  @override
  State<SprintProgressScreen> createState() => _SprintProgressScreenState();
}

class _SprintProgressScreenState extends State<SprintProgressScreen> {
  // The sprint data the ring shows
  int tasksDone = 7;
  final int totalTasks = 10;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sprint Progress')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 24),
            // Same ring as before, now fed by state
            CustomPaint(
              painter: TaskRingPainter(done: tasksDone, total: totalTasks),
              size: const Size(220, 220),
            ),
            const SizedBox(height: 24),
            Text('$tasksDone of $totalTasks tasks done'),
            // Dragging updates tasksDone, which redraws the ring
            Slider(
              value: tasksDone.toDouble(),
              min: 0,
              max: totalTasks.toDouble(),
              divisions: totalTasks,
              label: '$tasksDone',
              onChanged: (value) {
                setState(() => tasksDone = value.round());
              },
            ),
          ],
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