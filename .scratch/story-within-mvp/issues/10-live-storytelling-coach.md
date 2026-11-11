# 10: Coach a parent's story through the live service

Status: needs-info
Approval: Ticket breakdown approved by the user on 2026-11-12; GitHub publication authorized.
Implementation gate: Authorized by the user on 2026-11-12; follow the approved dependency graph and retain unmet external prerequisites.
GitHub publication: Published and linked to the parent specification.
GitHub issue: https://github.com/octiv-fortune/story-within/issues/11
Milestone: M2
Blocked by: 03: Develop an idea through the demo storytelling coach
GitHub blockers: https://github.com/octiv-fortune/story-within/issues/4
External prerequisites: Secure coaching proxy and reviewed contract/configuration. If it must be built or deployed by this project, first obtain a separate reviewed backend scope; this ticket does not silently authorize a backend stack or deployment.
Spec acceptance: AC-03, AC-04, AC-14, AC-15, AC-16, AC-21
Parent specification: [Approved Story Within specification](../spec.md) (approved in chat on 2026-11-12).

## What to build

A parent can choose disclosed live coaching, receive contextual short guidance, and continue into the same recording journey while retaining authorship and an explicit service mode.

## Acceptance criteria

- [ ] Before implementation readiness, record an approved available proxy endpoint, owner, client authentication/abuse controls, provider capability, operational limits and retention/deletion behavior, plus the coaching request/result/error contract.
- [ ] Live coaching uses URLSession behind the existing StoryCoachService interface. Provider secrets remain server-side and are absent from the source shipped to devices, bundle, and logs.
- [ ] Explain which coaching text/context leaves the device and obtain a deliberate action before the first cloud request. Send only relevant bounded context and never create a persistent child profile.
- [ ] Actual service scenarios produce at most one primary question, honor the parent's decisions and skip/start-recording actions, avoid whole-story generation, and avoid diagnostic, therapeutic, or invented cultural claims.
- [ ] Prepare optional cues before capture; cue failure cannot block recording or trigger live narration analysis.
- [ ] Loading, cancellation, timeout, unavailable service, and invalid response states retain parent input and offer retry/continue. A failure never silently swaps in mock output.
- [ ] Native contract/workflow fixtures cover success/errors/cancellation, and real proxy calls demonstrate the complete parent action → live response → recording path; explicit demo mode remains usable offline.

## Demonstration

Choose live coaching after disclosure, provide a tortoise idea, answer one question, then enter recording; repeat with an unavailable service and continue without losing input.

## Delivery constraints and verification

Use native Swift/SwiftUI and Apple frameworks only. Keep recording/playback real in the app. Inspect and document relevant Mobbin patterns before implementing a new primary screen; adapt interactions without screen copying. Apply Dynamic Type, VoiceOver, contrast, Reduce Motion, clear state and large touch targets to each changed flow. Verify the user-visible behavior at the agreed app-workflow seam with temporary storage/deterministic services, and keep the build and relevant checks green. Tests using audio doubles do not establish device microphone behavior.

Technical blocker is the existing coach workflow, not transcription or community publication. Prioritize M1 delivery before M2 rollout.

## Comments

- 2026-11-12: Proposed with to-tickets following specification approval. Ticket approval is pending. Dependencies are implementation prerequisites, not authorization to start. M1 delivery is prioritized before M2 rollout; independent M2 service paths intentionally do not block one another. External prerequisites remain real blockers even when not represented by ticket numbers. After approval, only sufficiently specified/unblocked work becomes ready-for-agent; unresolved service/content/device prerequisites remain visible. No feature implementation or GitHub publication has occurred.


- 2026-11-12: The user approved this ticket and the dependency graph and authorized GitHub publication. Implementation remains ON HOLD. The triage status describes specification/prerequisite readiness, not authorization to execute; needs-info tickets retain the external content, service, review, or device prerequisites stated above.

- 2026-11-12: Published as https://github.com/octiv-fortune/story-within/issues/11; native sub-issue and blocking relationships preserved. Implementation remains ON HOLD.

- 2026-11-12: The user resumed implementation with implement-spec, starting at the first unblocked ticket, and required native build verification before changes. The prior implementation hold is revoked.
