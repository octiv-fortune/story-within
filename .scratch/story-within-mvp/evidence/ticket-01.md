# Ticket 01 implementation evidence

Scope: record → stop → private draft → listen → save → relaunch/reopen. No coach, AI, translation, or community fixtures in this slice.

Base: `codex/story-within-ticket-01` at `d4edaed2e38c2e6d12f1a24ba55833d99567d952` (the integration tip when work began). Unchanged baseline build was verified before this task; see `/private/tmp/story-within-preimplementation-20261112.log`.

## Design evidence

The coordinating agent actually inspected the following Mobbin images before implementation; its notes are `/private/tmp/story-within-research/ticket-01.md`. These are structural adaptations, not copied screens:

- [Journal recording](https://mobbin.com/screens/fb8e2aae-a965-40ca-add0-2604b87f1e6b): separate elapsed time, recording state, central capture control, and completion action. Studio uses a readable duration and an explicit Stop and review control. Pause/hints belong to later tickets.
- [OpenPhone audio review](https://mobbin.com/screens/5413e081-a207-47ef-9565-6b559855faa5): audio playback separated from Save/Discard. Review presents original voice controls before title/private-save actions, with confirmation for discard.
- [QUITTR journal list](https://mobbin.com/screens/8af8c63e-c357-430f-bd41-7f49cbd1ea1f): dated entry list and prominent creation action. Home uses compact dated story rows with lifecycle and a distinct Create a Story action.
- [pillowtalk entries](https://mobbin.com/screens/b206bf57-2210-4ab0-a6af-c2b448370fff): date hierarchy and separate creation action. Home keeps this hierarchy without empty oversized cards.

Visual treatment uses system type, forest `#183E34`, ivory `#F8F4EA`, terracotta `#C47A56`, text `#243B31`, generous native controls, Dynamic Type wrapping, and no motion or fake waveform. No external images/dependencies.

## Approved workflow test seam

The user previously approved application workflow behavior with deterministic audio boundary results and real temporary SwiftData/local asset storage. Tests exercise the same `StoryWorkflow` commands and observations as the views. They do not establish microphone capture quality. Each behavioral test is introduced red before its corresponding implementation.

## Verification record

Native workflow and compilation checks passed below. Physical narration and accessibility-device observations remain pending; the ticket stays claimed.

## Implementation

- `StoryWorkflow` is the shared public application-workflow seam used by the SwiftUI screens and tests. It owns creation, actual recording results, stable private draft identity, review edits, save/reopen, retry, and explicit discard.
- `NativeStoryAudio` uses `AVAudioApplication` permission and AVFoundation AAC recording/playback. Finalization decodes the stopped file before returning a duration. No sound autoplays. Starting recording stops playback. Interruption/background notifications safely finalize a take and never restart the microphone.
- SwiftData metadata is saved explicitly with autosave disabled and rollback on write errors. Audio is app-relative under Application Support; capture files remain durable until a fully copied asset and metadata are retained. Audio promotion uses a staging sibling and atomic final replacement, including after a partial previous copy. No cloud store or AI service is configured.
- Close presents a Keep/Discard choice; interactive sheet dismissal is disabled. Discard has a separate destructive confirmation, stages owned audio before metadata deletion, and restores staged audio if that commit fails. A filesystem failure leaves the private draft available and reports the failure.
- Startup failure has a retry screen and does not erase existing data. Explore accurately reports the empty on-device collection.

## Native verification evidence

- First workflow red: `/private/tmp/story-within-ticket01-red-01-generic.log` — expected missing public workflow/audio seam before implementation.
- Recoverable storage red: `/private/tmp/story-within-ticket01-red-02.log`; keep-review-edits red: `/private/tmp/story-within-ticket01-red-03.log`; explicit-discard red: `/private/tmp/story-within-ticket01-red-04.log` — expected missing public behavior before each corresponding implementation.
- First actual iOS 17.5 run: `/private/tmp/story-within-ticket01-green-04-test.log` — 4 tests passed. Denial/empty/missing-audio regressions: `/private/tmp/story-within-ticket01-regressions-test.log` — 7 tests passed.
- Deletion-failure behavioral red: `/private/tmp/story-within-ticket01-red-05-test.log` — a real read-only audio directory exposed that discard claimed success despite failing to remove audio. Green: `/private/tmp/story-within-ticket01-green-05-test.log` — all 8 tests passed after staged deletion/rollback. Test fixture cleanup was corrected so live SwiftData SQLite files are not unlinked in `defer`; isolated temporary folders remain for test-host/OS cleanup.
- Partial-audio-copy behavioral red: `/private/tmp/story-within-ticket01-red-06-test.log` — an existing 4-byte partial destination was incorrectly accepted rather than the 16-byte deterministic narration. Atomic promotion corrects this.
- Unsigned Release iOS builds passed in `/private/tmp/story-within-ticket01-release.log`, `/private/tmp/story-within-ticket01-release-final.log`, and `/private/tmp/story-within-ticket01-final-release.log`. The final verification pointers below supersede earlier passes if code changes.
- Coordinating agent confirmed signed Debug iPhone build and installation using the existing team, without provisioning changes: `/private/tmp/story-within-ticket01-device/Build/Products/Debug-iphoneos/StoryWithin.app`. This establishes installation, not audible microphone capture.
- Coordinating agent inspected the default-size Home on iOS 27 / iPhone 18 Pro simulator: `/private/tmp/story-within-ticket01-home-ios27.png`; branded Home, Create/Explore, recent empty state, and private-device explanation were visible without clipping.

## Final checked revision

- `/private/tmp/story-within-ticket01-final-test.log`: **TEST SUCCEEDED**, 9 native application-workflow tests on iOS 17.5 / iPhone 13 simulator, 0 failures. The exact `StoryWorkflow` and test sources in this revision were exercised. Deterministic audio returns fixed narration bytes at the hardware boundary; persistence and filesystem failures use real temporary storage.
- `/private/tmp/story-within-ticket01-final-debug.log`: **BUILD SUCCEEDED**, final Debug generic iOS Simulator app.
- `/private/tmp/story-within-ticket01-final-ios-release.log`: **BUILD SUCCEEDED**, final Release generic iOS app, unsigned compilation. Both final app builds include the native adapter's safe decoded-duration check after interruption. The only warning is the initialized project's nonblocking missing AppIntents metadata extraction.
- `git diff --check` passed. No third-party packages, AI service, desktop/visionOS target, or later-ticket feature was introduced.

## Remaining acceptance checks

Physical microphone capture, audible original playback, save/relaunch/replay, actual permission-denial recovery, and accessibility-device checks require human observations. The installed phone app has not yet been reported as completing these steps. Do not mark this ticket resolved or audio-device ready based on deterministic test results. iOS 17.5 is the oldest available installed iOS 17 runtime; exact iOS 17.0 runtime execution has not been verified. VoiceOver and large Dynamic Type journey verification remain pending unless the coordinating agent records further results.
