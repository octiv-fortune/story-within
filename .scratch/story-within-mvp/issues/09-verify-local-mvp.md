# 09: Verify the complete local MVP on simulator and iPhone

Status: needs-info
Approval: Ticket breakdown approved by the user on 2026-11-12; GitHub publication authorized.
Implementation gate: Authorized by the user on 2026-11-12; follow the approved dependency graph and retain unmet external prerequisites.
GitHub publication: Published and linked to the parent specification.
GitHub issue: https://github.com/octiv-fortune/story-within/issues/10
Milestone: M1 verification gate
Blocked by: 04: Request prepared inspiration without interrupting narration; 05: Protect takes during interruptions, navigation, and replacement; 08: Choose and withdraw an explicitly local community preview
GitHub blockers: https://github.com/octiv-fortune/story-within/issues/5, https://github.com/octiv-fortune/story-within/issues/6, https://github.com/octiv-fortune/story-within/issues/9
External prerequisites: Physical iPhone and the permission-cleared demo collection. Unavailable device access is an explicit unmet verification gate, not a passing result.
Spec acceptance: AC-01, AC-02, AC-03, AC-04, AC-05, AC-06, AC-07, AC-08, AC-09, AC-10, AC-11, AC-12, AC-13, AC-14, AC-15, AC-21, AC-22, AC-23
Parent specification: [Approved Story Within specification](../spec.md) (approved in chat on 2026-11-12).

## What to build

The complete local parent/listener journey is demonstrated and its build, accessibility, privacy, recovery, and actual audio results are recorded before declaring the local MVP ready.

## Acceptance criteria

- [ ] Complete both start approaches → contextual demo coach → real narration → pause/hint/resume → review/manual text → private save/relaunch → community preview/withdrawal, plus bundled listening, without crashing.
- [ ] Relevant native workflow tests and a small UI smoke journey pass. Run Debug simulator and Release iOS compilation checks; record simulator/OS/device versions and signing or oldest-OS gaps accurately.
- [ ] On a physical iPhone, hear narration before and after a pause, verify elapsed duration, replay after relaunch, and check permission denial, background/interruption recovery, and a failed/retried save.
- [ ] Complete the main journey with accessibility-size Dynamic Type and VoiceOver; validate focus, state announcements, contrast, primary 44-point targets, Reduce Motion, predictable navigation, and no autoplay.
- [ ] Test offline operation, empty/missing assets, cancel/retry, private-story exclusion, draft/replacement preservation, and owned-content deletion.
- [ ] Record the walkthrough steps, real/demo capability inventory, permission evidence for demo content, observed results, and any remaining limitations. Do not claim local-MVP readiness with unmet essential acceptance criteria.

## Demonstration

Run and record one complete offline storytelling journey on iPhone, followed by the negative/recovery and accessibility checks.

## Delivery constraints and verification

Use native Swift/SwiftUI and Apple frameworks only. Keep recording/playback real in the app. Inspect and document relevant Mobbin patterns before implementing a new primary screen; adapt interactions without screen copying. Apply Dynamic Type, VoiceOver, contrast, Reduce Motion, clear state and large touch targets to each changed flow. Verify the user-visible behavior at the agreed app-workflow seam with temporary storage/deterministic services, and keep the build and relevant checks green. Tests using audio doubles do not establish device microphone behavior.

This is an integration/acceptance gate, not a delayed accessibility or testing implementation phase. Every preceding feature ticket includes its own accessible controls, regression checks, and working build.

## Comments

- 2026-11-12: Proposed with to-tickets following specification approval. Ticket approval is pending. Dependencies are implementation prerequisites, not authorization to start. M1 delivery is prioritized before M2 rollout; independent M2 service paths intentionally do not block one another. External prerequisites remain real blockers even when not represented by ticket numbers. After approval, only sufficiently specified/unblocked work becomes ready-for-agent; unresolved service/content/device prerequisites remain visible. No feature implementation or GitHub publication has occurred.


- 2026-11-12: The user approved this ticket and the dependency graph and authorized GitHub publication. Implementation remains ON HOLD. The triage status describes specification/prerequisite readiness, not authorization to execute; needs-info tickets retain the external content, service, review, or device prerequisites stated above.

- 2026-11-12: Published as https://github.com/octiv-fortune/story-within/issues/10; native sub-issue and blocking relationships preserved. Implementation remains ON HOLD.

- 2026-11-12: The user resumed implementation with implement-spec, starting at the first unblocked ticket, and required native build verification before changes. The prior implementation hold is revoked.


- 2026-11-12: Functional prerequisites 04/05/08 are resolved after user-confirmed hint/narration, background/replacement/interruption recovery, and first-open/cancel/reopen/withdrawal checks. Current source passes 64 native workflow tests, rendered preview UI regression, Debug simulator, Release iOS and signed iPhone builds. This gate remains needs-info pending complete accessibility-size Dynamic Type/VoiceOver/Reduce Motion and remaining physical negative/recovery verification. Actual interruption trigger was not specified, so no call/headset-specific result is asserted. See [walkthrough](../evidence/ticket-09-walkthrough.md).
