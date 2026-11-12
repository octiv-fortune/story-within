# 09: Verify the complete local MVP on simulator and iPhone

Status: resolved
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

The local parent/listener journey is demonstrated and its functional, build, privacy, recovery and actual-audio results are recorded. Full accessibility verification is deferred by explicit user direction on 2026-11-12 and does not block the current functional MVP.

## Current demo acceptance criteria

These replace the broader release checklist for the user's explicitly narrowed iOS27/iPhone15Pro demo scope (2026-11-12).

- [x] Current iOS27 native Debug simulator, Release iOS and signed iPhone builds pass; install on the existing iPhone15Pro without resetting its data.
- [x] Actual on-device English coaching and real record → save → replay work on the phone. Recording remains the parent's original voice.
- [x] Retain prior user-confirmed pause/hints, save/reopen, existing-story preservation, replacement cancellation, background/interruption recovery, demo listening and local-preview/cancel/reopen/withdrawal results.
- [x] Record relevant deterministic workflow and rendered preview checks. Current coaching source passes 76 deterministic iOS27 tests; disclose the simulator asset-loading failure separately from phone success.
- [x] Record the real/demo boundary and user-directed deferrals without claiming unperformed checks passed.

Deferred from the original gate by the user's demo-only direction: older-device/iOS17 compatibility, full accessibility checks, additional physical failure injection and exhaustive release/language-quality scenarios. Controlled workflow error tests do not become physical-phone failure tests. Later transcription/translation features remain outside this demo slice.

## Demonstration

Demonstrate the functional local storytelling journey and record negative/recovery results at the agreed workflow/device boundaries. Full accessibility checks are deferred for the current MVP.

## Delivery constraints and verification

Use native Swift/SwiftUI and Apple frameworks only. Keep recording/playback real in the app. Inspect and document relevant Mobbin patterns before implementing a new primary screen; adapt interactions without screen copying. Apply Dynamic Type, VoiceOver, contrast, Reduce Motion, clear state and large touch targets to each changed flow. Verify the user-visible behavior at the agreed app-workflow seam with temporary storage/deterministic services, and keep the build and relevant checks green. Tests using audio doubles do not establish device microphone behavior.

This is an integration/acceptance gate, not a delayed accessibility or testing implementation phase. Every preceding feature ticket includes its own accessible controls, regression checks, and working build.

## Comments

- 2026-11-12: Proposed with to-tickets following specification approval. Ticket approval is pending. Dependencies are implementation prerequisites, not authorization to start. M1 delivery is prioritized before M2 rollout; independent M2 service paths intentionally do not block one another. External prerequisites remain real blockers even when not represented by ticket numbers. After approval, only sufficiently specified/unblocked work becomes ready-for-agent; unresolved service/content/device prerequisites remain visible. No feature implementation or GitHub publication has occurred.


- 2026-11-12: The user approved this ticket and the dependency graph and authorized GitHub publication. Implementation remains ON HOLD. The triage status describes specification/prerequisite readiness, not authorization to execute; needs-info tickets retain the external content, service, review, or device prerequisites stated above.

- 2026-11-12: Published as https://github.com/octiv-fortune/story-within/issues/10; native sub-issue and blocking relationships preserved. Implementation remains ON HOLD.

- 2026-11-12: The user resumed implementation with implement-spec, starting at the first unblocked ticket, and required native build verification before changes. The prior implementation hold is revoked.


- 2026-11-12: Functional prerequisites 04/05/08 are resolved after user-confirmed hint/narration, background/replacement/interruption recovery, and first-open/cancel/reopen/withdrawal checks. Current source passes 64 native workflow tests, rendered preview UI regression, Debug simulator, Release iOS and signed iPhone builds. This gate remains needs-info pending complete accessibility-size Dynamic Type/VoiceOver/Reduce Motion and remaining physical negative/recovery verification. Actual interruption trigger was not specified, so no call/headset-specific result is asserted. See [walkthrough](../evidence/ticket-09-walkthrough.md).


- 2026-11-12: User explicitly deferred accessibility checks to prioritize MVP functionality. The outstanding large-text prompt is withdrawn; no accessibility result is claimed. This gate now tracks remaining functional verification only. Existing 64 workflow tests, rendered preview UI regression, builds and user-confirmed actual-audio/preview/interruption results remain valid; physical permission-denial and failed-save behavior have not been independently observed on the phone and are not silently marked passed.


- 2026-11-12: Demo scope narrowed by the user to iOS 27 on the current iPhone 15 Pro: real on-device English coaching, record/pause/save/reopen/replay. Older-OS compatibility, accessibility and broader nonessential release checklists are deferred. Keep known functional evidence and limitations explicit; actual native generation on the demo phone remains pending. Do not request additional broad manual checklists for this demo.


## Answer

The focused iOS27/iPhone15Pro MVP demo is verified. After installation of source `3ff3d8d` (merge `53e59d9`), the user confirmed “Actual on-device coach responds; recording/save/replay work.” Earlier recording/privacy/recovery results remain recorded. This resolves the amended demo gate; it does not claim all original release/accessibility/language scenarios were performed. See [walkthrough](../evidence/ticket-09-walkthrough.md) and [Apple coaching evidence](../evidence/apple-coach.md).
