int? asInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString());
}

double? asDouble(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
}

double? asGapSeconds(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString().trim().replaceAll('+', ''));
}

String? asGapLabel(dynamic value) {
  if (value == null) return null;
  if (value is num) {
    if (value == 0) return 'LEADER';
    return '+${value.toDouble().toStringAsFixed(3)}';
  }
  final text = value.toString().trim();
  if (text.isEmpty) return null;
  final parsed = double.tryParse(text.replaceAll('+', ''));
  if (parsed != null) return parsed == 0 ? 'LEADER' : '+${parsed.toStringAsFixed(3)}';
  return text;
}

String? asString(dynamic value) {
  if (value == null) return null;
  return value.toString();
}

bool asBool(dynamic value, {bool fallback = false}) {
  if (value is bool) return value;
  return fallback;
}

DateTime? asDate(dynamic value) {
  if (value == null) return null;
  return DateTime.tryParse(value.toString());
}

int parseTeamColorValue(String? hex, {int fallback = 0xFFE10600}) {
  if (hex == null || hex.isEmpty) return fallback;
  final clean = hex.replaceAll('#', '').trim();
  if (clean.length != 6) return fallback;
  return int.tryParse('FF$clean', radix: 16) ?? fallback;
}
