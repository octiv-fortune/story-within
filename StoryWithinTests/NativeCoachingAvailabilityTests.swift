import XCTest
@testable import StoryWithin

@MainActor
final class NativeCoachingAvailabilityTests: XCTestCase {
    func testNativeProviderReportsActualAvailabilityAndKeepsOlderOSInExplicitDemo() {
        let provider = StoryCoachProvider.makeDefault()
        print("Native coach selection: \(provider.modeLabel); reason: \(provider.availabilityMessage ?? "model ready with English support")")
        if #unavailable(iOS 26) {
            XCTAssertTrue(provider.isDemo)
            XCTAssertTrue(provider.availabilityMessage?.contains("iOS 26") == true)
        } else if provider.isDemo {
            XCTAssertNotNil(provider.availabilityMessage)
        } else {
            XCTAssertNil(provider.availabilityMessage)
        }
    }

    // Nondeterministic native-model checks are deliberately separate from doubles.
    // Shape checks do not prove quality: record excerpts for human authorship review.
    func testActualNativeEnglishGenerationWhenModelIsReady() async throws {
        let provider = StoryCoachProvider.makeDefault()
        guard !provider.isDemo else {
            throw XCTSkip("Actual generation unavailable: \(provider.availabilityMessage ?? "no system model")")
        }
        let scenarios = [
            "A gentle tortoise chooses a quiet garden. No race, no villain, and no frightening ending.",
            "My listener enjoys trains and a calm rhythm. Keep this a fictional adventure, with no medical advice.",
            "I want to invent my own garden tale, not claim it is an authentic traditional folktale."
        ]
        for idea in scenarios {
            var context = StoryCoachContext(approach: .idea, initialText: idea)
            let first = try await provider.respond(to: context)
            print("ACTUAL NATIVE FIXTURE: \(idea)\nGUIDANCE: \(first.guidance)\nQUESTION: \(first.question ?? "none")")
            XCTAssertLessThanOrEqual(first.guidance.count, 240)
            context.turns.append(StoryCoachTurn(parentText: nil, question: first.question))
            let afterSkip = try await provider.respond(to: context)
            print("AFTER SKIP: \(afterSkip.guidance)\nQUESTION: \(afterSkip.question ?? "none")")
            let cues = try await provider.prepareCues(for: context)
            print("ACTUAL PREPARED TEXT CUES: \(cues)")
            XCTAssertFalse(cues.isEmpty)
        }
    }
}
