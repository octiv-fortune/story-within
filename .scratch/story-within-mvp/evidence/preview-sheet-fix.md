# First-tap community review sheet regression

Ticket: [08](../issues/08-community-preview-and-withdrawal.md). Baseline: `3874246`, isolated worktree `/private/tmp/story-within-preview-fix`, branch `codex/story-within-preview-fix`.

## Rendered reproduction before source changes

The coordinating agent reproduced the reported symptom in the actual unchanged simulator app: Home → disposable private saved story → fresh RecordingStudio → first tap **Review for local community preview**. An empty white sheet appeared, without the review heading or Cancel. A retry on the physical phone had shown content, so further physical actions stopped while the user was interacting.

Baseline generic Debug simulator build passed: `/private/tmp/story-within-preview-baseline.log`. Simulator: iPhone 18 Pro, iOS 27, `6FED4861-30B3-4F1C-8E4D-DA91CC42787A`. No device reset, store reset, or physical phone modification. A throwaway simulator Swift CLI compiled the actual app model sources with `-module-name StoryWithin`, inserted one fixed-identity saved private **Preview Regression — Goat** story with bundled permission-cleared Goat narration, and decoded its 77.09 seconds with AVAudioPlayer. Before: 0 records; after: 1. Existing identities were checked and preserved. No personal recording/text was copied.

The external XCUITest harness points its application target at the actual worktree sources. Its test launches the app, opens the fixture, scrolls to Review, taps exactly once, attaches a screenshot, and requires rendered **Review what will be visible** and **Cancel**. It does not replace this with an app-workflow assertion.

Baseline command (after build-for-testing):

```sh
xcodebuild -project /private/tmp/story-within-preview-harness/StoryWithin.xcodeproj -scheme StoryWithin -configuration Debug -destination 'platform=iOS Simulator,id=6FED4861-30B3-4F1C-8E4D-DA91CC42787A' -derivedDataPath /private/tmp/story-within-preview-ui-tests CODE_SIGNING_ALLOWED=NO -parallel-testing-enabled NO -only-testing:StoryWithinTests/PreviewSheetTests/testFirstReviewTapRendersCommunityPreview -resultBundlePath /private/tmp/story-within-preview-red.xcresult test-without-building
```

Observed output: `XCTAssertTrue failed - First Review tap must render preview content, rather than an empty sheet`. One test, one failure; 21.059 seconds. Log: `/private/tmp/story-within-preview-red.log`. The baseline runner recorded its screenshot attachment, but Xcode stalled for more than eight minutes while collecting failure diagnostics; that incomplete result bundle cannot currently be exported. Its assertion log and the independent CUA blank-sheet observation establish the red result. The stuck diagnostic collector was stopped after green verification. This independently matches the CUA reproduction.

## Ranked hypotheses (shared before probing/fixing)

1. The independent Boolean presentation state and optional story state allow the sheet closure to see its initial nil payload. Driving presentation with the story item should render first time.
2. Nested SwiftUI presentation hosting loses the sheet content. If this is the cause, replacing only the presentation driver will remain blank.
3. Preview preparation does not supply a valid snapshot. A read-only probe through the actual workflow and native audio decoder should report missing snapshot or a preparation error.

No production source changed before the rendered red test.


## Probe and smallest fix

With the current simulator data path resolved after app installation, a throwaway CLI using StoryWorkflow and NativeStoryAudio reported `prepared=true; snapshot identity=fixture; visibility=private; error=nil` (`/private/tmp/story-within-preview-harness/probe.log`). The valid native-decoded audio and exact saved snapshot were available. Snapshot preparation was not the blank-sheet cause.

Source commit `bde75c25e04f92264ef2fba29e8bffb049c1f877` changes only RecordingStudio's presentation state: the optional Story itself drives `.sheet(item:)`, and the content closure receives that story. The independent Boolean and conditional empty content are removed. This changes one variable and makes the same first-tap rendered test green: 14.647 seconds, `TEST SUCCEEDED`, `/private/tmp/story-within-preview-green.log`, `/private/tmp/story-within-preview-green.xcresult`. The exported screenshot `/private/tmp/story-within-preview-green-attachments/9A304731-BAA0-4A3B-89BA-BC2350B53ACE.png` was visually inspected and shows the real review heading, Cancel, fictional attribution, and original-audio controls on first presentation. The unchanged nested host renders correctly with the item driver, falsifying the nested-host hypothesis for this reproduction.

## Retained regression and final verification

The test-only [runner](../../../test-support/preview-sheet/run.sh), [UI test](../../../test-support/preview-sheet/UITests/PreviewSheetTests.swift), and [fixture](../../../test-support/preview-sheet/Seed.swift) are outside the production source and normal test target. The runner parses the actual Xcode plist structurally via Apple's plutil and Python's standard plistlib; it does not depend on project formatting. It generates only a throwaway external UI project. No third-party dependencies, permanent UI target, production fixture hooks, or reset hooks were added.

The final focused test preserves the first-opening assertion, then cancels, requires the private review to return, reopens with one tap, requires the heading and Cancel again, cancels again, and requires the private review again. It never confirms community visibility.

End-to-end retained runner command was executed from an external tree containing a byte-for-byte copy of the root worktree's formatted Xcode project and a symlink to the actual fixed application source:

```sh
/private/tmp/story-within-preview-formatted-check/test-support/preview-sheet/run.sh 6FED4861-30B3-4F1C-8E4D-DA91CC42787A
```

Result: `Fixture already present; preserved all 1 stories`, one rendered UI test passed, 0 failures, 21.114 seconds, `TEST EXECUTE SUCCEEDED` with exit 0. Generated project, build/test/seed logs, and screenshot result: `/private/tmp/story-within-preview-ui.FN4DUe/`. Outer log: `/private/tmp/story-within-preview-retained-run.log`. This verifies compatibility with the root's retained Xcode autosave formatting and correct cancellation/reopening.

The fixed application also passed all **64 native workflow tests** on iPhone 13 / iOS 17.5 (`26D1BB68-2093-4A28-B84A-495BC17B094A`): 0 failures, 3.249 seconds, `/private/tmp/story-within-preview-workflow.log`, `/private/tmp/story-within-preview-workflow.xcresult`. Generic Debug iOS Simulator build passed (`/private/tmp/story-within-preview-debug.log`), and generic Release iOS build passed (`/private/tmp/story-within-preview-release.log`), both with signing disabled. No workflow test is presented as proof of SwiftUI presentation; the separate rendered test provides that evidence.

No debug instrumentation was added. The initial throwaway native probe and bootstrap UI project sources were removed after the retained harness and evidence were in place; diagnostic logs/results are retained under `/private/tmp`. Root separately reviewed the source delta, built a signed iPhone candidate, and installed it. The user subsequently confirmed the updated iPhone result: **“Preview opens immediately; cancel/reopen and withdrawal pass.”** Root owns ticket 08 resolution and issue synchronization after integration; this candidate leaves status untouched. Full ticket 09 manual gates remain outstanding as tracked there. Neither this fix nor the simulator harness establishes VoiceOver, full Dynamic Type, privacy comprehension, or physical microphone behavior.
