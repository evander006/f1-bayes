import 'package:flutter/material.dart';

import 'app_strings.dart';

class LocaleScope extends InheritedNotifier<ValueNotifier<Locale>> {
  const LocaleScope({
    super.key,
    required ValueNotifier<Locale> notifier,
    required super.child,
  }) : super(notifier: notifier);

  static ValueNotifier<Locale> of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<LocaleScope>();
    assert(scope != null, 'LocaleScope not found');
    return scope!.notifier!;
  }

  static AppStrings stringsOf(BuildContext context) {
    final locale = of(context).value;
    return locale.languageCode == 'ru' ? AppStrings.ru : AppStrings.en;
  }
}
