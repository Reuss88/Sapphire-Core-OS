# Lifecycle Foundation

This document outlines the goals and scope of the Phase 4 Lifecycle Foundation.

Overview

- Provide a canonical registry for lifecycle definitions used across Sapphire Core.
- Provide runtime tables and contracts for lifecycle states and transitions.
- Provide RPCs for registering and querying lifecycle definitions.
- Provide standards and a pattern library for implementing lifecycle-aware domain objects.

Design principles

- Keep metadata in sca_meta schema.
- Keep runtime state in sca_core schema.
- Audit lifecycle events in sca_audit when lifecycle definitions change at runtime.
