## ADR-0001 — Operator SBCaaS vs self-hosted SBC

**Status:** Accepted  
**Date:** 2026-01-15

### Context

Microsoft Teams Direct Routing requires an SBC layer to interconnect the Teams cloud with the PSTN.
Two deployment models are commonly available:

- **operator-provided SBCaaS**
- **self-hosted SBC**

### Decision

Both models remain valid and supported.
The portfolio documents both options and keeps the responsibility boundary explicit.

### Consequences

- architecture documentation must state the chosen boundary clearly
- public tooling remains read-only in either case
- handover and evidence expectations differ depending on where the SBC boundary sits
