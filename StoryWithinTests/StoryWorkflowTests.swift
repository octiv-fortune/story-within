import XCTest
import SwiftData
@testable import StoryWithin

@MainActor
final class StoryWorkflowTests: XCTestCase {
    func testFailedReplacementCopyAndEmptyTakeKeepOriginalForCancellationAndRelaunch() async throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let recordings = root.appendingPathComponent("Recordings")
        defer { try? FileManager.default.setAttributes([.posixPermissions: 0o700], ofItemAtPath: recordings.path) }
        let audio = PausableAudio()
        let workflow = try StoryWorkflow(storageURL: root, audio: audio)
        await workflow.startRecording()
        try audio.speak("irreplaceable first voice", lasting: 3)
        workflow.stopRecording()
        workflow.title = "My kept story"
        workflow.savePrivately()
        let original = try XCTUnwrap(workflow.currentStory)
        let originalURL = try XCTUnwrap(workflow.currentAudioURL)
        await workflow.startReplacementRecording(confirmed: true)
        try audio.speak("failed copy voice", lasting: 5)
        try FileManager.default.setAttributes([.posixPermissions: 0o500], ofItemAtPath: recordings.path)
        workflow.stopRecording()
        XCTAssertNotNil(workflow.errorMessage)
        XCTAssertEqual(workflow.currentStory, original)
        XCTAssertEqual(try Data(contentsOf: originalURL), Data("irreplaceable first voice ".utf8))
        let reopened = try StoryWorkflow(storageURL: root, audio: PausableAudio())
        reopened.openStory(id: original.id)
        XCTAssertEqual(reopened.currentStory, original)
        XCTAssertEqual(try Data(contentsOf: XCTUnwrap(reopened.currentAudioURL)), Data("irreplaceable first voice ".utf8))
        try FileManager.default.setAttributes([.posixPermissions: 0o700], ofItemAtPath: recordings.path)
        workflow.cancelReplacementRecording()
        XCTAssertNil(workflow.errorMessage)
        await workflow.startReplacementRecording(confirmed: true)
        workflow.stopRecording()
        XCTAssertNotNil(workflow.errorMessage)
        XCTAssertEqual(workflow.currentStory, original)
        workflow.cancelReplacementRecording()
        XCTAssertNil(workflow.errorMessage)
        XCTAssertEqual(workflow.currentStory, original)
        XCTAssertFalse(workflow.hasPendingRecording)
        XCTAssertEqual(try Data(contentsOf: originalURL), Data("irreplaceable first voice ".utf8))
    }

    func testReplacementRecoveryNeverDeletesLastOwnedCopyWhenRetainedAssetIsMissing() async throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let captures = root.appendingPathComponent("Captures")
        defer { try? FileManager.default.setAttributes([.posixPermissions: 0o700], ofItemAtPath: captures.path) }
        let audio = PausableAudio()
        let workflow = try StoryWorkflow(storageURL: root, audio: audio)
        await workflow.startRecording()
        try audio.speak("old voice", lasting: 2)
        workflow.stopRecording()
        let id = try XCTUnwrap(workflow.currentStory?.id)
        await workflow.startReplacementRecording(confirmed: true)
        try audio.speak("replacement worth keeping", lasting: 4)
        try FileManager.default.setAttributes([.posixPermissions: 0o500], ofItemAtPath: captures.path)
        workflow.stopRecording()
        XCTAssertNotNil(workflow.errorMessage)
        let retained = try XCTUnwrap(workflow.currentAudioURL)
        let source = try XCTUnwrap(FileManager.default.contentsOfDirectory(at: captures, includingPropertiesForKeys: nil).first)
        let pending = retained.deletingPathExtension().appendingPathExtension("pending")
        try Data("extra owned staging bytes".utf8).write(to: pending)
        let unavailable = root.appendingPathComponent("unavailable.m4a")
        try FileManager.default.moveItem(at: retained, to: unavailable)
        let reopened = try StoryWorkflow(storageURL: root, audio: PausableAudio())
        reopened.openStory(id: id)
        XCTAssertNotNil(reopened.errorMessage)
        try FileManager.default.setAttributes([.posixPermissions: 0o700], ofItemAtPath: captures.path)
        reopened.retryKeepingRecording()
        XCTAssertNotNil(reopened.errorMessage)
        XCTAssertTrue(reopened.hasPendingRecording)
        XCTAssertEqual(try Data(contentsOf: source), Data("replacement worth keeping ".utf8))
        XCTAssertTrue(FileManager.default.fileExists(atPath: pending.path))
        try FileManager.default.moveItem(at: unavailable, to: retained)
        reopened.retryKeepingRecording()
        XCTAssertNil(reopened.errorMessage)
        XCTAssertFalse(reopened.hasPendingRecording)
        XCTAssertEqual(try Data(contentsOf: XCTUnwrap(reopened.currentAudioURL)), Data("replacement worth keeping ".utf8))
        XCTAssertFalse(FileManager.default.fileExists(atPath: source.path))
        XCTAssertFalse(FileManager.default.fileExists(atPath: pending.path))
    }

    func testInterruptionDuringPermissionRequestRequiresANewParentRecordAction() async throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let audio = DeterministicAudio()
        let requested = expectation(description: "Microphone permission requested")
        var permissionResponse: CheckedContinuation<Bool, Never>?
        audio.permissionRequest = {
            await withCheckedContinuation { continuation in
                permissionResponse = continuation
                requested.fulfill()
            }
        }
        let workflow = try StoryWorkflow(storageURL: root, audio: audio)
        let starting = Task { await workflow.startRecording() }
        await fulfillment(of: [requested], timeout: 2)
        XCTAssertEqual(workflow.captureState, .requestingPermission)
        workflow.handleInterruption()
        permissionResponse?.resume(returning: true)
        await starting.value
        XCTAssertEqual(workflow.captureState, .idle)
        XCTAssertNotNil(workflow.errorMessage)
        XCTAssertFalse(workflow.hasPendingRecording)
        XCTAssertTrue(workflow.stories.isEmpty)
        audio.permissionRequest = nil
        await workflow.startRecording()
        XCTAssertEqual(workflow.captureState, .recording)
        workflow.stopRecording()
        XCTAssertNotNil(workflow.currentStory)
    }

    func testCorruptRetainedAudioIsReportedOnOpenAndCannotClaimSuccessfulSave() async throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let initial = try StoryWorkflow(storageURL: root, audio: DeterministicAudio())
        await initial.startRecording()
        initial.stopRecording()
        let id = try XCTUnwrap(initial.currentStory?.id)
        let url = try XCTUnwrap(initial.currentAudioURL)
        let bundled = try XCTUnwrap(DemoLibrary.bundled().audioURLs.values.first)
        let goodAudio = try Data(contentsOf: bundled)
        try Data("corrupt audio header".utf8).write(to: url)
        let workflow = try StoryWorkflow(storageURL: root, audio: NativeStoryAudio())
        workflow.openStory(id: id)
        XCTAssertNotNil(workflow.errorMessage)
        XCTAssertFalse(workflow.isPlaying)
        workflow.title = "My recovered story"
        workflow.transcript = "Keep my manual text"
        workflow.savePrivately()
        XCTAssertNotNil(workflow.errorMessage)
        XCTAssertEqual(workflow.currentStory?.isSaved, false)
        XCTAssertEqual(workflow.transcript, "Keep my manual text")
        try goodAudio.write(to: url)
        workflow.savePrivately()
        XCTAssertNil(workflow.errorMessage)
        let reopened = try StoryWorkflow(storageURL: root, audio: NativeStoryAudio())
        reopened.openStory(id: id)
        XCTAssertNil(reopened.errorMessage)
        XCTAssertEqual(reopened.title, "My recovered story")
        XCTAssertEqual(reopened.transcript, "Keep my manual text")
        XCTAssertEqual(reopened.currentStory?.isSaved, true)
        XCTAssertFalse(reopened.isPlaying)
    }

    func testFailedReplacementCommitPreservesOriginalUntilRetryDurablyRetainsNewVoice() async throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        var failWrites = false
        let audio = PausableAudio()
        let workflow = try StoryWorkflow(storageURL: root, audio: audio, commitChanges: { context in
            if failWrites { throw CocoaError(.fileWriteNoPermission) }
            try context.save()
        })
        await workflow.startRecording()
        try audio.speak("first take", lasting: 2)
        workflow.stopRecording()
        workflow.title = "The moon garden"
        workflow.creatorName = "Mama"
        workflow.theme = "Kindness"
        workflow.sourceLanguage = "English"
        workflow.transcript = "My manual text"
        workflow.savePrivately()
        let original = try XCTUnwrap(workflow.currentStory)
        let originalURL = try XCTUnwrap(workflow.currentAudioURL)
        await workflow.startReplacementRecording(confirmed: true)
        try audio.speak("second longer take", lasting: 5)
        failWrites = true
        workflow.handleInterruption()
        XCTAssertNotNil(workflow.errorMessage)
        XCTAssertFalse(workflow.errorMessage?.contains("kept as a private draft") == true)
        XCTAssertEqual(workflow.currentStory, original)
        XCTAssertTrue(workflow.hasPendingRecording)
        let unchanged = try StoryWorkflow(storageURL: root, audio: PausableAudio())
        unchanged.openStory(id: original.id)
        XCTAssertEqual(unchanged.currentStory, original)
        XCTAssertEqual(try Data(contentsOf: originalURL), Data("first take ".utf8))
        failWrites = false
        workflow.retryKeepingRecording()
        XCTAssertNil(workflow.errorMessage)
        XCTAssertFalse(workflow.hasPendingRecording)
        XCTAssertEqual(workflow.currentStory?.id, original.id)
        XCTAssertEqual(workflow.currentStory?.duration, 5)
        XCTAssertEqual(workflow.currentStory?.visibility, "private")
        let reopened = try StoryWorkflow(storageURL: root, audio: PausableAudio())
        reopened.openStory(id: original.id)
        XCTAssertEqual(reopened.stories.count, 1)
        XCTAssertEqual(reopened.currentStory?.duration, 5)
        XCTAssertEqual(reopened.currentStory?.createdAt, original.createdAt)
        XCTAssertEqual(reopened.title, "The moon garden")
        XCTAssertEqual(reopened.creatorName, "Mama")
        XCTAssertEqual(reopened.theme, "Kindness")
        XCTAssertEqual(reopened.sourceLanguage, "English")
        XCTAssertEqual(reopened.transcript, "My manual text")
        XCTAssertEqual(reopened.currentStory?.isSaved, true)
        XCTAssertEqual(try Data(contentsOf: XCTUnwrap(reopened.currentAudioURL)), Data("second longer take ".utf8))
        XCTAssertFalse(FileManager.default.fileExists(atPath: originalURL.path))
        reopened.deleteCurrentStory(confirmed: true)
        XCTAssertNil(reopened.errorMessage)
        for folder in ["Captures", "Recordings"] {
            XCTAssertEqual(try FileManager.default.contentsOfDirectory(atPath: root.appendingPathComponent(folder).path), [])
        }
    }

    func testReplacementRequiresConfirmationAndCancellationPreservesOriginalAndReviewEdits() async throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let audio = PausableAudio()
        let workflow = try StoryWorkflow(storageURL: root, audio: audio)
        await workflow.startRecording()
        try audio.speak("original voice", lasting: 2)
        workflow.stopRecording()
        workflow.title = "A family story"
        workflow.creatorName = "Mama"
        workflow.theme = "Courage"
        workflow.sourceLanguage = "English"
        workflow.transcript = "My own words"
        workflow.savePrivately()
        let original = try XCTUnwrap(workflow.currentStory)
        let originalURL = try XCTUnwrap(workflow.currentAudioURL)
        workflow.transcript = "An unfinished correction"
        await workflow.startReplacementRecording(confirmed: false)
        XCTAssertEqual(workflow.captureState, .stopped)
        XCTAssertFalse(workflow.hasPendingRecording)
        await workflow.startReplacementRecording(confirmed: true)
        try audio.speak("replacement voice", lasting: 4)
        XCTAssertEqual(workflow.currentStory, original)
        XCTAssertEqual(try Data(contentsOf: originalURL), Data("original voice ".utf8))
        workflow.cancelReplacementRecording()
        XCTAssertNil(workflow.errorMessage)
        XCTAssertEqual(workflow.currentStory, original)
        XCTAssertEqual(workflow.transcript, "An unfinished correction")
        XCTAssertFalse(workflow.hasPendingRecording)
        let reopened = try StoryWorkflow(storageURL: root, audio: PausableAudio())
        reopened.openStory(id: original.id)
        XCTAssertEqual(reopened.currentStory, original)
        XCTAssertEqual(try Data(contentsOf: XCTUnwrap(reopened.currentAudioURL)), Data("original voice ".utf8))
    }

    func testFailedDeleteRestoresOwnedAudioAndTextUntilDeletionCanBeRetried() async throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        var storageUnavailable = false
        let workflow = try StoryWorkflow(storageURL: root, audio: DeterministicAudio(), commitChanges: { context in
            if storageUnavailable { throw CocoaError(.fileWriteNoPermission) }
            try context.save()
        })
        await workflow.startRecording()
        workflow.stopRecording()
        workflow.title = "A story worth keeping"
        workflow.transcript = "The hare came home."
        workflow.savePrivately()
        let id = try XCTUnwrap(workflow.currentStory?.id)
        let audioURL = try XCTUnwrap(workflow.currentAudioURL)
        storageUnavailable = true
        workflow.deleteCurrentStory(confirmed: true)
        XCTAssertNotNil(workflow.errorMessage)
        XCTAssertEqual(workflow.currentStory?.id, id)
        let unchanged = try StoryWorkflow(storageURL: root, audio: DeterministicAudio())
        unchanged.openStory(id: id)
        XCTAssertEqual(unchanged.title, "A story worth keeping")
        XCTAssertEqual(unchanged.transcript, "The hare came home.")
        XCTAssertEqual(try Data(contentsOf: audioURL), Data("spoken narration".utf8))
        storageUnavailable = false
        workflow.deleteCurrentStory(confirmed: true)
        XCTAssertNil(workflow.errorMessage)
        XCTAssertNil(workflow.currentStory)
        XCTAssertFalse(FileManager.default.fileExists(atPath: audioURL.path))
        let reopened = try StoryWorkflow(storageURL: root, audio: DeterministicAudio())
        XCTAssertTrue(reopened.stories.isEmpty)
    }

    func testBlankTitleValidationKeepsReviewEditsAndRecordingForCorrection() async throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let workflow = try StoryWorkflow(storageURL: root, audio: DeterministicAudio())
        await workflow.startRecording()
        workflow.stopRecording()
        workflow.title = " \n "
        workflow.transcript = "My own text"
        workflow.savePrivately()
        XCTAssertNotNil(workflow.errorMessage)
        XCTAssertEqual(workflow.currentStory?.isSaved, false)
        XCTAssertEqual(workflow.transcript, "My own text")
        workflow.title = "The first seed"
        workflow.savePrivately()
        XCTAssertNil(workflow.errorMessage)
        XCTAssertEqual(workflow.currentStory?.isSaved, true)
        XCTAssertEqual(try Data(contentsOf: XCTUnwrap(workflow.currentAudioURL)), Data("spoken narration".utf8))
    }
    func testDeletionRequiresConfirmationAndPreservesSharedAndDemoAssets() async throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let initial = try StoryWorkflow(storageURL: root, audio: DeterministicAudio())
        await initial.startRecording()
        initial.stopRecording()
        let original = try XCTUnwrap(initial.currentStory)
        let sharedURL = try XCTUnwrap(initial.currentAudioURL)
        let demoURL = root.appendingPathComponent("Recordings/Demo/shared.m4a")
        try FileManager.default.createDirectory(at: demoURL.deletingLastPathComponent(), withIntermediateDirectories: true)
        try Data("permission-cleared demo".utf8).write(to: demoURL)
        let container = try ModelContainer(for: StoryRecord.self, configurations:
            ModelConfiguration(url: root.appendingPathComponent("Stories.sqlite"), cloudKitDatabase: .none))
        let context = ModelContext(container)
        let shared = Story(id: UUID(), title: "Shared recording", audioName: original.audioName, duration: 3,
                       isSaved: true, visibility: "private", createdAt: Date(), updatedAt: Date())
        let demo = Story(id: UUID(), title: "Demo", audioName: "Demo/shared.m4a", duration: 3,
                         isSaved: true, visibility: "private", createdAt: Date(), updatedAt: Date())
        context.insert(StoryRecord(shared)); context.insert(StoryRecord(demo))
        try context.save()
        let workflow = try StoryWorkflow(storageURL: root, audio: DeterministicAudio())
        workflow.openStory(id: original.id)
        workflow.deleteCurrentStory(confirmed: false)
        XCTAssertEqual(workflow.currentStory?.id, original.id)
        XCTAssertEqual(workflow.stories.count, 3)
        workflow.deleteCurrentStory(confirmed: true)
        XCTAssertNil(workflow.errorMessage)
        XCTAssertFalse(workflow.stories.contains { $0.id == original.id })
        XCTAssertEqual(try Data(contentsOf: sharedURL), Data("spoken narration".utf8))
        workflow.openStory(id: demo.id)
        workflow.deleteCurrentStory(confirmed: true)
        XCTAssertNil(workflow.errorMessage)
        XCTAssertEqual(try Data(contentsOf: demoURL), Data("permission-cleared demo".utf8))
        XCTAssertEqual(workflow.stories.map(\.id), [shared.id])
    }
    func testFailedMetadataWriteKeepsEditsForRetryAndNeverClaimsSuccessfulExit() async throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        var storageUnavailable = false
        let workflow = try StoryWorkflow(storageURL: root, audio: DeterministicAudio(), commitChanges: { context in
            if storageUnavailable { throw CocoaError(.fileWriteNoPermission) }
            try context.save()
        })
        await workflow.startRecording()
        workflow.stopRecording()
        let id = try XCTUnwrap(workflow.currentStory?.id)
        workflow.title = "Tomorrow's story"
        workflow.transcript = "The garden woke."
        storageUnavailable = true
        XCTAssertFalse(workflow.resolveReviewExit(.keepChanges))
        XCTAssertNotNil(workflow.errorMessage)
        XCTAssertEqual(workflow.transcript, "The garden woke.")
        XCTAssertTrue(workflow.hasUnsavedReviewChanges)
        let unchanged = try StoryWorkflow(storageURL: root, audio: DeterministicAudio())
        unchanged.openStory(id: id)
        XCTAssertEqual(unchanged.title, "My new story")
        XCTAssertEqual(unchanged.transcript, "")
        XCTAssertEqual(unchanged.currentStory?.isSaved, false)
        storageUnavailable = false
        XCTAssertTrue(workflow.resolveReviewExit(.keepChanges))
        let reopened = try StoryWorkflow(storageURL: root, audio: DeterministicAudio())
        reopened.openStory(id: id)
        XCTAssertEqual(reopened.title, "Tomorrow's story")
        XCTAssertEqual(reopened.transcript, "The garden woke.")
        XCTAssertEqual(reopened.currentStory?.isSaved, false)
    }
    func testReviewExitCancelPreservesEditsAndDiscardOnlyRemovesUnsavedChanges() async throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let workflow = try StoryWorkflow(storageURL: root, audio: DeterministicAudio())
        await workflow.startRecording()
        workflow.stopRecording()
        workflow.title = "Kept title"
        workflow.transcript = "Kept text"
        workflow.savePrivately()
        let id = try XCTUnwrap(workflow.currentStory?.id)
        workflow.title = "Unfinished title"
        workflow.transcript = "Unfinished text"
        XCTAssertTrue(workflow.hasUnsavedReviewChanges)
        XCTAssertFalse(workflow.resolveReviewExit(.cancel))
        XCTAssertEqual(workflow.transcript, "Unfinished text")
        XCTAssertTrue(workflow.resolveReviewExit(.discardChanges))
        XCTAssertEqual(workflow.title, "Kept title")
        XCTAssertEqual(workflow.transcript, "Kept text")
        XCTAssertFalse(workflow.hasUnsavedReviewChanges)
        let reopened = try StoryWorkflow(storageURL: root, audio: DeterministicAudio())
        reopened.openStory(id: id)
        XCTAssertEqual(reopened.currentStory?.isSaved, true)
        XCTAssertEqual(reopened.transcript, "Kept text")
        XCTAssertEqual(try Data(contentsOf: XCTUnwrap(reopened.currentAudioURL)), Data("spoken narration".utf8))
    }
    func testManualReviewEditsSaveAndReopenWithoutChangingOriginalNarration() async throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let workflow = try StoryWorkflow(storageURL: root, audio: DeterministicAudio())
        await workflow.startRecording()
        workflow.stopRecording()
        let id = try XCTUnwrap(workflow.currentStory?.id)
        workflow.title = "The moon's garden"
        workflow.creatorName = "Mama"
        workflow.theme = "Kindness"
        workflow.sourceLanguage = "isiZulu"
        workflow.transcript = "A little hare planted a seed."
        workflow.savePrivately()
        let reopened = try StoryWorkflow(storageURL: root, audio: DeterministicAudio())
        reopened.openStory(id: id)
        XCTAssertEqual(reopened.title, "The moon's garden")
        XCTAssertEqual(reopened.creatorName, "Mama")
        XCTAssertEqual(reopened.theme, "Kindness")
        XCTAssertEqual(reopened.sourceLanguage, "isiZulu")
        XCTAssertEqual(reopened.transcript, "A little hare planted a seed.")
        XCTAssertEqual(reopened.currentStory?.isSaved, true)
        XCTAssertEqual(reopened.currentStory?.visibility, "private")
        XCTAssertEqual(try Data(contentsOf: XCTUnwrap(reopened.currentAudioURL)), Data("spoken narration".utf8))
    }
    // Each case has an isolated OS-temporary workspace. Do not unlink live SQLite
    // files in defer: SwiftData may retain their descriptors until host teardown.

    func testPauseResumeKeepsBothSegmentsInOneSavedNarrationAndExcludesTheBreak() async throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let audio = PausableAudio()
        let workflow = try StoryWorkflow(storageURL: root, audio: audio)
        await workflow.startRecording()
        try audio.speak("beginning", lasting: 2)
        workflow.pauseRecording()
        XCTAssertEqual(workflow.captureState, .paused)
        XCTAssertEqual(workflow.elapsedRecording, 2)
        XCTAssertFalse(workflow.canLeaveReview)
        audio.wait(seconds: 7)
        XCTAssertEqual(workflow.elapsedRecording, 2)
        workflow.resumeRecording()
        XCTAssertEqual(workflow.captureState, .recording)
        try audio.speak("ending", lasting: 3)
        workflow.stopRecording()
        let draft = try XCTUnwrap(workflow.currentStory)
        XCTAssertEqual(draft.duration, 5)
        workflow.savePrivately()
        let reopened = try StoryWorkflow(storageURL: root, audio: PausableAudio())
        XCTAssertEqual(reopened.stories.count, 1)
        reopened.openStory(id: draft.id)
        XCTAssertEqual(reopened.currentStory?.duration, 5)
        XCTAssertEqual(try Data(contentsOf: XCTUnwrap(reopened.currentAudioURL)), Data("beginning ending ".utf8))
    }

    func testInterruptionWhilePausedKeepsTheTakeWithoutRestartingTheMicrophone() async throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let audio = PausableAudio()
        let workflow = try StoryWorkflow(storageURL: root, audio: audio)
        await workflow.startRecording()
        try audio.speak("before interruption", lasting: 2)
        workflow.pauseRecording()
        workflow.handleInterruption()
        XCTAssertEqual(workflow.captureState, .stopped)
        XCTAssertNotNil(workflow.errorMessage)
        let draft = try XCTUnwrap(workflow.currentStory)
        XCTAssertEqual(draft.duration, 2)
        workflow.resumeRecording()
        XCTAssertEqual(workflow.captureState, .stopped)
        XCTAssertEqual(try Data(contentsOf: XCTUnwrap(workflow.currentAudioURL)), Data("before interruption ".utf8))
    }

    func testDiscardingAPausedTakeClosesCaptureBeforeStartingAnotherStory() async throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let audio = PausableAudio()
        let workflow = try StoryWorkflow(storageURL: root, audio: audio)
        await workflow.startRecording()
        try audio.speak("discard me", lasting: 2)
        workflow.pauseRecording()
        workflow.discardRecording()
        XCTAssertEqual(workflow.captureState, .idle)
        await workflow.startRecording()
        XCTAssertEqual(workflow.captureState, .recording)
        try audio.speak("keep me", lasting: 3)
        workflow.stopRecording()
        XCTAssertEqual(workflow.stories.count, 1)
        XCTAssertEqual(try Data(contentsOf: XCTUnwrap(workflow.currentAudioURL)), Data("keep me ".utf8))
    }

    func testRepeatedAndOutOfOrderActionsPreserveTheActiveNarration() async throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let audio = PausableAudio()
        let workflow = try StoryWorkflow(storageURL: root, audio: audio)
        workflow.pauseRecording(); workflow.resumeRecording(); workflow.stopRecording()
        await workflow.startRecording()
        workflow.resumeRecording()
        try audio.speak("beginning", lasting: 2)
        workflow.retryKeepingRecording()
        XCTAssertEqual(workflow.captureState, .recording)
        XCTAssertNil(workflow.currentStory)
        workflow.pauseRecording(); workflow.pauseRecording()
        await workflow.startRecording()
        workflow.keepDraft(); workflow.savePrivately()
        XCTAssertEqual(workflow.captureState, .paused)
        XCTAssertNil(workflow.currentStory)
        workflow.resumeRecording(); workflow.resumeRecording()
        try audio.speak("ending", lasting: 3)
        workflow.stopRecording(); workflow.stopRecording(); workflow.resumeRecording()
        XCTAssertEqual(workflow.captureState, .stopped)
        XCTAssertEqual(workflow.stories.count, 1)
        XCTAssertEqual(workflow.currentStory?.duration, 5)
        XCTAssertEqual(try Data(contentsOf: XCTUnwrap(workflow.currentAudioURL)), Data("beginning ending ".utf8))
    }

    func testPauseFailurePreservesFinalizationErrorAndTheTakeCanBeRecovered() async throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let audio = PausableAudio()
        let workflow = try StoryWorkflow(storageURL: root, audio: audio)
        await workflow.startRecording()
        try audio.speak("keep this narration", lasting: 2)
        audio.pauseError = NSError(domain: "AudioBoundary", code: 1, userInfo: [NSLocalizedDescriptionKey: "Pause unavailable"])
        audio.finishError = NSError(domain: "AudioBoundary", code: 2, userInfo: [NSLocalizedDescriptionKey: "Finalization unavailable"])
        workflow.pauseRecording()
        XCTAssertEqual(workflow.captureState, .failed)
        XCTAssertNil(workflow.currentStory)
        XCTAssertTrue(workflow.hasPendingRecording)
        XCTAssertTrue(workflow.errorMessage?.contains("Finalization unavailable") == true)
        audio.finishError = nil
        workflow.retryKeepingRecording()
        XCTAssertNil(workflow.errorMessage)
        XCTAssertEqual(workflow.captureState, .stopped)
        XCTAssertEqual(workflow.currentStory?.duration, 2)
        XCTAssertEqual(try Data(contentsOf: XCTUnwrap(workflow.currentAudioURL)), Data("keep this narration ".utf8))
    }

    func testFailedDraftWriteCanBeRetriedWithoutLosingTheTakeOrIdentity() async throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let workflow = try StoryWorkflow(storageURL: root, audio: DeterministicAudio())
        await workflow.startRecording()
        // An actual filesystem obstruction, rather than mocking our repository.
        let recordings = root.appendingPathComponent("Recordings")
        try Data("blocked directory".utf8).write(to: recordings)
        workflow.stopRecording()
        let recoverableDraft = try XCTUnwrap(workflow.currentStory)
        XCTAssertNotNil(workflow.errorMessage)
        XCTAssertTrue(workflow.hasPendingRecording)
        XCTAssertFalse(workflow.canLeaveReview)
        try FileManager.default.removeItem(at: recordings)
        workflow.retryKeepingRecording()
        let draft = try XCTUnwrap(workflow.currentStory)
        XCTAssertNil(workflow.errorMessage)
        XCTAssertTrue(workflow.canLeaveReview)
        let reopened = try StoryWorkflow(storageURL: root, audio: DeterministicAudio())
        reopened.openStory(id: draft.id)
        XCTAssertEqual(reopened.currentStory, draft)
        XCTAssertEqual(draft.id, recoverableDraft.id)
        XCTAssertEqual(try Data(contentsOf: XCTUnwrap(reopened.currentAudioURL)), Data("spoken narration".utf8))
    }

    func testKeepingReviewEditsRetainsPrivateDraftBeforeRelaunch() async throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let workflow = try StoryWorkflow(storageURL: root, audio: DeterministicAudio())
        await workflow.startRecording()
        workflow.stopRecording()
        let id = try XCTUnwrap(workflow.currentStory?.id)
        workflow.title = "A story for tomorrow"
        workflow.keepDraft()
        let reopened = try StoryWorkflow(storageURL: root, audio: DeterministicAudio())
        reopened.openStory(id: id)
        XCTAssertEqual(reopened.title, "A story for tomorrow")
        XCTAssertEqual(reopened.currentStory?.isSaved, false)
        XCTAssertEqual(reopened.currentStory?.visibility, "private")
    }

    func testExplicitDiscardRemovesTheDraftAndItsOwnedRecording() async throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let workflow = try StoryWorkflow(storageURL: root, audio: DeterministicAudio())
        await workflow.startRecording()
        workflow.stopRecording()
        let audioURL = try XCTUnwrap(workflow.currentAudioURL)
        workflow.discardRecording()
        XCTAssertNil(workflow.currentStory)
        XCTAssertFalse(FileManager.default.fileExists(atPath: audioURL.path))
        let reopened = try StoryWorkflow(storageURL: root, audio: DeterministicAudio())
        XCTAssertTrue(reopened.stories.isEmpty)
    }

    func testDeniedMicrophoneNeverEntersRecordingAndCanRetryAfterAccessChanges() async throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let audio = DeterministicAudio()
        audio.permissionGranted = false
        let workflow = try StoryWorkflow(storageURL: root, audio: audio)
        await workflow.startRecording()
        XCTAssertEqual(workflow.captureState, .idle)
        XCTAssertTrue(workflow.permissionDenied)
        XCTAssertNotNil(workflow.errorMessage)
        XCTAssertFalse(workflow.hasPendingRecording)
        XCTAssertTrue(workflow.stories.isEmpty)
        audio.permissionGranted = true
        await workflow.startRecording()
        XCTAssertEqual(workflow.captureState, .recording)
        XCTAssertFalse(workflow.permissionDenied)
        workflow.stopRecording()
        XCTAssertNotNil(workflow.currentStory)
    }

    func testEmptyTakeCannotBeSavedAndExplicitDiscardAllowsANewRecording() async throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let audio = DeterministicAudio()
        audio.captureDuration = 0
        let workflow = try StoryWorkflow(storageURL: root, audio: audio)
        await workflow.startRecording()
        workflow.stopRecording()
        workflow.savePrivately()
        XCTAssertNil(workflow.currentStory)
        XCTAssertNotNil(workflow.errorMessage)
        XCTAssertTrue(workflow.stories.isEmpty)
        workflow.discardRecording()
        audio.captureDuration = 3
        await workflow.startRecording()
        workflow.stopRecording()
        XCTAssertNotNil(workflow.currentStory)
        XCTAssertNil(workflow.errorMessage)
    }

    func testUnavailableAudioDoesNotClaimASuccessfulSaveAndCanRetryWithTheSameDraft() async throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let workflow = try StoryWorkflow(storageURL: root, audio: DeterministicAudio())
        await workflow.startRecording()
        workflow.stopRecording()
        let draft = try XCTUnwrap(workflow.currentStory)
        let audioURL = try XCTUnwrap(workflow.currentAudioURL)
        let unavailable = root.appendingPathComponent("unavailable.m4a")
        try FileManager.default.moveItem(at: audioURL, to: unavailable)
        workflow.title = "Still my story"
        workflow.savePrivately()
        XCTAssertNotNil(workflow.errorMessage)
        XCTAssertEqual(workflow.currentStory?.isSaved, false)
        XCTAssertEqual(workflow.title, "Still my story")
        try FileManager.default.moveItem(at: unavailable, to: audioURL)
        workflow.savePrivately()
        let reopened = try StoryWorkflow(storageURL: root, audio: DeterministicAudio())
        reopened.openStory(id: draft.id)
        XCTAssertEqual(reopened.currentStory?.isSaved, true)
        XCTAssertEqual(reopened.title, "Still my story")
        XCTAssertEqual(try Data(contentsOf: XCTUnwrap(reopened.currentAudioURL)), Data("spoken narration".utf8))
    }

    func testFailedDiscardKeepsTheDraftAndAudioAvailable() async throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let recordings = root.appendingPathComponent("Recordings")
        defer {
            try? FileManager.default.setAttributes([.posixPermissions: 0o700], ofItemAtPath: recordings.path)
        }
        let workflow = try StoryWorkflow(storageURL: root, audio: DeterministicAudio())
        await workflow.startRecording()
        workflow.stopRecording()
        let id = try XCTUnwrap(workflow.currentStory?.id)
        try FileManager.default.setAttributes([.posixPermissions: 0o500], ofItemAtPath: recordings.path)
        workflow.discardRecording()
        XCTAssertNotNil(workflow.errorMessage)
        XCTAssertEqual(workflow.currentStory?.id, id)
        let reopened = try StoryWorkflow(storageURL: root, audio: DeterministicAudio())
        reopened.openStory(id: id)
        XCTAssertEqual(reopened.currentStory?.id, id)
        XCTAssertEqual(try Data(contentsOf: XCTUnwrap(reopened.currentAudioURL)), Data("spoken narration".utf8))
    }

    func testPartialDestinationIsNeverReportedAsTheRetainedNarration() async throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let workflow = try StoryWorkflow(storageURL: root, audio: DeterministicAudio())
        await workflow.startRecording()
        let capture = try XCTUnwrap(FileManager.default.contentsOfDirectory(at: root.appendingPathComponent("Captures"), includingPropertiesForKeys: nil).first)
        let recordings = root.appendingPathComponent("Recordings")
        try FileManager.default.createDirectory(at: recordings, withIntermediateDirectories: true)
        try Data("part".utf8).write(to: recordings.appendingPathComponent(capture.lastPathComponent))
        workflow.stopRecording()
        XCTAssertNil(workflow.errorMessage)
        XCTAssertEqual(try Data(contentsOf: XCTUnwrap(workflow.currentAudioURL)), Data("spoken narration".utf8))
    }

    func testSourceCleanupFailureRemainsOwnedAfterRelaunchAndExplicitDiscard() async throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let captures = root.appendingPathComponent("Captures")
        defer { try? FileManager.default.setAttributes([.posixPermissions: 0o700], ofItemAtPath: captures.path) }
        let workflow = try StoryWorkflow(storageURL: root, audio: DeterministicAudio())
        await workflow.startRecording()
        let original = try XCTUnwrap(FileManager.default.contentsOfDirectory(at: captures, includingPropertiesForKeys: nil).first)
        try FileManager.default.setAttributes([.posixPermissions: 0o500], ofItemAtPath: captures.path)
        workflow.stopRecording()
        let draft = try XCTUnwrap(workflow.currentStory)
        XCTAssertNotNil(workflow.errorMessage)
        XCTAssertEqual(try Data(contentsOf: XCTUnwrap(workflow.currentAudioURL)), Data("spoken narration".utf8))
        let staging = root.appendingPathComponent("Recordings/\(draft.id.uuidString).pending")
        try Data("retained staging narration".utf8).write(to: staging)
        let reopened = try StoryWorkflow(storageURL: root, audio: DeterministicAudio())
        reopened.openStory(id: draft.id)
        reopened.discardRecording()
        XCTAssertNotNil(reopened.errorMessage)
        XCTAssertEqual(reopened.currentStory?.id, draft.id)
        XCTAssertTrue(FileManager.default.fileExists(atPath: original.path))
        XCTAssertTrue(FileManager.default.fileExists(atPath: staging.path))
        try FileManager.default.setAttributes([.posixPermissions: 0o700], ofItemAtPath: captures.path)
        reopened.discardRecording()
        XCTAssertNil(reopened.errorMessage)
        XCTAssertFalse(FileManager.default.fileExists(atPath: original.path))
        XCTAssertFalse(FileManager.default.fileExists(atPath: staging.path))
        XCTAssertTrue(reopened.stories.isEmpty)
    }

    func testFailedPromotionStagingRemainsOwnedAfterRelaunchAndExplicitDiscard() async throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let recordings = root.appendingPathComponent("Recordings")
        defer { try? FileManager.default.setAttributes([.posixPermissions: 0o700], ofItemAtPath: recordings.path) }
        let workflow = try StoryWorkflow(storageURL: root, audio: DeterministicAudio())
        await workflow.startRecording()
        let original = try XCTUnwrap(FileManager.default.contentsOfDirectory(at: root.appendingPathComponent("Captures"), includingPropertiesForKeys: nil).first)
        let staging = recordings.appendingPathComponent(original.deletingPathExtension().lastPathComponent + ".pending")
        try FileManager.default.createDirectory(at: recordings, withIntermediateDirectories: true)
        try Data("partial spoken narration".utf8).write(to: staging)
        try FileManager.default.setAttributes([.posixPermissions: 0o500], ofItemAtPath: recordings.path)
        workflow.stopRecording()
        let draft = try XCTUnwrap(workflow.currentStory)
        XCTAssertNotNil(workflow.errorMessage)
        let reopened = try StoryWorkflow(storageURL: root, audio: DeterministicAudio())
        reopened.openStory(id: draft.id)
        XCTAssertEqual(try Data(contentsOf: XCTUnwrap(reopened.currentAudioURL)), Data("spoken narration".utf8))
        reopened.discardRecording()
        XCTAssertNotNil(reopened.errorMessage)
        XCTAssertEqual(reopened.currentStory?.id, draft.id)
        XCTAssertTrue(FileManager.default.fileExists(atPath: staging.path))
        try FileManager.default.setAttributes([.posixPermissions: 0o700], ofItemAtPath: recordings.path)
        reopened.discardRecording()
        XCTAssertNil(reopened.errorMessage)
        XCTAssertFalse(FileManager.default.fileExists(atPath: staging.path))
        XCTAssertFalse(FileManager.default.fileExists(atPath: original.path))
        XCTAssertTrue(reopened.stories.isEmpty)
    }

    func testFirstInstalledAppRecordingAndEditsReopenWithoutResettingItsStore() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let id = UUID(uuidString: "113F70C1-DF52-4D97-A2B5-E090CDE63D31")!
        let originalTitle = "My first recorded family story"
        let filename = id.uuidString + ".m4a"
        let folder = root.appendingPathComponent("Recordings")
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        try Data("original installed-app narration".utf8).write(to: folder.appendingPathComponent(filename))
        let date = Date(timeIntervalSince1970: 1_795_000_000)
        // Persist the actual original entity shape, then release its container.
        // This catches incompatible additions rather than merely testing new rows.
        try autoreleasepool {
            let legacyContainer = try ModelContainer(for: FirstInstalledModel.StoryRecord.self, configurations:
                ModelConfiguration(url: root.appendingPathComponent("Stories.sqlite"), cloudKitDatabase: .none))
            let legacyContext = ModelContext(legacyContainer)
            legacyContext.insert(FirstInstalledModel.StoryRecord(id: id, title: originalTitle, audioName: filename, date: date))
            try legacyContext.save()
        }
        let workflow = try StoryWorkflow(storageURL: root, audio: DeterministicAudio())
        workflow.openStory(id: id)
        XCTAssertEqual(workflow.title, originalTitle)
        XCTAssertEqual(workflow.currentStory?.visibility, "private")
        XCTAssertEqual(workflow.currentStory?.createdAt, date)
        XCTAssertEqual(workflow.currentStory?.isSaved, true)
        XCTAssertEqual(workflow.creatorName, "")
        XCTAssertEqual(workflow.theme, "")
        XCTAssertEqual(workflow.sourceLanguage, "")
        XCTAssertEqual(workflow.transcript, "")
        XCTAssertEqual(try Data(contentsOf: XCTUnwrap(workflow.currentAudioURL)), Data("original installed-app narration".utf8))
        workflow.title = "My edited family story"
        workflow.savePrivately()
        let reopened = try StoryWorkflow(storageURL: root, audio: DeterministicAudio())
        reopened.openStory(id: id)
        XCTAssertEqual(reopened.title, "My edited family story")
        XCTAssertEqual(reopened.currentStory?.id, id)
        XCTAssertEqual(reopened.currentStory?.visibility, "private")
        XCTAssertEqual(try Data(contentsOf: XCTUnwrap(reopened.currentAudioURL)), Data("original installed-app narration".utf8))
    }

    func testStoppedNarrationIsPrivateAndSurvivesSaveAndRelaunch() async throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let audio = DeterministicAudio()
        let workflow = try StoryWorkflow(storageURL: root, audio: audio)
        await workflow.startRecording()
        XCTAssertEqual(workflow.captureState, .recording)
        workflow.stopRecording()
        let draft = try XCTUnwrap(workflow.currentStory)
        XCTAssertFalse(draft.isSaved)
        XCTAssertEqual(draft.visibility, "private")
        workflow.title = "The brave little hare"
        workflow.savePrivately()
        XCTAssertNil(workflow.errorMessage)
        let reopened = try StoryWorkflow(storageURL: root, audio: DeterministicAudio())
        reopened.openStory(id: draft.id)
        XCTAssertEqual(reopened.currentStory?.id, draft.id)
        XCTAssertEqual(reopened.title, "The brave little hare")
        XCTAssertEqual(reopened.currentStory?.isSaved, true)
        XCTAssertEqual(try Data(contentsOf: XCTUnwrap(reopened.currentAudioURL)), Data("spoken narration".utf8))
        XCTAssertFalse(reopened.isPlaying)
        reopened.play()
        XCTAssertTrue(reopened.isPlaying)
    }
}

