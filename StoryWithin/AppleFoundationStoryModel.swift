import Foundation
import FoundationModels

extension StoryCoachProvider {
    static func makeDefault() -> any StoryCoachService {
        if #available(iOS 26, *) {
            return select(model: AppleFoundationStoryModel())
        }
        return DemoStoryCoachService(availabilityMessage: "On-device Apple Intelligence coaching requires iOS 26 or later and a ready, eligible model. You can use demo prompts or record your own story.")
    }
}

@available(iOS 26, *)
@MainActor
struct AppleFoundationStoryModel: OnDeviceStoryModel {
    private let model = SystemLanguageModel.default

    var availability: StoryModelAvailability {
        switch model.availability {
        case .available:
            guard model.supportsLocale(Locale(identifier: "en_US")) else {
                return .unavailable("English coaching is unavailable with this on-device model. Demo prompts are available.")
            }
            return .available
        case .unavailable(let reason):
            switch reason {
            case .deviceNotEligible:
                return .unavailable("This device cannot use the on-device Apple Intelligence model. Demo prompts are available.")
            case .appleIntelligenceNotEnabled:
                return .unavailable("Apple Intelligence is turned off. Demo prompts are available; you can enable Apple Intelligence in Settings on an eligible device.")
            case .modelNotReady:
                return .unavailable("The on-device Apple Intelligence model is not ready. Demo prompts are available while the system prepares the model.")
            @unknown default:
                return .unavailable("The on-device Apple Intelligence model is unavailable. Demo prompts are available.")
            }
        }
    }

    func reply(to request: StoryModelRequest) async throws -> StoryCoachReply {
        do {
            try await checkBudget(request, schema: AppleCoachReply.generationSchema)
            // A fresh session prevents accumulated history from consuming the 4096-token window.
            // SystemLanguageModel is explicitly on-device; no cloud model, tools, or audio.
            let session = LanguageModelSession(model: model, instructions: request.instructions)
            let response = try await session.respond(to: request.prompt, generating: AppleCoachReply.self,
                options: GenerationOptions(temperature: 0.4, maximumResponseTokens: request.maximumResponseTokens))
            try Task.checkCancellation()
            return StoryCoachReply(guidance: response.content.guidance, question: response.content.question)
        } catch { throw mapped(error) }
    }

    func cues(for request: StoryModelRequest) async throws -> [String] {
        do {
            try await checkBudget(request, schema: AppleCoachCues.generationSchema)
            let session = LanguageModelSession(model: model, instructions: request.instructions)
            let response = try await session.respond(to: request.prompt, generating: AppleCoachCues.self,
                options: GenerationOptions(temperature: 0.4, maximumResponseTokens: request.maximumResponseTokens))
            try Task.checkCancellation()
            return response.content.cues
        } catch { throw mapped(error) }
    }

    private func checkBudget(_ request: StoryModelRequest, schema: GenerationSchema) async throws {
        try Task.checkCancellation()
        if case .unavailable(let reason) = availability { throw StoryCoachFailure.unavailable(reason) }
        // Older iOS 26 releases use the conservative UTF-8 request bounds in the service.
        // On 26.4+, count the actual prompt, instructions and guided schema as well,
        // reserving output and 512 tokens for framework formatting/special tokens.
        if #available(iOS 26.4, *) {
            let promptTokens = try await model.tokenCount(for: Prompt(request.prompt))
            let instructionTokens = try await model.tokenCount(for: Instructions(request.instructions))
            let schemaTokens = try await model.tokenCount(for: schema)
            guard promptTokens + instructionTokens + schemaTokens + request.maximumResponseTokens + 512 <= min(4096, model.contextSize) else {
                throw StoryCoachFailure.contextLimit
            }
        }
    }

    private func mapped(_ error: Error) -> Error {
        if error is CancellationError || error is StoryCoachFailure { return error }
        if #available(iOS 27, *), let native = error as? LanguageModelError {
            switch native {
            case .contextSizeExceeded: return StoryCoachFailure.contextLimit
            case .unsupportedLanguageOrLocale: return StoryCoachFailure.unsupportedLanguage
            default: return StoryCoachFailure.generationFailed
            }
        }
        // iOS 26's generation error names remain necessary for the original framework.
        if let native = error as? LanguageModelSession.GenerationError {
            switch native {
            case .exceededContextWindowSize: return StoryCoachFailure.contextLimit
            case .unsupportedLanguageOrLocale: return StoryCoachFailure.unsupportedLanguage
            default: return StoryCoachFailure.generationFailed
            }
        }
        return StoryCoachFailure.generationFailed
    }
}

@available(iOS 26, *)
@Generable
private struct AppleCoachReply {
    @Guide(description: "One short sentence of guidance; no question or story narration.")
    var guidance: String
    @Guide(description: "One short question, or nil when no question is useful.")
    var question: String?
}

@available(iOS 26, *)
@Generable
private struct AppleCoachCues {
    @Guide(description: "Brief suggestions for the parent; no story narration or questions.", .count(3))
    var cues: [String]
}
