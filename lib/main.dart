import 'dart:math' as math;

import 'package:flutter/material.dart';

void main() => runApp(const TaskRingApp());

// App root: theme and home screen
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
  int tasksDone = 7;
  final int totalTasks = 10;

  // Property 1: painter (on = ring painter, off = null)
  bool usePainter = true;
  // Property 2: size (Size.zero is the default)
  double ringSize = 220;
  // Property 3: child (null is the default)
  bool showLabel = false;

  @override
  Widget build(BuildContext context) {
    // Percentage shown in the centre label
    final percent = (tasksDone * 100 / totalTasks).round();
    return Scaffold(
      appBar: AppBar(title: const Text('Sprint Progress')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Center(
            child: CustomPaint(
              painter: usePainter
                  ? TaskRingPainter(done: tasksDone, total: totalTasks)
                  : null,
              size: Size(ringSize, ringSize),
              // The label is drawn on top of the painter
              child: showLabel
                  ? SizedBox(
                      // Same size as the ring, so CustomPaint keeps its size
                      width: ringSize,
                      height: ringSize,
                      child: Padding(
                        padding: const EdgeInsets.all(30),
                        // Shrinks the text if the ring gets small
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '$percent%',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium,
                              ),
                              Text('$tasksDone/$totalTasks done'),
                            ],
                          ),
                        ),
                      ),
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 24),
          Center(child: Text('$tasksDone of $totalTasks tasks done')),
          // Dragging updates tasksDone which redraws the ring
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
          const Divider(),

          // Property 1 control: shows the current painter value
          SwitchListTile(
            title: const Text('painter'),
            subtitle: Text(usePainter ? 'TaskRingPainter' : 'null (default)'),
            value: usePainter,
            onChanged: (value) => setState(() => usePainter = value),
          ),

          // Property 2 control: the size CustomPaint aims for
          ListTile(
            title: const Text('size'),
            subtitle: Text(
              ringSize == 0
                  ? 'Size.zero (default)'
                  : 'Size(${ringSize.round()}, ${ringSize.round()})',
            ),
          ),
          Slider(
            value: ringSize,
            min: 0,
            max: 280,
            divisions: 14,
            label: '${ringSize.round()}',
            onChanged: (value) => setState(() => ringSize = value),
          ),

          // Property 3 control: a label widget inside the ring
          SwitchListTile(
            title: const Text('child'),
            subtitle: Text(
              showLabel ? 'Label in the centre' : 'null (default)',
            ),
            value: showLabel,
            onChanged: (value) => setState(() => showLabel = value),
          ),
        ],
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
    // Canvas too small for the stroke: nothing to draw
    if (radius <= 0) return;
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

    // Start from the top or North, then move the completion clockwise
    canvas.drawArc(rect, -math.pi / 2, sweep, false, progressPaint);
  }

  // Only repaint when the numbers actually change
  @override
  bool shouldRepaint(covariant TaskRingPainter oldDelegate) =>
      oldDelegate.done != done || oldDelegate.total != total;
}
