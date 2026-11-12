import XCTest
@testable import StoryWithin

@MainActor
final class StoryCoachingTests: XCTestCase {
    private var folder: URL!
    override func setUp() async throws {
        folder = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    }

    func testIdeaEntersContextualDemoCoachingWithoutWritingTheStory() async throws {
        let workflow = try StoryWorkflow(storageURL: folder, audio: DeterministicAudio())
        await workflow.coaching.begin(approach: .idea, text: "A magical tortoise in a moonlit garden")

        XCTAssertEqual(workflow.coaching.modeLabel, "Demo coaching · On this device")
        XCTAssertEqual(workflow.coaching.context?.initialText, "A magical tortoise in a moonlit garden")
        XCTAssertTrue(workflow.coaching.reply?.guidance.contains("magical tortoise") == true)
        XCTAssertEqual(workflow.coaching.reply?.question, "What does your character want at the beginning?")
        XCTAssertLessThan(workflow.coaching.reply?.guidance.count ?? 1000, 240)
        XCTAssertEqual(workflow.captureState, .idle)
    }
    func testChildInterestAndParentAnswersShapeOneQuestionAtATime() async throws {
        let workflow = try StoryWorkflow(storageURL: folder, audio: DeterministicAudio())
        await workflow.coaching.begin(approach: .listener, text: "My child enjoys trains and quiet rhythms")
        XCTAssertTrue(workflow.coaching.reply?.guidance.contains("trains") == true)
        XCTAssertEqual(workflow.coaching.reply?.question, "What character could share this interest in your story?")
        await workflow.coaching.answer("A small train named Lelo, with a gentle tone")
        XCTAssertEqual(workflow.coaching.parentAnswers, ["A small train named Lelo, with a gentle tone"])
        XCTAssertTrue(workflow.coaching.reply?.guidance.contains("Lelo") == true)
        XCTAssertEqual(workflow.coaching.reply?.question, "Where would you like this story to take place?")
        XCTAssertEqual(workflow.coaching.context?.initialText, "My child enjoys trains and quiet rhythms")
    }

    func testSkipAdvancesWithoutInventingAParentAnswerAndCanEnterRecordingImmediately() async throws {
        let workflow = try StoryWorkflow(storageURL: folder, audio: DeterministicAudio())
        await workflow.coaching.begin(approach: .idea, text: "A magical tortoise")
        await workflow.coaching.skip()
        XCTAssertTrue(workflow.coaching.parentAnswers.isEmpty)
        XCTAssertEqual(workflow.coaching.reply?.question, "Where would you like this story to take place?")
        await workflow.prepareCoachedRecording()
        XCTAssertEqual(workflow.coaching.context?.initialText, "A magical tortoise")
        XCTAssertTrue(workflow.coaching.preparedCues.contains { $0.contains("magical tortoise") })
        XCTAssertFalse(workflow.coaching.usingGenericCues)
        await workflow.startRecording()
        XCTAssertEqual(workflow.captureState, .recording)
        workflow.stopRecording()
        XCTAssertNotNil(workflow.currentStory)
    }

    func testCuePreparationFailureStillAllowsRecordingWithGenericLabel() async throws {
        let workflow = try StoryWorkflow(storageURL: folder, audio: DeterministicAudio(), coach: UnavailableCueCoach())
        await workflow.coaching.begin(approach: .listener, text: "My child likes calm train journeys")
        await workflow.prepareCoachedRecording()
        XCTAssertTrue(workflow.coaching.parentAnswers.isEmpty)
        XCTAssertTrue(workflow.coaching.usingGenericCues)
        XCTAssertEqual(workflow.coaching.cueLabel, "Generic cues · Demo preparation unavailable")
        XCTAssertEqual(workflow.coaching.preparedCues.first, "Introduce a character in a place you choose.")
        await workflow.startRecording()
        XCTAssertEqual(workflow.captureState, .recording)
        workflow.stopRecording()
        workflow.savePrivately()
        XCTAssertTrue(workflow.currentStory?.isSaved == true)
    }

    func testImmediateRecordingKeepsUnsubmittedIdeaInSessionButNotSavedStoryOrReopen() async throws {
        let workflow = try StoryWorkflow(storageURL: folder, audio: DeterministicAudio())
        await workflow.prepareCoachedRecording(approach: .listener, text: "PRIVATE-PREFERENCE: quiet train journeys")
        XCTAssertNil(workflow.coaching.reply)
        XCTAssertEqual(workflow.coaching.context?.initialText, "PRIVATE-PREFERENCE: quiet train journeys")
        XCTAssertFalse(workflow.coaching.preparedCues.isEmpty)
        await workflow.startRecording()
        workflow.stopRecording()
        workflow.title = "The little train"
        workflow.savePrivately()
        let id = try XCTUnwrap(workflow.currentStory?.id)
        workflow.openStory(id: id)
        XCTAssertNil(workflow.coaching.context)
        XCTAssertTrue(workflow.coaching.preparedCues.isEmpty)
        let reopened = try StoryWorkflow(storageURL: folder, audio: DeterministicAudio())
        reopened.openStory(id: id)
        XCTAssertEqual(reopened.title, "The little train")
        XCTAssertEqual(reopened.currentStory?.visibility, "private")
        XCTAssertNil(reopened.coaching.context)
        XCTAssertTrue(reopened.coaching.preparedCues.isEmpty)
        XCTAssertFalse(String(describing: reopened.currentStory).contains("PRIVATE-PREFERENCE"))
        reopened.play()
        XCTAssertTrue(reopened.isPlaying)
    }

