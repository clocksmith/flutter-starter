# Architecture contract

**Status:** Canonical ownership and lifecycle contract for this starter. The task
reference is implemented with synthetic accounts and an in-memory server. The
broader production capabilities described in the [architecture guide](guide.md)
require their own adapters and device evidence; they are not implied by the
starter's tests.

## Enforced ownership in this repository

| Boundary | Current path | Allowed responsibility |
|---|---|---|
| Domain | `example/lib/features/*/domain/` | Pure Dart models and repository contracts |
| Application, when needed | `example/lib/features/*/application/` | Business operations over domain contracts, never concrete adapters |
| Infrastructure | `example/lib/features/*/infrastructure/` | API adapters, persistence/device access, repository reconciliation |
| Presentation | `example/lib/features/*/presentation/` | Contract-typed state projections, local drafts, and callbacks into ui components |
| Composition | `example/lib/app/`, `example/lib/main.dart` | Provider overrides, concrete adapter assembly, routes, session gates |
| Design system | `packages/ui/`, `example/lib/design_system/` | Visual components, layout, tokens, interaction and accessibility; app branding |
| Shared domain utilities | `packages/core/` | Pure Dart sessions, failures, diagnostics |
| Localization | `example/lib/l10n/` | Labels and safe failure-to-text mapping |

Short `AGENTS.md` files identify the owner at each boundary and refer back here.
They do not maintain separate architecture rules. The current task flow needs no
application use-case class: presentation invokes the repository contract and
infrastructure owns reconciliation. Add orchestration only when a business rule
requires it.

`tool/architecture.json` is the machine-readable dependency policy.
`tool/check_boundaries.dart` parses Dart syntax and checks every import, export,
conditional alternative, and part across the production source roots. It rejects
unclassified paths, missing local dependencies, cross-feature coupling,
cross-package internal access (including relative paths), and dependency cycles.
Workspace manifests must match the checked roots; core and ui runtime
dependencies must match their allowed external packages.
External packages are explicitly allowlisted per owner; new transport or device
plugins require an infrastructure policy entry. Part files must retain their
owner. Source symlinks are rejected rather than silently skipped.

Presentation imports Flutter only with a narrow `show` list of lifecycle types.
Composition has a separate list for navigation and app bootstrap. Visual symbols
and indirect device APIs such as `Clipboard` are checked in parsed code, including
prefixed references. External framework re-exports are rejected. These are
syntactic, deterministic policy checks, not a security sandbox or a proof that
arbitrary business logic belongs in the correct layer. Review still owns business
meaning; behavior tests own observable correctness. Do not add exemptions to
accommodate misplaced code.

The reusable ui package has no core, account, repository, or provider dependency.
`SessionGate` now belongs to `example/lib/app/session_gate.dart`; applications
copy that composition boundary instead of importing it from ui. Task screens
receive navigation and optional demo controls as callbacks. Their
`taskRepositoryProvider` exposes `TaskRepository`, and app composition creates,
registers, and closes the concrete implementation. Fake failure controls are
account-bound so an action for one account cannot affect another account's next
request.

Run `bash tool/check.sh` for formatting, analysis, architecture checks and their
negative fixtures, core/UI/example behavior tests, and an independent consumer.
CI additionally compiles the example for web. Account replacement, late results,
draft disposal, keyboard actions, semantics, narrow layouts, and enlarged text
are regression targets. Native-device runs remain a separate acceptance step.

The design rationale behind these rules, the layer-by-layer guidance and the
source notes are in the [architecture guide](guide.md). This file is the
enforced contract; the guide does not add rules.
