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