private enum FirstInstalledModel {
    @Model final class StoryRecord {
        @Attribute(.unique) var id: UUID
        var title: String
        var audioName: String
        var duration: TimeInterval
        var isSaved: Bool
        var visibility: String
        var createdAt: Date
        var updatedAt: Date

        init(id: UUID, title: String, audioName: String, date: Date) {
            self.id = id; self.title = title; self.audioName = audioName
            duration = 8; isSaved = true; visibility = "private"
            createdAt = date; updatedAt = date
        }
    }
}

@MainActor
final class DeterministicAudio: StoryAudio {
    var captureDuration: TimeInterval = 3
    var playbackTime: TimeInterval = 0
    var isPlaying = false
    var permissionGranted = true
    var permissionRequest: (() async -> Bool)?
    private var outputURL: URL?
    func requestPermission() async -> Bool {
        if let permissionRequest { return await permissionRequest() }
        return permissionGranted
    }
    func startRecording(to url: URL) throws {
        outputURL = url
        try Data("spoken narration".utf8).write(to: url)
    }
    func pauseRecording() throws { }
    func resumeRecording() throws { }
    func finishRecording() throws -> TimeInterval { captureDuration }
    func play(url: URL, fromStart: Bool) throws { isPlaying = true }
    func pausePlayback() { isPlaying = false }
    func stopPlayback() { isPlaying = false; playbackTime = 0 }
}

