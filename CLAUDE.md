# GOBL (Go Business Language)

Library for creating, validating, and signing structured business documents (invoices) with country-specific tax regime and addon support.

## Stack

- Go 1.24+
- Mage (build tool)
- `github.com/invopop/validation` (struct validation)
- `github.com/invopop/jsonschema` (JSON Schema generation)

## Structure

- `bill/` — Invoice model, calculation engine
- `tax/` — RegimeDef, AddonDef, registries, Normalizer/Validator, Scenarios
- `regimes/<cc>/` — Country tax regimes (registered via `init()`)
- `addons/<cc>/<format>/` — Format/standard addons (registered via `init()`)
- `cbc/`, `org/`, `num/` — Primitives, business entities, decimal math
- `data/`, `examples/` — Generated JSON + YAML test fixtures (committed, must stay in sync)

## Commands

- `make check` — Full pipeline: generate, lint, test, verify generated files
- `make test` — Run all tests
- `go test ./regimes/es/...` — Test a single package
- `make test-examples` — Regenerate example `out/*.json` snapshots

## Patterns

- **Registration**: Regimes/addons register via `init()` → `tax.RegisterRegimeDef()`/`tax.RegisterAddonDef()`. Aggregators blank-import all sub-packages.
- **Normalizer/Validator**: Function fields `func(doc any)` / `func(doc any) error` with `switch obj := doc.(type)` dispatch.

## Docs

- `agent_docs/philosophy.md` — Architecture invariants, design patterns, and rationale
- `agent_docs/patterns.md` — Scenarios, extension keys, JSON Schema overrides, new regime/addon checklist
