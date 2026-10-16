import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../core/l10n/locale_scope.dart';
import '../core/theme/app_colors.dart';
import '../data/models/openf1_models.dart';

class F1Card extends StatelessWidget {
  const F1Card({
    super.key,
    required this.child,
    this.padding,
    this.color,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color ?? Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark ? AppColors.lineDark : AppColors.line,
        ),
      ),
      child: child,
    );
  }
}

class Eyebrow extends StatelessWidget {
  const Eyebrow(this.text, {super.key, this.color});

  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
            letterSpacing: 1.1,
            fontWeight: FontWeight.w700,
            color: color ?? AppColors.muted,
          ),
    );
  }
}

class DriverAvatar extends StatelessWidget {
  const DriverAvatar({
    super.key,
    required this.driver,
    this.size = 36,
  });

  final Driver driver;
  final double size;

  @override
  Widget build(BuildContext context) {
    final color = Color(driver.teamColorValue);
    final url = driver.headshotUrl?.trim();
    final image = (url == null || url.isEmpty) ? null : NetworkImage(url);
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: color.withValues(alpha: 0.18),
      foregroundImage: image,
      onForegroundImageError: image == null ? null : (_, _) {},
      child: Text(
        driver.nameAcronym.isEmpty ? '?' : driver.nameAcronym.substring(0, 1),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w800,
          fontSize: size * 0.34,
        ),
      ),
    );
  }
}

class TeamFlagBar extends StatelessWidget {
  const TeamFlagBar({super.key, required this.color, this.height = 22});

  final Color color;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 4,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(99),
      ),
    );
  }
}

class ProbabilityBar extends StatelessWidget {
  const ProbabilityBar({
    super.key,
    required this.value,
    required this.color,
    this.height = 8,
  });

  final double value;
  final Color color;
  final double height;

  @override
  Widget build(BuildContext context) {
    final track = Theme.of(context).brightness == Brightness.dark
        ? AppColors.lineDark
        : const Color(0xFFEEF0F4);
    final width = value.isNaN ? 0.0 : value.clamp(0.0, 1.0);
    return ClipRRect(
      borderRadius: BorderRadius.circular(99),
      child: SizedBox(
        height: height,
        child: Stack(
          children: [
            Container(color: track),
            FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: width,
              child: Container(color: color),
            ),
          ],
        ),
      ),
    );
  }
}

class TyreChip extends StatelessWidget {
  const TyreChip(this.compound, {super.key});

  final String compound;

  @override
  Widget build(BuildContext context) {
    final upper = compound.toUpperCase();
    final isSoft = upper == 'SOFT';
    final isMed = upper == 'MEDIUM';
    final isInter = upper == 'INTERMEDIATE';
    final isWet = upper == 'WET';
    final color = isSoft
        ? AppColors.soft
        : isMed
            ? AppColors.medium
            : isInter
                ? AppColors.inter
                : isWet
                    ? AppColors.wet
                    : AppColors.hard;
    final letter = upper.isEmpty ? '?' : upper[0];
    return Container(
      width: 22,
      height: 22,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 2),
      ),
      child: Text(
        letter,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: isMed ? const Color(0xFF8A6A00) : color,
        ),
      ),
    );
  }
}

class LocaleToggle extends StatelessWidget {
  const LocaleToggle({super.key, this.dark = false});

  final bool dark;

  @override
  Widget build(BuildContext context) {
    final notifier = LocaleScope.of(context);
    final isRu = notifier.value.languageCode == 'ru';
    final active = dark ? Colors.white : AppColors.text;
    final idle = dark ? Colors.white54 : AppColors.muted;

    Widget chip(String label, bool selected, VoidCallback onTap) {
      return GestureDetector(
        onTap: onTap,
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 12,
            color: selected ? active : idle,
          ),
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        chip('EN', !isRu, () => notifier.value = const Locale('en')),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Text('/', style: TextStyle(color: idle, fontSize: 12)),
        ),
        chip('RU', isRu, () => notifier.value = const Locale('ru')),
      ],
    );
  }
}

String formatLap(double? seconds) {
  if (seconds == null) return '—';
  final m = seconds ~/ 60;
  final s = seconds - m * 60;
  return '$m:${s.toStringAsFixed(3).padLeft(6, '0')}';
}

String formatGap(double? gap) {
  if (gap == null || gap == 0) return '0.00';
  return '+${gap.toStringAsFixed(3)}';
}

String formatMeetingWhen(DateTime start, {required bool isRu}) {
  final locale = isRu ? 'ru' : 'en';
  return DateFormat('d MMM yyyy, HH:mm', locale).format(start.toLocal());
}

String formatMeetingRange(DateTime start, DateTime end, {required bool isRu}) {
  final locale = isRu ? 'ru' : 'en';
  final sameDay = start.toLocal().year == end.toLocal().year &&
      start.toLocal().month == end.toLocal().month &&
      start.toLocal().day == end.toLocal().day;
  if (sameDay) return DateFormat('d MMM yyyy', locale).format(start.toLocal());
  final left = DateFormat('d MMM', locale).format(start.toLocal());
  final right = DateFormat('d MMM yyyy', locale).format(end.toLocal());
  return '$left – $right';
}

String formatClock(DateTime time, {required bool isRu}) {
  final locale = isRu ? 'ru' : 'en';
  return DateFormat('d MMM, HH:mm', locale).format(time.toLocal());
}

String formatCountdown(Duration d, {required bool isRu}) {
  if (d.isNegative) return isRu ? 'сейчас' : 'now';
  final days = d.inDays;
  final hours = d.inHours % 24;
  final mins = d.inMinutes % 60;
  final secs = d.inSeconds % 60;
  if (days > 0) return isRu ? '$days д $hours ч' : '${days}d ${hours}h';
  if (hours > 0) return isRu ? '$hours ч $mins мин' : '${hours}h ${mins}m';
  return isRu ? '$mins мин $secs с' : '${mins}m ${secs}s';
}

String percent(double value) => '${(value * 100).toStringAsFixed(1)}%';
