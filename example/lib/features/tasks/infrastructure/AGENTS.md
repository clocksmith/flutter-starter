# Ownership

Follow the [root architecture contract](../../../../../docs/architecture.md).

Own task adapters, synthetic server behavior, and repository reconciliation. Depend on domain contracts; keep presentation and visual decisions outside this directory.

Run the relevant behavior tests; keep `tool/check.sh` for releases and cross-package changes.
