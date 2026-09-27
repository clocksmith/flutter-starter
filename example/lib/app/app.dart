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
    theme: createUiTheme(
      seedColor: const Color(0xff315b54),
      fontFamily: 'Manrope',
    ),
    darkTheme: createUiTheme(
      seedColor: const Color(0xff315b54),
      brightness: Brightness.dark,
      fontFamily: 'Manrope',
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
            const SizedBox(height: 24),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  Icons.checklist_rounded,
                  size: 32,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              Strings.welcome,
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 12),
            Text(
              Strings.welcomeDetail,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 32),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      Strings.chooseAccount,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      failed ? Strings.sessionFailure : Strings.demo,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ActionButton(
                      label: Strings.accountA,
                      pendingLabel: Strings.switching,
                      onPressed: () => unawaited(
                        ref.read(sessionStateProvider.notifier).activate('A'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: () => unawaited(
                        ref.read(sessionStateProvider.notifier).activate('B'),
                      ),
                      child: const Text(Strings.accountB),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
