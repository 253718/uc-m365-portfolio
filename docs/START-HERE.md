# START HERE

This repository consumes a validated read-only feed and generates public-facing delivery artefacts such as DAT snippets, evidence packs, and review outputs.

It does not claim to generate a full architecture dossier from feed data alone.

## Read first

1. `docs/output-contract.md`
2. `docs/integration/ops-feed-contract.md`
3. `docs/offer/operating-model.md`
4. `docs/diagrams/architecture.md`

## Official demonstration path

### Validate the bundled feed fixture

```powershell
./tooling/Validate-FeedContract.ps1 -FeedPath ./tests/Fixtures/feed-sample
```

### Generate audit / DAT snippet outputs

```powershell
./src/TeamsPhone/Exports/Invoke-TeamsPhoneDatExport.ps1 -FeedPath ./tests/Fixtures/feed-sample -RunId demo001
```

### Generate the evidence pack

```powershell
./src/Compliance/EvidencePacks/Invoke-TeamsPhoneEvidencePack.ps1 -FeedPath ./tests/Fixtures/feed-sample -RunId demo001
```

### Open first

- `./out/audit/teamsphone-demo001/DAT-snippets.md`
- `./out/evidence/teamsphone-evidence-demo001/SUMMARY.md`
- `./out/evidence/teamsphone-evidence-demo001.zip`

## Repository checks

```powershell
./tooling/Verify-ReadOnly.ps1 -Root . -FailOnMatch
./tooling/Invoke-RepoTests.ps1
```
