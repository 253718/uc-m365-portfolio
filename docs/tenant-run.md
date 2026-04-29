## Tenant run reference

This document provides **run-time reference patterns** for Teams Phone environments after delivery.
It remains a portfolio reference, not a private operational handbook.

## Relevance in the new model

- producer-side tenant collection is now primarily handled in `uc-m365-ops-feed`
- tenant-changing runbooks are private in `uc-m365-ops-change`
- this public repo still documents how delivery outputs support day-2 run conversations

## Typical run-time activities

- validation of reachability and call routing
- review of evidence packs as technical baselines
- use of architecture and call-flow documentation during incidents and handovers
- escalation to operator, network, or change-control boundaries as required

## Boundaries and exclusions

This page intentionally excludes:

- live tenant-changing execution
- private operational auth/bootstrap details
- customer-specific thresholds or internal escalation paths
