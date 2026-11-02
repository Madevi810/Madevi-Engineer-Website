# UWF CLI

Run UWF without arguments for the beginner-friendly menu.

| Command | Purpose |
| --- | --- |
| uwf | Interactive menu |
| uwf init name | Create a workspace |
| uwf doctor | Check Linux command and PATH requirements |
| uwf status | Display current manifest status |
| uwf status --json | Display compact machine-readable workspace status |
| uwf next | Show the active Foundation stage and recommended next action |
| uwf next --json | Show machine-readable active-stage guidance |
| uwf validate | Run standard Foundation validation |
| uwf validate --json | Run validation with a machine-readable result |
| uwf context [--json] | Show the safe read order and current AI-agent context |
| uwf review stage-N | Validate and show the stage review template |
| uwf change new "title" | Create a reviewable change request; it does not alter code |
| uwf change assess CR-id | Show the required impact-analysis workflow for a request |
| uwf change list | List recorded change requests |
| uwf feature-gap audit | Create a dated missing-requirements audit draft |
| uwf ui brief | Show the UI/UX creative-brief workflow |
| uwf ui review | Show the responsive, accessibility, and simulation review workflow |
| uwf template list | List original Foundation starter packs |
| uwf template apply id | Add a starter-pack brief to the current workspace for review |
| uwf reference [figcraft] | Show the clean-room UI/UX reference workflow; `figcraft` creates an analysis draft and marks it active |
| uwf reference custom "name" | Create an active clean-room analysis draft for a custom reference |
| uwf reference complete figcraft\|custom | Validate required analysis fields and mark the active reference analyzed |
| uwf capability | Show current UWF capability maturity and limitations |
| uwf release check | Create or open the release-readiness checklist |
| uwf plugin inspect id | Show a plugin's permissions, scope, effects, risk, and fallback |
| uwf approve implementation --project name | Activate an approved implementation area |
| uwf version | Display installed UWF version |
| uwf update | Install the latest stable patch in the current major/minor line |
| uwf update --check | Show the stable patch update without changing files |
| uwf update --minor | Permit a minor update in the current major line |
| uwf update --major | Permit the newest stable major release |
| uwf update --edge | Explicitly use moving main for testing |

The CLI never stores credentials or silently updates itself. A new install uses the newest stable release tag; main is only used with the explicit edge option.

`--json` commands use only basic JSON fields and require no JSON-parser dependency. They are intended for Codex, Claude Code, Gemini CLI, Cursor, and other terminal agents. Agents must still read `AGENTS.md` and obey implementation gates.