/// Deterministic microphone/clock boundary: only captured speech consumes duration.
@MainActor
final class PausableAudio: StoryAudio {
    var pauseError: Error?
    var finishError: Error?
    var captureDuration: TimeInterval = 0
    var playbackTime: TimeInterval = 0
    var isPlaying = false
    private var outputURL: URL?
    private var capturing = false
    func requestPermission() async -> Bool { true }
    func startRecording(to url: URL) throws {
        guard outputURL == nil else { throw CocoaError(.fileWriteFileExists) }
        outputURL = url; capturing = true; captureDuration = 0
        try Data().write(to: url)
    }
    func pauseRecording() throws {
        if let pauseError { throw pauseError }
        capturing = false
    }
    func resumeRecording() throws { capturing = true }
    func speak(_ words: String, lasting seconds: TimeInterval) throws {
        guard capturing, let outputURL else { return }
        let file = try FileHandle(forWritingTo: outputURL)
        defer { try? file.close() }
        try file.seekToEnd()
        try file.write(contentsOf: Data((words + " ").utf8))
        captureDuration += seconds
    }
    func wait(seconds: TimeInterval) { if capturing { captureDuration += seconds } }
    func finishRecording() throws -> TimeInterval {
        capturing = false; outputURL = nil
        if let finishError { throw finishError }
        return captureDuration
    }
    func play(url: URL, fromStart: Bool) throws { isPlaying = true }
    func pausePlayback() { isPlaying = false }
    func stopPlayback() { isPlaying = false; playbackTime = 0 }
}
