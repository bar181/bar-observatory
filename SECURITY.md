# Security Policy

BAR Observatory is a **local-only** measurement instrument: capture and report run entirely on
your machine, with no network in the capture→report path. It never transmits captured data.

- **BYOK / no key required.** Primary use is a Claude Code subscription; no API key is needed.
  When a key is present it is forwarded verbatim by the capture proxy and never logged or persisted.
- **Redaction.** PII is scrubbed on write; absolute host paths are excluded from ranking and reports.
- **Reporting a vulnerability.** Open a private security advisory on the GitHub repository. Please do
  not file public issues for suspected vulnerabilities.
