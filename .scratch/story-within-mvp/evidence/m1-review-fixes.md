# M1 stopped replacement recovery review fix

Date: 2026-11-12 (Africa/Johannesburg). Source fix commits: `6a73f29` and `f839c99`. The isolated branch `codex/story-within-recovery-fix` started at integration `e8eedfc` and merged the latest integration `109bcdc` in `beabd34` before final verification. Worktree: `/private/tmp/story-within-recovery-fix`.

## Review finding and resulting behavior

Addresses the concrete P2 in [the independent specification review](m1-spec-review.md): Retry keeping after a failed stopped-replacement metadata commit and relaunch previously validated the original and deleted the new finalized narration. The standards review's module-extraction suggestion remains nonblocking and is outside this repair.

A small JSON record in `Recovery/<StoryID>.json` now atomically retains the stopped replacement's Story ID, Take ID, original audio identity, and duration before promotion/metadata commit. Reopening restores that pending replacement, so Retry keeping retains the new voice under the same story and take identities, preserving authored metadata and created date. The original remains available until replacement metadata commits successfully. No SwiftData model/schema change was needed.

Recovery paths are generated from UUIDs under the app's owned folders; serialized paths are not used as file locations. Missing, corrupt, foreign, or older mismatched records block destructive retry cleanup and expose cancellation. A record matching the already committed replacement permits only cleanup, while an older mismatched record cannot reapply an earlier voice. Explicit cancellation preserves every copy of the original take's basename, including capture/staging backups when the metadata's retained audio is missing/corrupt, and preserves files referenced by another story. Other owned replacement files and the marker are removed. Confirmed story deletion includes its owned recovery marker in staged, rollback-aware removal.

## Agreed seam and red → green evidence

Used the already approved application-workflow seam: parent actions through `StoryWorkflow`, real temporary SwiftData stores and filesystem copies, deterministic microphone/clock results, and an injected metadata commit failure. These tests establish retention/relaunch behavior; they do not establish physical microphone/audio-session behavior.

Before any source change, the unchanged worktree passed a native Debug simulator build (`/private/tmp/story-within-recovery-baseline.log`):

```text
** BUILD SUCCEEDED **
```

The new stopped-replacement failure → reopen → Retry keeping regression failed against the unchanged source. Actual excerpts from `/private/tmp/story-within-recovery-red.log`:

```text
XCTAssertEqual failed: ("2.0") is not equal to ("7.0")
XCTAssertEqual failed: ("15 bytes") is not equal to ("20 bytes")
** TEST FAILED **
```

The failed filename assertion also showed the old `StoryID.m4a` instead of the replacement's `StoryID--TakeID.m4a`. After the repair, that same test passed with the expected 7-second new narration, take identity, story identity, saved status, private visibility, title, creator, theme, language, transcript, and created date intact after another reopen.

A separate reopened-cancellation regression was run against the unchanged source and failed: cancellation left pending recovery and the replacement asset behind. It passed after recovery identity was restored.

Coordinator source review then identified an original-backup cancellation edge case. A new workflow regression reproduced deletion of the remaining original capture when its primary retained asset was unavailable. Actual excerpt from `/private/tmp/story-within-recovery-original-backup-red.log`:

```text
Executed 1 test, with 3 failures (2 unexpected)
** TEST FAILED **
```

The corrected cancellation preserves all copies of the original take identity. Its regression covers both missing and corrupt primary assets and then restores the original and safely retries ordinary cleanup. Actual green excerpt:

```text
Executed 1 test, with 0 failures (0 unexpected) in 0.064 (0.065) seconds
** TEST SUCCEEDED **
```

The eight added checks cover stopped-replacement relaunch/retry; explicit cancellation and owned cleanup; missing marker; corrupt/foreign identity/path marker; promoted-copy recovery when capture is unavailable; stale marker after successful commit and confirmed deletion; an older marker against a newer voice; and original-backup preservation during unknown-marker cancellation.

## Final native verification

Final source candidate: `f839c99`, including merged integration tip `109bcdc`. All commands used `CODE_SIGNING_ALLOWED=NO`; no signing, device installation, phone operation, push, PR, or GitHub mutation occurred in this worktree.

Environment: Xcode 27.1 (`27A9275`), iOS/iOS Simulator SDK 27.1, macOS 27.0.1 (`26A434`). Tests ran on the existing `iPhone 13_17.5`, simulator `26D1BB68-2093-4A28-B84A-495BC17B094A`, runtime iOS 17.5 (`21F79`, `com.apple.CoreSimulator.SimRuntime.iOS-17-5`). Simulator inventory was checked before building. The initial restricted simulator query could not reach CoreSimulator; the authorized native commands ran with required developer-cache/simulator access.

Combined tests:

```sh
xcodebuild -project StoryWithin.xcodeproj -scheme StoryWithin -configuration Debug \
  -destination 'platform=iOS Simulator,id=26D1BB68-2093-4A28-B84A-495BC17B094A' \
  -derivedDataPath /private/tmp/story-within-recovery-build \
  -parallel-testing-enabled NO -collect-test-diagnostics never CODE_SIGNING_ALLOWED=NO test
```

Actual completion excerpts from `/private/tmp/story-within-recovery-full-tests.log`:

```text
Executed 5 tests, with 0 failures (0 unexpected) in 0.899 (0.902) seconds
Executed 13 tests, with 0 failures (0 unexpected) in 0.254 (0.258) seconds
Executed 46 tests, with 0 failures (0 unexpected) in 1.971 (1.984) seconds
Executed 64 tests, with 0 failures (0 unexpected) in 3.123 (3.146) seconds
** TEST SUCCEEDED **
```

Final Debug generic iOS Simulator build used `-configuration Debug -sdk iphonesimulator -destination 'generic/platform=iOS Simulator' -derivedDataPath /private/tmp/story-within-recovery-build`. Actual completion from `/private/tmp/story-within-recovery-debug.log`:

```text
** BUILD SUCCEEDED **
```

Final Release generic iOS build used `-configuration Release -sdk iphoneos -destination 'generic/platform=iOS' -derivedDataPath /private/tmp/story-within-recovery-release`. Actual completion from `/private/tmp/story-within-recovery-release.log`:

```text
** BUILD SUCCEEDED **
```

Both builds emitted the existing nonblocking App Intents metadata-extraction warning because the app has no AppIntents dependency. The simulator runner also emitted an Xcode operating-system-build parsing diagnostic; test completion remained successful. Intentional corrupt-audio tests emitted audio decoding diagnostics and passed. `git diff --check` passed.

Full logs/result bundles remain temporary. The actual completion excerpts and environment identifiers above are committed so the evidence survives another environment restart. The root worktree's pre-existing unstaged `project.pbxproj` formatting delta was untouched; its SHA-256 remained `1b66df8e503b6b2c326fc54b4de4f03f5b0415016165f3b69438ea9cd32079b3` before and after verification.

## Acceptance limits

Ticket 05 remains **claimed**, pending physical background/interruption/route-change, finalized-draft/replacement playback, and accessibility acceptance. This fix does not close ticket 05 or ticket 09, establish physical iPhone behavior, or complete M2 service/language prerequisites. Existing device/accessibility gaps remain as recorded in [ticket 05 evidence](ticket-05.md) and [the walkthrough](ticket-09-walkthrough.md).
