# Ownership

Follow the [root architecture contract](../../../../../docs/architecture.md).

Own task models and repository contracts as pure Dart. Keep DTO decoding, widgets, providers, storage, and transport outside this directory.

Run the relevant behavior tests; keep `tool/check.sh` for releases and cross-package changes.
