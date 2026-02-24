# GOBL Patterns Reference

## Scenarios

Auto-inject notes, codes, extensions based on document state (tags, type, ext values). Defined in each regime's `scenarios.go`.

## Extension Keys

Named `<country>-<platform>-<description>` (e.g., `es-sii-doc-type`).

## JSON Schema

Types implement `JSONSchema()` (full override) or `JSONSchemaExtend()` (augment reflected schema).

## New Regime Checklist

1. Create `regimes/<cc>/`, implement `New() *tax.RegimeDef`, add `init()`
2. Blank-import in `regimes/regimes.go`
3. Run `make generate` and `make test-examples`

## New Addon Checklist

1. Create `addons/<cc>/<format>/`, implement `newAddon() *tax.AddonDef`, add `init()`
2. Blank-import in `addons/addons.go`
3. Run `make generate` and `make test-examples`
