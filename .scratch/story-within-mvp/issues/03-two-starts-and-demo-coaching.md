# 03: Develop an idea through the demo storytelling coach

Status: resolved
Approval: Ticket breakdown approved by the user on 2026-11-12; GitHub publication authorized.
Implementation gate: Authorized by the user on 2026-11-12; follow the approved dependency graph and retain unmet external prerequisites.
GitHub publication: Published and linked to the parent specification.
GitHub issue: https://github.com/octiv-fortune/story-within/issues/4
Milestone: M1
Blocked by: 01: Record, privately save, and replay a story
GitHub blockers: https://github.com/octiv-fortune/story-within/issues/2
External prerequisites: None; deterministic local coaching only.
Spec acceptance: AC-02, AC-03, AC-04, AC-14, AC-21
Parent specification: [Approved Story Within specification](../spec.md) (approved in chat on 2026-11-12).

## What to build

A parent can start with an idea or a child preference, shape it through brief contextual demo coaching, and enter the already working recording journey whenever ready.

## Acceptance criteria

- [x] Both starting approaches accept parent text and enter the same conversation; deterministic replies reflect the chosen approach and at least the parent's supplied character, setting, or preference.
- [x] Each response has at most one primary question; Skip works without answering; Start Recording remains available with no minimum exchange count.
- [x] A StoryCoachService boundary returns contextual short guidance and prepared text cues through a deterministic mock implementation, visibly labeled as demo coaching.
- [x] Test scenarios preserve the parent's decisions, never output a completed story, and make no diagnostic, therapeutic, or invented cultural-authenticity claims.
- [x] Starting recording carries the working story context and prepared cues into the studio. Cue preparation failure leaves recording available with clearly generic fallback cues.
- [x] Conversation and child preferences remain session-scoped; saving the narration does not copy them into story metadata or discovery data.
- [x] Workflow checks cover both entries, skip, immediate recording, and cue-preparation failure; recording and save/reopen remain functional offline.

## Demonstration

Start once with a magical tortoise idea and once with a child interest; observe different contextual questions, skip one, and record without completing a questionnaire.

## Delivery constraints and verification

Use native Swift/SwiftUI and Apple frameworks only. Keep recording/playback real in the app. Inspect and document relevant Mobbin patterns before implementing a new primary screen; adapt interactions without screen copying. Apply Dynamic Type, VoiceOver, contrast, Reduce Motion, clear state and large touch targets to each changed flow. Verify the user-visible behavior at the agreed app-workflow seam with temporary storage/deterministic services, and keep the build and relevant checks green. Tests using audio doubles do not establish device microphone behavior.

This introduces the mock/live seam without adding a provider, credential, backend, or complete-story generator.

## Comments

- 2026-11-12: Proposed with to-tickets following specification approval. Ticket approval is pending. Dependencies are implementation prerequisites, not authorization to start. M1 delivery is prioritized before M2 rollout; independent M2 service paths intentionally do not block one another. External prerequisites remain real blockers even when not represented by ticket numbers. After approval, only sufficiently specified/unblocked work becomes ready-for-agent; unresolved service/content/device prerequisites remain visible. No feature implementation or GitHub publication has occurred.


- 2026-11-12: The user approved this ticket and the dependency graph and authorized GitHub publication. Implementation remains ON HOLD. The triage status describes specification/prerequisite readiness, not authorization to execute; needs-info tickets retain the external content, service, review, or device prerequisites stated above.

- 2026-11-12: Published as https://github.com/octiv-fortune/story-within/issues/4; native sub-issue and blocking relationships preserved. Implementation remains ON HOLD.

- 2026-11-12: The user resumed implementation with implement-spec, starting at the first unblocked ticket, and required native build verification before changes. The prior implementation hold is revoked.

- 2026-11-12: Ticket 01 resolved after reviewed integration, 12 native workflow passes, green Debug/Release builds, and user-confirmed physical narration/save/reopen. This ticket is now claimed in an isolated worktree.
- 2026-11-12: Mobbin coach search failed twice with HTTP transport error. The user explicitly approved native patterns now and revisiting Mobbin later; do not claim uninspected coach references.

## Answer

Resolved locally on 2026-11-12 from the approved workflow criteria, reviewed source, native tests, and compilation evidence. No-ff merge `c1a0cfad0964ec3fb3d8ecc20d29714d91aee030` integrates candidate `d87f0d145f7152cea39bb8d65970faaf6e078da1` from `codex/story-within-ticket-03`, including accepted ticket 06 via `f77505a`. The merge was conflict-free and its committed tree exactly matched the tested candidate. The coordinating agent reviewed deterministic/contextual guidance, parent-choice preservation, bounded service context, pending-request guards, generic cue fallback, and session-only data with no concrete defect found.

Home Create now offers idea or listener-interest starts into the same visibly labeled demo coach. Skip and immediate recording remain available; short contextual replies have at most one primary question. Prepared or clearly generic fallback cues accompany session context into the existing studio. Session-only coach/child-preference data is cleared when reopening a story and never copied into persisted metadata. Recent and personal-library stories continue to open review directly. See [ticket 03 implementation evidence](../evidence/ticket-03.md).

Final candidate verification passed all **31 native workflow tests** on iOS 27.0, covering all accepted recording/pause/library regressions and eight coaching scenarios: `/private/tmp/story-within-03-review-integrated-tests.log`. Candidate Debug simulator and Release iOS builds passed. One merged integration generic Debug iOS Simulator build passed with signing disabled: `/private/tmp/story-within-integration-ticket03.log`; outputs: `/private/tmp/story-within-integration-ticket03`. No source delta required a duplicate full-suite run. A concurrent project-file formatting change was preserved outside this merge/tracker commit; its parsed plist was semantically identical to the committed candidate project.

The user explicitly authorized native patterns after two Mobbin transport failures: “Proceed with native patterns; revisit Mobbin.” Coach-reference inspection remains deferred. Interactive CUA verification was blocked by the locked Mac and unsuccessful automatic unlock; no bypass was attempted. Interactive typing/navigation, rendered layout, full Dynamic Type/VoiceOver traversal, and new physical microphone behavior remain unverified. This resolution does not claim those checks or the still-pending ticket 02 physical continuity result. No phone or GitHub action was performed during integration.
