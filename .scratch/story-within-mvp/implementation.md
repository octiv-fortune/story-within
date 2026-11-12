# Implementation record

Integration branch: codex/story-within-mvp
Authorization: User resumed implement-spec on 2026-11-12.
Completed local demo tickets: 01, 02, 03, 04, 05, 06, 07, 08, 09, 10.
Current demo status: verified on iOS27/iPhone15Pro. No implementation ticket is claimed; language-service tickets11–14 are outside the immediate demo scope.
Tickets09/10 are resolved under the user-amended demo scope; actual native coaching and record/save/replay passed on the current phone. Broader checks are deferred.

## Baseline

Before code changes, the unchanged native project passed Debug generic iOS Simulator compilation with Xcode 27.1. Log: /private/tmp/story-within-preimplementation-20261112.log. This is not evidence of microphone or iOS 17 runtime validation.

## Verification boundary

Use the user-confirmed app-workflow seam with deterministic services and temporary real storage; actual recording/playback additionally requires an iPhone check. Do not mark device checks complete from simulator/test doubles.

## Ticket 01 result

Merged reviewed candidate `9cefefe8e16ff2340c124f767c4815fd254f8e1a` via no-ff merge `383e0639dd00a5cf08343294c1d7cbde7e670e44`. The merge was conflict-free, with an identical candidate/integration tree. Independent Standards and Spec rechecks reported no remaining concrete defect after the review corrections.

All 12 native workflow tests passed on iOS 17.5, the oldest available runtime; the exact iOS 17.0 runtime remains unavailable. Reviewed Debug simulator and Release iOS builds passed. The integration generic Debug iOS Simulator build also passed with signing disabled: `/private/tmp/story-within-integration-ticket01.log`; outputs: `/private/tmp/story-within-integration-ticket01`. The sandboxed first attempt lacked required CoreSimulator/Swift macro service access; the same build passed with host access. No source delta required another full suite run.

The user confirmed audible original recording/playback and title/audio persistence after close/reopen on a physical iPhone 15 Pro, iOS 27.0.1. This observation preceded the final failure-recovery corrections, which have final workflow/build evidence. Full physical VoiceOver and large Dynamic Type studio/review journeys remain unverified. See [ticket 01](issues/01-record-save-and-replay.md) and its [evidence](evidence/ticket-01.md) for exact verification boundaries.

## Ticket 02 integration checkpoint

Merged reviewed candidate `dc9d004f90ece9c7d4ed91c0259b0e7d42364ca6` via no-ff merge `3c2dc080d5cfaa638b79325eb3ede2924d8c2478`. The merge was conflict-free and its entire tree matched the candidate; existing root-committed ticket claims were preserved. The coordinating review found no concrete defect in the native recorder, workflow, or UI changes.

All 17 native workflow tests passed on iOS 17.5, retaining all 12 ticket 01 regressions. Candidate Debug simulator and Release iOS builds passed. One merged integration generic Debug iOS Simulator build passed with signing disabled: `/private/tmp/story-within-integration-ticket02.log`; outputs: `/private/tmp/story-within-integration-ticket02`. The identical candidate/integration source did not require a duplicate full-suite run. See [ticket 02](issues/02-pause-and-resume-narration.md) and its [evidence](evidence/ticket-02.md).

Ticket 02 remains **claimed**. Deterministic audio/clock tests verify allowed transitions, duration semantics, retained narration, recovery, and real temporary persistence. Physical speech before/after pause, excluded break duration, playback, and save/relaunch continuity still require the coordinating agent and user. Full VoiceOver/Dynamic Type studio/review verification is not claimed. No phone or GitHub action was performed in this integration step.

## Ticket 06 result

Merged reviewed candidate `cb7377cfc126d6d4ab1f080559f94bc4a7cd8453` via no-ff merge `e6e3ab815e28ee63034965359cb50a4ffe1b41d1`. The merge was conflict-free and its entire tree matched the tested candidate. The coordinating agent reviewed the native workflow, UI, optional-field SwiftData migration, and guarded asset deletion with no concrete defect found; root-committed ticket 02/03/07 claims were preserved.

All **23 native workflow tests** passed on iOS 17.5, including all accepted 01/02 cases plus original-schema migration, metadata/manual-text editing and persistence, recoverable writes, review exit choices, and confirmed/cancelled/failed deletion with asset ownership. Release generic iOS compilation passed. One merged integration generic Debug iOS Simulator build passed with signing disabled: `/private/tmp/story-within-integration-ticket06.log`; outputs: `/private/tmp/story-within-integration-ticket06`. Identical source did not require a duplicate full-suite run. See [ticket 06](issues/06-edit-and-manage-personal-stories.md) and its [evidence](evidence/ticket-06.md).

