# Crux shared config

`slack.json` is the single source of truth for Crux's Slack channels/DMs and
"Send for review" groups. It is symlinked to `~/.config/crux/slack.json`, which
is where the Crux native host reads it (re-read on every call) and where other
tools (agent skills, scripts) can read it too.

```jsonc
{
  "team": "T…",                // workspace id; target url = https://app.slack.com/client/<team>/<id>
  "enabled": false,            // master switch for Slack WRITES (default off)
  "allowAnyTarget": false,     // true = any channel may be written; false = declared targets only
  "targets": {                 // declared destinations (also the write allowlist)
    "<name>": { "id": "C…|D…|G…", "label": "human label" }
  },
  "reviewGroups": [            // "Send for review" menu entries
    "<target name>",           //   shorthand: one-target group
    { "name": "…", "targets": ["<target name or id>", …], "template": "Please review: {links}" }
  ]
}
```

Use it from the CLI: `crux slack targets`, `crux slack config`,
`crux slack send <target-name> --text … [--send]` (preview unless `--send`).
Full docs: `docs/tab-groups-cli.md` in the crux repo.
