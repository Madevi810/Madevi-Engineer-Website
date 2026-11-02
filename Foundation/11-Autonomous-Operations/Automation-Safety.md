# Automation Safety Rules

Automation is a policy-controlled capability, not a default MEW behavior.

Before it is enabled, the Foundation must record:

- permitted module and write paths;
- schedule and timezone;
- runner and credential boundary;
- monthly/operation budget ceiling;
- quality and test gate;
- notification and audit location;
- publishing rule;
- rollback procedure;
- kill switch;
- developer approval.

Automation may draft plans or produce sandbox output. It must not publish, delete data, access real-user secrets, or make payment actions unless a separate explicit policy permits it.