Ticket 06 is resolved locally from source/workflow/build evidence. No ticket 06 physical-device migration/playback, visual-layout, VoiceOver, or full Dynamic Type journey result is claimed. The coordinating agent will handle updated iPhone installation and user verification; ticket 02 remains claimed pending real pause/continuity. No further source integration is started in this checkpoint.

## Ticket 03 result

Merged reviewed candidate `d87f0d145f7152cea39bb8d65970faaf6e078da1` via no-ff merge `c1a0cfad0964ec3fb3d8ecc20d29714d91aee030`. The merge was conflict-free and its committed tree exactly matched the tested candidate, including accepted ticket 06 via `f77505a`. The coordinating agent found no concrete defect in contextual deterministic coaching, one-question replies, preserved parent choices, bounded service context, asynchronous request guards, generic cue fallback, session-only data, or direct review entry from recent/library rows.

All **31 native workflow tests** passed on iOS 27.0, including all accepted recording/pause/library regressions and eight coach scenarios. Candidate Debug simulator and Release iOS builds passed. One merged integration generic Debug iOS Simulator build passed with signing disabled: `/private/tmp/story-within-integration-ticket03.log`; outputs: `/private/tmp/story-within-integration-ticket03`. No source delta required a duplicate full-suite run. A concurrent project-file formatting change was preserved outside this merge/tracker commit and verified to have the same parsed plist as the committed candidate project. See [ticket 03](issues/03-two-starts-and-demo-coaching.md) and its [evidence](evidence/ticket-03.md).

Ticket 03 is resolved locally against the approved workflow criteria. The explicit user exception permits native patterns after Mobbin transport failures; coach-reference inspection remains deferred. A locked Mac blocked interactive CUA, so typing/navigation, rendered layout, full Dynamic Type/VoiceOver traversal, and physical microphone checks remain unverified. No phone, GitHub, or additional source merge was performed in this checkpoint.

## Ticket 07 integration and playback contrast checkpoint

Merged candidate `1009f9f1266c687dbfa8c3c3889b614235784ac8` via no-ff merge `0d556cb81e7f9fbe40d8c50f586ba0f79b06398f`. It includes accepted 02/03/06 and the user-reported playback contrast fix. The conflict-free committed tree exactly matched the reviewed candidate. Read-only bundled demo assets remain separate from personal SwiftData/assets, and the coordinating review found no concrete defect in loader/player/credits behavior. The known root project-file formatting delta was preserved byte-for-byte and left unstaged; its parsed plist equals the committed candidate project.

Both unchanged human MP3 recordings retain original publisher permission/source links, CC BY 3.0 license, separate author/narrator credits, and SHA256 metadata. The combined **36 native workflow tests** passed, including real AVAudioPlayer playback/clock/pause/replay/switch/duration plus all accepted recording/library/coaching cases. The subsequent styling-only change explicitly gives both personal/demo prominent Play/Pause labels white foreground with forest tint, and Replay forest labels. Debug simulator and Release iOS builds passed afterward; no behavioral suite rerun was needed for color properties. One merged integration generic Debug iOS Simulator build passed with signing disabled: `/private/tmp/story-within-integration-ticket07.log`; outputs: `/private/tmp/story-within-integration-ticket07`. See [ticket 07](issues/07-discover-and-play-demo-stories.md) and its [evidence](evidence/ticket-07.md).

Ticket 07 remains **claimed** pending human full-recording listening and device playback/credits checks. The user clarified that recording works perfectly and only playback colors were illegible; ticket 02 remains **claimed** until the corrected controls are rechecked. No physical/visual/VoiceOver/full Dynamic Type success is inferred from builds or automated playback. The coordinating agent owns corrected phone installation and the user follow-up. No phone or GitHub action occurred in this checkpoint.

## Ticket 08 result

Merged candidate `433ce71e8f04ce48c611032282eaca3237c36b55` via no-ff merge `48ec00fa5491a463e926c5829f4f0e32a2f5e33f`. The conflict-free committed tree exactly matched the reviewed/tested candidate. The coordinating agent found no concrete defect in private-first saved-content gates, exact snapshot/revalidation, voice/device-only consent, cancellation, failed-commit visibility, withdrawal/fresh consent after edits, or saved-local-preview filtering. No new persisted schema field was added.

