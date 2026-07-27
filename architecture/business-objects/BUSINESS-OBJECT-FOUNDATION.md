# Phase 2 — Business Object Foundation

## Status

Architecture locked at conceptual level; implementation foundation added in this phase.

## Purpose

Define the canonical metamodel for enterprise Business Objects so every later module—relationships, lifecycle, workflow, authority, evidence, AI, and applications—operates on stable governed entities.

## Core principle

A Business Object is a governed semantic entity with identity, meaning, ownership, effective time, provenance, lifecycle participation, and history.

A Business Object is not merely:

- a database row;
- an API payload;
- a UI card;
- a workflow item;
- a document;
- a file;
- an event.

Those may represent or interact with a Business Object, but they do not define it.

## Canonical metamodel

Every Business Object Type must define:

- stable type key;
- canonical name;
- description;
- object family;
- identity strategy;
- ownership model;
- classification rules;
- required attributes;
- optional attributes;
- lifecycle participation;
- relationship permissions;
- provenance requirements;
- audit requirements;
- retention expectations;
- versioning policy;
- implementation mappings.

Every Business Object Instance must preserve:

- stable object identifier;
- type identifier;
- organisation or tenant scope;
- canonical display label;
- current record version;
- effective period;
- recorded period;
- source and provenance;
- owning party or organisational unit where applicable;
- classification;
- current lifecycle reference where applicable;
- immutable history.

## Identity

Business Object identity is stable across application, database, integration, and interface changes.

Identity must not depend solely on:

- mutable names;
- email addresses;
- external supplier identifiers;
- application-generated sequence numbers;
- current ownership;
- lifecycle state.

External identifiers may be attached as governed identifiers with source, namespace, validity, and uniqueness rules.

## Time model

The architecture distinguishes:

- **effective time** — when the business truth is valid;
- **recorded time** — when the system recorded that truth.

This enables correction without rewriting history.

## Versioning

Business Object changes create a new immutable record version.

The stable object identity remains constant while record versions preserve the sequence of accepted business truth.

## Ownership

Ownership must be explicit and separate from:

- authorship;
- responsibility;
- assignment;
- access;
- authority.

An owner may be a person, team, organisational unit, legal entity, or governed system actor, depending on the object type.

## Classification

Classification is governed metadata that may drive access, retention, risk, workflow, policy, and AI handling.

Classification does not replace type or lifecycle state.

## Provenance

Every accepted object version must identify how the information entered or changed within the enterprise.

Examples:

- human entry;
- imported dataset;
- external integration;
- document extraction;
- system calculation;
- AI-assisted preparation;
- authorised automated execution.

## History

Object history is append-only.

Corrections create new versions and preserve the superseded record. Deletion of business truth must be represented through governed retention, redaction, or legal erasure procedures rather than silent mutation.

## Implementation boundary

The PostgreSQL schema in this phase implements the metamodel. It does not define the complete domain catalogue.

Domain object types such as Supplier, Buyer, Company, Contact, Opportunity, Task, Document, Property, Product, or Contract are registered through the metamodel in later domain modules.
