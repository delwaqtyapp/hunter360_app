import 'dart:math' as math;
import 'package:flutter/material.dart';

class GaugeSize {
  final double total;
  final double fontSize;
  final double valueFontSize;
  final double strokeWidth;
  final double needleLength;

  const GaugeSize({required this.total, required this.fontSize, required this.valueFontSize, required this.strokeWidth, required this.needleLength});

  static const small = GaugeSize(total: 80, fontSize: 8, valueFontSize: 12, strokeWidth: 6, needleLength: 28);
  static const medium = GaugeSize(total: 120, fontSize: 10, valueFontSize: 18, strokeWidth: 8, needleLength: 42);
  static const large = GaugeSize(total: 160, fontSize: 12, valueFontSize: 24, strokeWidth: 10, needleLength: 56);

  static GaugeSize fromString(String size) {
    switch (size) {
      case 'small':
        return small;
      case 'large':
        return large;
      default:
        return medium;
    }
  }
}

class GaugeWidget extends StatefulWidget {
  final double value;
  final double minValue;
  final double maxValue;
  final String title;
  final String subtitle;
  final String unit;
  final GaugeSize size;
  final Color? alarmHigh;
  final Color? alarmLow;
  final Color normalColor;

  const GaugeWidget({
    super.key,
    required this.value,
    this.minValue = 0,
    this.maxValue = 100,
    this.title = '',
    this.subtitle = '',
    this.unit = '',
    this.size = GaugeSize.medium,
    this.alarmHigh,
    this.alarmLow,
    this.normalColor = const Color(0xFF4CAF50),
  });

  @override
  State<GaugeWidget> createState() => _GaugeWidgetState();
}

class _GaugeWidgetState extends State<GaugeWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _prevValue = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _animation = Tween<double>(begin: 0, end: _normalizedValue).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(GaugeWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _prevValue = _animation.value;
      _animation = Tween<double>(begin: _prevValue, end: _normalizedValue).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
      );
      _controller
        ..reset()
        ..forward();
    }
  }

  double get _normalizedValue {
    final range = widget.maxValue - widget.minValue;
    if (range <= 0) return 0;
    return ((widget.value - widget.minValue) / range).clamp(0.0, 1.0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.size;
    return SizedBox(
      width: s.total,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.title.isNotEmpty) ...[
            Text(widget.title, style: TextStyle(fontSize: s.fontSize, fontWeight: FontWeight.w600, color: Colors.white70), maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 2),
          ],
          AnimatedBuilder(
            animation: _animation,
            builder: (context, _) {
              return CustomPaint(
                size: Size(s.total, s.total * 0.65),
                painter: _GaugePainter(
                  value: _animation.value,
                  strokeWidth: s.strokeWidth,
                  needleLength: s.needleLength,
                ),
              );
            },
          ),
          const SizedBox(height: 2),
          Text(
            '${widget.value.toStringAsFixed(1)} ${widget.unit}',
            style: TextStyle(fontSize: s.valueFontSize, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          if (widget.subtitle.isNotEmpty)
            Text(widget.subtitle, style: TextStyle(fontSize: s.fontSize - 1, color: Colors.white54)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${widget.minValue.toStringAsFixed(0)} ${widget.unit}', style: TextStyle(fontSize: s.fontSize - 2, color: Colors.white38)),
              Text('${widget.maxValue.toStringAsFixed(0)} ${widget.unit}', style: TextStyle(fontSize: s.fontSize - 2, color: Colors.white38)),
            ],
          ),
        ],
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  final double value;
  final double strokeWidth;
  final double needleLength;

  _GaugePainter({required this.value, required this.strokeWidth, required this.needleLength});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.85);
    final radius = (size.width / 2) - strokeWidth;

    final startAngle = math.pi * 0.8;
    final sweepAngle = math.pi * 1.4;

    final bgPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..color = Colors.white12;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), startAngle, sweepAngle, false, bgPaint);

    final segments = 120;
    for (int i = 0; i < segments; i++) {
      final t = i / segments;
      if (t > value) break;
      final segSweep = sweepAngle / segments;
      final segStart = startAngle + t * sweepAngle;
      final color = _interpolateColor(t);
      final segPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..color = color;
      canvas.drawArc(Rect.fromCircle(center: center, radius: radius), segStart, segSweep * 0.9, false, segPaint);
    }

    final needleAngle = startAngle + value * sweepAngle;
    final needleEnd = Offset(
      center.dx + needleLength * math.cos(needleAngle),
      center.dy + needleLength * math.sin(needleAngle),
    );

    final needlePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(center, needleEnd, needlePaint);

    final dotPaint = Paint()..color = Colors.white;
    canvas.drawCircle(center, 4, dotPaint);
    final innerDot = Paint()..color = const Color(0xFF156082);
    canvas.drawCircle(center, 2, innerDot);
  }

  Color _interpolateColor(double t) {
    if (t < 0.5) {
      return Color.lerp(const Color(0xFF4CAF50), const Color(0xFFFFC107), t * 2)!;
    } else {
      return Color.lerp(const Color(0xFFFFC107), const Color(0xFFF44336), (t - 0.5) * 2)!;
    }
  }

  @override
  bool shouldRepaint(_GaugePainter oldDelegate) => oldDelegate.value != value;
}
