# 04: Request prepared inspiration without interrupting narration

Status: ready-for-agent
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

- [ ] During active capture, Pause for inspiration pauses the actual recorder before displaying the hint.
- [ ] While paused, an explicit parent action advances an ordered cue list; cues are text-only and visibly identified as prepared demo or generic cues as appropriate.
- [ ] No hint fetch requires a live service during capture, no hint speaks/autoplays, and viewing a cue never resumes capture automatically.
- [ ] Exhausted or unavailable cues show a useful state while Resume and Stop remain available.
- [ ] Workflow checks and a device narration → pause → hint → resume → stop → replay demonstration retain narration from both sides of the pause.

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
