# 11: Transcribe a real recording and preserve parent corrections

Status: needs-info
Approval: Ticket breakdown approved by the user on 2026-11-12; GitHub publication authorized.
Implementation gate: Authorized by the user on 2026-11-12; follow the approved dependency graph and retain unmet external prerequisites.
GitHub publication: Published and linked to the parent specification.
GitHub issue: https://github.com/octiv-fortune/story-within/issues/12
Milestone: M2
Blocked by: 06: Edit and manage stories in the personal library
GitHub blockers: https://github.com/octiv-fortune/story-within/issues/7
External prerequisites: Secure transcription proxy, agreed operation contract/limits, actual audio fixtures, and competent review of the claimed transcription language.
Spec acceptance: AC-09, AC-14, AC-15, AC-17, AC-19, AC-21
Parent specification: [Approved Story Within specification](../spec.md) (approved in chat on 2026-11-12).

## What to build

A parent can request transcription of a finalized recording, correct the returned text and language, and reopen those corrections without risking the original narration.

## Acceptance criteria

- [ ] Define the TranscriptionService boundary with deterministic fixtures before wiring its live implementation; any sample text is labeled as a sample and never presented as recognition of arbitrary recorded speech.
- [ ] Before enabling live requests, record the available secure proxy operation, audio/size/duration limits, supported transcription language(s), authentication, retention behavior, timeout/cancellation rules, result provenance, and error contract.
- [ ] Explain that the finalized recording is sent for transcription, require the parent's deliberate consent, and send only the selected audio with necessary language information.
- [ ] A real recorded English test fixture yields live editable text and optional detected language. Parent-selected source language remains correctable; additional transcription languages are not implied by translation support.
- [ ] Preserve original audio and manual text through failure/cancellation. A delayed result offers review/replacement rather than overwriting newer parent edits; transcript/source revisions allow existing translations to be flagged when present.
- [ ] Generated versus parent-edited provenance and text survive save/relaunch. Unsupported audio/language and service errors show retry/manual-entry paths without mock fallback.
- [ ] Contract/workflow tests cover revision races and recoveries; actual recorded-audio → proxy → edit → save/reopen demonstrates the live behavior.

## Demonstration

Record real speech, consent to transcription, correct a word/language, save and relaunch; change manual text during a slow request and show it is not overwritten.

## Delivery constraints and verification

Use native Swift/SwiftUI and Apple frameworks only. Keep recording/playback real in the app. Inspect and document relevant Mobbin patterns before implementing a new primary screen; adapt interactions without screen copying. Apply Dynamic Type, VoiceOver, contrast, Reduce Motion, clear state and large touch targets to each changed flow. Verify the user-visible behavior at the agreed app-workflow seam with temporary storage/deterministic services, and keep the build and relevant checks green. Tests using audio doubles do not establish device microphone behavior.

Depends on editable review/persistence, not live coaching. Keep cloud transcription opt-in; recording/saving continue to work without it.

## Comments

- 2026-11-12: Proposed with to-tickets following specification approval. Ticket approval is pending. Dependencies are implementation prerequisites, not authorization to start. M1 delivery is prioritized before M2 rollout; independent M2 service paths intentionally do not block one another. External prerequisites remain real blockers even when not represented by ticket numbers. After approval, only sufficiently specified/unblocked work becomes ready-for-agent; unresolved service/content/device prerequisites remain visible. No feature implementation or GitHub publication has occurred.


- 2026-11-12: The user approved this ticket and the dependency graph and authorized GitHub publication. Implementation remains ON HOLD. The triage status describes specification/prerequisite readiness, not authorization to execute; needs-info tickets retain the external content, service, review, or device prerequisites stated above.

- 2026-11-12: Published as https://github.com/octiv-fortune/story-within/issues/12; native sub-issue and blocking relationships preserved. Implementation remains ON HOLD.

- 2026-11-12: The user resumed implementation with implement-spec, starting at the first unblocked ticket, and required native build verification before changes. The prior implementation hold is revoked.
