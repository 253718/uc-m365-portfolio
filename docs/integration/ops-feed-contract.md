## Integration contract — `uc-m365-ops-feed` -> `uc-m365-portfolio`

This document defines the public consumer contract between:

- **producer:** `uc-m365-ops-feed` (private, read-only)
- **consumer:** `uc-m365-portfolio` (public, read-only, presenter)

## Responsibilities split

### `uc-m365-ops-feed`

Owns:

- real tenant connectivity
- read-only extraction
- normalized feed run generation
- feed quality checks focused on consumability

Does **not** own:

- DAT generation
- public evidence packs
- recruiter-facing documentation
- tenant-changing actions

### `uc-m365-portfolio`

Owns:

- feed validation on the consumer side
- DAT snippet generation
- evidence pack packaging
- handover-oriented and reviewer-oriented outputs
- public documentation, templates, ADRs, case studies, sample outputs

Does **not** own:

- tenant-changing runbooks
- producer-side auth/bootstrap logic

## Canonical feed shape

```text
out/
  teamsphone-<RunId>/
    meta/
      run.json
      manifest.json
    exports/
      tenant-teamsphone-config.json
      tenant-teamsphone-callflows.json
    inventory/
      teamsphone-inventory.csv
      teamsphone-inventory.json
    validation/
      feed-quality.json
```

## `meta/run.json`

Minimum fields expected by the public consumer:

- `contractVersion`
- `domain`
- `runId`
- `sourceRepo`
- `mode`
- `generatedAtUtc`
- `producer`

## `meta/manifest.json`

Must list produced files with relative paths and SHA256 checksums.

## `inventory/teamsphone-inventory.csv`

Must contain these columns:

- `DisplayName`
- `UserPrincipalName`
- `PhoneNumber`
- `VoiceEnabled`
- `VoiceLicenseSku`
- `VoiceServicePlan`

## `validation/feed-quality.json`

Consumer expectation is intentionally narrow:

- consumability status
- file presence checks
- required column checks
- row counts
- anomaly counts

## Versioning posture

- **PATCH** — non-breaking fixes
- **MINOR** — additive optional fields or files
- **MAJOR** — breaking path, file, or schema changes

## Consumer behavior rules

`uc-m365-portfolio` must:

- validate the contract before consumption
- treat the feed as **immutable input**
- generate its own outputs under its own `./out/` tree
- avoid hidden mutation or enrichment of the feed source itself

## Public review angle

This contract is deliberately documented in the public repo because it helps reviewers understand that the portfolio is not “smaller now”; it is **better aligned**:

- private producer for real collection
- public consumer for evidence, presentation, and handover outputs
