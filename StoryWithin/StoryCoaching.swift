import Foundation
import Observation

enum StoryStartingApproach: String, CaseIterable, Identifiable {
    case idea, listener
    var id: Self { self }
    var title: String { self == .idea ? "Start with an idea" : "Start with my child" }
}

struct StoryCoachContext: Equatable {
    let approach: StoryStartingApproach
    let initialText: String
    var turns: [StoryCoachTurn] = []
}

struct StoryCoachTurn: Equatable, Identifiable {
    let id = UUID()
    let parentText: String?
    var question: String? = nil
}

struct StoryCoachReply: Equatable {
    let guidance: String
    let question: String?
}

@MainActor
protocol StoryCoachService {
    var modeLabel: String { get }
    func respond(to context: StoryCoachContext) async throws -> StoryCoachReply
    func prepareCues(for context: StoryCoachContext?) async throws -> [String]
}

struct DemoStoryCoachService: StoryCoachService {
    let modeLabel = "Demo coaching · On this device"
    func respond(to context: StoryCoachContext) async throws -> StoryCoachReply {
        let detail = context.turns.compactMap(\.parentText).last ?? context.initialText
        let guidance = context.turns.isEmpty
            ? "Your \(context.approach == .idea ? "idea" : "listener’s interest"), ‘\(detail.prefix(120))’, is the starting point. You choose what happens."
            : "Keep your choice, ‘\(detail.prefix(120))’, in your own telling. You decide the next step."
        let question: String
        if context.turns.isEmpty {
            question = context.approach == .idea
                ? "What does your character want at the beginning?"
                : "What character could share this interest in your story?"
        } else {
            let questions = ["Where would you like this story to take place?",
                             "What small challenge could your character face?",
                             "What feeling would you like to leave your listener with?"]
            question = questions[(context.turns.count - 1) % questions.count]
        }
        return StoryCoachReply(guidance: guidance, question: question)
    }
    func prepareCues(for context: StoryCoachContext?) async throws -> [String] {
        guard let context, !context.initialText.isEmpty else { return StoryCoaching.genericCues }
        var cues = ["Begin with your starting point: \(context.initialText.prefix(140))",
                    "Give your character a small choice. You decide what it is."]
        if let choice = context.turns.compactMap(\.parentText).last {
            cues.append("Return to your choice: \(choice.prefix(140))")
        }
        cues.append("Bring the story to an ending that feels right to you.")
        return cues
    }
}

@MainActor
@Observable
final class StoryCoaching {
    private let service: any StoryCoachService
    private var requestID = UUID()
    private(set) var context: StoryCoachContext?
    private(set) var errorMessage: String?
    private(set) var isResponding = false
    private(set) var isPreparingCues = false
    private(set) var reply: StoryCoachReply?
    private(set) var preparedCues: [String] = []
    private(set) var usingGenericCues = false
    private(set) var cueLabel = ""
    static let genericCues = ["Introduce a character in a place you choose.",
                              "Give your character a small choice.",
                              "Find an ending that feels right to you."]
    var modeLabel: String { service.modeLabel }
    var parentAnswers: [String] { context?.turns.compactMap(\.parentText) ?? [] }

    init(service: any StoryCoachService) { self.service = service }

    func skip() async {
        guard var context else { return }
        context.turns.append(StoryCoachTurn(parentText: nil, question: reply?.question))
        self.context = context
        await requestReply(for: context)
    }

    func prepareCues() async -> Bool {
        cancelPendingReply()
        let id = requestID
        isPreparingCues = true
        defer { if requestID == id { isPreparingCues = false } }
        do {
            let cues = try await service.prepareCues(for: context.map(boundedContext))
            guard requestID == id, !Task.isCancelled else { return false }
            guard !cues.isEmpty else { throw CocoaError(.fileReadUnknown) }
            preparedCues = cues
            usingGenericCues = context == nil || context?.initialText.isEmpty == true
            cueLabel = usingGenericCues ? "Generic cues · Demo" : "Prepared cues · Demo"
        } catch {
            guard requestID == id, !Task.isCancelled else { return false }
            preparedCues = Self.genericCues
            usingGenericCues = true
            cueLabel = "Generic cues · Demo preparation unavailable"
        }
        return true
    }

    func keepThought(_ text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, var context else { return }
        context.turns.append(StoryCoachTurn(parentText: trimmed, question: reply?.question))
        self.context = context
    }

    func answer(_ text: String) async {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        keepThought(text)
        guard let context else { return }
        await requestReply(for: context)
    }

    func retry() async {
        guard let context else { return }
        await requestReply(for: context)
    }

    private func requestReply(for context: StoryCoachContext) async {
        cancelPendingReply()
        let id = requestID
        isResponding = true; errorMessage = nil; reply = nil
        defer { if requestID == id { isResponding = false } }
        do {
            let response = try await service.respond(to: boundedContext(context))
            guard requestID == id, !Task.isCancelled else { return }
            reply = response
        } catch is CancellationError { }
        catch {
            guard requestID == id, !Task.isCancelled else { return }
            errorMessage = "Demo coaching could not continue. Your choices are kept. Retry, skip, or start recording."
        }
    }

    private func boundedContext(_ context: StoryCoachContext) -> StoryCoachContext {
        // Keep the complete parent choices in this session; bound only the service request.
        var request = StoryCoachContext(approach: context.approach, initialText: String(context.initialText.prefix(2000)))
        request.turns = context.turns.suffix(12).map { turn in
            StoryCoachTurn(parentText: turn.parentText.map { String($0.prefix(2000)) }, question: turn.question)
        }
        return request
    }

    private func cancelPendingReply() {
        requestID = UUID()
        isResponding = false
    }

    func reset() {
        cancelPendingReply(); isPreparingCues = false
        context = nil; reply = nil; preparedCues = []; usingGenericCues = false; cueLabel = ""
        errorMessage = nil; isResponding = false
    }

    func setStartingPoint(approach: StoryStartingApproach, text: String) {
        reset()
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty { context = StoryCoachContext(approach: approach, initialText: trimmed) }
    }

    func begin(approach: StoryStartingApproach, text: String) async {
        setStartingPoint(approach: approach, text: text)
        guard let context else { return }
        await requestReply(for: context)
    }
}
