# Security Policy

BAR Observatory is a **local-only** measurement instrument: capture and report run entirely on
your machine, with no network in the capture→report path. It never transmits captured data.

- **BYOK / no key required.** Primary use is a Claude Code subscription; no API key is needed.
  When a key is present it is forwarded verbatim by the capture proxy and never logged or persisted.
- **Redaction.** A narrow, specific set of patterns is redacted automatically on write:
  secret-shaped API keys (a small set of known vendor prefixes), email-shaped tokens, and the
  username segment of absolute home-directory paths. This is **not** a general PII or secrets
  scanner — full message text, the agent's thinking blocks, file contents, and tool output are
  otherwise stored as captured. Read
  [what data actually gets stored](wiki/human-md/enterprise.md#what-data-actually-gets-stored)
  before treating a capture database as safe to hand to someone else as-is; `bar-sanitize` exists
  for exactly that case.
- **Reporting a vulnerability.** Open a private security advisory on the GitHub repository. Please do
  not file public issues for suspected vulnerabilities.
