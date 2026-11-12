# Standards review

Inspected commit: `9113572`, against `d4edaed2e38c2e6d12f1a24ba55833d99567d952` (complete local M1 candidate, tickets 01–08). Read-only review; no build, device, network, or repository mutation performed.

## Documented requirements

No concrete blocking breach established. Sources: `AGENTS.md`, all `docs/agents/*.md`, approved `.scratch/story-within-mvp/spec.md`. No glossary/ADRs, CONTRIBUTING, or dedicated coding standards were present. The native Apple-framework implementation, iOS 17 target, local/demo disclosures, local issue structure, and documented verification limits conform to the applicable constraints. Evidence records an explicit user exception for deferred Mobbin research; that exception is not a breach. M2 remains intentionally externally blocked.

## Heuristic judgment calls (nonblocking)

- **Divergent Change / Duplicated Code — `StoryWithin/StoryWorkflow.swift:397–456`.** New-take and replacement retention independently implement staging and promotion: `try FileManager.default.copyItem(at: url, to: staged)` and `try files.copyItem(at: url, to: staged)`. The same observable workflow also owns `ModelContext`, filename ownership scanning, filesystem rollback, coaching, and community consent. Asset retention changes consequently require reviewing several branches of this coordinator; the replacement branch already validates the promoted destination separately from the new-take branch. Consider a small local repository/asset implementation encapsulating shared promotion and ownership rules while retaining the current workflow test seam. This follows the direction of spec §1 (“application workflows coordinate services”) and §7's StoryRepository boundary, but those passages do not mandate a particular class decomposition, so this is not a mandatory-rule finding or merge blocker.

Recorded device/accessibility gaps remain acceptance work, not newly discovered coding-standard violations. This review does not independently establish those checks.
