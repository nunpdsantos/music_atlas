import 'package:flutter/material.dart';
import '../../core/theme.dart';

class AccidentalButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const AccidentalButton({
    super.key,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);
    final borderColor = AppTheme.getBorderColor(context);

    // Colors based on active state and theme
    final Color backgroundColor;
    final Color textColor;
    final Color borderCol;

    if (isActive) {
      backgroundColor = AppTheme.getMajorLight(context);
      textColor = AppTheme.tonicBlue;
      borderCol = AppTheme.tonicBlue.withOpacity(0.3);
    } else {
      backgroundColor = isDark
          ? const Color(0xFF334155)
          : Colors.white;
      textColor = isDark
          ? const Color(0xFF94A3B8)
          : AppTheme.textSecondary;
      borderCol = borderColor;
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppTheme.durationFast,
        curve: AppTheme.curveEaseOut,
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(color: borderCol, width: isActive ? 1.5 : 1),
          boxShadow: isActive ? AppTheme.shadowGlow(AppTheme.tonicBlue) : AppTheme.getShadow(context, size: 'sm'),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }
}
