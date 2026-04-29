# Output contract

The public repository consumes a validated read-only feed and writes artefacts under `./out/`.

It produces DAT snippets and evidence-oriented technical artefacts, not a full architecture dossier.

## Input contract

Official demonstration input:

- `tests/Fixtures/feed-sample/`

The feed contract is described in `docs/integration/ops-feed-contract.md` and validated by:

```powershell
./tooling/Validate-FeedContract.ps1 -FeedPath ./tests/Fixtures/feed-sample
```

## Output locations

The generated outputs are intended for review, evidence, and handover-supporting use.

### Audit / DAT snippet outputs

- `./out/audit/teamsphone-<RunId>/`

Typical files:

- `DAT-snippets.md`
- `consumer-run.json`
- `tenant-teamsphone-config.json`
- `tenant-teamsphone-callflows.json`
- `teamsphone-inventory.csv`
- `teamsphone-inventory.json`
- `feed-quality.json`

### Evidence pack outputs

- `./out/evidence/teamsphone-evidence-<RunId>/`
- `./out/evidence/teamsphone-evidence-<RunId>.zip`

Typical files:

- `manifest.json`
- `SUMMARY.md`
- `exports/...`

## Traceability

A staged copy of the consumed input is stored under `feed-input/` within a run directory.

## Reading order

Start with:

1. `DAT-snippets.md` for the generated technical annex content
2. `SUMMARY.md`
3. the evidence ZIP
