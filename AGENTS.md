# Flutter starter

Build reusable packages named `core` and `ui`, plus a runnable example that consumes only their public APIs. Use `x_core` and `x_ui` only if a namespace becomes necessary.

## Architecture

- Follow the ownership and lifecycle rules in the [architecture guide](docs/architecture.md).
- `packages/core` is pure Dart: session lifecycle, typed failures, and safe diagnostics. It imports no Flutter, Riverpod, transport client, or app feature.
- `packages/ui` contains Flutter components, layout, and accessibility. Apps supply localized text, themes, routes, and feature behavior.
- The example owns task models, repository reconciliation, transport adapters, Riverpod composition, session gates, and navigation.
- One root ProviderScope. Session generations isolate accounts, late work, effects, and local drafts.
- Never put credentials or user payloads in diagnostics. Use synthetic data in the example.
- Add abstractions only when exercised by a consumer. Do not build a generic CRUD framework.

## Validation

- `tool/architecture.json` defines checked ownership; leaf `AGENTS.md` files point to the canonical guide.
- Run `tool/check.sh` for formatting, analysis, core tests, UI tests, example tests, and consumer verification.
- Add meaningful tests for lifecycle races, stale responses, cleanup, and component interaction.
- Keep documentation explicit about fake authentication, missing production adapters, and device validation.
- Do not publish packages, create remote repositories, or deploy without user direction.

## Workflow

Work in this project. Preserve unrelated files. Use plain language and no emojis. Do not predict implementation timelines.