All **43 native workflow tests** passed on iOS 17.5, including all 36 baseline cases plus seven privacy/preview cases with deterministic audio and real temporary persistence. Candidate Debug simulator and Release iOS builds passed. One integration generic Debug iOS Simulator build passed with signing disabled: `/private/tmp/story-within-integration-ticket08.log`; outputs: `/private/tmp/story-within-integration-ticket08`. Identical source required no duplicate full-suite run. The known unstaged Xcode project formatting delta was preserved byte-for-byte and its parsed plist still equals the committed project. See [ticket 08](issues/08-community-preview-and-withdrawal.md) and its [evidence](evidence/ticket-08.md).

Ticket 08 is resolved locally from reviewed source/tests/builds. Physical consent/privacy comprehension, exact-content preview/cancel/confirm/withdraw/delete journey, VoiceOver and full Dynamic Type/rendered-layout checks remain unverified for ticket 09. No phone, GitHub, or further source merge occurred in this checkpoint.

## Ticket 04 integration checkpoint

Merged reviewed candidate `903e345fe8665286910d8d17774c959274cdf7fc` via no-ff merge `1ca4b49ec16c3602d9402ed616506da775bc8112`. The conflict-free committed tree exactly matched the tested candidate. The coordinating review found no concrete defect in pause-before-cue, ordered/exhausted cue state, failed-resume retention, explicit action guards or native studio UI. No capture-time service request, cue audio/autoplay or automatic resume was introduced. The existing unstaged Xcode project formatting delta was preserved byte-for-byte and remains semantically identical to the committed project.

All **48 native workflow tests** passed on iOS 17.5, including the 43 accepted cases and five hint cases. Release iOS compilation passed. One integration generic Debug iOS Simulator build passed with signing disabled: `/private/tmp/story-within-integration-ticket04.log`; outputs: `/private/tmp/story-within-integration-ticket04`. Identical source required no duplicate full-suite run. Targeted iOS 27 passes and the full iOS 27 prelaunch stall remain documented rather than claimed as a full pass. See [ticket 04](issues/04-prepared-hints-while-paused.md) and its [evidence](evidence/ticket-04.md).

Ticket 04 remains **claimed** pending the combined physical hint/pause/resume/narration-preservation sequence after ticket 05's final integration. New visual, full Dynamic Type and VoiceOver walkthroughs remain unverified. The coordinating agent owns full-MVP installation and user acceptance; no phone, GitHub, or additional source merge occurred in this checkpoint.

## Current frontier

- 04: Prepared hints are integrated and claimed; the combined physical hint sequence remains pending.
- 05: Interruption/replacement protection is integrated and claimed; physical backgrounding, available interruption/route-change, replacement recovery/playback and accessibility checks remain pending.
- 08: Explicit on-device local preview/withdrawal is integrated and resolved locally; physical consent/privacy/accessibility walkthrough remains unverified.
- 09: Final local-MVP verification needs the recorded combined manual/device/accessibility acceptance checks, including ticket 04's hint sequence and ticket 05's interruption/replacement sequence. Existing user-confirmed recording, readable controls and both-demo playback are retained.

No GitHub issue was closed or changed as part of this local merge/tracker step. The coordinating agent owns publication and frontier scheduling.

## Physical feedback and next frontier

2026-11-12: User clarified that recording works perfectly; the only reported problem was illegible Play labels. Shared personal/demo playback foreground and tint were corrected in1009f9f/0d556cb, with signed Debug build and updated iPhone. User confirmed: "Buttons readable; both demos play." Tickets02 and07 are now resolved. Whole-story cultural/language review and full VoiceOver walkthrough remain unclaimed.

Current claimed frontier:04 prepared paused hints;05 interruptions/replacement protection;08 explicit on-device community preview/withdrawal. Tickets01,02,03,06,07 resolved. M2 proxy/qualified language reviewers remain unavailable. Known project.pbxproj working delta is Xcode formatting/comments/order only, semantically identical and preserved uncommitted.

After ticket 08 integration: 08 is resolved locally; current claimed implementation frontier is 04/05. The new-flow manual consent/privacy/accessibility checks remain for 09 rather than being inferred from code acceptance.

After ticket 04 integration: 04 remains claimed for the combined physical hint sequence; 05 final combined integration is pending. The accepted source tip is available to ticket 05 without duplicating the full suite for an identical source merge.

