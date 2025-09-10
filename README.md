# Rulesets Operator via gh-migrate-rulesets

This repo applies GitHub Repository Rulesets daily at 00:00 UTC for three profiles:
- Ansible Playbooks
- GitOps Branch
- GitOps Tags

## How it works
1. Each profile has a CSV under `policies/`.
2. A scheduled workflow resolves repositories using `gh search repos "<ORG + QUERY>"`.
3. The list is chunked and passed to `gh migrate-rulesets create <org> <repos...> -i <csv>`.

## Configure
- Set `SEARCH_QUERY` per profile in workflow `env`.
- Add `POLICY_TOKEN` (PAT with Administration: write on target repos/org) to repo secrets.
- Adjust CSV contents under `policies/*.csv`.

## Manual run
Go to **Actions → chosen profile → Run workflow**.
