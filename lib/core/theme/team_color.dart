import 'package:flutter/material.dart';

import '../../data/json_parse.dart';

Color parseTeamColor(String? value) {
  return Color(parseTeamColorValue(value, fallback: 0xFFE10600));
}
