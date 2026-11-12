# Independent M1 specification review

Inspected commit: `91135728c649c20773966e97fc36afdb1335fff0`, against `d4edaed2e38c2e6d12f1a24ba55833d99567d952` (commit range/diff, M1 source, specification, tickets 01–09, existing tests/evidence). Read-only review; no builds, device actions, or repository edits.

## (a) Missing or partial requirements

Ticket 09 remains an unmet verification gate, correctly explicit. Its lines 23–24 require physical interruption/recovery checks and “accessibility-size Dynamic Type and VoiceOver”; line 26 says “Do not claim local-MVP readiness with unmet essential acceptance criteria.” The new physical narration→hint→resume sequence, background/route recovery, complete privacy-preview/withdrawal walkthrough, VoiceOver and complete large-text navigation remain unverified. A source ScrollView and simulator rendering do not establish those results. This is a verification gap, not a newly inferred implementation failure.

## (b) Scope creep

None identified. Local previews and bundled human narration match M1. Unavailable secure proxy and competent language reviewers intentionally block M2; absent live services and language support are not M1 defects. M3 remote publishing is appropriately absent.

## (c) Implemented incorrectly

**[P2] Relaunch recovery silently deletes a failed stopped replacement when the parent retries keeping it.** Spec line 134: “Interrupted writes produce an error and retain recoverable audio for retry”; line 136: “Relaunch recovery is required for finalized/stopped drafts and saved stories.”

Reproduce from source: save an original; record and stop a confirmed replacement; fail its metadata commit at `StoryWithin/StoryWorkflow.swift:452`; relaunch; reopen the original; choose Retry keeping. The replacement's durable `StoryID--TakeID` copies remain, but reopening (`:573–585`) restores only the original ID, original duration, and bare `Captures/StoryID.m4a` path, without restoring replacement identity. Retry (`:285–293`) therefore validates the old original and calls cleanup; cleanup (`:481–486`, ownership enumeration `:470–475`) removes every replacement copy and clears the pending state. The original survives, but the new finalized narration is irreversibly discarded through a keep action. Preserve/reconstruct the pending replacement or expose explicit recovery/discard choices before cleanup. Existing failed-replacement tests inspect the reopened original but do not retry from that reopened workflow.
