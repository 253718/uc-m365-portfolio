## Shared helpers (`src/_common`)

Shared utilities used across the public consumer repository.

### Included

- `Logging.ps1` — consistent console logging surface
- `FeedContract.ps1` — feed contract validation used by tooling and tests

### Notes

This folder stays intentionally small.
The public repo keeps only consumer-side helpers; tenant auth and producer-side operational libraries remain private.
