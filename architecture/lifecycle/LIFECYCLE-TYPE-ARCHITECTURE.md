# Lifecycle Type Architecture

This document describes the type-level architecture for lifecycle definitions.

Key concepts

- LifecycleDefinition: canonical description of a lifecycle (states, transitions, descriptions).
- LifecycleState: named state key within a lifecycle (e.g. draft, approved, retired).
- LifecycleTransition: allowed transition between states with optional guards and reasons.

Storage

- Lifecycle definitions are stored in sca_meta.lifecycle_definition as JSONB for states and transitions to retain flexibility while preserving canonical IDs.
