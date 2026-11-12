# 01: Record, privately save, and replay a story

Status: resolved
Approval: Ticket breakdown approved by the user on 2026-11-12; GitHub publication authorized.
Implementation gate: Authorized by the user on 2026-11-12; follow the approved dependency graph and retain unmet external prerequisites.
GitHub publication: Published and linked to the parent specification.
GitHub issue: https://github.com/octiv-fortune/story-within/issues/2
Milestone: M1
Blocked by: None (first implementation frontier after all review gates)
GitHub blockers: None
External prerequisites: No external service. Actual microphone/playback verification requires a physical iPhone before claiming audio-device readiness.
Spec acceptance: AC-01, AC-05, AC-09, AC-10, AC-14, AC-15, AC-23
Parent specification: [Approved Story Within specification](../spec.md) (approved in chat on 2026-11-12).

## What to build

A parent can open a minimal branded Home, enter a simple recording studio, record actual speech, stop, save privately, and reopen the same narration after relaunch. This is the first thin path through the native UI, audio service, durable assets, repository, and workflow verification.

## Acceptance criteria

- [x] The existing project builds for iOS with an iOS 17 minimum, iPhone-first layouts, Apple frameworks only, and no unrequested desktop/visionOS targets; any unavailable oldest-OS runtime is recorded as a verification gap.
- [x] Home provides Create a Story and recent-story/empty states; Explore may show a truthful empty local collection until demo content is supplied. New drafts receive editable default titles and stable identity without requiring AI.
- [x] The first record action explains microphone access; granting it captures audible speech, while denial/restriction shows recovery guidance without entering a false recording state.
- [x] Stop finalizes actual audio into durable app storage and a private recoverable draft before review reports success. Empty or failed recordings cannot be saved as successful narration.
- [x] Review provides play, pause, replay, elapsed time/duration, title editing, and private save. Starting capture stops playback; no audio autoplays.
- [x] A stopped draft and a saved story both reopen after relaunch with the same owned recording and identity. Home can reopen recent stories; saving succeeds without network or generated text.
- [x] A failed audio/metadata write reports failure and retains recoverable narration for retry. Back/discard requires an explicit keep/discard choice and does not silently erase a finalized take.
- [x] A native workflow test exercises record-result → stop → private save → reopen using deterministic audio results and real temporary local storage; device verification separately captures and replays actual speech.

## Demonstration

Record a short sentence, stop, play it, save privately, relaunch, and play the same sentence from Home; repeat a controlled failed save and successful retry.

## Delivery constraints and verification

Use native Swift/SwiftUI and Apple frameworks only. Keep recording/playback real in the app. Inspect and document relevant Mobbin patterns before implementing a new primary screen; adapt interactions without screen copying. Apply Dynamic Type, VoiceOver, contrast, Reduce Motion, clear state and large touch targets to each changed flow. Verify the user-visible behavior at the agreed app-workflow seam with temporary storage/deterministic services, and keep the build and relevant checks green. Tests using audio doubles do not establish device microphone behavior.

Keep this slice narrow: one recording format, a default title, simple Home/review, and no coaching or translation. Introduce only the app/service/repository boundaries needed for this behavior; no standalone scaffolding or prefactoring ticket is warranted for the starter.

## Comments

- 2026-11-12: Proposed with to-tickets following specification approval. Ticket approval is pending. Dependencies are implementation prerequisites, not authorization to start. M1 delivery is prioritized before M2 rollout; independent M2 service paths intentionally do not block one another. External prerequisites remain real blockers even when not represented by ticket numbers. After approval, only sufficiently specified/unblocked work becomes ready-for-agent; unresolved service/content/device prerequisites remain visible. No feature implementation or GitHub publication has occurred.


- 2026-11-12: The user approved this ticket and the dependency graph and authorized GitHub publication. Implementation remains ON HOLD. The triage status describes specification/prerequisite readiness, not authorization to execute; needs-info tickets retain the external content, service, review, or device prerequisites stated above.

- 2026-11-12: Published as https://github.com/octiv-fortune/story-within/issues/2; native sub-issue and blocking relationships preserved. Implementation remains ON HOLD.

- 2026-11-12: The user resumed implementation with implement-spec, starting at the first unblocked ticket, and required native build verification before changes. The prior implementation hold is revoked.

## Answer

Resolved on 2026-11-12. Merge commit `383e0639dd00a5cf08343294c1d7cbde7e670e44` integrates reviewed source `9cefefe8e16ff2340c124f767c4815fd254f8e1a` from `codex/story-within-ticket-01` into `codex/story-within-mvp`, preserving implementation `0499164` and device evidence `8c101da`. The no-ff merge had no conflicts and its tree exactly matched the reviewed candidate. Independent Standards and Spec reviewers reported their findings resolved after rechecking the final correction.

The app now records real speech, retains a durable private draft, supports review/title editing/private save, and reopens the same story and narration. Failure/retry and explicit discard retain ownership of original, staging, and final audio paths. See the [implementation and verification evidence](../evidence/ticket-01.md), including inspected Mobbin references and installed-store compatibility coverage.

Verification: all 12 native application-workflow tests passed on actual iOS 17.5 / iPhone 13 simulator with deterministic audio results and real temporary storage (`/private/tmp/story-within-ticket01-review-final-test.log`). Reviewed Debug simulator and Release iOS builds passed. The merged integration passed the generic Debug iOS Simulator build with signing disabled: `/private/tmp/story-within-integration-ticket01.log`; outputs: `/private/tmp/story-within-integration-ticket01`. The first sandboxed attempt could not access required CoreSimulator/Swift macro services; its log is `/private/tmp/story-within-integration-ticket01-sandbox.log`. The same build passed with host access. No source changes or full test-suite rerun were necessary after the identical-tree merge.

The user confirmed audible original audio plus edited-title/audio persistence after close/reopen on a physical iPhone 15 Pro, iOS 27.0.1. That installed build preceded the final failure-recovery corrections; those corrections passed the workflow and build checks above. iOS 17.5 is the accepted oldest available runtime; exact iOS 17.0 remains unavailable. Microphone-denial/restriction recovery is verified deterministically; manual Settings recovery remains unrecorded. Native recording-state announcements and Home accessibility-size layout were checked as documented, but the complete physical VoiceOver and large Dynamic Type studio/review journeys remain unverified. These limits are retained for subsequent verification and are not inferred from test doubles.

Local ticket resolution only; GitHub publication/closure remains with the coordinating agent.
