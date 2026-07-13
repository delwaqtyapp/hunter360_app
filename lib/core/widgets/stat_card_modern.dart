import 'package:flutter/material.dart';

class StatCardModern extends StatefulWidget {
  final IconData icon;
  final String value;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback? onTap;
  final bool showPulse;

  const StatCardModern({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    this.subtitle = '',
    this.color = const Color(0xFF4CAF50),
    this.onTap,
    this.showPulse = false,
  });

  @override
  State<StatCardModern> createState() => _StatCardModernState();
}

class _StatCardModernState extends State<StatCardModern> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500));
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    if (widget.showPulse) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(StatCardModern oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.showPulse && !_pulseController.isAnimating) {
      _pulseController.repeat(reverse: true);
    } else if (!widget.showPulse && _pulseController.isAnimating) {
      _pulseController.stop();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              widget.color.withOpacity(0.12),
              widget.color.withOpacity(0.04),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: widget.color.withOpacity(0.2), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: widget.showPulse ? _pulseAnimation.value : 1.0,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: widget.color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(widget.icon, color: widget.color, size: 18),
                  ),
                );
              },
            ),
            const SizedBox(height: 10),
            Text(
              widget.value,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: widget.color),
            ),
            const SizedBox(height: 2),
            Text(widget.label, style: const TextStyle(fontSize: 11, color: Colors.white70, fontWeight: FontWeight.w500)),
            if (widget.subtitle.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(widget.subtitle, style: TextStyle(fontSize: 9, color: widget.color.withOpacity(0.6))),
            ],
          ],
        ),
      ),
    );
  }
}
