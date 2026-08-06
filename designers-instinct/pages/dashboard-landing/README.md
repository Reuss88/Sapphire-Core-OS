# Dashboard Landing — Implementation Doctrine

This directory is the authoritative page contract for the Sapphire Core OS Dashboard Landing surface.

It extends, and does not replace, `designers-instinct/dashboard-landing-principles.md`.

## Purpose

The contract must be precise enough to guide:

- Director review and approval;
- product and visual design;
- design-token creation;
- Next.js 16 App Router implementation;
- PWA and responsive behaviour;
- a future Capacitor wrapper;
- Supabase DDL, views, RPCs, functions, triggers, RLS and realtime subscriptions;
- Codex implementation without inventing business rules.

## Authority chain

Broker OS doctrine defines how the business operates.

Designers Instinct defines how the business is experienced.

This page contract translates both into an implementation-ready Dashboard Landing specification.

## Files

- `page-doctrine.md` — purpose, mandatory regions, hierarchy, actions and prohibitions.
- `surface-contract.md` — widget catalogue, states, routes, responsive and mobile behaviour.
- `data-contract.md` — Supabase-facing read models, RPCs, events, permissions and audit requirements.
- `design-tokens.md` — page-level semantic tokens and token constraints.
- `codex-handoff.md` — implementation sequence and definition of done.

## Binding rule

A design or implementation is non-compliant if it requires a designer, developer or AI agent to guess:

- what a widget means;
- which workspace owns its records;
- what action follows;
- which route receives drill-down;
- what data contract supplies it;
- whether the current user is authorised;
- how it behaves on mobile, offline or failure.
