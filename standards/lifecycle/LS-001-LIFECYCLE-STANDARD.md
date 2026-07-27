# LS-001 Lifecycle Standard

This standard defines the required minimal structure for lifecycle definitions in Sapphire Core.

- lifecycle_definition MUST include:
  - type_key (unique)
  - canonical_name
  - description
  - states: array of { key, name, is_terminal }
  - transitions: array of { from, to, guard, reason }

- Definitions are stored in sca_meta.lifecycle_definition.
