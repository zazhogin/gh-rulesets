# GitHub Rulesets & Actions

This repository automatically applies rulesets and Actions settings to repositories 
based on a gh search query, on a schedule.

---

## Prerequisites

Make sure to [create a personal access token](https://github.com/settings/tokens) with the admin scopes named `POLICY_TOKEN`.

---

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

JSON имеет два основных раздела, conditions и rules. Маппинга conditions к rules нет. Если мы хотим написать разные rules на разные ветки, указанные в 
conditions, придется создать два rulesets.

Rulesets легко сгенерировать используя:

1. Chat GPT, дополнительное обучение не требуется
2. GitHub UI
- Settings - Rules - Rulesets - New ruleset
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

**NOTES:** Некоторые ruleset требуют Enterprise подписку GitHub, например для стандартизации имен веток.

![enterprise-restrictions.png](docs/assets/enterprise-restrictions.png)

---





1. Create a ruleset manually in the GitHub UI (`Settings → Rulesets`).
2. Export it to JSON using UI
3. Add the JSON file under `policies/`.
4. Reference it in the workflow (`rulesets-apply.yml`) with a `search_query` to specify repositories.
Multiple rulesets supported.

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
