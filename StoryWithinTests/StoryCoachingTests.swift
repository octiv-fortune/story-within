import XCTest
@testable import StoryWithin

@MainActor
final class StoryCoachingTests: XCTestCase {
    private var folder: URL!
    override func setUp() async throws {
        folder = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    }

    func testPauseForInspirationPausesCaptureBeforeShowingContextualCueAndResumesOnlyOnRequest() async throws {
        let audio = PausableAudio()
        let workflow = try StoryWorkflow(storageURL: folder, audio: audio, coach: DemoStoryCoachService())
        await workflow.prepareCoachedRecording(approach: .idea, text: "A magical tortoise")
        await workflow.startRecording()
        try audio.speak("beginning", lasting: 2)
        XCTAssertNil(workflow.currentCue)
        workflow.pauseForInspiration()
        XCTAssertEqual(workflow.captureState, .paused)
        XCTAssertEqual(workflow.currentCue, "Begin with your starting point: A magical tortoise")
        XCTAssertEqual(workflow.inspirationLabel, "Prepared cues · Demo")
        XCTAssertFalse(workflow.isPlaying)
        try audio.speak("not captured", lasting: 8)
        XCTAssertEqual(workflow.elapsedRecording, 2)
        workflow.resumeRecording()
        XCTAssertNil(workflow.currentCue)
        XCTAssertEqual(workflow.captureState, .recording)
        try audio.speak("ending", lasting: 3)
        workflow.stopRecording()
        workflow.savePrivately()
        let id = try XCTUnwrap(workflow.currentStory?.id)
        let reopened = try StoryWorkflow(storageURL: folder, audio: PausableAudio(), coach: DemoStoryCoachService())
        reopened.openStory(id: id)
        XCTAssertEqual(reopened.currentStory?.duration, 5)
        XCTAssertEqual(try Data(contentsOf: XCTUnwrap(reopened.currentAudioURL)), Data("beginning ending ".utf8))
        XCTAssertNil(reopened.currentCue)
        XCTAssertTrue(reopened.coaching.preparedCues.isEmpty)
    }

    func testGenericCuesAdvanceOnlyWhilePausedAndExhaustionLeavesResumeAndStopAvailable() async throws {
        let workflow = try StoryWorkflow(storageURL: folder, audio: DeterministicAudio(), coach: DemoStoryCoachService())
        workflow.showNextCue()
        XCTAssertNil(workflow.currentCue)
        await workflow.startRecording()
        workflow.showNextCue()
        XCTAssertNil(workflow.currentCue)
        workflow.pauseForInspiration()
        XCTAssertEqual(workflow.inspirationLabel, "Generic cues · Demo")
        XCTAssertEqual(workflow.currentCue, "Introduce a character in a place you choose.")
        workflow.showNextCue()
        XCTAssertEqual(workflow.currentCue, "Give your character a small choice.")
        workflow.resumeRecording()
        XCTAssertNil(workflow.currentCue)
        workflow.pauseRecording()
        XCTAssertNil(workflow.currentCue)
        workflow.showNextCue()
        XCTAssertEqual(workflow.currentCue, "Find an ending that feels right to you.")
        workflow.showNextCue()
        XCTAssertNil(workflow.currentCue)
        XCTAssertEqual(workflow.inspirationMessage, "You’ve reached the last cue. Continue in your own words, or stop to review your story.")
        workflow.showNextCue()
        XCTAssertEqual(workflow.captureState, .paused)
        XCTAssertFalse(workflow.isPlaying)
        workflow.resumeRecording()
        XCTAssertNil(workflow.inspirationMessage)
        XCTAssertEqual(workflow.captureState, .recording)
        workflow.stopRecording()
        XCTAssertNotNil(workflow.currentStory)
        XCTAssertNil(workflow.currentCue)
    }

    func testUnavailablePreparationUsesLabeledGenericCuesWithoutCallingCoachDuringCapture() async throws {
        let coach = UnavailableCueCoach()
        let workflow = try StoryWorkflow(storageURL: folder, audio: DeterministicAudio(), coach: coach)
        await workflow.prepareCoachedRecording(approach: .idea, text: "A tortoise")
        XCTAssertEqual(coach.preparationRequests, 1)
        await workflow.startRecording()
        workflow.pauseForInspiration()
        XCTAssertEqual(workflow.inspirationLabel, "Generic cues · Demo preparation unavailable")
        XCTAssertEqual(workflow.currentCue, "Introduce a character in a place you choose.")
        workflow.showNextCue()
        XCTAssertEqual(workflow.currentCue, "Give your character a small choice.")
        XCTAssertEqual(coach.preparationRequests, 1)
        XCTAssertEqual(workflow.captureState, .paused)
        workflow.stopRecording()
        XCTAssertNotNil(workflow.currentStory)
        XCTAssertNil(workflow.currentCue)
    }

