# 08: Choose and withdraw an explicitly local community preview

Status: resolved
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

- [x] Saving stays private by default; private stories never enter community queries or cards.
- [x] A separate preview step shows attribution, original audio, transcript, and selected available translations and clearly says the story is available on this device only.
- [x] Confirmation explicitly mentions the original voice recording. Cancelling changes no visibility; failed persistence never shows successful publication.
- [x] Confirmed local preview is discoverable with its scope label after relaunch; withdrawal removes it from community results while retaining the private personal copy.
- [x] Coaching history and child-specific descriptions are excluded from discovery metadata; parents can review any personal content contained in the actual audio/text before confirming.
- [x] Deleting an owned story removes its local preview without affecting bundled content; workflow checks verify private → cancel → preview → withdraw and persistence failure.

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

- 2026-11-12: Prerequisites resolved, including user-confirmed physical recording/demo playback and readable controls. Claimed next local-MVP slice in isolated worktree.

- 2026-11-12: Implemented local saved-story review → original-voice/device-only confirmation → read-only local discovery → withdrawal retaining the private personal copy, with truthful visibility labels and fresh consent after kept edits. Full 43 native workflow tests passed, including all 36 prior regressions. Evidence and pending physical/privacy/VoiceOver walkthrough are recorded in [ticket 08 evidence](../evidence/ticket-08.md). Status remains claimed for root review, integration and manual acceptance; no remote issue action was performed.

## Answer

Resolved locally on 2026-11-12 from reviewed source, native workflow tests, and build evidence. No-ff merge `48ec00fa5491a463e926c5829f4f0e32a2f5e33f` integrates candidate `433ce71e8f04ce48c611032282eaca3237c36b55` from `codex/story-within-ticket-08`. The merge was conflict-free and its committed tree exactly matched the tested candidate. The coordinating review found no concrete defect in saved/private-first gates, exact saved-content snapshot, original-voice/device-only confirmation and revalidation, cancellation, private-save withdrawal, truthful failed commits, or saved-local-preview query filtering. The existing persisted visibility String schema is retained.

Private saves remain excluded from Explore. A separate review names attribution, original audio, transcript, and this-device-only scope; it truthfully reports that no translations currently exist. Confirmation requires valid nonempty original audio and kept saved content. Cancellation does not publish; successful confirmation survives relaunch; withdrawal retains the personal story/audio; edits require fresh consent. Owned deletion removes its preview while preserving bundled demos and session-only coaching data never enters discovery. See [ticket 08 evidence](../evidence/ticket-08.md).

All **43 native workflow tests** passed on iOS 17.5: all 36 accepted regressions plus seven privacy/preview cases, using deterministic audio and real temporary storage (`/private/tmp/story-within-08-green-full.log`). Candidate Debug simulator and Release iOS builds passed. One integration generic Debug iOS Simulator build passed with signing disabled: `/private/tmp/story-within-integration-ticket08.log`; outputs: `/private/tmp/story-within-integration-ticket08`. No source delta required a duplicate full-suite run. The known unstaged Xcode project formatting delta was preserved byte-for-byte, excluded from this commit, and verified semantically identical to the committed project.

Physical private/cancel/exact-content consent/local discovery/withdraw/delete walkthrough, privacy comprehension, VoiceOver, full Dynamic Type and rendered control checks remain unverified for the ticket 09 acceptance gate. Source/tests/builds do not establish those manual results. No phone, GitHub, or further source merge occurred in this checkpoint.


- 2026-11-12: Reopened after the updated iPhone walkthrough: the user reports a blank popup on tapping Review for local community preview. Other requested recording/hint/reopen, replacement-cancel, background-finalization and existing-story checks were reported as looking great. First-opening sheet rendering requires an isolated UI reproduction and repair; workflow-only consent tests did not catch this presentation defect. Preview confirmation/discovery/withdrawal acceptance remains open.


## First-opening sheet repair and verification

- 2026-11-12: Integrated reviewed candidate 4d44844 through no-ff merge f43aa10; app change bde75c2 binds sheet presentation directly to its story item. Baseline rendered UI reproduced an empty white sheet despite valid native snapshot preparation. The same actual-app regression passes first tap, Cancel, private review, reopen and Cancel. The simulator-only runner and fictional native fixture are retained under test-support/preview-sheet; no production test hooks, project targets, dependencies or schema changes were added.
- All 64 workflow tests, Debug simulator and Release iOS builds passed. The identical integration source passed a generic Debug simulator build. A signed iPhone build passed and the existing app was updated in place. The user confirmed: “Preview opens immediately; cancel/reopen and withdrawal pass.” Functional ticket 08 is resolved. Full accessibility and remaining physical recovery checks remain open for ticket 09; complete MVP readiness is not claimed. See [diagnosis and actual results](../evidence/preview-sheet-fix.md).
