import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ui/ui.dart';

import '../features/tasks/presentation/task_screens.dart';
import 'providers.dart';
import 'strings.dart';

class StarterApp extends ConsumerWidget {
  const StarterApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => MaterialApp(
    title: Strings.title,
    theme: createUiTheme(seedColor: const Color(0xff315b54)),
    darkTheme: createUiTheme(
      seedColor: const Color(0xff315b54),
      brightness: Brightness.dark,
    ),
    localizationsDelegates: GlobalMaterialLocalizations.delegates,
    supportedLocales: const [Locale('en')],
    home: SessionGate(
      state: ref.watch(sessionStateProvider),
      signedOut: (_) => const _SignIn(),
      transitioning: (_) =>
          const Scaffold(body: Center(child: Text(Strings.switching))),
      failure: (_, _) => const _SignIn(failed: true),
      ready: (_, session) => ScaffoldMessenger(
        child: Navigator(
          onGenerateRoute: (settings) => MaterialPageRoute<void>(
            settings: settings,
            builder: (_) => TaskListScreen(session: session),
          ),
        ),
      ),
    ),
  );
}

class _SignIn extends ConsumerWidget {
  const _SignIn({this.failed = false});
  final bool failed;

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
    appBar: AppBar(title: const Text(Strings.title)),
    body: SingleChildScrollView(
      child: ContentArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(failed ? Strings.sessionFailure : Strings.demo),
            SizedBox(height: UiSpacing.of(context).gap),
            for (final account in ['A', 'B'])
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ActionButton(
                  label: account == 'A' ? Strings.accountA : Strings.accountB,
                  pendingLabel: Strings.switching,
                  onPressed: () => unawaited(
                    ref.read(sessionStateProvider.notifier).activate(account),
                  ),
                ),
              ),
          ],
        ),
      ),
    ),
  );
}
