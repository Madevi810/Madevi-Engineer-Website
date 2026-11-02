# Manifest Schema Contract

Schema version `1` permits additive optional sections. Required top-level sections are `project`, `developer`, `foundation`, `agent_runtime`, `agent_orchestration`, `composition`, `external_evidence`, `automation`, `content_operations`, and `controls`.

The migration script adds compatible missing sections and creates a backup before changing a legacy manifest.
