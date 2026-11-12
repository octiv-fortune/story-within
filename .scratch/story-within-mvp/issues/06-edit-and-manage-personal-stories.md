# 06: Edit and manage stories in the personal library

Status: resolved
Approval: Ticket breakdown approved by the user on 2026-11-12; GitHub publication authorized.
Implementation gate: Authorized by the user on 2026-11-12; follow the approved dependency graph and retain unmet external prerequisites.
GitHub publication: Published and linked to the parent specification.
GitHub issue: https://github.com/octiv-fortune/story-within/issues/7
Milestone: M1
Blocked by: 01: Record, privately save, and replay a story
GitHub blockers: https://github.com/octiv-fortune/story-within/issues/2
External prerequisites: None.
Spec acceptance: AC-09, AC-10, AC-11, AC-15, AC-21
Parent specification: [Approved Story Within specification](../spec.md) (approved in chat on 2026-11-12).

## What to build

A parent can review and correct story details and manually entered text, reopen them from a personal library, and deliberately delete a story and its owned recording.

## Acceptance criteria

- [x] Review edits title, creator display name, theme, source language, and manual transcript while preserving original audio. A blank title gets validation or an editable default; AI output is never required to save.
- [x] The personal library lists saved stories/drafts appropriately and reopens the same identity; successful edits and lifecycle state persist after relaunch.
- [x] Unsaved changes have keep/discard/cancel behavior; failed saves keep the editing session recoverable and never show false success.
- [x] Deletion requires confirmation, removes owned audio/text and any local preview reference, and does not delete bundled/shared demo assets; a failed deletion is not reported as complete.
- [x] Manual text is not labeled as AI transcription; coaching history and child preferences are absent from persisted discoverable metadata.
- [x] Workflow verification covers edit → save → reopen, failed/retried write, and delete/cancel with temporary storage and owned-asset cleanup.

## Demonstration

Reopen a recording, change its title/language, enter a short transcript, save and relaunch; then cancel a deletion before confirming it and verify the owned asset is removed.

## Delivery constraints and verification

Use native Swift/SwiftUI and Apple frameworks only. Keep recording/playback real in the app. Inspect and document relevant Mobbin patterns before implementing a new primary screen; adapt interactions without screen copying. Apply Dynamic Type, VoiceOver, contrast, Reduce Motion, clear state and large touch targets to each changed flow. Verify the user-visible behavior at the agreed app-workflow seam with temporary storage/deterministic services, and keep the build and relevant checks green. Tests using audio doubles do not establish device microphone behavior.

Introduce only data needed for review and library behavior. Later language slices add their own persisted provenance/revisions; do not build an unused language framework here.

## Comments

- 2026-11-12: Proposed with to-tickets following specification approval. Ticket approval is pending. Dependencies are implementation prerequisites, not authorization to start. M1 delivery is prioritized before M2 rollout; independent M2 service paths intentionally do not block one another. External prerequisites remain real blockers even when not represented by ticket numbers. After approval, only sufficiently specified/unblocked work becomes ready-for-agent; unresolved service/content/device prerequisites remain visible. No feature implementation or GitHub publication has occurred.


- 2026-11-12: The user approved this ticket and the dependency graph and authorized GitHub publication. Implementation remains ON HOLD. The triage status describes specification/prerequisite readiness, not authorization to execute; needs-info tickets retain the external content, service, review, or device prerequisites stated above.

- 2026-11-12: Published as https://github.com/octiv-fortune/story-within/issues/7; native sub-issue and blocking relationships preserved. Implementation remains ON HOLD.

- 2026-11-12: The user resumed implementation with implement-spec, starting at the first unblocked ticket, and required native build verification before changes. The prior implementation hold is revoked.

- 2026-11-12: Ticket 01 resolved after reviewed integration, 12 native workflow passes, green Debug/Release builds, and user-confirmed physical narration/save/reopen. This ticket is now claimed in an isolated worktree.

## Answer

Resolved locally on 2026-11-12 from reviewed source, native workflow tests, and compilation evidence. No-ff merge `e6e3ab815e28ee63034965359cb50a4ffe1b41d1` integrates candidate `cb7377cfc126d6d4ab1f080559f94bc4a7cd8453` from `codex/story-within-ticket-06`. The merge was conflict-free and its entire tree matched the tested candidate. The coordinating agent reviewed metadata/manual-text persistence, personal library, keep/discard/cancel, guarded confirmed deletion, and original-schema compatibility, and found no concrete defect.

Review now keeps editable story metadata and explicitly manual text without altering the narration. The personal library reopens saved stories/drafts with stable identity; keep/discard/cancel and failed-save recovery preserve editing work. Confirmed deletion respects owned, shared, and bundled assets and reports failures truthfully. New optional SwiftData fields default safely without resetting the store. See [ticket 06 implementation evidence](../evidence/ticket-06.md), including the existing inspected design references and exact test boundaries.

Final candidate verification passed all **23 native workflow tests** on iOS 17.5, including every accepted ticket 01/02 case, original-schema migration with original audio/title/identity preservation, edit/save/reopen, validation, recoverable write failures, cancel/confirm deletion, asset ownership, and failed-delete restoration/retry: `/private/tmp/story-within-ticket06-integrated-tests.log`. Release generic iOS compilation passed: `/private/tmp/story-within-ticket06-integrated-release.log`. One merged integration generic Debug iOS Simulator build passed with signing disabled: `/private/tmp/story-within-integration-ticket06.log`; outputs: `/private/tmp/story-within-integration-ticket06`. The identical source did not require a duplicate full-suite run.

These results use deterministic hardware results and real temporary SwiftData/filesystem storage. No ticket 06 physical-device migration/playback, visual-layout, VoiceOver, or full Dynamic Type journey check is claimed. The coordinating agent owns subsequent iPhone installation and user verification. Ticket 02 remains claimed pending physical pause/continuity verification; this ticket's resolution does not imply that external check passed. No GitHub or phone action was performed during integration.
