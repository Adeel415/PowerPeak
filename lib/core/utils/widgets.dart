import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class PPCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;

  const PPCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.cardBorder, width: 1),
        ),
        padding: padding ?? const EdgeInsets.all(16),
        child: child,
      ),
    );
  }
}

class PPSectionTitle extends StatelessWidget {
  final String title;
  final String? subtitle;

  const PPSectionTitle({super.key, required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.headlineSmall),
        if (subtitle != null)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(subtitle!,
                style: Theme.of(context).textTheme.bodyMedium),
          ),
      ],
    );
  }
}

class PPStatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;

  const PPStatChip({
    super.key,
    required this.label,
    required this.value,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: (color ?? AppTheme.accent).withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: (color ?? AppTheme.accent).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: TextStyle(
              color: color ?? AppTheme.accent,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(
                  color: AppTheme.textSecondary, fontSize: 11)),
        ],
      ),
    );
  }
}

class PPProgressBar extends StatelessWidget {
  final double value; // 0.0 to 1.0
  final String label;
  final String trailing;
  final Color? color;

  const PPProgressBar({
    super.key,
    required this.value,
    required this.label,
    required this.trailing,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final clampedValue = value.clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: Theme.of(context).textTheme.bodyMedium),
            Text(trailing, style: Theme.of(context).textTheme.labelLarge),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: clampedValue,
            minHeight: 10,
            backgroundColor: AppTheme.surfaceLight,
            color: color ?? AppTheme.accent,
          ),
        ),
      ],
    );
  }
}

class PPDropdown<T> extends StatelessWidget {
  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  final String label;

  const PPDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      value: value,
      items: items,
      onChanged: onChanged,
      decoration: InputDecoration(labelText: label),
      dropdownColor: AppTheme.surfaceLight,
      style: const TextStyle(color: AppTheme.textPrimary),
    );
  }
}

class PPIconButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const PPIconButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: (color ?? AppTheme.primary).withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: (color ?? AppTheme.primary).withOpacity(0.5)),
            ),
            child: Icon(icon, color: color ?? AppTheme.accent, size: 26),
          ),
          const SizedBox(height: 6),
          Text(label,
              style: const TextStyle(
                  color: AppTheme.textSecondary, fontSize: 11)),
        ],
      ),
    );
  }
}