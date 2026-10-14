# Ownership

Follow the [root architecture contract](../../../../../docs/architecture.md).

Own business operations only when orchestration or reuse requires them. Depend on domain contracts, never concrete adapters, providers, or widgets. No artificial use-case wrapper is required for the current single-repository flow.

Run the relevant behavior tests; keep `tool/check.sh` for releases and cross-package changes.
