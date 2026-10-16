import 'package:flutter/material.dart';

/// Schematic centerlines used only when OpenF1 location samples are unavailable.
///
/// These are plan-view outlines for identifying the circuit. They are not a
/// coordinate frame for car positions.
class CircuitLayout {
  const CircuitLayout({required this.name, required this.points});

  final String name;
  final List<Offset> points;
}

CircuitLayout? circuitLayoutFor({required String shortName, required String location}) {
  final hay = _norm('$shortName $location');
  if (hay.isEmpty) return null;
  final keys = _layouts.keys.toList()..sort((a, b) => b.length.compareTo(a.length));
  for (final key in keys) {
    if (hay.contains(key)) return _layouts[key];
  }
  return null;
}

String _norm(String value) {
  var text = value.toLowerCase();
  const folded = {
    'á': 'a',
    'à': 'a',
    'ã': 'a',
    'â': 'a',
    'é': 'e',
    'è': 'e',
    'ê': 'e',
    'í': 'i',
    'ó': 'o',
    'ô': 'o',
    'ö': 'o',
    'ú': 'u',
    'ü': 'u',
    'ñ': 'n',
    'ç': 'c',
  };
  folded.forEach((from, to) => text = text.replaceAll(from, to));
  return text.replaceAll(RegExp(r'[^a-z0-9]+'), ' ').trim();
}

List<Offset> _ring(List<double> pairs) {
  final points = <Offset>[];
  for (var i = 0; i + 1 < pairs.length; i += 2) {
    points.add(Offset(pairs[i] / 100, pairs[i + 1] / 100));
  }
  return points;
}

final Map<String, CircuitLayout> _layouts = {
  'melbourne': CircuitLayout(name: 'Albert Park', points: _ring(_melbourne)),
  'albert': CircuitLayout(name: 'Albert Park', points: _ring(_melbourne)),
  'shanghai': CircuitLayout(name: 'Shanghai', points: _ring(_shanghai)),
  'suzuka': CircuitLayout(name: 'Suzuka', points: _ring(_suzuka)),
  'bahrain': CircuitLayout(name: 'Bahrain', points: _ring(_bahrain)),
  'sakhir': CircuitLayout(name: 'Bahrain', points: _ring(_bahrain)),
  'jeddah': CircuitLayout(name: 'Jeddah', points: _ring(_jeddah)),
  'miami': CircuitLayout(name: 'Miami', points: _ring(_miami)),
  'imola': CircuitLayout(name: 'Imola', points: _ring(_imola)),
  'monaco': CircuitLayout(name: 'Monaco', points: _ring(_monaco)),
  'monte carlo': CircuitLayout(name: 'Monaco', points: _ring(_monaco)),
  'catalunya': CircuitLayout(name: 'Catalunya', points: _ring(_catalunya)),
  'barcelona': CircuitLayout(name: 'Catalunya', points: _ring(_catalunya)),
  'villeneuve': CircuitLayout(name: 'Gilles Villeneuve', points: _ring(_montreal)),
  'montreal': CircuitLayout(name: 'Gilles Villeneuve', points: _ring(_montreal)),
  'spielberg': CircuitLayout(name: 'Red Bull Ring', points: _ring(_austria)),
  'red bull': CircuitLayout(name: 'Red Bull Ring', points: _ring(_austria)),
  'silverstone': CircuitLayout(name: 'Silverstone', points: _ring(_silverstone)),
  'hungar': CircuitLayout(name: 'Hungaroring', points: _ring(_hungaroring)),
  'francorchamps': CircuitLayout(name: 'Spa-Francorchamps', points: _ring(_spa)),
  'spa': CircuitLayout(name: 'Spa-Francorchamps', points: _ring(_spa)),
  'zandvoort': CircuitLayout(name: 'Zandvoort', points: _ring(_zandvoort)),
  'monza': CircuitLayout(name: 'Monza', points: _ring(_monza)),
  'baku': CircuitLayout(name: 'Baku', points: _ring(_baku)),
  'marina bay': CircuitLayout(name: 'Marina Bay', points: _ring(_singapore)),
  'singapore': CircuitLayout(name: 'Marina Bay', points: _ring(_singapore)),
  'americas': CircuitLayout(name: 'Circuit of the Americas', points: _ring(_cota)),
  'cota': CircuitLayout(name: 'Circuit of the Americas', points: _ring(_cota)),
  'austin': CircuitLayout(name: 'Circuit of the Americas', points: _ring(_cota)),
  'rodriguez': CircuitLayout(name: 'Mexico City', points: _ring(_mexico)),
  'mexico': CircuitLayout(name: 'Mexico City', points: _ring(_mexico)),
  'interlagos': CircuitLayout(name: 'Interlagos', points: _ring(_interlagos)),
  'paulo': CircuitLayout(name: 'Interlagos', points: _ring(_interlagos)),
  'vegas': CircuitLayout(name: 'Las Vegas', points: _ring(_vegas)),
  'lusail': CircuitLayout(name: 'Lusail', points: _ring(_lusail)),
  'losail': CircuitLayout(name: 'Lusail', points: _ring(_lusail)),
  'qatar': CircuitLayout(name: 'Lusail', points: _ring(_lusail)),
  'yas': CircuitLayout(name: 'Yas Marina', points: _ring(_yas)),
  'abu dhabi': CircuitLayout(name: 'Yas Marina', points: _ring(_yas)),
};

