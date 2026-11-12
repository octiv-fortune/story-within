# 02: Pause and resume one continuous narration

Status: claimed
Approval: Ticket breakdown approved by the user on 2026-11-12; GitHub publication authorized.
Implementation gate: Authorized by the user on 2026-11-12; follow the approved dependency graph and retain unmet external prerequisites.
GitHub publication: Published and linked to the parent specification.
GitHub issue: https://github.com/octiv-fortune/story-within/issues/3
Milestone: M1
Blocked by: 01: Record, privately save, and replay a story
GitHub blockers: https://github.com/octiv-fortune/story-within/issues/2
External prerequisites: Physical iPhone for conclusive audio continuity verification.
Spec acceptance: AC-06, AC-23
Parent specification: [Approved Story Within specification](../spec.md) (approved in chat on 2026-11-12).

## What to build

A parent can take a break and resume the same real recording, then hear narration from both sides of the pause in one saved story.

## Acceptance criteria

- [ ] Record, Pause, Resume, and Stop controls and accessible state announcements reflect actual capture state rather than a UI-only timer.
- [ ] Pausing excludes the break from recorded duration; resuming appends to the same narration without dropping the earlier segment or creating a second visible story.
- [ ] Stopping while recording or paused finalizes a valid playable asset; repeated or rapid actions cannot start competing recorders.
- [ ] Saving/relaunching preserves both spoken segments, and cancellation/errors retain recoverable audio.
- [ ] Workflow checks exercise allowed transitions and duration semantics; a physical iPhone recording with distinguishable speech before/after the pause confirms real continuity.

## Demonstration

Say 'beginning', pause for several seconds, resume and say 'ending', then stop, save, relaunch, and hear both segments without the pause being counted as narration.

## Delivery constraints and verification

Use native Swift/SwiftUI and Apple frameworks only. Keep recording/playback real in the app. Inspect and document relevant Mobbin patterns before implementing a new primary screen; adapt interactions without screen copying. Apply Dynamic Type, VoiceOver, contrast, Reduce Motion, clear state and large touch targets to each changed flow. Verify the user-visible behavior at the agreed app-workflow seam with temporary storage/deterministic services, and keep the build and relevant checks green. Tests using audio doubles do not establish device microphone behavior.

Prepared hints are deliberately added by ticket 04; this slice establishes the functional pause state they require.

## Comments

- 2026-11-12: Proposed with to-tickets following specification approval. Ticket approval is pending. Dependencies are implementation prerequisites, not authorization to start. M1 delivery is prioritized before M2 rollout; independent M2 service paths intentionally do not block one another. External prerequisites remain real blockers even when not represented by ticket numbers. After approval, only sufficiently specified/unblocked work becomes ready-for-agent; unresolved service/content/device prerequisites remain visible. No feature implementation or GitHub publication has occurred.


- 2026-11-12: The user approved this ticket and the dependency graph and authorized GitHub publication. Implementation remains ON HOLD. The triage status describes specification/prerequisite readiness, not authorization to execute; needs-info tickets retain the external content, service, review, or device prerequisites stated above.

- 2026-11-12: Published as https://github.com/octiv-fortune/story-within/issues/3; native sub-issue and blocking relationships preserved. Implementation remains ON HOLD.

- 2026-11-12: The user resumed implementation with implement-spec, starting at the first unblocked ticket, and required native build verification before changes. The prior implementation hold is revoked.

- 2026-11-12: Ticket 01 resolved after reviewed integration, 12 native workflow passes, green Debug/Release builds, and user-confirmed physical narration/save/reopen. This ticket is now claimed in an isolated worktree.

- 2026-11-12: Reviewed pause/resume code integrated into `codex/story-within-mvp` via no-ff merge `3c2dc080d5cfaa638b79325eb3ede2924d8c2478`, preserving candidate `dc9d004f90ece9c7d4ed91c0259b0e7d42364ca6`. The merge was conflict-free and its entire tree matched the tested candidate. The coordinating review found no concrete defect in the native recorder/workflow/UI changes. See [ticket 02 evidence](../evidence/ticket-02.md).

- 2026-11-12: Candidate verification passed all 17 native workflow tests on iOS 17.5, including the 12 existing regressions, plus Debug simulator and Release iOS builds. The merged integration passed one generic Debug iOS Simulator build with code signing disabled: `/private/tmp/story-within-integration-ticket02.log`; outputs: `/private/tmp/story-within-integration-ticket02`. No source delta required a duplicate full-suite run. Tests use deterministic audio/clock results and real temporary storage; they do not establish microphone continuity.

- 2026-11-12: Status remains **claimed**, and acceptance completion is pending physical iPhone verification: distinguishable speech before and after a several-second pause, one playable narration with the break excluded from duration, then save/relaunch/replay. Full VoiceOver/Dynamic Type walkthrough also remains unverified. The coordinating agent owns installation and the user check; no phone interaction or GitHub update was performed during this merge.
