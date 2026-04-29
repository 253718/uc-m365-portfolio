# France / Monaco dual-operator Teams Phone design

## Context

This case study illustrates a Teams Phone design pattern for a regulated environment operating across France and Monaco within a single Microsoft 365 tenant.

The objective was not to expose tenant-changing tooling or client-specific implementation details, but to demonstrate how a voice service can be structured when different countries, operators, numbering domains, and call handling models must coexist in a controlled and reviewable way.

## Problem statement

The voice service had to support two distinct telephony domains:

- a France domain using a French operator and French numbering
- a Monaco domain using a Monaco operator and Monaco numbering

The challenge was not only technical connectivity. It was also about presenting a design that remained understandable, supportable, and reviewable across BUILD and RUN.

In practical terms, callers needed different entry paths depending on the service they were trying to reach:

- a French entry point for local office services
- a French entry point with IVR navigation to reach Monaco-based services
- a Monaco entry point handled through a receptionist model with manual redirection when required

## Constraints

Several constraints shaped the design:

- separate operators for France and Monaco
- separate numbering domains (`+33` and `+377`)
- separate SBC connectivity per operator
- no artificial cross-country PSTN failover assumptions
- a need for clean handover and review artefacts
- a public portfolio boundary that must remain read-only and non-sensitive

That last point matters. In a public portfolio, the goal is not to reproduce a client environment literally, but to demonstrate the architecture and delivery thinking behind a realistic pattern.

## Architecture approach

The design separates the France and Monaco telephony domains while keeping them within a single tenant.

At Direct Routing level, this means:

- one SBC and routing domain for France
- one SBC and routing domain for Monaco
- distinct PSTN usages and voice routing policies
- dial plans aligned with each numbering context

At service-entry level, this means:

- a France office entry point routing callers to a France desk queue
- a France-to-Monaco services entry point using IVR navigation to reach Monaco service queues
- a Monaco reception entry point using a receptionist / manual transfer model

This is intentionally more realistic than a simplistic “active / backup SBC” story. Where different operators and numbering ranges are involved, the cleaner design signal is domain separation and explicit routing intent, not fictional failover.

## Delivery / review approach

This portfolio models the solution through a feed-driven, read-only documentation path.

A validated input feed is consumed by the public repository and transformed into:

- DAT snippets
- evidence-oriented output packs
- traceability artefacts
- review-friendly markdown outputs

This makes the public repository useful without exposing private operational runbooks or tenant-changing scripts.

From a delivery perspective, that approach is valuable because it supports several goals at once:

- architecture review
- technical handover
- evidence packaging
- continuity between implementation and operations

The emphasis is therefore not only on “what exists in the tenant”, but on how the design can be reviewed and transmitted in a controlled way.

## Why this pattern is interesting

This pattern is interesting because it combines several themes that often appear in real-world Teams Voice delivery but are rarely shown clearly in public examples:

- dual-operator coexistence
- multi-country numbering domains
- different entry models for different user journeys
- separation between routing design and service-access design
- a delivery model that stays audit-friendly and read-only

It also highlights an important architectural principle: not every environment should be simplified into a generic failover narrative. In some cases, the better design is to make the boundaries explicit and the routing intent understandable.

## What this demonstrates

This case study is meant to demonstrate more than basic Teams Phone administration.

It shows an approach to Teams Voice delivery that values:

- routing clarity
- operational readability
- handover quality
- evidence-oriented documentation
- realistic service design in regulated environments

In other words, the point is not only to configure voice workloads, but to structure them in a way that can be reviewed, documented, and carried into RUN with less ambiguity.
