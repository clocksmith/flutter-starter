# ui

Flutter components using Material theme roles and app-provided strings. Depends on core for the session identity contract; has no Riverpod dependency.

- `createUiTheme`: Material 3 theme from an app-owned seed and brightness.
- `UiSpacing`: replaceable layout roles via ThemeExtension.
- `ContentArea`: constrained content width and semantic padding.
- `ActionButton`: app-owned pending state, disabled duplicate interaction, wrapping labels.
- `AsyncContent`: retain confirmed content during refresh and recoverable failure.
- `SessionGate`: show only the active session and replace all private widget state on a new key.

Apps provide loading, retry, failure, and button labels from their localization catalog. AsyncContent accepts already-mapped safe messages; it never renders an exception. Put long content in an app-owned scroll view. Put private navigation and snackbar state inside SessionGate's ready builder.

These components implement presentation behavior. Repositories must still coalesce duplicate commands and enforce data ownership. Run `flutter test` from this directory.
