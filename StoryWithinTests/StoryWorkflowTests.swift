import XCTest
@testable import StoryWithin

@MainActor
final class StoryWorkflowTests: XCTestCase {
    // Each case has an isolated OS-temporary workspace. Do not unlink live SQLite
    // files in defer: SwiftData may retain their descriptors until host teardown.

    func testFailedDraftWriteCanBeRetriedWithoutLosingTheTakeOrIdentity() async throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let workflow = try StoryWorkflow(storageURL: root, audio: DeterministicAudio())
        await workflow.startRecording()
        // An actual filesystem obstruction, rather than mocking our repository.
        let recordings = root.appendingPathComponent("Recordings")
        try Data("blocked directory".utf8).write(to: recordings)
        workflow.stopRecording()
        XCTAssertNil(workflow.currentStory)
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

@MainActor
final class DeterministicAudio: StoryAudio {
    var captureDuration: TimeInterval = 3
    var playbackTime: TimeInterval = 0
    var isPlaying = false
    var permissionGranted = true
    private var outputURL: URL?
    func requestPermission() async -> Bool { permissionGranted }
    func startRecording(to url: URL) throws {
        outputURL = url
        try Data("spoken narration".utf8).write(to: url)
    }
    func finishRecording() throws -> TimeInterval { captureDuration }
    func play(url: URL, fromStart: Bool) throws { isPlaying = true }
    func pausePlayback() { isPlaying = false }
    func stopPlayback() { isPlaying = false; playbackTime = 0 }
}
