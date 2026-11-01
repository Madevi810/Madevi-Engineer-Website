# UWF CLI

Run UWF without arguments for the beginner-friendly menu.

| Command | Purpose |
| --- | --- |
| uwf | Interactive menu |
| uwf init name | Create a workspace |
| uwf doctor | Check Linux command and PATH requirements |
| uwf status | Display current manifest status |
| uwf next | Show the active Foundation stage and recommended next action |
| uwf validate | Run standard Foundation validation |
| uwf review stage-N | Validate and show the stage review template |
| uwf approve implementation --project name | Activate an approved implementation area |
| uwf version | Display installed UWF version |
| uwf update | Install the latest stable patch in the current major/minor line |
| uwf update --check | Show the stable patch update without changing files |
| uwf update --minor | Permit a minor update in the current major line |
| uwf update --major | Permit the newest stable major release |
| uwf update --edge | Explicitly use moving main for testing |

The CLI never stores credentials or silently updates itself. A new install uses the newest stable release tag; main is only used with the explicit edge option.
