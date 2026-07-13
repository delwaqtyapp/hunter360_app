import 'dart:math' as math;
import 'package:flutter/material.dart';

class FlowMeterWidget extends StatelessWidget {
  final String label;
  final double value;
  final String unit;
  final String status;
  final List<double> trendData;
  final double? minThreshold;
  final double? maxThreshold;

  const FlowMeterWidget({
    super.key,
    required this.label,
    this.value = 0,
    this.unit = 'L/min',
    this.status = 'Normal',
    this.trendData = const [],
    this.minThreshold,
    this.maxThreshold,
  });

  Color get _statusColor {
    switch (status.toLowerCase()) {
      case 'high':
      case 'alarm':
        return const Color(0xFFF44336);
      case 'low':
      case 'warning':
        return const Color(0xFFFF9800);
      default:
        return const Color(0xFF4CAF50);
    }
  }

  IconData get _trendIcon {
    if (trendData.length < 2) return Icons.remove;
    final recent = trendData.last;
    final prev = trendData[trendData.length - 2];
    if (recent > prev * 1.02) return Icons.trending_up;
    if (recent < prev * 0.98) return Icons.trending_down;
    return Icons.trending_flat;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF0D2137),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _statusColor.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.speed, size: 12, color: _statusColor),
              const SizedBox(width: 4),
              Expanded(
                child: Text(label, style: const TextStyle(fontSize: 10, color: Colors.white60), maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value.toStringAsFixed(1),
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: _statusColor),
              ),
              const SizedBox(width: 3),
              Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Text(unit, style: const TextStyle(fontSize: 10, color: Colors.white54)),
              ),
              const Spacer(),
              Icon(_trendIcon, size: 16, color: _statusColor.withOpacity(0.8)),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: _statusColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(status, style: TextStyle(fontSize: 9, color: _statusColor, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(height: 6),
          if (trendData.isNotEmpty) _Sparkline(data: trendData, color: _statusColor),
        ],
      ),
    );
  }
}

class _Sparkline extends StatelessWidget {
  final List<double> data;
  final Color color;

  const _Sparkline({required this.data, required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 28,
      child: CustomPaint(
        size: const Size(double.infinity, 28),
        painter: _SparklinePainter(data: data, color: color),
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  final List<double> data;
  final Color color;

  _SparklinePainter({required this.data, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.length < 2) return;

    final minVal = data.reduce(math.min);
    final maxVal = data.reduce(math.max);
    final range = (maxVal - minVal);
    final normalized = range > 0
        ? data.map((v) => (v - minVal) / range).toList()
        : data.map((_) => 0.5).toList();

    final path = Path();
    final fillPath = Path();
    final step = size.width / (normalized.length - 1);

    for (int i = 0; i < normalized.length; i++) {
      final x = i * step;
      final y = size.height - (normalized[i] * (size.height - 4)) - 2;
      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }
    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [color.withOpacity(0.2), color.withOpacity(0.0)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawPath(fillPath, fillPaint);

    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(_SparklinePainter oldDelegate) => oldDelegate.data != data;
}