## Independent review and recovery follow-up

The independent Standards review found no documented-rule breach and one nonblocking asset-promotion maintainability observation. The Spec review found a concrete finalized-replacement recovery defect after a failed metadata commit and relaunch. Both reports are committed under `evidence/m1-*-review.md`. Ticket 05 remains claimed while a fresh implementer fixes the defect using red/green workflow regression tests. A pre-fix signed iPhone build compiled but was not installed.

GitHub issues #3 (ticket 02, pause/resume) and #8 (ticket 07, demo listening) were closed separately after verifying exact titles and the recorded user feedback. Later recovery, hint, preview and complete accessibility acceptance gates remain open; no dependency relationships were changed. Clean integrated worktrees 01, 02, 03, 06, 07 and 08 were removed with branches retained. A subsequent environment restart cleared the remaining temporary worktrees/logs; committed source and evidence summaries remain intact.

## Updated iPhone acceptance checkpoint

Reviewed recovery source `f839c99`, integrated via `b339313`, passed 64 native tests, Debug simulator and Release iOS compilation, an integration Debug simulator build, and a signed Debug iOS build. The in-place iPhone update succeeded after one transient network-disconnection retry. No app data reset or schema migration was performed. The user has been asked to check existing-story opening plus a disposable story's hints/resume, save/reopen, replacement cancellation, background finalization and local preview/withdrawal. Results remain pending, alongside full VoiceOver/Dynamic Type and remaining physical recovery checks. See [the walkthrough](evidence/ticket-09-walkthrough.md). Tickets 04/05 remain claimed; ticket 09 remains incomplete; M2 retains its external prerequisites.

The clean, integrated recovery worktree was removed; missing temporary registrations from the environment restart were pruned. All implementation branches were retained. Only the pre-existing unstaged Xcode project formatting delta is intended to remain in the root working tree after committing this checkpoint.


## Ticket 05 integration checkpoint

Merged reviewed candidate `91135728c649c20773966e97fc36afdb1335fff0` via no-ff merge `d5cfdd064f9f8be953731560c58673e9cdef76d2`. The conflict-free committed tree exactly matched the reviewed/tested candidate, including accepted ticket 04/08 source and current tracking metadata. Original narration survives cancelled or failed replacement; successful replacement retains story identity and authored metadata, commits new duration/voice, and returns visibility to private pending fresh local-preview consent. Corrupt/missing audio and interruption recovery have the candidate evidence recorded below; follow-up review identified a potential failed-replacement relaunch recovery defect that remains unresolved.

The reviewed candidate passed **56 native tests** on iOS 17.5 and Debug simulator/Release iOS compilation. One merged integration generic Debug iOS Simulator build passed with signing disabled: `/private/tmp/story-within-integration-ticket05.log`; outputs: `/private/tmp/story-within-integration-ticket05`. The sandboxed attempt failed because Swift macro services were unavailable; the same build passed with host access, with only the existing nonblocking AppIntents warning. Identical candidate/integration source required no duplicate full-suite run. The known unstaged Xcode project comments/formatting/order delta was preserved byte-for-byte and its parsed plist equals the committed project. See [ticket 05](issues/05-protect-recordings-and-recover.md) and its [evidence](evidence/ticket-05.md).

Ticket 05 remains **claimed** pending physical backgrounding, available audio interruption/route-change scenarios, finalized-draft reopen, replacement playback/cancellation, and combined VoiceOver/Dynamic Type walkthroughs. Ticket 04's physical hint sequence and ticket 09's combined manual acceptance remain pending. No phone installation, GitHub change, push, or issue closure occurred in this checkpoint.

Follow-up review flagged a potential failed-replacement relaunch recovery defect after this integration; investigation/correction remains with the coordinator. This checkpoint records integration/build evidence only and does not resolve ticket 05 or authorize phone installation.

## Reviewed recovery fix integration checkpoint

Merged reviewed candidate `4841e6b5c380b07667460fefd668e8abf4a7f961` via no-ff merge `b3393136aebc8d60e5671599b3b645125a14d16b`. Application source fix commits are `6a73f29` and `f839c99`; the latter includes the reviewed original-backup correction. The merge was conflict-free and its committed tree exactly matched the candidate, including integration tip `109bcdc`.

