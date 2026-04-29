# Demo path

The official demonstration path uses the bundled feed fixture under `tests/Fixtures/feed-sample/`.

It demonstrates feed-driven technical artefacts and evidence outputs rather than a full architecture dossier.

## Step 1 — validate the feed

```powershell
./tooling/Validate-FeedContract.ps1 -FeedPath ./tests/Fixtures/feed-sample
```

## Step 2 — generate audit / DAT snippet outputs

```powershell
./src/TeamsPhone/Exports/Invoke-TeamsPhoneDatExport.ps1 -FeedPath ./tests/Fixtures/feed-sample -RunId demo001
```

## Step 3 — generate the evidence pack

```powershell
./src/Compliance/EvidencePacks/Invoke-TeamsPhoneEvidencePack.ps1 -FeedPath ./tests/Fixtures/feed-sample -RunId demo001
```

## Inspect the outputs

Open these first:

- `./out/audit/teamsphone-demo001/DAT-snippets.md`
- `./out/evidence/teamsphone-evidence-demo001/SUMMARY.md`
- `./out/evidence/teamsphone-evidence-demo001.zip`

## Output reading guide

### Human-facing artefacts

- `DAT-snippets.md` (technical annex content)
- `SUMMARY.md`
- the evidence ZIP

### Supporting artefacts

- `consumer-run.json`
- `tenant-teamsphone-*.json`
- `teamsphone-inventory.*`
- `feed-quality.json`

### Traceability artefacts

- `feed-input/`
- `manifest.json`
