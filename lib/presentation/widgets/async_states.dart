import 'package:flutter/material.dart';

import '../../core/l10n/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../data/openf1_exception.dart';
import '../bloc/load_status.dart';

class AsyncBody extends StatelessWidget {
  const AsyncBody({
    super.key,
    required this.status,
    required this.strings,
    required this.child,
    this.error,
    this.onRetry,
  });

  final LoadStatus status;
  final AppStrings strings;
  final Widget child;
  final OpenF1Exception? error;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case LoadStatus.initial:
      case LoadStatus.loading:
        return const Center(child: CircularProgressIndicator(color: AppColors.red));
      case LoadStatus.empty:
        return _Message(text: strings.noData, onRetry: onRetry, retryLabel: strings.retry);
      case LoadStatus.error:
        return _Message(
          text: errorText(strings, error),
          onRetry: onRetry,
          retryLabel: strings.retry,
        );
      case LoadStatus.success:
        return child;
    }
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.text, this.onRetry, this.retryLabel});

  final String text;
  final VoidCallback? onRetry;
  final String? retryLabel;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(text, textAlign: TextAlign.center),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              FilledButton(
                onPressed: onRetry,
                style: FilledButton.styleFrom(backgroundColor: AppColors.red),
                child: Text(retryLabel ?? 'Retry'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

String errorText(AppStrings s, OpenF1Exception? error) {
  if (error == null) return s.errorGeneric;
  switch (error.kind) {
    case OpenF1ErrorKind.timeout:
      return s.errorTimeout;
    case OpenF1ErrorKind.network:
      return s.errorNetwork;
    case OpenF1ErrorKind.subscription:
      return s.errorSubscription;
    case OpenF1ErrorKind.malformed:
      return s.errorMalformed;
    case OpenF1ErrorKind.http:
      return s.errorHttp;
  }
}
