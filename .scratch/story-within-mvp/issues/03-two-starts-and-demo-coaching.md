# 03: Develop an idea through the demo storytelling coach

Status: claimed
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

- [ ] Both starting approaches accept parent text and enter the same conversation; deterministic replies reflect the chosen approach and at least the parent's supplied character, setting, or preference.
- [ ] Each response has at most one primary question; Skip works without answering; Start Recording remains available with no minimum exchange count.
- [ ] A StoryCoachService boundary returns contextual short guidance and prepared text cues through a deterministic mock implementation, visibly labeled as demo coaching.
- [ ] Test scenarios preserve the parent's decisions, never output a completed story, and make no diagnostic, therapeutic, or invented cultural-authenticity claims.
- [ ] Starting recording carries the working story context and prepared cues into the studio. Cue preparation failure leaves recording available with clearly generic fallback cues.
- [ ] Conversation and child preferences remain session-scoped; saving the narration does not copy them into story metadata or discovery data.
- [ ] Workflow checks cover both entries, skip, immediate recording, and cue-preparation failure; recording and save/reopen remain functional offline.

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
