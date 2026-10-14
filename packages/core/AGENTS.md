# Ownership

Follow the [root architecture contract](../../docs/architecture.md).

Own pure Dart session lifecycle, failures, and safe diagnostics. Keep framework, transport, storage, providers, and app features outside this package.

Run the relevant behavior tests; keep `tool/check.sh` for releases and cross-package changes.