    func testFailedPauseNeverDisplaysACueOrFalselyReportsPausedCapture() async throws {
        for finalizationFails in [false, true] {
            let audio = PausableAudio()
            audio.pauseError = CocoaError(.fileWriteUnknown)
            if finalizationFails { audio.finishError = CocoaError(.fileWriteUnknown) }
            let workflow = try StoryWorkflow(storageURL: folder.appendingPathComponent(UUID().uuidString), audio: audio, coach: DemoStoryCoachService())
            await workflow.startRecording()
            try audio.speak("kept beginning", lasting: 2)
            workflow.pauseForInspiration()
            XCTAssertEqual(workflow.captureState, finalizationFails ? .failed : .stopped)
            XCTAssertNotNil(workflow.errorMessage)
            XCTAssertNil(workflow.currentCue)
            XCTAssertNil(workflow.inspirationMessage)
            workflow.showNextCue()
            XCTAssertNil(workflow.currentCue)
            if !finalizationFails {
                XCTAssertEqual(try Data(contentsOf: XCTUnwrap(workflow.currentAudioURL)), Data("kept beginning ".utf8))
            }
        }
    }

    func testFailedResumeKeepsCueAndPausedTakeUntilExplicitRetryOrStop() async throws {
        let audio = PausableAudio()
        let workflow = try StoryWorkflow(storageURL: folder, audio: audio, coach: DemoStoryCoachService())
        await workflow.startRecording()
        try audio.speak("beginning", lasting: 2)
        workflow.pauseForInspiration()
        audio.resumeError = CocoaError(.fileWriteUnknown)
        workflow.resumeRecording()
        XCTAssertEqual(workflow.captureState, .paused)
        XCTAssertNotNil(workflow.errorMessage)
        XCTAssertEqual(workflow.currentCue, "Introduce a character in a place you choose.")
        try audio.speak("not captured", lasting: 8)
        XCTAssertEqual(workflow.elapsedRecording, 2)
        audio.resumeError = nil
        workflow.resumeRecording()
        XCTAssertEqual(workflow.captureState, .recording)
        XCTAssertNil(workflow.currentCue)
        XCTAssertNil(workflow.errorMessage)
        try audio.speak("ending", lasting: 3)
        workflow.stopRecording()
        XCTAssertEqual(try Data(contentsOf: XCTUnwrap(workflow.currentAudioURL)), Data("beginning ending ".utf8))
    }

    func testIdeaEntersContextualDemoCoachingWithoutWritingTheStory() async throws {
        let workflow = try StoryWorkflow(storageURL: folder, audio: DeterministicAudio(), coach: DemoStoryCoachService())
        await workflow.coaching.begin(approach: .idea, text: "A magical tortoise in a moonlit garden")

        XCTAssertEqual(workflow.coaching.modeLabel, "Demo coaching · On this device")
        XCTAssertEqual(workflow.coaching.context?.initialText, "A magical tortoise in a moonlit garden")
        XCTAssertTrue(workflow.coaching.reply?.guidance.contains("magical tortoise") == true)
        XCTAssertEqual(workflow.coaching.reply?.question, "What does your character want at the beginning?")
        XCTAssertLessThan(workflow.coaching.reply?.guidance.count ?? 1000, 240)
        XCTAssertEqual(workflow.captureState, .idle)
    }
    func testChildInterestAndParentAnswersShapeOneQuestionAtATime() async throws {
        let workflow = try StoryWorkflow(storageURL: folder, audio: DeterministicAudio(), coach: DemoStoryCoachService())
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
        let workflow = try StoryWorkflow(storageURL: folder, audio: DeterministicAudio(), coach: DemoStoryCoachService())
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
        let workflow = try StoryWorkflow(storageURL: folder, audio: DeterministicAudio(), coach: DemoStoryCoachService())
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
        let reopened = try StoryWorkflow(storageURL: folder, audio: DeterministicAudio(), coach: DemoStoryCoachService())
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
        let workflow = try StoryWorkflow(storageURL: folder, audio: DeterministicAudio(), coach: DemoStoryCoachService())
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


@MainActor
private final class UnavailableCueCoach: StoryCoachService {
    private(set) var preparationRequests = 0
    let modeLabel = "Demo coaching · On this device"
    func respond(to context: StoryCoachContext) async throws -> StoryCoachReply {
        try await DemoStoryCoachService().respond(to: context)
    }
    func prepareCues(for context: StoryCoachContext?) async throws -> [String] {
        preparationRequests += 1
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
