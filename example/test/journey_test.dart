import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:starter_example/app/app.dart';
import 'package:starter_example/app/providers.dart';
import 'package:starter_example/app/strings.dart';
import 'package:starter_example/features/tasks/infrastructure/memory_task_server.dart';

void main() {
  testWidgets('list, detail, failure, retry, Back, and account replacement', (
    tester,
  ) async {
    final coordinator = SessionCoordinator();
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
      final closing = coordinator.dispose();
      await tester.pump();
      await closing;
    });
    final server = MemoryTaskServer(latency: Duration.zero);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sessionCoordinatorProvider.overrideWithValue(coordinator),
          memoryServerProvider.overrideWithValue(server),
        ],
        child: const StarterApp(),
      ),
    );
    await tester.tap(find.text(Strings.accountA));
    await tester.pumpAndSettle();
    await tester.tap(find.text('A: Plan the first release'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Keep this draft');
    await tester.pump();
    server.nextCompletion = CompletionBehavior.reject;
    await tester.tap(find.text(Strings.complete));
    await tester.pumpAndSettle();
    expect(find.text('Keep this draft'), findsOneWidget);
    expect(find.text(Strings.failure(FailureKind.validation)), findsOneWidget);
    await tester.tap(find.text(Strings.complete));
    await tester.pumpAndSettle();
    expect(find.text(Strings.completed), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text(Strings.completed), findsOneWidget);
    await tester.tap(find.text('A: Review the checklist'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Private A draft');
    await tester.tap(find.text(Strings.rejectNext));
    await tester.pump();
    expect(find.text(Strings.failureArmed), findsOneWidget);
    await tester.tap(find.text(Strings.accountB));
    await tester.pumpAndSettle();
    expect(find.text('Private A draft'), findsNothing);
    expect(find.text(Strings.failureArmed), findsNothing);
    expect(find.text('A: Review the checklist'), findsNothing);
    expect(find.text('B: Plan the first release'), findsOneWidget);
    expect(find.byType(BackButton), findsNothing);
    await tester.tap(find.text(Strings.signOut));
    await tester.pumpAndSettle();
    expect(find.text(Strings.demo), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('pending A read cannot flash when B becomes ready', (
    tester,
  ) async {
    final coordinator = SessionCoordinator();
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
      final closing = coordinator.dispose();
      await tester.pump();
      await closing;
    });
    final server = MemoryTaskServer(latency: const Duration(seconds: 1));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sessionCoordinatorProvider.overrideWithValue(coordinator),
          memoryServerProvider.overrideWithValue(server),
        ],
        child: const StarterApp(),
      ),
    );
    await tester.tap(find.text(Strings.accountA));
    await tester.pump();
    await tester.pump();
    await tester.tap(find.text(Strings.accountB));
    for (var frame = 0; frame < 15; frame++) {
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('A: Plan the first release'), findsNothing);
    }
    expect(find.text('B: Plan the first release'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
