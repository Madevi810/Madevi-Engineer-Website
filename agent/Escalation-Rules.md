# Escalation Rules

| Condition | Agent action |
| --- | --- |
| Missing low-risk detail | Record an assumption and continue |
| Missing material decision | Ask a concise question with recommendation |
| Compatibility concern | Mark WARNING, explain impact and alternatives |
| Objective conflict | Mark CONFLICT and wait for developer decision |
| Critical security/rights/data risk | Mark CRITICAL/BLOCKED; do not implement or publish |
| Feature remembered after approval | Create Change Request and impact analysis |
| Tool/runtime unavailable | Report LIMITATION and use safe fallback |
| External write requested | Require policy, scope, and developer approval |
