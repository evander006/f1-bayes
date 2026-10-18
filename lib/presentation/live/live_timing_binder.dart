import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/app_context_cubit.dart';
import '../bloc/live_timing_cubit.dart';
import '../bloc/load_status.dart';

class LiveTimingBinder extends StatefulWidget {
  const LiveTimingBinder({super.key, required this.child});

  final Widget child;

  @override
  State<LiveTimingBinder> createState() => _LiveTimingBinderState();
}

class _LiveTimingBinderState extends State<LiveTimingBinder> {
  Object? _boundKey;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _sync(context.read<AppContextCubit>().state);
    });
  }

  void _sync(AppContextState app) {
    if (app.status != LoadStatus.success) return;
    final session = app.liveSession ?? app.latestSession;
    final key = session?.sessionKey;
    if (key == _boundKey) return;
    _boundKey = key;
    context.read<LiveTimingCubit>().start(
          session: session,
          drivers: app.drivers,
          fallback: session?.sessionKey == app.latestSession?.sessionKey
              ? app.latestResults
              : const [],
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AppContextCubit, AppContextState>(
      listenWhen: (prev, next) =>
          prev.liveSession?.sessionKey != next.liveSession?.sessionKey ||
          prev.latestSession?.sessionKey != next.latestSession?.sessionKey ||
          prev.status != next.status,
      listener: (context, app) => _sync(app),
      child: widget.child,
    );
  }
}
