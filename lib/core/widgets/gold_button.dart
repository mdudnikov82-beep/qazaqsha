import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../motion.dart';

/// The main call to action: gold, with a pressable 3D edge.
class GoldButton extends StatefulWidget {
  const GoldButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon = Icons.arrow_forward_rounded,
  });

  final String label;
  final VoidCallback onPressed;
  final IconData? icon;

  @override
  State<GoldButton> createState() => _GoldButtonState();
}

class _GoldButtonState extends State<GoldButton> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    const edge = 4.0;
    return Semantics(
      button: true,
      onTap: widget.onPressed,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _down = true),
        onTapCancel: () => setState(() => _down = false),
        onTapUp: (_) {
          setState(() => _down = false);
          Haptics.tap();
          widget.onPressed();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 80),
          height: 54,
          margin: EdgeInsets.only(top: _down ? edge : 0),
          decoration: BoxDecoration(
            color: AppColors.gold,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              if (!_down)
                const BoxShadow(
                  color: Color(0xFFC99700),
                  offset: Offset(0, edge),
                ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.label,
                style: const TextStyle(
                  color: AppColors.onGold,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
              if (widget.icon case final icon?) ...[
                const SizedBox(width: 8),
                Icon(icon, color: AppColors.onGold, size: 20),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
