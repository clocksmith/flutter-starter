import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui/ui.dart';

void main() {
  testWidgets('refresh and error preserve content and expose retry', (
    tester,
  ) async {
    var retries = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AsyncContent(
            loadingLabel: 'Refreshing',
            emptyLabel: 'Empty',
            retryLabel: 'Retry',
            content: const Text('Confirmed content'),
            loading: true,
            errorMessage: 'Try again',
            onRetry: () => retries++,
          ),
        ),
      ),
    );
    expect(find.text('Confirmed content'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    await tester.tap(find.text('Retry'));
    expect(retries, 1);
  });

  testWidgets('pending action is disabled and accommodates large text', (
    tester,
  ) async {
    var taps = 0;
    await tester.pumpWidget(
      MaterialApp(
        theme: createUiTheme(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        home: MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(2.5)),
          child: Scaffold(
            body: SizedBox(
              width: 240,
              child: ActionButton(
                label: 'Complete this task',
                pendingLabel: 'Saving your changes',
                pending: true,
                onPressed: () => taps++,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Saving your changes'));
    expect(taps, 0);
    expect(tester.takeException(), isNull);
  });

  testWidgets('account replacement destroys widget drafts', (tester) async {
    final coordinator = SessionCoordinator();
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
      final closing = coordinator.dispose();
      await tester.pump();
      await closing;
    });
    await coordinator.activate(const SessionIdentity('A'));
    Widget app() => MaterialApp(
      home: SessionGate(
        state: coordinator.state,
        signedOut: (_) => const Text('Signed out'),
        transitioning: (_) => const Text('Switching'),
        failure: (_, _) => const Text('Failure'),
        ready: (_, _) => const Scaffold(body: TextField()),
      ),
    );
    await tester.pumpWidget(app());
    await tester.enterText(find.byType(TextField), 'A private draft');
    await coordinator.activate(const SessionIdentity('B'));
    await tester.pumpWidget(app());
    expect(find.text('A private draft'), findsNothing);
    final switching = coordinator.signOut();
    await tester.pumpWidget(app());
    expect(find.byType(TextField), findsNothing);
    await switching;
    await tester.pumpWidget(app());
    expect(find.text('Signed out'), findsOneWidget);
  });
}
