import 'package:flutter/material.dart';

import '../../core/l10n/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/ui_kit.dart';
import '../bloc/app_context_cubit.dart';

class WeatherStrip extends StatelessWidget {
  const WeatherStrip({
    super.key,
    required this.store,
    required this.strings,
  });

  final AppContextState store;
  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    final weather = store.weather;
    if (weather == null) return const SizedBox.shrink();
    return F1Card(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Eyebrow(strings.weather, color: AppColors.red),
          const SizedBox(height: 8),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              _metric(strings.weatherAir, weather.airTemperature == null ? '—' : '${weather.airTemperature!.toStringAsFixed(0)}°C'),
              _metric(strings.trackTemp, weather.trackTemperature == null ? '—' : '${weather.trackTemperature!.toStringAsFixed(0)}°C'),
              _metric(strings.humidity, weather.humidity == null ? '—' : '${weather.humidity!.toStringAsFixed(0)}%'),
              _metric(strings.wind, weather.windSpeed == null ? '—' : '${weather.windSpeed!.toStringAsFixed(0)} km/h'),
              _metric(strings.rainfall, weather.isWet ? strings.rain : '—'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _metric(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: const TextStyle(fontSize: 10, letterSpacing: 0.8, color: AppColors.mutedDark, fontWeight: FontWeight.w700)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w800)),
      ],
    );
  }
}