Both concrete recovery defects are fixed in source. A failed stopped-replacement metadata commit now retains an atomic recovery record so relaunch and Retry keeping preserve the new narration, story/take identities, and authored metadata. UUID-owned paths and missing, invalid, foreign, stale, or already-committed record guards prevent destructive or obsolete recovery. Explicit cancellation also preserves every copy of the original take's basename, including capture/staging backups when its primary retained asset is missing or corrupt, while respecting assets referenced by another story. The earlier unresolved-defect notes above are superseded by this reviewed source correction.

The candidate passed **64 native workflow tests** on iOS 17.5, Debug generic iOS Simulator compilation, and Release generic iOS compilation. One merged integration generic Debug iOS Simulator build passed with signing disabled: `/private/tmp/story-within-recovery-integration.log`; outputs: `/private/tmp/story-within-recovery-integration`. The only build warning was the existing nonblocking AppIntents metadata-extraction warning. Identical candidate/integration source required no duplicate full-suite run. `git diff --check` passed. The known unstaged Xcode project formatting/comments/order delta was never staged or reset; its SHA-256 remained `1b66df8e503b6b2c326fc54b4de4f03f5b0415016165f3b69438ea9cd32079b3`, and its parsed plist equals the candidate project. See [the recovery fix evidence](evidence/m1-review-fixes.md) for regression failures, successful verification, and limits.

Tickets **04 and 05 remain claimed**. Physical hint/pause/resume/narration continuity; backgrounding and available interruption/route-change behavior; finalized-draft/replacement relaunch, retry, cancellation, and playback; and full VoiceOver/Dynamic Type/rendered-layout acceptance remain pending. Ticket **08 remains resolved locally for code/workflow acceptance**, with its physical consent/privacy/preview/withdrawal/accessibility walkthrough pending. Ticket **09 verification remains incomplete** until those manual gates are recorded. No signing, phone operation or installation, GitHub mutation, push, PR, or cleanup occurred in this integration step; the coordinating agent owns the separate device follow-up.


## Latest device feedback and preview repair

The user passed the requested existing-story opening, hint/resume/save/reopen, replacement cancellation and background-finalization checks, then reported a blank local-preview popup. Ticket 04 is resolved from source/tests/builds plus that physical hint sequence. Ticket 08 is reopened for the presentation defect; no preview/withdrawal success is inferred. Ticket 05 retains its remaining physical route/interruption/accessibility checks within the incomplete M1 verification gate.

The UI defect was reproduced on a disposable simulator fixture on the first tap, with an empty white sheet and no content or Cancel control. A real rendered XCUITest failed on the missing heading; native preparation returned a valid private story. Application fix bde75c2 uses the optional story as the sheet presentation item. The same rendered test passed, 64 workflow tests and Debug/Release builds passed, and a signed in-place iPhone update succeeded. User first-open/cancel/reopen/confirmation/withdrawal verification is pending. The retained rendered regression runner is being finalized independently of production targets.


## Preview repair accepted

Reviewed source bde75c2 and retained simulator-only rendered regression integrated through no-ff merge f43aa10 (candidate 4d44844). Source/support trees match the tested candidate. All 64 workflow tests, the rendered first-open/cancel/reopen test, Debug simulator, Release iOS and signed Debug iPhone builds passed. The merged integration also passed generic Debug simulator compilation; the initial restricted macro/simulator-access failure and successful host-access retry are documented separately. Root project formatting stayed byte-for-byte unchanged and unstaged.

The updated iPhone app was installed in place without a reset. User confirmed “Preview opens immediately; cancel/reopen and withdrawal pass.” Ticket 08 is resolved. Ticket 04 is resolved and its exact GitHub issue #5 was closed after the earlier physical hint journey passed. Ticket 08 GitHub issue #9 is closed after the verified completion evidence was posted; dependencies remain unchanged. M1 still requires its remaining physical recovery, full VoiceOver/Dynamic Type and other recorded ticket 09 checks; M2 still lacks the secure proxy and language reviewers. See evidence/preview-sheet-fix.md and evidence/ticket-09-walkthrough.md.


The clean merged preview worktree was removed after verification; its branch, committed rendered regression support and temporary validation artifacts were retained. Final root status is only the original unstaged project.pbxproj formatting delta, with its SHA-256 unchanged at 1b66df8e503b6b2c326fc54b4de4f03f5b0415016165f3b69438ea9cd32079b3.


## Interruption acceptance

