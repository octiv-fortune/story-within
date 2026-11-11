# 05: Protect takes during interruptions, navigation, and replacement

Status: ready-for-agent
Approval: Ticket breakdown approved by the user on 2026-11-12; GitHub publication authorized.
Implementation gate: Authorized by the user on 2026-11-12; follow the approved dependency graph and retain unmet external prerequisites.
GitHub publication: Published and linked to the parent specification.
GitHub issue: https://github.com/octiv-fortune/story-within/issues/6
Milestone: M1
Blocked by: 02: Pause and resume one continuous narration
GitHub blockers: https://github.com/octiv-fortune/story-within/issues/3
External prerequisites: Physical iPhone; interruption/route-change scenarios depend on available device routes and must be reported accurately.
Spec acceptance: AC-05, AC-08, AC-10, AC-11, AC-15
Parent specification: [Approved Story Within specification](../spec.md) (approved in chat on 2026-11-12).

## What to build

A parent can recover from an interrupted recording or reconsider a take without the app pretending to record, silently deleting narration, or replacing a good recording with a failed attempt.

## Acceptance criteria

- [ ] Backgrounding, audio-session interruptions, and loss of an active route pause or safely finalize capture and explain the resulting state; the microphone never restarts automatically.
- [ ] Captured content remains reviewable/recoverable after an interruption, and a parent can explicitly resume when supported or retain the finalized take.
- [ ] Leaving capture/review with unsaved work offers meaningful keep/discard/cancel choices. Cancelling leaves the current recording/edits intact.
- [ ] Re-recording requires confirmation. Keep the existing finalized take until a successful replacement is durably retained; a failed or cancelled replacement preserves the original.
- [ ] Missing/corrupt audio, storage errors, and denied access produce truthful retry/recovery states without false save success.
- [ ] Workflow checks cover these recoveries; physical iPhone checks cover at least backgrounding, an audio interruption/route change when available, and reopening finalized drafts. Forced-termination recovery of an in-flight take is not promised.

## Demonstration

Interrupt a recording, return to the app and retain/play what was captured; then attempt a replacement, cancel or fail it, and verify the original is still available.

## Delivery constraints and verification

Use native Swift/SwiftUI and Apple frameworks only. Keep recording/playback real in the app. Inspect and document relevant Mobbin patterns before implementing a new primary screen; adapt interactions without screen copying. Apply Dynamic Type, VoiceOver, contrast, Reduce Motion, clear state and large touch targets to each changed flow. Verify the user-visible behavior at the agreed app-workflow seam with temporary storage/deterministic services, and keep the build and relevant checks green. Tests using audio doubles do not establish device microphone behavior.

01 already guarantees truthful writes and basic keep/discard behavior; this slice deepens interruption and replacement recovery rather than leaving ordinary data-loss protection until the end.

## Comments

- 2026-11-12: Proposed with to-tickets following specification approval. Ticket approval is pending. Dependencies are implementation prerequisites, not authorization to start. M1 delivery is prioritized before M2 rollout; independent M2 service paths intentionally do not block one another. External prerequisites remain real blockers even when not represented by ticket numbers. After approval, only sufficiently specified/unblocked work becomes ready-for-agent; unresolved service/content/device prerequisites remain visible. No feature implementation or GitHub publication has occurred.


- 2026-11-12: The user approved this ticket and the dependency graph and authorized GitHub publication. Implementation remains ON HOLD. The triage status describes specification/prerequisite readiness, not authorization to execute; needs-info tickets retain the external content, service, review, or device prerequisites stated above.

- 2026-11-12: Published as https://github.com/octiv-fortune/story-within/issues/6; native sub-issue and blocking relationships preserved. Implementation remains ON HOLD.

- 2026-11-12: The user resumed implementation with implement-spec, starting at the first unblocked ticket, and required native build verification before changes. The prior implementation hold is revoked.
