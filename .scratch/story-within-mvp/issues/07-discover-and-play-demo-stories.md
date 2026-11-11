# 07: Discover and listen to original demo stories

Status: needs-info
Approval: Ticket breakdown approved by the user on 2026-11-12; GitHub publication authorized.
Implementation gate: Authorized by the user on 2026-11-12; follow the approved dependency graph and retain unmet external prerequisites.
GitHub publication: Published and linked to the parent specification.
GitHub issue: https://github.com/octiv-fortune/story-within/issues/8
Milestone: M1
Blocked by: 01: Record, privately save, and replay a story
GitHub blockers: https://github.com/octiv-fortune/story-within/issues/2
External prerequisites: At least two original/permission-cleared human demo recordings with attribution and permission evidence. Content must be supplied or recorded with permission; never invent a license or reviewer.
Spec acceptance: AC-01, AC-12, AC-14, AC-15
Parent specification: [Approved Story Within specification](../spec.md) (approved in chat on 2026-11-12).

## What to build

A family can open Explore, choose a permission-cleared story, inspect attribution and language, and listen to an actual human recording without needing a network.

## Acceptance criteria

- [ ] Bundle a small collection of at least two original or permission-cleared stories with actual human recordings and recorded content permissions/attribution; silence or generated placeholder audio does not satisfy this ticket.
- [ ] Discovery cards and story detail expose title, creator, source language, and theme, plus any text/translation actually supplied with accurate provenance.
- [ ] All bundled entries are identified as demo content; seed identities remain stable and relaunching never duplicates the collection.
- [ ] Play, pause, replay, duration, and switching between stories work offline. Only one story plays at a time; entering capture stops playback; nothing autoplays.
- [ ] Empty, missing-asset, and playback-error states are actionable and do not corrupt personal stories.
- [ ] Workflow checks verify seed idempotence and discovery/player selection; manual listening confirms that every bundled recording is audible and permission-cleared.

## Demonstration

Open Explore offline, inspect two attributed stories, play each in turn, and relaunch to confirm the collection is not duplicated.

## Delivery constraints and verification

Use native Swift/SwiftUI and Apple frameworks only. Keep recording/playback real in the app. Inspect and document relevant Mobbin patterns before implementing a new primary screen; adapt interactions without screen copying. Apply Dynamic Type, VoiceOver, contrast, Reduce Motion, clear state and large touch targets to each changed flow. Verify the user-visible behavior at the agreed app-workflow seam with temporary storage/deterministic services, and keep the build and relevant checks green. Tests using audio doubles do not establish device microphone behavior.

Depends on 01 for the app navigation and functioning shared playback boundary; does not require personal text editing or coaching.

## Comments

- 2026-11-12: Proposed with to-tickets following specification approval. Ticket approval is pending. Dependencies are implementation prerequisites, not authorization to start. M1 delivery is prioritized before M2 rollout; independent M2 service paths intentionally do not block one another. External prerequisites remain real blockers even when not represented by ticket numbers. After approval, only sufficiently specified/unblocked work becomes ready-for-agent; unresolved service/content/device prerequisites remain visible. No feature implementation or GitHub publication has occurred.


- 2026-11-12: The user approved this ticket and the dependency graph and authorized GitHub publication. Implementation remains ON HOLD. The triage status describes specification/prerequisite readiness, not authorization to execute; needs-info tickets retain the external content, service, review, or device prerequisites stated above.

- 2026-11-12: Published as https://github.com/octiv-fortune/story-within/issues/8; native sub-issue and blocking relationships preserved. Implementation remains ON HOLD.

- 2026-11-12: The user resumed implementation with implement-spec, starting at the first unblocked ticket, and required native build verification before changes. The prior implementation hold is revoked.
