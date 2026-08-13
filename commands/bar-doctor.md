---
name: bar-doctor
description: Live health check — is BAR Observatory's recorder actually working, and what did it capture?
---
$ARGUMENTS

Run BAR Observatory's live diagnostic — distinct from the deterministic report, this answers
"is the recorder healthy right now?" not "what happened in this session?"

1. Determine the database path from `$ARGUMENTS`, defaulting to `.bar/ambient.sqlite`. If no
   database has been initialized yet, run `bar doctor` with no argument — it still reports on the
   `bar` binary itself.
2. Run: `bar doctor <db>`
3. Summarize the result plainly: which checks passed, which warned, and — critically — which
   capture channels actually have rows versus which are honestly reported as not recorded. Never
   round a warning up to "everything's fine."