The user confirmed “Passed; microphone stays stopped and draft plays,” following earlier background/replacement/reopen checks. Ticket 05 is resolved from combined functional workflow/build and physical evidence; the exact interruption trigger was not stated and no call/headset-specific result is inferred. Tickets 01–08 are now resolved locally. Ticket 09 remains open for full accessibility and remaining physical negative/recovery verification; M2 remains externally blocked. No application source changed for this result, so no additional build/test run is needed.


## MVP functionality priority

2026-11-12: The user explicitly deferred accessibility checks for now. Specification v0.2 and ticket 09 reflect the amendment; the outstanding large-text request is withdrawn, and existing support remains. No accessibility pass or full functional device-test pass is inferred. Functional tickets 01–08 are complete; the local MVP uses real recording/storage/playback and explicit on-device preview with deterministic demo coaching. The next functional expansion is live coaching (ticket 10), followed by live transcription/translation; the missing secure proxy/reviewed contract and language review prerequisites remain real blockers. A minimal coaching proxy contract is being drafted for review, without choosing/deploying a backend stack.

## Live coaching hosting recommendation

2026-11-12: The user requested the simplest hosting/authentication setup, preferring OpenAI, and confirmed ChatGPT Plus. The reviewed-source proposal recommends one Supabase project for Edge Function hosting and managed pre-created demo-user authentication, with OpenAI Responses API for coaching and a server-only project credential. The native app stays Swift/SwiftUI/URLSession/Keychain; the small TypeScript backend is proposed scope, not implemented or deployed. OpenAI subscription API-credit eligibility, private-client sign-in limits, Sites considerations, Supabase authentication and free-plan limitations are cited in [the proposal](live-coaching-proxy-proposal.md). Ticket 10 remains needs-info until the backend scope/accounts/endpoint/funding are available. No application code changed or new build/test result is claimed.


## Apple on-device coaching decision

2026-11-12: After reviewing Apple's current Foundation Models documentation and device/language limits, the user selected on-device English coaching first, with demo mode on unsupported devices. Spec v0.3 and ticket 10 reflect this explicit provider/scope amendment. The unchanged native project passed a fresh Debug simulator build before feature changes (/private/tmp/story-within-coach-baseline.log). Root project formatting SHA remains unchanged. Supabase/OpenAI setup is parked for this slice; later transcription/translation scope and language-review prerequisites remain visible. The optional fm CLI availability probe could not run because its separate machine-wide CLI legal notice has not been accepted; no privileged acceptance was attempted, and the implementation will use the app framework.


## iPhone demo priority

2026-11-12: User requested iOS27-only on the existing iPhone15Pro and skipping work unnecessary for the MVP demo. Specv0.4 and tickets09/10 record the narrowed scope. The implementer is raising the deployment target in its isolated project, finishing the small bypass/input-preservation fix, and preparing current-OS builds. Historical iOS17 passes remain evidence only; simulator native generation failed to load assets and is not treated as a model pass. The immediate acceptance target is genuine coaching plus the existing working record/save/replay path on the phone. No cloud or credential setup is needed for the selected slice.


## iPhone demo verified

Source `3ff3d8d`/candidate `6581746` merged via `53e59d9`. Both review axes have no remaining concrete blockers after cue wait/busy-state and pending-thought repairs. Current 76 deterministic iOS27 tests, Debug simulator, Release iOS, integration Debug and signed device builds passed. User confirmed actual on-device Apple coaching and record/save/replay on iPhone15Pro after the in-place update. Tickets09/10 are resolved for this narrowed demo; the future language backlog is not reported complete. No cloud/API credential setup is needed.

Original project formatting is retained except four authorized 27.0 target substitutions. It remains unstaged, SHA256 `aa0ea85da9b1808bfb4f776afe508943488f709f4329558cf8aa09d9de671219`, with parsed semantics equal to committed candidate. Backup/stash preserved during validation. See evidence/apple-coach.md and evidence/apple-coach-review.md for results and limits.


## Demo closeout

GitHub demo gate #10 and Apple coaching #11 were renamed to the user-selected scope and closed with the actual phone result and deferred-check boundaries. Parent #1 stays open for later language work. The clean merged coaching worktree was removed; branch and temporary validation artifacts are retained. Existing project formatting remains unstaged with only the authorized deployment-target substitutions.

The retained preview regression fixture runner was updated to compile the new coaching source dependencies and target iOS27. Its shell syntax and standalone native seed-tool compilation passed; the full rendered regression was not unnecessarily rerun after the already user-verified demo. No application source changed during closeout.
