# 05: Protect takes during interruptions, navigation, and replacement

Status: resolved
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

- [x] Backgrounding, audio-session interruptions, and loss of an active route pause or safely finalize capture and explain the resulting state; the microphone never restarts automatically.
- [x] Captured content remains reviewable/recoverable after an interruption, and a parent can explicitly resume when supported or retain the finalized take.
- [x] Leaving capture/review with unsaved work offers meaningful keep/discard/cancel choices. Cancelling leaves the current recording/edits intact.
- [x] Re-recording requires confirmation. Keep the existing finalized take until a successful replacement is durably retained; a failed or cancelled replacement preserves the original.
- [x] Missing/corrupt audio, storage errors, and denied access produce truthful retry/recovery states without false save success.
- [x] Workflow checks cover these recoveries; physical iPhone checks cover at least backgrounding, an audio interruption/route change when available, and reopening finalized drafts. Forced-termination recovery of an in-flight take is not promised.

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

- 2026-11-12: Prerequisites resolved, including user-confirmed physical recording/demo playback and readable controls. Claimed next local-MVP slice in isolated worktree.

- 2026-11-12: Implementer candidate protects the original finalized take until a confirmed replacement is fully copied, validated, and committed under the same story identity. Cancellation/failed copy/failed write/empty replacement retain the original and authored metadata; replacement voice becomes private and needs fresh local-preview consent. Recovery validates retained audio before save/cleanup/preview, preserves owned source/staging copies if the promoted asset is missing, and invalidates delayed permission responses after interruption. Accepted hints and visibility source merged; all 56 combined native iOS 17.5 workflow tests plus Debug simulator and Release iOS builds passed. See [ticket 05 evidence](../evidence/ticket-05.md). Physical backgrounding, available route/interruption scenarios, finalized-draft/replacement playback, and VoiceOver replacement checks remain for coordinator/user review; status remains claimed, with no issue closure, push, or phone action by the implementer.

- 2026-11-12: Reviewed candidate `9113572` integrated as `d5cfdd0`; identical committed tree and merged generic Debug Simulator build passed. See [integration evidence](../evidence/ticket-05.md#coordinator-integration-checkpoint). Status remains claimed pending physical interruption/route-change/replacement and accessibility acceptance; no device or GitHub completion is inferred.

- 2026-11-12: Independent M1 review's stopped-replacement relaunch/retry data-loss finding repaired in isolated branch `codex/story-within-recovery-fix` (`6a73f29`, `f839c99`, merged integration `109bcdc`). Atomic filesystem recovery metadata restores the new take identity/duration without a SwiftData schema change; absent/corrupt/foreign/stale records cannot silently discard audio, and cancellation preserves original-take backups. Eight regression checks added; all 64 combined iOS 17.5 workflow tests plus final Debug Simulator and Release iOS builds passed. See [M1 review fix evidence](../evidence/m1-review-fixes.md). Status remains claimed pending physical interruption/route/replacement and accessibility acceptance; no phone or GitHub completion is inferred.


- 2026-11-12: Following earlier user-passed background finalization, existing-story/reopen and replacement-cancellation checks, the user confirmed the real interruption result: “Passed; microphone stays stopped and draft plays.” A one-device Clock alarm procedure was offered because a second phone was unavailable. The reply does not explicitly name the trigger, so do not claim an incoming-call, alarm-specific or headset route-change result. Combined with the native workflow/relaunch/error regressions, functional ticket 05 is resolved. Full VoiceOver/accessibility-size Dynamic Type, permission-denial and remaining physical failure verification remain open under ticket 09.

## Answer

Resolved on codex/story-within-mvp from reviewed recovery source, 64 passing native workflow tests, green Debug/Release/signed device builds, and user-confirmed physical background/replacement/interruption recovery. The captured draft remains playable without automatically restarting the microphone. See [recovery repair evidence](../evidence/m1-review-fixes.md) and [device walkthrough](../evidence/ticket-09-walkthrough.md). This does not establish forced-termination recovery of an in-flight take or complete M1 accessibility acceptance.
