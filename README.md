# GitHub Rulesets & Actions

This repository automatically applies rulesets and Actions settings to repositories 
based on a gh search query, on a schedule.

## Prerequisites

Make sure to [create a personal access token](https://github.com/settings/tokens) with the admin scopes named `GH_TOKEN`.

## How to create GitHub rulesets

Rulesets являются JSON:

```json
{
  "name": "Ruleset name",
  "target": "branch",
  "enforcement": "active",
  "conditions": {
    ...
  },
  "rules": [
    {
      ...
    }
  ]
}
```

JSON has two main sections: `conditions` and `rules`. There is no direct mapping from `conditions` to `rules`.  
If you want to apply different rules to different branches specified in `conditions`, you need to create two separate rulesets.

Rulesets can be easily generated using:
1. ChatGPT (no additional training required)
2. GitHub UI
    - Settings → Rules → Rulesets → New ruleset
    - Export ruleset

![create-export-ruleset.png](docs/assets/create-export-ruleset.png)

Rulesets example:

```json
{
  "name": "Require PR for dev",
  "target": "branch",
  "enforcement": "active",
  "conditions": {
    "ref_name": {
      "include": [
        "refs/heads/dev"
      ],
      "exclude": []
    }
  },
  "rules": [
    {
      "type": "pull_request"
    }
  ]
}
```

**NOTES:** Some rulesets require a GitHub Enterprise subscription, for example to enforce branch naming standards.

![enterprise-restrictions.png](docs/assets/enterprise-restrictions.png)

## How to apply GitHub rulesets

1. Add created before JSON rulesets under `rulesets/`.
2. Create *-ruleset.yml under `.github/workflows/` using template:
```yml
name: GitOps Branch

on:
  schedule:
    - cron: "0 0 * * *"
  workflow_dispatch: {}

jobs:
  apply:
    uses: ./.github/workflows/rulesets-apply.yml
    with:
      search_repos: org:digital-iq in:name zazhogin-ansible archived:false fork:false
      rulesets_paths: |
        rulesets/allowed-branch-names.json
        rulesets/require-pr-for-dev.json
    secrets: inherit
```
3. Override the following fields:
- `cron` — schedule for applying rules
- `search_repos` — repository search rule for gh search
- `rulesets_paths` — list of rulesets

The workflow will:
- Find repositories matching the query (e.g. `org:digital-iq in:name ansible archived:false fork:false`).
- Delete all existing rulest.
- Apply the ruleset JSON if missing.

**NOTES:** gh search repos doesn't support regex, but supports [jq expressions](https://cli.github.com/manual/gh_search_repos).

## How to create GitHub Actions REST API calls

Rulesets do not cover GitHub Actions settings. To manage these, call the REST API directly with `gh api`.
For example, allow all actions and reusable workflows:

```bash
gh api -X PUT /repos/<owner>/<repo>/actions/permissions \
--input - <<'JSON'
{"enabled":true,"allowed_actions":"all"}
JSON
```

Visit [REST API endpoints for GitHub Actions permissions](https://docs.github.com/en/enterprise-server@3.16/rest/actions/permissions?apiVersion=2022-11-28) for more examples.

## How to apply GitHub Actions REST API calls

Create own or update existing *-actions.yml under `.github/workflows/` using section `Apply Actions`. For example:

```bash
gh api -X PUT "/repos/${OWNER}/${REPO}/actions/permissions" \
  -H "Accept: application/vnd.github+json" \
  -F enabled=true \
  -f allowed_actions=all
```