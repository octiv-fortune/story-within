# 13: Offer isiXhosa as a second validated African translation target

Status: needs-info
Approval: Ticket breakdown approved by the user on 2026-11-12; GitHub publication authorized.
Implementation gate: Authorized by the user on 2026-11-12; follow the approved dependency graph and retain unmet external prerequisites.
GitHub publication: Published and linked to the parent specification.
GitHub issue: https://github.com/octiv-fortune/story-within/issues/14
Milestone: M2
Blocked by: 12: Translate reviewed text into isiZulu and retain corrections
GitHub blockers: https://github.com/octiv-fortune/story-within/issues/13
External prerequisites: Competent isiXhosa reviewer and actual service support for the candidate direction. Failed validation leaves the milestone's two-language criterion unmet until a reviewed decision is made.
Spec acceptance: AC-18, AC-19, AC-20
Parent specification: [Approved Story Within specification](../spec.md) (approved in chat on 2026-11-12).

## What to build

A parent can choose between two honestly supported African text-translation targets and retain separate corrected versions of the same original story.

## Acceptance criteria

- [ ] Validate actual English → isiXhosa proxy capability and competent speaker review; record direction, sample source/result text, reviewer, observed errors, and limitations before exposing it as supported.
- [ ] The existing language chooser distinguishes supported, unavailable, and sample-only capabilities. Do not claim isiXhosa support if review fails; return the language-set decision for review rather than inventing a replacement.
- [ ] Selecting isiXhosa submits the correct target without changing the source or overwriting an existing isiZulu result; each translation retains its own provenance, corrections, source revision, and review status.
- [ ] Compare/edit/save/reopen works for both target versions, including local story detail/selected preview, and source changes flag both as needing review when appropriate.
- [ ] Workflow/contract tests distinguish target selection and version retention; real service calls and reviewer-approved examples demonstrate both directions advertised by the UI.

## Demonstration

Translate the same reviewed English text into both targets, correct one, relaunch, and switch between the retained versions while listening to the unchanged original recording.

## Delivery constraints and verification

Use native Swift/SwiftUI and Apple frameworks only. Keep recording/playback real in the app. Inspect and document relevant Mobbin patterns before implementing a new primary screen; adapt interactions without screen copying. Apply Dynamic Type, VoiceOver, contrast, Reduce Motion, clear state and large touch targets to each changed flow. Verify the user-visible behavior at the agreed app-workflow seam with temporary storage/deterministic services, and keep the build and relevant checks green. Tests using audio doubles do not establish device microphone behavior.

The dependency on 12 is for the implemented shared translation workflow and persistence behavior, not because isiZulu linguistically gates isiXhosa.

## Comments

- 2026-11-12: Proposed with to-tickets following specification approval. Ticket approval is pending. Dependencies are implementation prerequisites, not authorization to start. M1 delivery is prioritized before M2 rollout; independent M2 service paths intentionally do not block one another. External prerequisites remain real blockers even when not represented by ticket numbers. After approval, only sufficiently specified/unblocked work becomes ready-for-agent; unresolved service/content/device prerequisites remain visible. No feature implementation or GitHub publication has occurred.


- 2026-11-12: The user approved this ticket and the dependency graph and authorized GitHub publication. Implementation remains ON HOLD. The triage status describes specification/prerequisite readiness, not authorization to execute; needs-info tickets retain the external content, service, review, or device prerequisites stated above.

- 2026-11-12: Published as https://github.com/octiv-fortune/story-within/issues/14; native sub-issue and blocking relationships preserved. Implementation remains ON HOLD.

- 2026-11-12: The user resumed implementation with implement-spec, starting at the first unblocked ticket, and required native build verification before changes. The prior implementation hold is revoked.
