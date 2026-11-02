# Question Policy

Ask only a question whose answer materially changes a decision. Do not ask a developer to choose internal implementation details when a safe recommendation can be made.

## Question budget

- Maximum active questions: value of `agent_orchestration.question_budget`; default `3`.
- Ask the smallest number that unlocks the next meaningful stage.
- Present a recommended answer, brief reason, concise options, and a custom answer path.
- Record unanswered questions in `Foundation/00-Control/Open-Questions.md` with impact and safe default, if any.

## Good question

“Is this an offline prototype or an online prototype? I recommend online prototype because public article testing is part of your goal.”

## Bad question

“Choose HTTP framework, ORM, state library, cache, queue, database driver, and deployment region.”

The second question belongs to agent composition unless the developer explicitly requests the complete choice list.
