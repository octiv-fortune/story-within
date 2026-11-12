import AVFoundation
import XCTest
@testable import StoryWithin

@MainActor
final class DemoStoryWorkflowTests: XCTestCase {
    func testHumanDemoPlaybackCanPauseResumeReplaySwitchAndStopForCapture() async throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let native = NativeStoryAudio()
        let workflow = try StoryWorkflow(storageURL: root, audio: native)
        let first = try XCTUnwrap(workflow.demoStories.first)
        let second = workflow.demoStories[1]
        workflow.openDemoStory(id: first.id)
        XCTAssertEqual(workflow.selectedDemoStory?.id, first.id)
        XCTAssertFalse(workflow.isPlaying, "Selecting never autoplays")
        workflow.playDemo()
        XCTAssertNil(workflow.demoPlaybackError)
        XCTAssertTrue(workflow.isPlaying, "Real AVAudioPlayer must accept the bundled MP3")
        try await Task.sleep(for: .milliseconds(300))
        XCTAssertGreaterThan(workflow.playbackTime, 0)
        workflow.pausePlayback()
        XCTAssertFalse(workflow.isPlaying)
        let pausedAt = workflow.playbackTime
        workflow.playDemo()
        XCTAssertTrue(workflow.isPlaying)
        XCTAssertGreaterThanOrEqual(workflow.playbackTime, pausedAt)
        workflow.playDemo(fromStart: true)
        XCTAssertLessThan(workflow.playbackTime, 0.2)
        workflow.openDemoStory(id: second.id)
        XCTAssertFalse(workflow.isPlaying, "Switching stops the prior story")
        XCTAssertEqual(workflow.playbackTime, 0)
        workflow.playDemo()
        XCTAssertNil(workflow.demoPlaybackError)
        XCTAssertTrue(workflow.isPlaying)
        workflow.prepareNewRecording()
        XCTAssertFalse(workflow.isPlaying)
        XCTAssertEqual(workflow.playbackTime, 0)
        for story in workflow.demoStories {
            let asset = try XCTUnwrap(Bundle.main.url(forResource: (story.file as NSString).deletingPathExtension, withExtension: "mp3"))
            let decoded = try AVAudioPlayer(contentsOf: asset)
            XCTAssertEqual(decoded.duration, story.duration, accuracy: 0.2)
        }
    }

    func testCaptureStopsDemoPlaybackAndKeepsThePersonalLibrarySeparate() async throws {
        let audio = DeterministicAudio()
        let workflow = try StoryWorkflow(storageURL: FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString), audio: audio)
        workflow.openDemoStory(id: "storybook-0006-en")
        workflow.playDemo()
        XCTAssertTrue(workflow.isPlaying)
        await workflow.startRecording()
        XCTAssertFalse(workflow.isPlaying)
        XCTAssertFalse(audio.isPlaying)
        XCTAssertNil(workflow.selectedDemoStory)
        XCTAssertEqual(workflow.captureState, .recording)
        workflow.stopRecording()
        let personal = try XCTUnwrap(workflow.currentStory)
        workflow.openDemoStory(id: "storybook-0004-en")
        workflow.playDemo()
        XCTAssertEqual(workflow.currentStory?.id, personal.id, "Demo playback must not replace a parent’s draft")
        workflow.openStory(id: personal.id)
        XCTAssertFalse(workflow.isPlaying)
        XCTAssertNil(workflow.selectedDemoStory)
        workflow.play()
        XCTAssertTrue(workflow.isPlaying)
    }

    func testMissingDemoAndEmptyCollectionHaveRecoverableStatesWithoutChangingPrivateDrafts() async throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let bundled = DemoLibrary.bundled()
        let workflow = try StoryWorkflow(storageURL: root, audio: DeterministicAudio(), demoLibrary: DemoLibrary(stories: bundled.stories, audioURLs: [:]))
        await workflow.startRecording()
        workflow.stopRecording()
        let personal = try XCTUnwrap(workflow.currentStory)
        workflow.openDemoStory(id: "storybook-0006-en")
        workflow.playDemo()
        XCTAssertFalse(workflow.isPlaying)
        XCTAssertTrue(try XCTUnwrap(workflow.demoPlaybackError).contains("missing"))
        XCTAssertEqual(workflow.currentStory, personal)
        XCTAssertNil(workflow.errorMessage)
        let empty = try StoryWorkflow(storageURL: root, audio: DeterministicAudio(), demoLibrary: DemoLibrary(stories: [], audioURLs: [:]))
        XCTAssertTrue(empty.demoStories.isEmpty)
        empty.openDemoStory(id: "unknown")
        empty.playDemo()
        XCTAssertNil(empty.selectedDemoStory)
        XCTAssertFalse(empty.isPlaying)
        XCTAssertEqual(empty.stories.map(\.id), [personal.id])
    }

    func testPlaybackFailureCanRetryAndNeverMutatesPersonalStories() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        let broken = root.appendingPathComponent("broken.mp3")
        try Data("not a recording".utf8).write(to: broken)
        let bundled = DemoLibrary.bundled()
        let workflow = try StoryWorkflow(storageURL: root, audio: NativeStoryAudio(), demoLibrary: DemoLibrary(stories: bundled.stories, audioURLs: ["storybook-0006-en": broken]))
        workflow.openDemoStory(id: "storybook-0006-en")
        workflow.playDemo()
        XCTAssertFalse(workflow.isPlaying)
        XCTAssertTrue(try XCTUnwrap(workflow.demoPlaybackError).contains("Try Play again"))
        try FileManager.default.copyItem(at: XCTUnwrap(bundled.audioURLs["storybook-0006-en"]), to: root.appendingPathComponent("valid.mp3"))
        try FileManager.default.removeItem(at: broken)
        try FileManager.default.moveItem(at: root.appendingPathComponent("valid.mp3"), to: broken)
        workflow.playDemo()
        XCTAssertTrue(workflow.isPlaying)
        XCTAssertNil(workflow.demoPlaybackError)
        XCTAssertTrue(workflow.stories.isEmpty)
        workflow.stopPlayback()
    }

    func testBundledDiscoveryIsStableAcrossRelaunchAndNeverIncludesPrivateStories() async throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let workflow = try StoryWorkflow(storageURL: root, audio: DeterministicAudio())
        XCTAssertEqual(workflow.demoStories.map(\.id), ["storybook-0006-en", "storybook-0004-en"])
        XCTAssertTrue(workflow.stories.isEmpty)
        await workflow.startRecording()
        workflow.stopRecording()
        workflow.title = "My private family story"
        workflow.savePrivately()
        let relaunched = try StoryWorkflow(storageURL: root, audio: DeterministicAudio())
        XCTAssertEqual(relaunched.demoStories.map(\.id), ["storybook-0006-en", "storybook-0004-en"])
        XCTAssertEqual(relaunched.stories.map(\.title), ["My private family story"])
        XCTAssertFalse(relaunched.demoStories.contains { $0.title == "My private family story" })
        XCTAssertEqual(relaunched.demoStories.map(\.narrator), ["Darshan Soni", "Darshan Soni"])
        XCTAssertEqual(relaunched.demoStories.map(\.sourceAuthor), ["Ghanaian folktale", "Fabian Wakholi"])
    }
}
