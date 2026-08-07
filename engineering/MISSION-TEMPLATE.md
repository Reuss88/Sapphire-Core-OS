# Engineering Mission Template

## Mission ID

`<WORKSPACE>-<NNN>`

## Status

Approved / Draft / Blocked

## Objective

State one concrete implementation outcome.

## Authority

State whether the mission is Director-approved and identify any locked parity reference.

## Read first

List exact doctrine, architecture, design-system and engineering files Codex must read before coding.

## Pre-flight

Codex must inspect existing routes, components, design tokens, types, database schema, migrations, RPCs, functions, triggers, RLS, audit/event infrastructure and tests related to the mission.

## Do not

List prohibited redesigns, duplicate systems, destructive migrations and authority violations.

## Expected output

Define the user-visible and technical result.

## Files to create

List expected files when known. Codex may adapt paths to existing repository conventions but must explain deviations.

## Files to modify

List expected existing files when known.

## Frontend contract

Routes, components, states, fixtures, interactions, accessibility and parity requirements.

## Backend contract

DDL, RPCs, functions, triggers, RLS, realtime, audit and data migration requirements.

## Acceptance criteria

Objective pass/fail checks.

## Definition of done

State exactly what must be true before Codex may mark PASS.

## Mission Result

Codex must use the standard result format defined in `engineering/WORKFLOW.md`.
