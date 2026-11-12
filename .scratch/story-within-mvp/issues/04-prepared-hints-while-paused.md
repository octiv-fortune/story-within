# 04: Request prepared inspiration without interrupting narration

Status: resolved
Approval: Ticket breakdown approved by the user on 2026-11-12; GitHub publication authorized.
Implementation gate: Authorized by the user on 2026-11-12; follow the approved dependency graph and retain unmet external prerequisites.
GitHub publication: Published and linked to the parent specification.
GitHub issue: https://github.com/octiv-fortune/story-within/issues/5
Milestone: M1
Blocked by: 02: Pause and resume one continuous narration; 03: Develop an idea through the demo storytelling coach
GitHub blockers: https://github.com/octiv-fortune/story-within/issues/3, https://github.com/octiv-fortune/story-within/issues/4
External prerequisites: Physical iPhone for actual narration preservation verification.
Spec acceptance: AC-06, AC-07, AC-14, AC-23
Parent specification: [Approved Story Within specification](../spec.md) (approved in chat on 2026-11-12).

## What to build

A parent can pause a real narration, request the next cue prepared from coaching, and resume without losing audio or hearing AI speak.

## Acceptance criteria

- [x] During active capture, Pause for inspiration pauses the actual recorder before displaying the hint.
- [x] While paused, an explicit parent action advances an ordered cue list; cues are text-only and visibly identified as prepared demo or generic cues as appropriate.
- [x] No hint fetch requires a live service during capture, no hint speaks/autoplays, and viewing a cue never resumes capture automatically.
- [x] Exhausted or unavailable cues show a useful state while Resume and Stop remain available.
- [x] Workflow checks and a device narration → pause → hint → resume → stop → replay demonstration retain narration from both sides of the pause.

## Demonstration

Develop a tortoise story, begin narrating, pause for a contextual cue, resume deliberately, then play and save the complete recording.

## Delivery constraints and verification

Use native Swift/SwiftUI and Apple frameworks only. Keep recording/playback real in the app. Inspect and document relevant Mobbin patterns before implementing a new primary screen; adapt interactions without screen copying. Apply Dynamic Type, VoiceOver, contrast, Reduce Motion, clear state and large touch targets to each changed flow. Verify the user-visible behavior at the agreed app-workflow seam with temporary storage/deterministic services, and keep the build and relevant checks green. Tests using audio doubles do not establish device microphone behavior.

02 supplies real pause/resume; 03 supplies contextual cues. Neither is an artificial ordering dependency.

## Comments

- 2026-11-12: Proposed with to-tickets following specification approval. Ticket approval is pending. Dependencies are implementation prerequisites, not authorization to start. M1 delivery is prioritized before M2 rollout; independent M2 service paths intentionally do not block one another. External prerequisites remain real blockers even when not represented by ticket numbers. After approval, only sufficiently specified/unblocked work becomes ready-for-agent; unresolved service/content/device prerequisites remain visible. No feature implementation or GitHub publication has occurred.


- 2026-11-12: The user approved this ticket and the dependency graph and authorized GitHub publication. Implementation remains ON HOLD. The triage status describes specification/prerequisite readiness, not authorization to execute; needs-info tickets retain the external content, service, review, or device prerequisites stated above.

- 2026-11-12: Published as https://github.com/octiv-fortune/story-within/issues/5; native sub-issue and blocking relationships preserved. Implementation remains ON HOLD.

- 2026-11-12: The user resumed implementation with implement-spec, starting at the first unblocked ticket, and required native build verification before changes. The prior implementation hold is revoked.

- 2026-11-12: Prerequisites resolved, including user-confirmed physical recording/demo playback and readable controls. Claimed next local-MVP slice in isolated worktree.

- 2026-11-12: Implemented optional contextual/generic paused cue consumption in the existing recording studio, with pause-before-display, ordered explicit advancement, explicit resume, and an exhausted state. No live cue request, speech playback, persisted coaching content, or auto-resume was added. Native workflow and build evidence is recorded in [ticket 04 evidence](../evidence/ticket-04.md). Status remains claimed pending parent review and a physical narration → hint → resume demonstration; interactive visual/VoiceOver checks were unavailable while the Mac was locked.

- 2026-11-12: No-ff merge `1ca4b49ec16c3602d9402ed616506da775bc8112` integrated reviewed candidate `903e345fe8665286910d8d17774c959274cdf7fc` into `codex/story-within-mvp`. The merge was conflict-free and its committed tree exactly matched the tested candidate. The coordinating review found no concrete defect in cue ordering/exhaustion, pause-before-display, failed-resume retention, explicit advancement, or native studio controls. No capture-time service request, cue speech/autoplay, or automatic resume was introduced. The existing Xcode project formatting delta remained unstaged and byte-for-byte unchanged; its parsed plist equals the committed project.

- 2026-11-12: Final combined native evidence passed **48 workflow tests** on iOS 17.5, including all 43 accepted cases and five hint cases: `/private/tmp/story-within-04-combined-full-tests.log`. Release iOS compilation passed. One merged integration generic Debug iOS Simulator build passed with signing disabled: `/private/tmp/story-within-integration-ticket04.log`; outputs: `/private/tmp/story-within-integration-ticket04`. Identical source required no duplicate full-suite run. Targeted iOS 27 passes and the documented full iOS 27 prelaunch stall remain in [ticket 04 evidence](../evidence/ticket-04.md); no reset/erase was performed.

- 2026-11-12: Status remains **claimed** pending the combined physical narration → actual pause → contextual/generic hint → explicit resume → stop → replay/save sequence after ticket 05 integration. New visual layout, full Dynamic Type and VoiceOver checks remain unverified. The coordinating agent owns the full-MVP installation/user check; no phone or GitHub action occurred in this integration step.


- 2026-11-12: The user completed the updated iPhone check including narration before a hint, Pause for inspiration, explicit cue/resume, narration afterward, save/reopen/play, and reported “Everything looks great,” identifying only the later local-preview sheet as faulty. Combined with the passing hint workflow cases and final 64-test suite, the functional hint acceptance is resolved. Full VoiceOver/accessibility-size Dynamic Type remains part of ticket 09 and is not inferred from this result.

## Answer

Resolved on codex/story-within-mvp after reviewed native hint integration, automated transition/exhaustion/failure checks, green builds, and the user-confirmed iPhone hint/narration journey. See [evidence](../evidence/ticket-04.md) and [current walkthrough](../evidence/ticket-09-walkthrough.md).
