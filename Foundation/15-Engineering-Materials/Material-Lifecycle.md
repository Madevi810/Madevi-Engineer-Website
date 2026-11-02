# Material Lifecycle

| Status | Meaning | Agent behavior |
| --- | --- | --- |
| `candidate` | Known option, not yet verified for this project | Explain uncertainty; do not present as safe default |
| `recommended` | Fits current requirements with recorded evidence | Explain fit and alternatives |
| `review_due` | Time-sensitive, changed, or incomplete evidence | Re-check before implementation or release |
| `deprecated` | Retained only for migration/history | Do not select for new work unless developer accepts the risk |
| `blocked` | Incompatible, unsafe, unlicensed, unavailable, or outside scope | Explain why and propose alternatives |

Refresh an evidence record when a security concern, breaking change, pricing/model change, license change, provider change, or release decision makes it material.
