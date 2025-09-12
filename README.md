# GitHub Rulesets & Actions Policies Automation

This repository contains GitHub Actions workflows that automatically apply
**repository rulesets** and **Actions settings** to multiple repositories
based on a search query.

## Rulesets

1. Create a ruleset manually in the GitHub UI (`Settings → Rulesets`).
2. Export it to JSON using UI
3. Add the JSON file under `policies/`.
4. Reference it in the workflow (`rulesets-apply.yml`) with a `search_query`.

The workflow will:
- Find repositories matching the query (e.g. `org:digital-iq in:name ansible archived:false fork:false`).
- Skip if the ruleset with the same name already exists.
- Apply the ruleset JSON if missing.

## Actions Settings

Rulesets do not cover **GitHub Actions settings**.  
To manage these, we call the REST API directly with `gh api`.

Examples:
- Allow all actions and reusable workflows:
  ```bash
  gh api -X PUT /repos/<owner>/<repo>/actions/permissions \
    --input - <<'JSON'
  {"enabled":true,"allowed_actions":"all"}
  JSON
