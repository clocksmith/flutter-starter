# Flutter starter

Reusable packages named **core** and **ui**, with a task example that consumes their public APIs.

The project targets Flutter **3.47.5 stable**, Dart **3.13.4**, and Riverpod **3.4.3** in the example. `.flutter-version` records the Flutter pin; `pubspec.lock` records dependency resolution. Set your Flutter version manager or CI to this pin.

| Location | Owns |
|---|---|
| `packages/core` | Pure Dart session lifecycle, revocable session handles, typed failures, safe diagnostics |
| `packages/ui` | Theme and spacing, loading/error surfaces, action buttons, session subtree replacement |
| `example` | App bootstrap, Riverpod composition, task models, repository reconciliation, synthetic backend, routes, local drafts |
| `tool` | Formatting, analysis, boundary checks, tests, independent consumer verification |

Neither package requires Riverpod. The example demonstrates one root ProviderScope and explicit session dependencies. Task caches, optimistic completion, idempotency, and conflict rules belong to the example feature.

## Run and verify

Put Flutter 3.47.5 on PATH, then:

```sh
flutter pub get
bash tool/check.sh
cd example
flutter run
```

Alternatively, pass an installed SDK to the checks:

```sh
FLUTTER_BIN=/path/to/flutter/bin/flutter bash tool/check.sh
```

The example includes Android, iOS, and web runners. Select a configured device with `flutter run -d <device-id>`. Native builds need the corresponding Android or Xcode toolchain. `flutter build web` provides a separate application compilation check.

Run the device journey against the synthetic backend:

```sh
cd example
flutter test integration_test/task_journey_test.dart -d <device-id>
```

Unit and widget tests do not establish device, platform secure-storage, backup, or real-server behavior.

## Consume from another app

Keep this checkout nearby and add path dependencies to the consuming app's `pubspec.yaml`:

```yaml
dependencies:
  core:
    path: ../flutter_starter/packages/core
  ui:
    path: ../flutter_starter/packages/ui
```

Use public imports:

```dart
import 'package:core/core.dart';
import 'package:ui/ui.dart';
```

An app supplies localized labels, theme seeds or its own ThemeData, routes, authentication, and data adapters. It can use core without Flutter or ui with a different state-management choice. Copy the example shell when starting a new app; retain dependencies on the packages so fixes can be adopted together.

`tool/verify_consumer.dart` copies only package manifests and public library trees into a temporary directory, removes workspace resolution from those exported copies, and runs a separate app test. It proves the packages do not need the example or the workspace to execute. Local path consumption is the supported distribution in this first version. No packages have been published; generic names may require the permitted `x_core` / `x_ui` namespace before registry publication. Git distribution requires replacing ui's local core dependency with an appropriate version or Git source.

## Build a new feature in this order

1. Define the journey, resource identity, failures, and transport contract.
2. Implement the feature's domain models and repository interface.
3. Build the repository against a controllable fake adapter and test its merge rules.
4. Create session-dependent providers and keep workflow state separate from resource authority.
5. Build screens with ui components; supply app labels and branding.
6. Replace the fake adapter with a tested real adapter, then run the device journey.

Use cases are optional. Extract shared logic only after a second consumer needs the same behavior. Avoid a generic CRUD base repository: each feature must define its concurrency, authorization, and reconciliation contract.

## Session contract

`SessionCoordinator.activate` and `signOut` immediately revoke the old `SessionHandle`. Cleanup is serialized before another session is exposed. Even a new sign-in to the same account gets a distinct key. Register resource cleanup with `session.registerCleanup`; cleanup must be idempotent. Failed cleanup keeps the app out of private content and can be retried by a subsequent transition.

Use `SessionHandle.requireActive()` after each asynchronous boundary before publishing or changing local data. Guard credential refresh, storage writes, late 401 handling, navigation, and snackbars too. Register credentials and subscriptions with the appropriate session owner. A session handle is a client lifecycle capability, not proof of server authorization, and revocation does not cancel a command already sent to a server.

`SessionGate` keys the private subtree by the full session key. Put private Navigators and ScaffoldMessengers inside it. Providers must watch the session or its repository and refuse retained values from a different session. App shutdown must await coordinator cleanup when its lifecycle allows it; widget disposal can only initiate asynchronous cleanup.

## Data and diagnostics

The example persists no task data, notes, credentials, or pending writes. Authentication is a synthetic A/B switch. Core intentionally does not choose a credential plugin or database for consumers. Production apps must implement authentication, credential refresh, secure storage, authorization, retention, and backup rules appropriate to their product.

`Diagnostics` accepts fixed operation/outcome enums, a failure category, and a duration. It accepts no text, IDs, bodies, or exception objects. `AppFailure.cause` may be retained for local debugging but is excluded from its string representation and diagnostic events. A failing diagnostic sink does not fail a user action. These protections apply only to calls using this API; configure HTTP loggers and crash SDKs separately.

## Reference

The design follows the [architecture guide](https://github.com/clocksmith/256/blob/c582d4d/wip/drafts/flutter-mobile-app-architecture.md). Package public APIs are intentionally small. See the package READMEs and [example README](example/README.md) for customization and the concrete journey.

## Validation record

Verified locally on Flutter 3.47.5 / Dart 3.13.4: formatting, static analysis, dependency boundary checks, seven core tests, three UI tests, eight example tests, one independent consumer test, and a release web build. The final example tests also verify that an opaque server version token is forwarded unchanged. Android/iOS runners and a device integration test are included; native device execution has not been verified. The CI workflow is supplied but has not run on a remote repository.
