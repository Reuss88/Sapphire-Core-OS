# LS-003 Lifecycle Runtime Object Register

This standard describes the runtime register shape for instances bound to lifecycles.

Recommended table: sca_core.lifecycle_instance
- id uuid
- organisation_id uuid
- object_type text
- object_id uuid
- lifecycle_definition_id uuid
- current_state_key text
- created_at timestamptz
