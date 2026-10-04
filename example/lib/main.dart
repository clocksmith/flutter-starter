import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter/widgets.dart'
    show BuildContext, Widget, StatefulWidget, State, runApp;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'app/providers.dart';

void main() => runApp(const StarterRoot());

class StarterRoot extends StatefulWidget {
  const StarterRoot({super.key});

  @override
  State<StarterRoot> createState() => _StarterRootState();
}

/// Owns the external coordinator, including its asynchronous shutdown.
class _StarterRootState extends State<StarterRoot> {
  final coordinator = SessionCoordinator();

  @override
  void dispose() {
    unawaited(coordinator.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ProviderScope(
    overrides: [
      sessionCoordinatorProvider.overrideWithValue(coordinator),
      taskRepositoryProvider.overrideWith(createTaskRepository),
    ],
    child: const StarterApp(),
  );
}
