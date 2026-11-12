import XCTest
@testable import StoryWithin

@MainActor
final class OnDeviceCoachingTests: XCTestCase {
    func testUnavailableSystemModelSelectsExplicitDemoAndStillSavesARecording() async throws {
        let model = ControlledStoryModel()
        model.availability = .unavailable("Apple Intelligence is turned off.")
        let folder = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let workflow = try StoryWorkflow(storageURL: folder, audio: DeterministicAudio(), coach: StoryCoachProvider.select(model: model))
        await workflow.coaching.begin(approach: .idea, text: "A gentle tortoise")
        XCTAssertEqual(workflow.coaching.modeLabel, "Demo coaching · On this device")
        XCTAssertEqual(workflow.coaching.availabilityMessage, "Apple Intelligence is turned off.")
        XCTAssertNotNil(workflow.coaching.reply)
        await workflow.prepareCoachedRecording()
        await workflow.startRecording()
        workflow.stopRecording()
        workflow.savePrivately()
        XCTAssertTrue(workflow.currentStory?.isSaved == true)
        XCTAssertTrue(model.requests.isEmpty)
    }
    func testReadyEnglishModelProducesLabeledOnDeviceGuidanceAndPreparedCuesBeforeRecording() async throws {
        let model = ControlledStoryModel()
        let folder = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let workflow = try StoryWorkflow(storageURL: folder, audio: DeterministicAudio(), coach: StoryCoachProvider.select(model: model))
        await workflow.coaching.begin(approach: .idea, text: "A gentle tortoise")
        XCTAssertEqual(workflow.coaching.modeLabel, "Apple Intelligence · On-device English coaching")
        XCTAssertNil(workflow.coaching.availabilityMessage)
        XCTAssertEqual(workflow.coaching.reply?.question, "Where would you like her to go?")
        XCTAssertEqual(workflow.coaching.coachTitle, "On-device coach")
        await workflow.prepareCoachedRecording(thought: "She chooses the garden")
        XCTAssertEqual(workflow.coaching.cueLabel, "Prepared cues · Apple Intelligence on device")
        XCTAssertEqual(workflow.coaching.parentAnswers, ["She chooses the garden"])
        let requestsBeforeCapture = model.requests.count
        await workflow.startRecording()
        workflow.pauseForInspiration()
        XCTAssertEqual(workflow.currentCue, "Begin with your gentle tortoise.")
        XCTAssertEqual(workflow.captureState, .paused)
        XCTAssertFalse(workflow.isPlaying)
        workflow.resumeRecording()
        workflow.stopRecording()
        workflow.savePrivately()
        XCTAssertEqual(model.requests.count, requestsBeforeCapture)
        let reopened = try StoryWorkflow(storageURL: folder, audio: DeterministicAudio())
        reopened.openStory(id: try XCTUnwrap(workflow.currentStory?.id))
        XCTAssertTrue(reopened.currentStory?.isSaved == true)
        XCTAssertNil(reopened.coaching.context)
    }

    func testFailedRealResponseKeepsChoicesAndRetryNeverSilentlyUsesDemo() async throws {
        let model = ControlledStoryModel()
        let folder = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let workflow = try StoryWorkflow(storageURL: folder, audio: DeterministicAudio(), coach: StoryCoachProvider.select(model: model))
        await workflow.coaching.begin(approach: .idea, text: "A gentle tortoise")
        model.failure = CocoaError(.fileReadUnknown)
        await workflow.coaching.answer("No race; she wants to rest")
        XCTAssertNil(workflow.coaching.reply)
        XCTAssertTrue(workflow.coaching.errorMessage?.contains("On-device coaching") == true)
        XCTAssertFalse(workflow.coaching.errorMessage?.contains("Demo") == true)
        XCTAssertEqual(workflow.coaching.parentAnswers, ["No race; she wants to rest"])
        await workflow.prepareCoachedRecording()
        XCTAssertEqual(workflow.coaching.cueLabel, "Generic cues · On-device preparation unavailable")
        XCTAssertTrue(workflow.coaching.usingGenericCues)
        await workflow.startRecording()
        workflow.stopRecording()
        workflow.savePrivately()
        XCTAssertTrue(workflow.currentStory?.isSaved == true)
        model.failure = nil
        await workflow.coaching.retry()
        XCTAssertNil(workflow.coaching.errorMessage)
        XCTAssertEqual(workflow.coaching.reply?.question, "Where would you like her to go?")
        XCTAssertEqual(workflow.coaching.parentAnswers, ["No race; she wants to rest"])
    }