    func testCoachFailureShowsRecoveryAndKeepsParentContextWithoutBlockingRecording() async throws {
        let service = RecoveringDemoCoach()
        let workflow = try StoryWorkflow(storageURL: folder, audio: DeterministicAudio(), coach: service)
        await workflow.coaching.begin(approach: .idea, text: "Grandmother and a tortoise in Soweto")
        XCTAssertNotNil(workflow.coaching.errorMessage)
        XCTAssertNil(workflow.coaching.reply)
        XCTAssertEqual(workflow.coaching.context?.initialText, "Grandmother and a tortoise in Soweto")
        service.isUnavailable = false
        await workflow.coaching.retry()
        XCTAssertNil(workflow.coaching.errorMessage)
        XCTAssertEqual(workflow.coaching.reply?.question, "What does your character want at the beginning?")
        XCTAssertTrue(workflow.coaching.reply?.guidance.contains("Grandmother and a tortoise in Soweto") == true)
        await workflow.prepareCoachedRecording()
        await workflow.startRecording()
        XCTAssertEqual(workflow.captureState, .recording)
        workflow.stopRecording()
    }

    func testRecordingWhileCoachIsPreparingDoesNotWaitForOrApplyALateReply() async throws {
        let service = DelayedDemoCoach()
        let workflow = try StoryWorkflow(storageURL: folder, audio: DeterministicAudio(), coach: service)
        let beginning = Task { await workflow.coaching.begin(approach: .idea, text: "A moon garden") }
        await service.waitForRequest()
        XCTAssertTrue(workflow.coaching.isResponding)
        await workflow.prepareCoachedRecording()
        await workflow.startRecording()
        XCTAssertEqual(workflow.captureState, .recording)
        XCTAssertFalse(workflow.coaching.isResponding)
        service.finishReply()
        await beginning.value
        XCTAssertNil(workflow.coaching.reply)
        XCTAssertEqual(workflow.coaching.context?.initialText, "A moon garden")
        workflow.stopRecording()
    }

    func testRecordingCarriesTheParentsUnsubmittedNextThoughtWithoutAnotherExchange() async throws {
        let workflow = try StoryWorkflow(storageURL: folder, audio: DeterministicAudio())
        await workflow.coaching.begin(approach: .idea, text: "A magical tortoise")
        await workflow.prepareCoachedRecording(thought: "She stays gentle and visits the mountain")
        XCTAssertEqual(workflow.coaching.parentAnswers, ["She stays gentle and visits the mountain"])
        XCTAssertTrue(workflow.coaching.preparedCues.contains { $0.contains("visits the mountain") })
        XCTAssertEqual(workflow.coaching.context?.initialText, "A magical tortoise")
        await workflow.startRecording()
        XCTAssertEqual(workflow.captureState, .recording)
        workflow.stopRecording()
    }

}


private struct UnavailableCueCoach: StoryCoachService {
    let modeLabel = "Demo coaching · On this device"
    func respond(to context: StoryCoachContext) async throws -> StoryCoachReply {
        try await DemoStoryCoachService().respond(to: context)
    }
    func prepareCues(for context: StoryCoachContext?) async throws -> [String] {
        throw CocoaError(.fileReadUnknown)
    }
}


@MainActor
private final class RecoveringDemoCoach: StoryCoachService {
    let modeLabel = "Demo coaching · On this device"
    var isUnavailable = true
    func respond(to context: StoryCoachContext) async throws -> StoryCoachReply {
        if isUnavailable { throw CocoaError(.fileReadUnknown) }
        return try await DemoStoryCoachService().respond(to: context)
    }
    func prepareCues(for context: StoryCoachContext?) async throws -> [String] {
        try await DemoStoryCoachService().prepareCues(for: context)
    }
}


@MainActor
private final class DelayedDemoCoach: StoryCoachService {
    let modeLabel = "Demo coaching · On this device"
    private var pending: CheckedContinuation<StoryCoachReply, Error>?
    private var waiting: CheckedContinuation<Void, Never>?
    func respond(to context: StoryCoachContext) async throws -> StoryCoachReply {
        try await withCheckedThrowingContinuation { continuation in
            pending = continuation
            waiting?.resume(); waiting = nil
        }
    }
    func waitForRequest() async {
        if pending != nil { return }
        await withCheckedContinuation { waiting = $0 }
    }
    func finishReply() {
        pending?.resume(returning: StoryCoachReply(guidance: "A late prompt", question: "What happens next?"))
        pending = nil
    }
    func prepareCues(for context: StoryCoachContext?) async throws -> [String] {
        try await DemoStoryCoachService().prepareCues(for: context)
    }
}
