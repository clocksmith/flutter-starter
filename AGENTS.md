# Flutter starter

Build reusable packages named `core` and `ui`, plus a runnable example that consumes only their public APIs. Use `x_core` and `x_ui` only if a namespace becomes necessary.

## Development verification

- During development, choose checks for the changed behavior: syntax/type checks,
  existing focused tests, or a local visual check. A command list is not a requirement
  to run every suite before each commit, push, or ordinary application deployment.
- Do not automatically run full repository suites, broad browser/device matrices,
  GPU/model campaigns, benchmarks, or full release qualification. Run them when
  explicitly requested or when a named correctness question cannot be answered by
  focused checks; state that reason before starting.
- Config-contract, mirror, drift, and freshness checks run only when the change
  edits what they check. Don't add tests that just restate another file or pin
  config literals. Time-box long processes.
- Once relevant checks pass, continue. Repeat or broaden verification only after
  another relevant change, a failure, or a concrete unresolved concern.
- For documentation-only edits, inspect the diff and changed links. Do not run
  application, GPU, browser, or benchmark suites for prose changes.
- For ordinary deployments, build the changed artifact where needed and check the
  affected route after deployment. Deployment alone does not require a new release
  qualification campaign.
- Keep existing acceptance thresholds and release-qualification requirements.
  Report exactly what was checked; focused development checks do not establish
  numerical qualification, performance, multi-device support, or full acceptance.

## Architecture

- Follow the ownership and lifecycle rules in the [architecture guide](docs/architecture.md).
- `packages/core` is pure Dart: session lifecycle, typed failures, and safe diagnostics. It imports no Flutter, Riverpod, transport client, or app feature.
- `packages/ui` contains Flutter components, layout, and accessibility. Apps supply localized text, themes, routes, and feature behavior.
- The example owns task models, repository reconciliation, transport adapters, Riverpod composition, session gates, and navigation.
- One root ProviderScope; session generations isolate accounts, late work, effects, and local drafts.
- Never put credentials or user payloads in diagnostics; use synthetic data in the example.
- Add abstractions only when a consumer exercises them; no generic CRUD framework.

## Validation

- `tool/architecture.json` defines checked ownership; leaf `AGENTS.md` files point to the canonical guide.
- Run the touched package's tests (`dart test` in `packages/core`, `flutter test` in `packages/ui` or `example`); reserve the full `tool/check.sh` for releases and cross-package or `tool/` changes.
- Add meaningful tests for lifecycle races, stale responses, cleanup, and component interaction.
- Keep documentation explicit about fake authentication, missing production adapters, and device validation.
- Do not publish packages, create remote repositories, or deploy without user direction.

## Workflow

Preserve unrelated files. Use plain language and no emojis. Do not predict implementation timelines.
