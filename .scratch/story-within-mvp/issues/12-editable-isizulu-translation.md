# 12: Translate reviewed text into isiZulu and retain corrections

Status: needs-info
Approval: Ticket breakdown approved by the user on 2026-11-12; GitHub publication authorized.
Implementation gate: Authorized by the user on 2026-11-12; follow the approved dependency graph and retain unmet external prerequisites.
GitHub publication: Published and linked to the parent specification.
GitHub issue: https://github.com/octiv-fortune/story-within/issues/13
Milestone: M2
Blocked by: 06: Edit and manage stories in the personal library
GitHub blockers: https://github.com/octiv-fortune/story-within/issues/7
External prerequisites: Secure translation proxy, agreed contract, and a competent isiZulu reviewer with actual fixture/result review. Backend implementation/deployment requires separately reviewed scope if not already available.
Spec acceptance: AC-14, AC-15, AC-18, AC-19, AC-20, AC-21
Parent specification: [Approved Story Within specification](../spec.md) (approved in chat on 2026-11-12).

## What to build

A parent can translate reviewed source text into a validated isiZulu target, compare and correct it, save it with the original story, and recognize when later source edits make it stale.

## Acceptance criteria

- [ ] Introduce the TranslationService interface and deterministic known-story fixtures first. Sample translations are explicitly labeled and are not advertised as live output or unrelated recording recognition.
- [ ] Before live readiness, record the secure proxy's text/language/result/error contract, request/source revision, size limits, authentication, retention, timeout/cancellation rules, and supported English → isiZulu direction.
- [ ] Disable requests for blank text, show the exact source and target for review, explain cloud processing, and require a deliberate action before sending only the necessary text/language.
- [ ] A real request returns text displayed alongside the preserved original with accurate AI-generated/unverified provenance; allow corrections, save/reopen, and confirmation before replacing manually corrected text.
- [ ] Source/language edits mark incompatible translations as needing review. Late responses cannot silently replace newer source revisions or corrections; errors/cancellation preserve local work and never substitute a mock as a live result.
- [ ] Keep playback in the original human voice; show saved translations in personal story detail and any selected local preview without changing private defaults.
- [ ] Record actual service results and competent isiZulu-speaker review for agreed sample cases, meaning, wording, names, repetition, and observed limitations. Advertise the target only after review passes; failure returns the support decision for review.
- [ ] Workflow/contract tests cover persistence, provenance, staleness, replacement consent, and service failure; the demo includes a real translated result and parent correction.

## Demonstration

Manually enter or use a reviewed English transcript, request isiZulu, correct and save the result, relaunch, then edit the source and show the needs-review state while original audio still plays.

## Delivery constraints and verification

Use native Swift/SwiftUI and Apple frameworks only. Keep recording/playback real in the app. Inspect and document relevant Mobbin patterns before implementing a new primary screen; adapt interactions without screen copying. Apply Dynamic Type, VoiceOver, contrast, Reduce Motion, clear state and large touch targets to each changed flow. Verify the user-visible behavior at the agreed app-workflow seam with temporary storage/deterministic services, and keep the build and relevant checks green. Tests using audio doubles do not establish device microphone behavior.

Manual source text from 06 is sufficient, so transcription and live coaching are not technical blockers. Translation-language quality is independent of audio transcription support.

## Comments

- 2026-11-12: Proposed with to-tickets following specification approval. Ticket approval is pending. Dependencies are implementation prerequisites, not authorization to start. M1 delivery is prioritized before M2 rollout; independent M2 service paths intentionally do not block one another. External prerequisites remain real blockers even when not represented by ticket numbers. After approval, only sufficiently specified/unblocked work becomes ready-for-agent; unresolved service/content/device prerequisites remain visible. No feature implementation or GitHub publication has occurred.


- 2026-11-12: The user approved this ticket and the dependency graph and authorized GitHub publication. Implementation remains ON HOLD. The triage status describes specification/prerequisite readiness, not authorization to execute; needs-info tickets retain the external content, service, review, or device prerequisites stated above.

- 2026-11-12: Published as https://github.com/octiv-fortune/story-within/issues/13; native sub-issue and blocking relationships preserved. Implementation remains ON HOLD.

- 2026-11-12: The user resumed implementation with implement-spec, starting at the first unblocked ticket, and required native build verification before changes. The prior implementation hold is revoked.
