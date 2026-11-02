# MEW CLI

Run MEW without arguments for the beginner-friendly menu.

| Command | Purpose |
| --- | --- |
| mew | Interactive menu |
| mew init name | Create a workspace |
| mew doctor | Check Linux command and PATH requirements |
| mew status | Display current manifest status |
| mew status --json | Display compact machine-readable workspace status |
| mew next | Show the active Foundation stage and recommended next action |
| mew next --json | Show machine-readable active-stage guidance |
| mew validate | Run standard Foundation validation |
| mew validate --json | Run validation with a machine-readable result |
| mew context [--json] | Show the safe read order and current AI-agent context |
| mew review stage-N | Validate and show the stage review template |
| mew change new "title" | Create a reviewable change request; it does not alter code |
| mew change assess CR-id | Show the required impact-analysis workflow for a request |
| mew change list | List recorded change requests |
| mew feature-gap audit | Create a dated missing-requirements audit draft |
| mew ui brief | Show the UI/UX creative-brief workflow |
| mew ui review | Show the responsive, accessibility, and simulation review workflow |
| mew template list | List original Foundation starter packs |
| mew template apply id | Add a starter-pack brief to the current workspace for review |
| mew reference [figcraft] | Show the clean-room UI/UX reference workflow; `figcraft` creates an analysis draft and marks it active |
| mew reference custom "name" | Create an active clean-room analysis draft for a custom reference |
| mew reference complete figcraft\|custom | Validate required analysis fields and mark the active reference analyzed |
| mew tool list | List local and external tool contracts |
| mew tool doctor | Validate local Tool Runtime requirements and contracts |
| mew tool capability | Show runtime capability declared in the manifest |
| mew tool run ID --dry-run | Record a safe local dry-run; external tools remain blocked |
| mew agent status\|route | Show orchestration state or role-routing rules |
| mew job list\|inspect ID\|cancel ID | Manage local dry-run job records |
| mew evaluation list\|inspect NAME\|run regression | Inspect scenarios or run test regression |
| mew runtime prepare | Create the agent-runtime capability profile; no capability is assumed |
| mew material list | Display the engineering-material catalog model |
| mew material assess | Begin a Composition Manifest review |
| mew compose plan | Open the required composition workflow |
| mew evidence list | List recorded external Evidence Cards |
| mew evidence add "name" | Create an evidence card for a reviewed source/material |
| mew research prepare | Create a research plan without performing a search |
| mew taxonomy plan | Open taxonomy and content-map planning |
| mew operations prepare | Prepare post-implementation content operations |
| mew operations status\|validate | Show or validate controlled content-operation status |
| mew content plan --count N | Set an approved-operation content target; does not draft/publish |
| mew capability | Show current MEW capability maturity and limitations |
| mew release check | Create or open the release-readiness checklist |
| mew plugin inspect id | Show a plugin's permissions, scope, effects, risk, and fallback |
| mew approve implementation --project name | Activate an approved implementation area |
| mew version | Display installed MEW version |
| mew update | Install the latest stable patch in the current major/minor line |
| mew update --check | Show the stable patch update without changing files |
| mew update --minor | Permit a minor update in the current major line |
| mew update --major | Permit the newest stable major release |
| mew update --edge | Explicitly use moving main for testing |

The CLI never stores credentials or silently updates itself. A new install uses the newest stable release tag; main is only used with the explicit edge option.

`--json` commands use only basic JSON fields and require no JSON-parser dependency. They are intended for Codex, Claude Code, Gemini CLI, Cursor, and other terminal agents. Agents must still read `AGENTS.md` and obey implementation gates.
# Engineering materials, evidence, and content operations

```bash
mew runtime prepare
mew material list
mew compose plan
mew evidence add "Official documentation"
mew research prepare
mew taxonomy plan
```

These commands create or open planning records. They do not perform hidden web searches, install dependencies, write application code, or publish content.

After the developer has approved implementation and `Project-Name-Project` exists, controlled content operations can be prepared:

```bash
mew operations prepare
mew content plan --count 200
mew operations status
mew operations validate
```

`mew operations prepare` creates `Project-Name-Project/Operations/` with a content map, production queue, rights ledger, and run history. Research, drafting, implementation writes, automation, and publishing remain separately governed.
