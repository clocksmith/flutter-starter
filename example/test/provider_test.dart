import 'package:core/core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:starter_example/app/providers.dart';
import 'package:starter_example/features/tasks/infrastructure/memory_task_server.dart';

void main() {
  test(
    'provider dependencies replace repositories even for the same account',
    () async {
      final coordinator = SessionCoordinator();
      final container = ProviderContainer.test(
        overrides: [
          sessionCoordinatorProvider.overrideWithValue(coordinator),
          memoryServerProvider.overrideWithValue(
            MemoryTaskServer(latency: Duration.zero),
          ),
        ],
      );
      addTearDown(coordinator.dispose);
      container.listen(taskRepositoryProvider, (_, _) {});
      await coordinator.activate(const SessionIdentity('A'));
      await container.pump();
      final first = container.read(taskRepositoryProvider)!;
      final reader = container.listen(taskProvider('1'), (_, _) {});
      await container.read(taskProvider('1').future);
      expect(first.subscriberCount, 1);
      reader.close();
      await container.pump();
      expect(first.subscriberCount, 0);
      expect(first.isClosed, isFalse);
      await coordinator.signOut();
      await coordinator.activate(const SessionIdentity('A'));
      await container.pump();
      final second = container.read(taskRepositoryProvider)!;
      expect(identical(first, second), isFalse);
      expect(first.isClosed, isTrue);
      expect(first.session.key, isNot(second.session.key));
    },
  );
}
