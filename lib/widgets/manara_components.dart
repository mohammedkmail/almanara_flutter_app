import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class ManaraSectionTitle extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;

  const ManaraSectionTitle({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              if (subtitle != null && subtitle!.trim().isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle!,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: AppTheme.muted),
                ),
              ],
            ],
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class ManaraImage extends StatelessWidget {
  final String? url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius borderRadius;
  final IconData fallbackIcon;

  const ManaraImage({
    super.key,
    this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
    this.fallbackIcon = Icons.auto_stories_rounded,
  });

  @override
  Widget build(BuildContext context) {
    Widget fallback() => Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [Color(0xFFE7EEE9), Color(0xFFD9E5DF)],
        ),
      ),
      alignment: Alignment.center,
      child: Icon(fallbackIcon, size: 42, color: AppTheme.teal),
    );

    if (url == null || url!.trim().isEmpty) return fallback();
    return ClipRRect(
      borderRadius: borderRadius,
      child: Image.network(
        url!,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, __, ___) => fallback(),
      ),
    );
  }
}

class ManaraDecorativeImageSlot extends StatelessWidget {
  final double height;
  final BorderRadius borderRadius;
  final IconData icon;

  const ManaraDecorativeImageSlot({
    super.key,
    required this.height,
    this.borderRadius = const BorderRadius.all(Radius.circular(20)),
    this.icon = Icons.local_library_outlined,
  });

  @override
  Widget build(BuildContext context) {
    // Decorative image placeholder. Replace this widget later with Image.asset
    // after the final project photography is selected.
    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        color: const Color(0xFF184A45),
      ),
      child: Stack(
        children: [
          Positioned(
            left: -25,
            top: -30,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: .04),
              ),
            ),
          ),
          Center(
            child: Icon(
              icon,
              size: 54,
              color: Colors.white.withValues(alpha: .16),
            ),
          ),
        ],
      ),
    );
  }
}

class ManaraStatusChip extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;

  const ManaraStatusChip({
    super.key,
    required this.label,
    required this.color,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .11),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 5),
          ],
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class ManaraMetric extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color tone;

  const ManaraMetric({
    super.key,
    required this.value,
    required this.label,
    required this.icon,
    this.tone = AppTheme.teal,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: tone, size: 23),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.w900,
              color: AppTheme.ink,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 10.5, color: AppTheme.muted),
          ),
        ],
      ),
    );
  }
}

class ManaraEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final Widget? action;

  const ManaraEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 18),
      child: Column(
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: const BoxDecoration(
              color: Color(0xFFE7F1EE),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppTheme.teal, size: 29),
          ),
          const SizedBox(height: 14),
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          if (action != null) ...[const SizedBox(height: 16), action!],
        ],
      ),
    );
  }
}

String formatDate(DateTime? value, {bool time = false}) {
  if (value == null) return '—';
  final d = value.toLocal();
  final date =
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  if (!time) return date;
  final hour = d.hour.toString().padLeft(2, '0');
  final minute = d.minute.toString().padLeft(2, '0');
  return '$date • $hour:$minute';
}
