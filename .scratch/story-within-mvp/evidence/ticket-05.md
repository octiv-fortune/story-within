# Ticket 05 implementation evidence

Scope: protect the finalized original during confirmed re-recording; make interruption/recovery messages truthful; validate retained audio before save. Native AVFoundation recording/playback remains real. No dependencies, schema fields, store reset, or fake recording path are added.

## Design and test boundary

Applied the TDD skill at the already approved public StoryWorkflow seam, with deterministic microphone/permission boundaries and real isolated temporary SwiftData/audio storage. The corrupt-audio test uses NativeStoryAudio and AVFoundation decoding, with a temporary copy of a permission-cleared bundled recording for recovery.

Extended the existing studio and native confirmation dialogs. Re-recording explains that the original remains kept until successful replacement and that replacement voice returns to private visibility. Capture exposes cancellation back to the original. Existing forest/white primary button contrast, Dynamic Type text, vertical controls, 44-point targets, and significant-state VoiceOver announcements are retained. Shared inspected references remain the Journal paused-state Resume/Done separation and OpenPhone save/discard interaction structure recorded in `/private/tmp/story-within-research/ticket-01.md`. No new Mobbin calls or fresh inspection are claimed.

## TDD evidence

- `/private/tmp/story-within-ticket05-red-01-native.log`: expected missing replacement workflow API compilation failures. `/private/tmp/story-within-ticket05-green-01.log`: replacement requires confirmation; cancelling preserves original audio/identity, saved metadata, and unfinished review text after reopening.
- `/private/tmp/story-within-ticket05-red-02.log`: replacement lost the new voice/duration on retry, leaked its capture, and falsely claimed interruption content was kept despite a failed commit. `/private/tmp/story-within-ticket05-green-02.log`: two replacement tests passed. Failed metadata commit leaves the original intact; retry retains the new voice with original identity, creation date, saved lifecycle and authored metadata; duration survives relaunch; explicit deletion cleans owned copies.

## Ownership and compatibility

Original bare UUID audio paths remain supported. Replacement files use stable StoryID plus independent take ID. Ownership derives these names on relaunch rather than requiring a new model field. A successful replacement commits its fully copied asset before removing the old take; cancelled/failed replacement keeps the original row and voice. Cleanup retains references used by other stories; bundled demo audio is outside personal asset ownership. Metadata persistence now includes replacement duration and visibility. New voice always becomes private until a fresh local-preview confirmation.

## Remaining verification

Native final suite, Debug simulator and Release iOS compilation results will be appended after integration. Physical backgrounding, available audio-interruption/route-change scenarios, replacement playback/cancellation, and a full replacement VoiceOver/Dynamic Type walkthrough remain for the coordinator/user. The simulator workflow doubles do not prove real microphone or audio-route behavior. Forced-termination recovery of an in-flight take is not promised. No phone installation, remote publication, issue closure, or push is performed by this implementer.

Additional TDD slices:

- `/private/tmp/story-within-ticket05-red-03.log`: opening corrupt audio had no recovery error and saving incorrectly succeeded. `/private/tmp/story-within-ticket05-green-03.log`: native decoder rejects corrupt retained audio; review text remains editable and restoring a valid temporary audio copy allows the same draft to save without autoplay.
- `/private/tmp/story-within-ticket05-red-04.log`: delayed permission response started capture after interruption. `/private/tmp/story-within-ticket05-green-04.log`: request identity is invalidated on interruption; delayed permission acceptance leaves capture idle until another parent record action. Native route handling also covers loss of a suitable route and media services loss, without restarting the microphone.
- `/private/tmp/story-within-ticket05-red-05.log`: cleanup deleted the final recovery source when the promoted asset was missing. `/private/tmp/story-within-ticket05-green-05.log`: relaunch detects missing retained audio; retry refuses cleanup, preserving source and staging copies until the retained asset is restored, then cleanup succeeds. Replacement ownership survives relaunch without a model migration.

## Integration and preliminary verification

- `/private/tmp/story-within-ticket05-preintegration-test.log`: **TEST SUCCEEDED**, 42 native tests, zero failures on assigned iPhone 13 / iOS 17.5 simulator `26D1BB68-2093-4A28-B84A-495BC17B094A`. All 36 existing tests retained; six new tests cover replacement confirmation/cancellation, failed commit retry, failed file copy/empty replacement, corrupt native audio, permission interruption, and last-copy retention after relaunch.
- `/private/tmp/story-within-ticket05-debug.log`: **BUILD SUCCEEDED**, Debug generic iOS Simulator.
- `/private/tmp/story-within-ticket05-release.log`: **BUILD SUCCEEDED**, Release generic iOS unsigned compilation. Both builds report only the existing nonblocking AppIntents warning.
- Merged accepted ticket 08 (`48ec00f`) as `cb552e3`, retaining its visibility tests and UI. `/private/tmp/story-within-ticket05-red-06.log` proved a nonempty corrupt recording could pass community review and confirmation. `/private/tmp/story-within-ticket05-green-06.log`: native decoding now validates original audio both when preparing and confirming a local preview; restoration can be retried without changing story identity.