const _melbourne = <double>[
  14, 58, 18, 42, 30, 30, 46, 22, 64, 18, 80, 28, 90, 46, 84, 62, 68, 74, 48, 80, 30, 76, 18, 66, 14, 58,
];
const _shanghai = <double>[
  12, 46, 16, 28, 34, 18, 52, 28, 58, 18, 74, 14, 88, 26, 92, 44, 78, 52, 86, 70, 64, 82, 40, 74, 22, 78, 12, 62, 12, 46,
];
const _suzuka = <double>[
  48, 12, 66, 10, 78, 22, 74, 36, 58, 44, 42, 40, 26, 48, 14, 62, 18, 78, 36, 88, 56, 80, 66, 66, 56, 52, 68, 46, 84, 36, 90, 20, 74, 8, 48, 12,
];
const _bahrain = <double>[
  24, 84, 46, 88, 68, 80, 82, 64, 76, 48, 84, 34, 70, 22, 50, 16, 32, 24, 18, 40, 12, 58, 16, 74, 24, 84,
];
const _jeddah = <double>[
  8, 70, 10, 48, 18, 30, 34, 16, 56, 10, 78, 18, 92, 36, 96, 58, 84, 76, 62, 90, 38, 86, 20, 78, 8, 70,
];
const _miami = <double>[
  20, 78, 48, 84, 76, 72, 90, 52, 86, 32, 64, 16, 40, 18, 22, 34, 12, 54, 20, 78,
];
const _imola = <double>[
  34, 86, 58, 82, 78, 68, 88, 48, 76, 28, 56, 16, 36, 22, 18, 40, 12, 60, 22, 78, 34, 86,
];
const _monaco = <double>[
  22, 78, 14, 62, 12, 44, 24, 30, 40, 18, 58, 14, 74, 22, 88, 38, 92, 54, 76, 66, 58, 78, 40, 86, 22, 78,
];
const _catalunya = <double>[
  16, 70, 22, 48, 14, 30, 32, 16, 56, 12, 78, 22, 92, 40, 86, 58, 70, 74, 46, 82, 24, 78, 16, 70,
];
const _montreal = <double>[
  18, 74, 22, 46, 36, 24, 58, 14, 80, 18, 94, 36, 90, 58, 72, 76, 48, 86, 26, 80, 18, 74,
];
const _austria = <double>[
  18, 78, 40, 86, 70, 78, 92, 58, 84, 34, 62, 16, 38, 14, 18, 32, 8, 56, 18, 78,
];
const _silverstone = <double>[
  12, 62, 10, 40, 24, 22, 44, 12, 66, 16, 84, 30, 94, 50, 82, 68, 60, 82, 36, 78, 18, 70, 12, 62,
];
const _hungaroring = <double>[
  30, 80, 52, 86, 74, 74, 88, 56, 80, 36, 62, 20, 40, 16, 22, 30, 12, 50, 18, 68, 30, 80,
];
const _spa = <double>[
  6, 58, 10, 36, 8, 18, 28, 8, 52, 14, 74, 10, 92, 22, 96, 42, 84, 56, 62, 64, 40, 78, 18, 88, 6, 70, 6, 58,
];
const _zandvoort = <double>[
  22, 70, 36, 82, 58, 84, 80, 70, 92, 50, 84, 30, 64, 14, 42, 12, 22, 24, 10, 44, 14, 62, 22, 70,
];
const _monza = <double>[
  28, 88, 58, 90, 78, 78, 90, 58, 94, 36, 82, 18, 62, 10, 42, 16, 24, 30, 14, 48, 10, 66, 18, 80, 28, 88,
];
const _baku = <double>[
  46, 6, 46, 28, 58, 36, 78, 30, 90, 42, 86, 58, 68, 66, 46, 74, 24, 66, 10, 50, 16, 34, 32, 28, 46, 28, 46, 6,
];
const _singapore = <double>[
  16, 46, 18, 28, 36, 16, 58, 14, 76, 24, 90, 40, 86, 58, 70, 74, 48, 86, 28, 78, 14, 62, 16, 46,
];
const _cota = <double>[
  8, 48, 14, 28, 32, 14, 54, 10, 76, 20, 92, 38, 88, 58, 70, 76, 46, 86, 24, 78, 10, 62, 8, 48,
];
const _mexico = <double>[
  20, 72, 34, 84, 58, 80, 78, 64, 90, 44, 80, 24, 58, 14, 36, 20, 18, 36, 12, 56, 20, 72,
];
const _interlagos = <double>[
  36, 18, 58, 12, 78, 24, 90, 44, 78, 64, 56, 80, 34, 86, 16, 68, 10, 46, 22, 28, 36, 18,
];
const _vegas = <double>[
  8, 62, 8, 38, 28, 30, 70, 26, 94, 34, 94, 58, 72, 70, 30, 74, 8, 62,
];
const _lusail = <double>[
  18, 64, 24, 40, 42, 22, 64, 16, 84, 28, 94, 48, 82, 68, 60, 82, 36, 78, 18, 64,
];
const _yas = <double>[
  14, 58, 22, 36, 44, 18, 68, 16, 86, 30, 94, 50, 80, 68, 56, 82, 32, 74, 16, 62, 14, 58,
];
