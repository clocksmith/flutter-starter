# Task reference app

Run `flutter run` here after resolving the workspace dependencies. This app uses synthetic accounts A and B with the same task IDs. It imports only `package:core/core.dart` and `package:ui/ui.dart` from the reusable packages.

## Journey

1. Select account A and open a task.
2. Enter a completion note. A blank note disables submission.
3. Optionally select **Reject next completion**, then submit. The confirmed task stays open and the note remains editable.
4. Submit again to complete. Back returns to the same list with the confirmed state.
5. For another task, select **Lose next response** before submitting. The synthetic server commits but throws a transport failure. **Retry completion** reuses the original operation ID, ETag, and note; the server replays the recorded result.
6. Switch to B while on detail or while a read/write is pending. Old drafts, navigation, and snackbars disappear. Server work may finish for A, but cannot update B's repository.

The failure controls are example-only scaffolding; remove them from a copied product shell. The in-memory server keeps records across account switches but resets on process restart. UI strings are centralized in `app/strings.dart` and currently English only; ui itself accepts arbitrary localized labels.

## Ownership

| State | Owner |
|---|---|
| Active account generation and cleanup | core SessionCoordinator |
| Provider dependencies | app/providers.dart |
| Confirmed task, optimistic overlay, original retry operation | SessionTaskRepository |
| Synthetic authority and replay records | MemoryTaskServer |
| Completion note and text controller | HookWidget form |
| Private route stack and snackbars | Navigator and ScaffoldMessenger inside SessionGate |

This reference uses complete task representations and one unpaginated all-tasks list. The repository merges by task revision; list and detail project the same records. Partial DTOs, deletion, filtered server queries, pagination, durable offline writes, and real HTTP authentication remain app-specific extensions requiring the architecture guide's additional contracts.

Replace `taskApiFactoryProvider` with an account-bound TaskApi adapter to connect a backend. Map wire DTOs into validated tasks, supply explicit revisions/validators, apply request timeouts, and preserve idempotency on retries. The synthetic server creates fixture validators. A real adapter must preserve server-issued validators in Task.versionToken; the repository forwards that opaque token without interpreting it.

Run `flutter test` for repository, provider, and widget checks. Run `flutter test integration_test/task_journey_test.dart -d <device-id>` for the synthetic journey on a configured device. No live backend or native secure-storage behavior is claimed by these tests.
