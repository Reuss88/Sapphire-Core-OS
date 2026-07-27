# Lifecycle Runtime Architecture

This document describes the runtime view of lifecycle: how lifecycle definitions are applied to domain objects.

Runtime artifacts

- sca_core.lifecycle_instance references sca_meta.lifecycle_definition and tracks the active state for a given domain object.
- lifecycle events are recorded in sca_audit.lifecycle_event.

Access patterns

- Applications query lifecycle definitions (metadata) to enforce state machines locally.
- RPCs allow safe creation and retrieval of definitions.
