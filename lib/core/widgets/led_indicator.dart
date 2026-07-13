import 'package:flutter/material.dart';

enum LedColor { green, red, orange, gray }

class LedIndicator extends StatefulWidget {
  final bool isOn;
  final LedColor activeColor;
  final double size;
  final String label;
  final bool animate;

  const LedIndicator({
    super.key,
    this.isOn = false,
    this.activeColor = LedColor.green,
    this.size = 14,
    this.label = '',
    this.animate = true,
  });

  @override
  State<LedIndicator> createState() => _LedIndicatorState();
}

class _LedIndicatorState extends State<LedIndicator> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _pulseAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    if (widget.isOn && widget.animate) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(LedIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isOn && widget.animate && !_pulseController.isAnimating) {
      _pulseController.repeat(reverse: true);
    } else if (!widget.isOn && _pulseController.isAnimating) {
      _pulseController.stop();
      _pulseController.value = 0;
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Color get _ledColor {
    if (!widget.isOn) return Colors.grey.shade700;
    switch (widget.activeColor) {
      case LedColor.green:
        return const Color(0xFF00E676);
      case LedColor.red:
        return const Color(0xFFFF1744);
      case LedColor.orange:
        return const Color(0xFFFF9100);
      case LedColor.gray:
        return Colors.grey.shade600;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            final glowOpacity = widget.isOn && widget.animate ? _pulseAnimation.value * 0.6 : 0.0;
            final scale = widget.isOn && widget.animate ? 0.95 + _pulseAnimation.value * 0.05 : 1.0;
            return Transform.scale(
              scale: scale,
              child: Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: _ledColor.withOpacity(glowOpacity),
                      blurRadius: widget.size * 0.6,
                      spreadRadius: widget.size * 0.15,
                    ),
                  ],
                ),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: widget.isOn
                        ? RadialGradient(
                            colors: [
                              _ledColor.withOpacity(1.0),
                              _ledColor.withOpacity(0.7),
                              _ledColor.withOpacity(0.3),
                            ],
                            stops: const [0.2, 0.6, 1.0],
                          )
                        : null,
                    color: widget.isOn ? null : Colors.grey.shade800,
                    border: Border.all(
                      color: widget.isOn ? _ledColor.withOpacity(0.5) : Colors.grey.shade700,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        if (widget.label.isNotEmpty) ...[
          const SizedBox(height: 3),
          Text(
            widget.label,
            style: TextStyle(fontSize: widget.size * 0.55, color: Colors.white70, fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }
}

class LedRow extends StatelessWidget {
  final List<LedItem> items;
  final double ledSize;

  const LedRow({super.key, required this.items, this.ledSize = 12});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < items.length; i++) ...[
          if (i > 0) SizedBox(width: ledSize * 0.8),
          LedIndicator(
            isOn: items[i].isOn,
            activeColor: items[i].color,
            size: ledSize,
            label: items[i].label,
            animate: items[i].animate,
          ),
        ],
      ],
    );
  }
}

class LedItem {
  final bool isOn;
  final LedColor color;
  final String label;
  final bool animate;

  const LedItem({required this.isOn, this.color = LedColor.green, this.label = '', this.animate = true});
}
