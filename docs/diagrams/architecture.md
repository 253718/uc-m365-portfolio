# Architecture

The public repository consumes a validated read-only feed and generates technical review artefacts, evidence packs, and DAT snippets rather than a full architecture dossier.

## Repository roles

```mermaid
flowchart LR
  FEEDREPO["uc-m365-ops-feed
private read-only producer"] --> FEED["validated read-only feed"]
  FEED --> PORT["uc-m365-portfolio
public consumer / presenter"]
  PORT --> AUD["audit / DAT snippet outputs"]
  PORT --> EV["evidence pack"]
  CHANGE["uc-m365-ops-change
private change runbooks"]
```

## Delivery pipeline

```mermaid
flowchart LR
  IN["validated feed"] --> VAL["contract validation"]
  VAL --> STAGE["staged input
feed-input/"]
  STAGE --> AUD["audit / DAT snippet outputs
out/audit/"]
  STAGE --> EV["evidence pack
out/evidence/"]
  STAGE --> TRACE["traceability
consumer-run.json
manifest.json"]
```

## Output shape

- `./out/audit/` contains run outputs and DAT snippet artefacts.
- `./out/evidence/` contains packaged evidence artefacts.
- `feed-input/` preserves the consumed input for traceability.
