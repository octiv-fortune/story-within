# Preview sheet rendered UI regression

From the repository root, run `test-support/preview-sheet/run.sh BOOTED_SIMULATOR_UDID` with Xcode selected. This is an explicit simulator-only harness, separate from the normal workflow unit tests and production target. Its generated Xcode project and results stay under a printed `/private/tmp/story-within-preview-ui.*` directory.

The script compiles the real application source with a throwaway XCUITest target, installs it while retaining the simulator's app data, and adds one fixed-ID **Preview Regression — Goat** private saved story if absent. The fixture uses the real SwiftData model, fictional metadata, and a copy of the bundled licensed narration. Existing stories are preserved. It never requests microphone access, confirms community visibility, resets the store, or accepts a physical device destination. Keep this fixture private. It can later be removed through the app's normal deletion flow.

The test launches the real app, opens a new review studio, taps **Review for local community preview** exactly once, and requires the actual rendered review heading and Cancel button. It then cancels, requires the private review to return, reopens once, checks the rendered content again, and cancels again. It preserves a screenshot attachment. An empty sheet fails the assertion; workflow success alone cannot pass it. The test is intentionally outside `StoryWithinTests`, so SwiftData seed tooling is never bundled into the app.

The first build requires Xcode compilation time; the UI scenario itself takes about 20 seconds. The baseline `3874246` failed this test with the reported blank sheet. See the [diagnosis evidence](../../.scratch/story-within-mvp/evidence/preview-sheet-fix.md).