    func testLargeParentSessionIsKeptWhileEachModelRequestHasASmallIndependentBudget() async throws {
        let model = ControlledStoryModel()
        let folder = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let workflow = try StoryWorkflow(storageURL: folder, audio: DeterministicAudio(), coach: StoryCoachProvider.select(model: model))
        let idea = String(repeating: "A tortoise 🌿 ", count: 500) + "."
        await workflow.coaching.begin(approach: .idea, text: idea)
        for index in 0..<16 { workflow.coaching.keepThought("Choice \(index): " + String(repeating: "gentle garden ", count: 200) + ".") }
        await workflow.coaching.answer("Latest choice: keep her gentle")
        let request = try XCTUnwrap(model.requests.last)
        XCTAssertLessThanOrEqual(request.prompt.utf8.count, 1500)
        XCTAssertLessThanOrEqual(request.instructions.utf8.count, 1100)
        XCTAssertLessThanOrEqual(request.maximumResponseTokens, 240)
        XCTAssertTrue(request.prompt.contains("Latest choice: keep her gentle"))
        XCTAssertTrue(request.instructions.contains("Never write"))
        XCTAssertEqual(workflow.coaching.context?.initialText, idea)
        XCTAssertEqual(workflow.coaching.parentAnswers.count, 17)
        XCTAssertTrue(workflow.coaching.parentAnswers[0].contains(String(repeating: "gentle garden ", count: 200)))
    }

    func testInvalidModelContentIsRejectedAndRecordingUsesExplicitGenericCues() async throws {
        let model = ControlledStoryModel()
        model.replyValue = StoryCoachReply(guidance: String(repeating: "A whole story. ", count: 80), question: "Where? Why?")
        model.cueValues = [String(repeating: "Story scene ", count: 80)]
        let folder = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let workflow = try StoryWorkflow(storageURL: folder, audio: DeterministicAudio(), coach: StoryCoachProvider.select(model: model))
        await workflow.coaching.begin(approach: .idea, text: "My own tortoise story")
        XCTAssertNil(workflow.coaching.reply)
        XCTAssertNotNil(workflow.coaching.errorMessage)
        XCTAssertEqual(workflow.coaching.context?.initialText, "My own tortoise story")
        await workflow.prepareCoachedRecording()
        XCTAssertTrue(workflow.coaching.usingGenericCues)
        XCTAssertEqual(workflow.coaching.cueLabel, "Generic cues · On-device preparation unavailable")
        await workflow.startRecording()
        workflow.pauseForInspiration()
        XCTAssertEqual(workflow.currentCue, "Introduce a character in a place you choose.")
        workflow.stopRecording()
    }

    func testAvailabilityChangeAfterRealSelectionReportsTheReasonAndDoesNotSwitchProvider() async throws {
        let model = ControlledStoryModel()
        let folder = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let workflow = try StoryWorkflow(storageURL: folder, audio: DeterministicAudio(), coach: StoryCoachProvider.select(model: model))
        await workflow.coaching.begin(approach: .idea, text: "A tortoise who rests")
        model.availability = .unavailable("The on-device model is not ready.")
        await workflow.coaching.answer("Keep her calm")
        XCTAssertNil(workflow.coaching.reply)
        XCTAssertTrue(workflow.coaching.errorMessage?.contains("model is not ready") == true)
        XCTAssertEqual(workflow.coaching.modeLabel, "Apple Intelligence · On-device English coaching")
        XCTAssertEqual(workflow.coaching.parentAnswers, ["Keep her calm"])
        await workflow.prepareCoachedRecording()
        XCTAssertEqual(workflow.coaching.cueLabel, "Generic cues · On-device preparation unavailable")
        await workflow.startRecording()
        XCTAssertEqual(workflow.captureState, .recording)
        workflow.stopRecording()
    }

}

@MainActor
private final class ControlledStoryModel: OnDeviceStoryModel {
    var availability: StoryModelAvailability = .available
    var requests: [StoryModelRequest] = []
    var failure: Error?
    var replyValue = StoryCoachReply(guidance: "Keep your gentle tortoise as you chose.", question: "Where would you like her to go?")
    var cueValues = ["Begin with your gentle tortoise.", "Choose her next step yourself.", "End in your own words."]
    func reply(to request: StoryModelRequest) async throws -> StoryCoachReply {
        requests.append(request)
        if let failure { throw failure }
        return replyValue
    }
    func cues(for request: StoryModelRequest) async throws -> [String] {
        requests.append(request)
        if let failure { throw failure }
        return cueValues
    }
}
