# 08: Choose and withdraw an explicitly local community preview

Status: ready-for-agent
Approval: Ticket breakdown approved by the user on 2026-11-12; GitHub publication authorized.
Implementation gate: Authorized by the user on 2026-11-12; follow the approved dependency graph and retain unmet external prerequisites.
GitHub publication: Published and linked to the parent specification.
GitHub issue: https://github.com/octiv-fortune/story-within/issues/9
Milestone: M1
Blocked by: 06: Edit and manage stories in the personal library; 07: Discover and listen to original demo stories
GitHub blockers: https://github.com/octiv-fortune/story-within/issues/7, https://github.com/octiv-fortune/story-within/issues/8
External prerequisites: None beyond the completed demo collection.
Spec acceptance: AC-11, AC-13, AC-14, AC-21
Parent specification: [Approved Story Within specification](../spec.md) (approved in chat on 2026-11-12).

## What to build

A parent can deliberately preview a saved story in this device's community collection, inspect exactly what is visible, and return it to private visibility without deleting their personal copy.

## Acceptance criteria

- [ ] Saving stays private by default; private stories never enter community queries or cards.
- [ ] A separate preview step shows attribution, original audio, transcript, and selected available translations and clearly says the story is available on this device only.
- [ ] Confirmation explicitly mentions the original voice recording. Cancelling changes no visibility; failed persistence never shows successful publication.
- [ ] Confirmed local preview is discoverable with its scope label after relaunch; withdrawal removes it from community results while retaining the private personal copy.
- [ ] Coaching history and child-specific descriptions are excluded from discovery metadata; parents can review any personal content contained in the actual audio/text before confirming.
- [ ] Deleting an owned story removes its local preview without affecting bundled content; workflow checks verify private → cancel → preview → withdraw and persistence failure.

## Demonstration

Save privately and show it absent from Explore; cancel a preview, then confirm it, find it locally, withdraw it, and replay the retained private copy.

## Delivery constraints and verification

Use native Swift/SwiftUI and Apple frameworks only. Keep recording/playback real in the app. Inspect and document relevant Mobbin patterns before implementing a new primary screen; adapt interactions without screen copying. Apply Dynamic Type, VoiceOver, contrast, Reduce Motion, clear state and large touch targets to each changed flow. Verify the user-visible behavior at the agreed app-workflow seam with temporary storage/deterministic services, and keep the build and relevant checks green. Tests using audio doubles do not establish device microphone behavior.

No remote upload, account, public URL, or cross-device sharing is implied. The preview must be able to show optional translations when later language tickets add them.

## Comments

- 2026-11-12: Proposed with to-tickets following specification approval. Ticket approval is pending. Dependencies are implementation prerequisites, not authorization to start. M1 delivery is prioritized before M2 rollout; independent M2 service paths intentionally do not block one another. External prerequisites remain real blockers even when not represented by ticket numbers. After approval, only sufficiently specified/unblocked work becomes ready-for-agent; unresolved service/content/device prerequisites remain visible. No feature implementation or GitHub publication has occurred.


- 2026-11-12: The user approved this ticket and the dependency graph and authorized GitHub publication. Implementation remains ON HOLD. The triage status describes specification/prerequisite readiness, not authorization to execute; needs-info tickets retain the external content, service, review, or device prerequisites stated above.

- 2026-11-12: Published as https://github.com/octiv-fortune/story-within/issues/9; native sub-issue and blocking relationships preserved. Implementation remains ON HOLD.

- 2026-11-12: The user resumed implementation with implement-spec, starting at the first unblocked ticket, and required native build verification before changes. The prior implementation hold is revoked.
