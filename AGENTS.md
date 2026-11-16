# Flutter starter

When working inside Deco, follow [the workspace operating rules](../AGENTS.md).
This file adds repository-specific guidance; standalone checkouts use it directly.

Build reusable packages named `core` and `ui`, plus a runnable example that consumes only their public APIs. Use `x_core` and `x_ui` only if a namespace becomes necessary.

## Architecture

- Follow the ownership and lifecycle rules in the [architecture guide](docs/architecture.md).
- `packages/core` is pure Dart: session lifecycle, typed failures, and safe diagnostics. It imports no Flutter, Riverpod, transport client, or app feature.
- `packages/ui` contains Flutter components, layout, and accessibility. Apps supply localized text, themes, routes, and feature behavior.
- The example owns task models, repository reconciliation, transport adapters, Riverpod composition, session gates, and navigation.
- One root ProviderScope; session generations isolate accounts, late work, effects, and local drafts.
- Never put credentials or user payloads in diagnostics; use synthetic data in the example.
- Add abstractions only when a consumer exercises them; no generic CRUD framework.

## Validation

- `tool/architecture.json` defines checked ownership; [the architecture guide](docs/architecture.md) owns the component map and lifecycle rules.
- Run the touched package's tests (`dart test` in `packages/core`, `flutter test` in `packages/ui` or `example`); reserve the full `tool/check.sh` for releases and cross-package or `tool/` changes.
- Add meaningful tests for lifecycle races, stale responses, cleanup, and component interaction.
- Keep documentation explicit about fake authentication, missing production adapters, and device validation.
- Do not publish packages, create remote repositories, or deploy without user direction.

## Workflow

Preserve unrelated files. Use plain language and no emojis. Do not predict implementation timelines.
