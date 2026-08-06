import 'package:flutter/material.dart';
import '../themes/app_theme.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final bool obscureText;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final Function(String)? onChanged;
  final int maxLines;
  final bool isDarkBackground; // برای مواردی که فیلد روی تصویر یا پس‌زمینه تیره است (مثل لاگین)

  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.obscureText = false,
    this.suffixIcon,
    this.validator,
    this.onChanged,
    this.maxLines = 1,
    this.isDarkBackground = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkTheme = theme.brightness == Brightness.dark;
    
    // انتخاب رنگ‌ها بر اساس پس‌زمینه (اگر دستی ست شده باشد) یا تم برنامه
    final Color textColor = (isDarkBackground || isDarkTheme) ? Colors.white : Colors.black87;
    final Color labelColor = (isDarkBackground || isDarkTheme) ? Colors.white70 : theme.hintColor;
    final Color hintColor = (isDarkBackground || isDarkTheme) ? Colors.white.withAlpha(120) : theme.hintColor.withAlpha(150);
    final Color fillColor = (isDarkBackground || isDarkTheme) ? Colors.white.withAlpha(15) : theme.primaryColor.withAlpha(10);
    final Color borderColor = (isDarkBackground || isDarkTheme) ? Colors.white.withAlpha(30) : theme.primaryColor.withAlpha(30);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: AppTheme.spacingSm, bottom: AppTheme.spacingSm),
          child: Text(
            label, 
            style: theme.textTheme.labelMedium?.copyWith(
              color: labelColor,
              fontWeight: FontWeight.w700,
            )
          ),
        ),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          onChanged: onChanged,
          maxLines: maxLines,
          style: TextStyle(color: textColor, fontSize: 15, fontWeight: FontWeight.w600),
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: hintColor, fontSize: 14),
            prefixIcon: Icon(icon, color: labelColor, size: 20),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: fillColor,
            contentPadding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingLg, vertical: AppTheme.spacingLg),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              borderSide: BorderSide(color: borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              borderSide: BorderSide(color: theme.primaryColor.withAlpha(150), width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              borderSide: BorderSide(color: theme.colorScheme.error.withAlpha(150)),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              borderSide: BorderSide(color: theme.colorScheme.error),
            ),
          ),
        ),
      ],
    );
  }
}
