# Contract Artifact Signing

Release signing binds the generated wasm checksums and artifact manifest to a
named release signer. It does not replace external audit or staging deployment
evidence, but it gives auditors and operators a clear chain of custody for the
exact artifacts being reviewed.

## Payloads

After `scripts/prepare-audit-artifacts.sh` runs, sign these files from
`audit-artifacts/contracts`:

- `SHA256SUMS`
- `manifest.json`

The signing script writes detached signatures and `signatures.json` into the
same directory. Archive those files with the wasm artifacts and record the
signer identity in the staging release manifest.

## Cosign

```bash
cd backend/contracts
bash scripts/prepare-audit-artifacts.sh
SIGNER_ID=aethelred-contracts-release \
SIGNING_BACKEND=cosign \
COSIGN_PRIVATE_KEY="${COSIGN_PRIVATE_KEY}" \
bash scripts/sign-audit-artifacts.sh

COSIGN_PUBLIC_KEY_FILE=./release-cosign.pub \
SIGNING_BACKEND=cosign \
bash scripts/verify-audit-artifact-signatures.sh
```

## GPG

```bash
cd backend/contracts
bash scripts/prepare-audit-artifacts.sh
SIGNER_ID=aethelred-contracts-release \
SIGNING_BACKEND=gpg \
GPG_SIGNING_KEY=aethelred-contracts-release \
bash scripts/sign-audit-artifacts.sh

SIGNING_BACKEND=gpg \
bash scripts/verify-audit-artifact-signatures.sh
```

## Launch Policy

- Use a production-controlled signer, not a developer laptop key.
- Sign only after the release wasm build and checksum manifest are complete.
- Store detached signatures, `signatures.json`, `SHA256SUMS`, `manifest.json`,
  and wasm artifacts together in the release record.
- Rotate signer keys through the same operator sign-off process used for
  contract admins and emergency roles.
