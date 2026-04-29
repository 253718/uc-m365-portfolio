# Tooling

## Main commands

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

### One-command demo

```powershell
./tooling/Invoke-Demo.ps1
```
