import Foundation
import Observation
import SwiftData

struct Story: Identifiable, Equatable {
    let id: UUID
    var title: String
    var audioName: String
    var duration: TimeInterval
    var isSaved: Bool
    var visibility: String
    let createdAt: Date
    var updatedAt: Date
    var creatorName = ""
    var theme = ""
    var sourceLanguage = ""
    var transcript = ""
}

@Model
final class StoryRecord {
    @Attribute(.unique) var id: UUID
    var title: String
    var audioName: String
    var duration: TimeInterval
    var isSaved: Bool
    var visibility: String
    var createdAt: Date
    var updatedAt: Date
    // Optional additions allow the first installed store to migrate without a reset.
    var creatorName: String? = nil
    var theme: String? = nil
    var sourceLanguage: String? = nil
    var transcript: String? = nil

    init(_ story: Story) {
        id = story.id; title = story.title; audioName = story.audioName
        duration = story.duration; isSaved = story.isSaved; visibility = story.visibility
        createdAt = story.createdAt; updatedAt = story.updatedAt
        creatorName = story.creatorName; theme = story.theme
        sourceLanguage = story.sourceLanguage; transcript = story.transcript
    }
    var story: Story {
        Story(id: id, title: title, audioName: audioName, duration: duration,
              isSaved: isSaved, visibility: visibility, createdAt: createdAt, updatedAt: updatedAt,
              creatorName: creatorName ?? "", theme: theme ?? "", sourceLanguage: sourceLanguage ?? "", transcript: transcript ?? "")
    }
}

@MainActor
protocol StoryAudio: AnyObject {
    var captureDuration: TimeInterval { get }
    var playbackTime: TimeInterval { get }
    var isPlaying: Bool { get }
    func requestPermission() async -> Bool
    func startRecording(to url: URL) throws
    func pauseRecording() throws
    func resumeRecording() throws
    func finishRecording() throws -> TimeInterval
    func validateRecording(at url: URL) throws
    func play(url: URL, fromStart: Bool) throws
    func pausePlayback()
    func stopPlayback()
}

extension StoryAudio {
    // Deterministic hardware doubles validate their retained bytes at this boundary.
    // The native adapter additionally decodes the actual audio format.
    func validateRecording(at url: URL) throws {
        let values = try url.resourceValues(forKeys: [.isRegularFileKey, .fileSizeKey])
        guard values.isRegularFile == true, (values.fileSize ?? 0) > 0 else { throw StoryFailure.emptyRecording }
    }
}

enum CaptureState: Equatable { case idle, requestingPermission, recording, paused, stopped, failed }
enum ReviewExitChoice { case keepChanges, discardChanges, cancel }

@MainActor
@Observable
final class StoryWorkflow {
    let coaching: StoryCoaching
    private let container: ModelContainer
    private let context: ModelContext
    private let storageURL: URL
    private let audio: StoryAudio
    private let demoLibrary: DemoLibrary
    var demoStories: [DemoStory] { demoLibrary.stories }
    var demoLibraryError: String? { demoLibrary.errorMessage }
    private(set) var selectedDemoStory: DemoStory?
    private(set) var demoPlaybackError: String?
    private let commitChanges: (ModelContext) throws -> Void
    private var captureURL: URL?
    private var captureID: UUID?
    private var finalizedDuration: TimeInterval?
    private var replacementOriginal: Story?
    private var captureRequestID: UUID?
    var isReplacingRecording: Bool { replacementOriginal != nil }
    var captureState: CaptureState = .idle
    private(set) var currentStory: Story?
    private(set) var stories: [Story] = []
    var title = "My new story"
    var creatorName = ""
    var theme = ""
    var sourceLanguage = ""
    var transcript = ""
    var errorMessage: String?
    private(set) var permissionDenied = false
    private(set) var isPlaying = false

    init(storageURL: URL, audio: StoryAudio, coach: (any StoryCoachService)? = nil,
         demoLibrary: DemoLibrary? = nil,
         commitChanges: @escaping (ModelContext) throws -> Void = { try $0.save() }) throws {
        self.coaching = StoryCoaching(service: coach ?? DemoStoryCoachService())
        self.storageURL = storageURL
        self.audio = audio
        self.demoLibrary = demoLibrary ?? .bundled()
        self.commitChanges = commitChanges
        try FileManager.default.createDirectory(at: storageURL, withIntermediateDirectories: true)
        container = try ModelContainer(for: StoryRecord.self, configurations:
            ModelConfiguration(url: storageURL.appendingPathComponent("Stories.sqlite"), cloudKitDatabase: .none))
        context = ModelContext(container)
        context.autosaveEnabled = false
        try refreshStories()
    }

    var currentAudioURL: URL? {
        currentStory.map { audioURL(for: $0) }
    }

    private func audioURL(for story: Story) -> URL {
        // The first installed app stored bare UUID.m4a filenames.
        let relative = story.audioName.hasPrefix("Captures/") ? story.audioName : "Recordings/\(story.audioName)"
        return storageURL.appendingPathComponent(relative)
    }
    var elapsedRecording: TimeInterval { audio.captureDuration }
    var playbackTime: TimeInterval { audio.playbackTime }
    var hasPendingRecording: Bool { captureID != nil }
    var canLeaveReview: Bool { !hasPendingRecording && captureState != .recording && captureState != .paused && captureState != .requestingPermission }
    var hasUnsavedReviewChanges: Bool {
        guard let story = currentStory else { return false }
        return title != story.title || creatorName != story.creatorName || theme != story.theme
            || sourceLanguage != story.sourceLanguage || transcript != story.transcript
    }

    /// Discarding review edits never discards a retained story or its narration.
    func resolveReviewExit(_ choice: ReviewExitChoice) -> Bool {
        switch choice {
        case .cancel: return false
        case .keepChanges:
            keepDraft()
            return currentStory != nil && canLeaveReview && errorMessage == nil
        case .discardChanges:
            guard currentStory != nil, canLeaveReview else { return false }
            title = currentStory?.title ?? "My new story"
            loadReviewFields()
            errorMessage = nil
            return true
        }
    }

    func startReplacementRecording(confirmed: Bool) async {
        guard confirmed, currentStory != nil, !hasPendingRecording, canLeaveReview else { return }
        replacementOriginal = currentStory
        await startRecording()
    }

    func cancelReplacementRecording() {
        guard replacementOriginal != nil else { return }
        if captureState == .recording || captureState == .paused { _ = try? audio.finishRecording() }
        stopPlayback()
        do {
            if let url = captureURL {
                let name = url.deletingPathExtension().lastPathComponent
                for relative in ["Captures/\(name).m4a", "Recordings/\(name).m4a", "Recordings/\(name).pending"] {
                    let candidate = storageURL.appendingPathComponent(relative)
                    if FileManager.default.fileExists(atPath: candidate.path) { try FileManager.default.removeItem(at: candidate) }
                }
            }
            currentStory = replacementOriginal
            replacementOriginal = nil
            clearPendingCapture()
            captureState = .stopped; errorMessage = nil
        } catch { captureState = .failed; errorMessage = "Your original story is unchanged, but the replacement could not be removed. Retry cancelling. \(error.localizedDescription)" }
    }

    func startRecording() async {
        guard captureState != .recording, captureState != .requestingPermission, !hasPendingRecording else { return }
        errorMessage = nil; permissionDenied = false
        stopPlayback(); selectedDemoStory = nil; demoPlaybackError = nil
        captureState = .requestingPermission
        let requestID = UUID()
        captureRequestID = requestID
        let granted = await audio.requestPermission()
        guard captureRequestID == requestID, captureState == .requestingPermission else { return }
        captureRequestID = nil
        guard granted else {
            replacementOriginal = nil
            permissionDenied = true
            captureState = .idle
            errorMessage = "Microphone access is off. Allow it in Settings to record your story."
            return
        }
        do {
            let folder = storageURL.appendingPathComponent("Captures")
            try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
            let id = UUID()
            let assetName = replacementOriginal.map { "\($0.id.uuidString)--\(id.uuidString)" } ?? id.uuidString
            let url = folder.appendingPathComponent("\(assetName).m4a")
            try audio.startRecording(to: url)
            captureID = id; captureURL = url; finalizedDuration = nil
            if replacementOriginal == nil {
                currentStory = nil; title = "My new story"
                loadReviewFields()
            }
            captureState = .recording
        } catch { replacementOriginal = nil; captureState = .failed; errorMessage = "Recording could not start. \(error.localizedDescription)" }
    }

    func pauseRecording() {
        guard captureState == .recording else { return }
        do {
            try audio.pauseRecording()
            captureState = .paused; errorMessage = nil
        } catch {
            // If pausing cannot be confirmed, finalize rather than imply the mic is off.
            stopRecording()
            if let recoveryError = errorMessage {
                errorMessage = "Recording could not pause. \(recoveryError)"
            } else {
                errorMessage = "Recording stopped because it could not pause. Your captured audio is kept for review. \(error.localizedDescription)"
            }
        }
    }

    func resumeRecording() {
        guard captureState == .paused else { return }
        do {
            try audio.resumeRecording()
            captureState = .recording; errorMessage = nil
        } catch {
            errorMessage = "Recording is still paused. Resume again or stop to keep your take. \(error.localizedDescription)"
        }
    }

    func stopRecording() {
        guard captureState == .recording || captureState == .paused else { return }
        do {
            finalizedDuration = try audio.finishRecording()
            captureState = .stopped
            retainDraft()
        } catch { captureState = .failed; errorMessage = "Recording could not finish. \(error.localizedDescription)" }
    }

    func retryKeepingRecording() {
        guard captureState != .recording, captureState != .paused, captureState != .requestingPermission else { return }
        if replacementOriginal == nil, let story = currentStory, !story.audioName.hasPrefix("Captures/") {
            do {
                // Never discard the recovery source until the promoted asset can be read.
                try audio.validateRecording(at: audioURL(for: story))
                try removeRedundantAudio(for: story)
                clearPendingCapture()
                errorMessage = nil
            } catch { errorMessage = "Your story details and recovery audio are kept, but the retained recording could not be verified or extra audio cleanup could not finish. Restore the recording and retry keeping, or explicitly discard it. \(error.localizedDescription)" }
            return
        }
        if finalizedDuration == nil {
            do {
                finalizedDuration = try audio.finishRecording()
                captureState = .stopped
            }
            catch { errorMessage = "This take could not be finalized. Retry or explicitly discard it. \(error.localizedDescription)"; return }
        }
        retainDraft()
    }

    @discardableResult
    func prepareCoachedRecording(approach: StoryStartingApproach? = nil, text: String = "", thought: String = "") async -> Bool {
        guard !hasPendingRecording, captureState != .requestingPermission else { return false }
        if coaching.context == nil, let approach { coaching.setStartingPoint(approach: approach, text: text) }
        coaching.keepThought(thought)
        guard await coaching.prepareCues() else { return false }
        prepareNewRecording()
        return true
    }

    func prepareNewRecording() {
        guard !hasPendingRecording else { return }
        stopPlayback()
        selectedDemoStory = nil; demoPlaybackError = nil
        currentStory = nil; title = "My new story"; errorMessage = nil; permissionDenied = false
        loadReviewFields()
        captureState = .idle
    }

    func handleInterruption() {
        if captureState == .requestingPermission {
            captureRequestID = nil; replacementOriginal = nil; captureState = .idle
            errorMessage = "Recording did not start because audio was interrupted or the app left the screen. Tap Record when you are ready. The microphone will not start automatically."
        }
        if captureState == .recording || captureState == .paused {
            stopRecording()
            if errorMessage == nil, currentStory != nil {
                errorMessage = "Recording stopped because audio was interrupted or the app left the screen. Your captured audio is kept on this device. The microphone will not restart automatically."
            }
        }
        stopPlayback()
    }

    func deleteCurrentStory(confirmed: Bool) {
        guard confirmed, currentStory != nil else { return }
        discardRecording()
    }

    func discardRecording() {
        if isReplacingRecording { cancelReplacementRecording(); return }
        audio.stopPlayback(); isPlaying = false
        if captureState == .recording || captureState == .paused { _ = try? audio.finishRecording(); captureState = .stopped }
        var staged: [(original: URL, holding: URL)] = []
        let files = FileManager.default
        do {
            var owned = Set<URL>()
            if let id = currentStory?.id ?? captureID { owned.formUnion(ownedAudioURLs(id: id)) }
            if let url = captureURL { owned.insert(url) }
            // A story owns only its generated UUID assets. Other references (for
            // example, demo audio) and files still used by another story survive.
            owned = owned.filter { url in
                !stories.contains { $0.id != currentStory?.id && audioURL(for: $0) == url }
            }
            let trash = storageURL.appendingPathComponent("Discarding")
            try files.createDirectory(at: trash, withIntermediateDirectories: true)
            // Stage owned files before committing metadata removal. A filesystem failure
            // leaves the draft intact; a metadata failure restores its original files.
            for original in owned {
                let holding = trash.appendingPathComponent("\(original.deletingLastPathComponent().lastPathComponent)-\(original.lastPathComponent)")
                if files.fileExists(atPath: original.path) { try files.moveItem(at: original, to: holding) }
                if files.fileExists(atPath: holding.path) { staged.append((original, holding)) }
            }
            if let story = currentStory {
                let records = try context.fetch(FetchDescriptor<StoryRecord>())
                if let record = records.first(where: { $0.id == story.id }) { context.delete(record) }
            }
            try commitChanges(context)
        } catch {
            context.rollback()
            var restorationFailed = false
            for file in staged where !files.fileExists(atPath: file.original.path) {
                do { try files.moveItem(at: file.holding, to: file.original) }
                catch { restorationFailed = true }
            }
            errorMessage = restorationFailed
                ? "Discard failed. Your audio is retained in local recovery storage. Keep this screen open and retry."
                : "This recording could not be discarded. It has been kept. \(error.localizedDescription)"
            return
        }
        do {
            try refreshStories()
            for file in staged { try files.removeItem(at: file.holding) }
            currentStory = nil; captureURL = nil; captureID = nil; finalizedDuration = nil
            captureState = .idle; errorMessage = nil
        } catch {
            errorMessage = "The story was removed from Home, but its local audio cleanup could not finish. Retry discarding. \(error.localizedDescription)"
        }
    }

    private func retainDraft() {
        if let original = replacementOriginal { retainReplacement(of: original); return }
        guard let url = captureURL, let id = captureID, let duration = finalizedDuration else { return }
        do {
            guard duration > 0, (try url.resourceValues(forKeys: [.fileSizeKey]).fileSize ?? 0) > 0 else {
                throw StoryFailure.emptyRecording
            }
            let now = Date()
            var draft = currentStory ?? Story(id: id, title: title, audioName: "Captures/\(id.uuidString).m4a", duration: duration,
                                             isSaved: false, visibility: "private", createdAt: now, updatedAt: now)
            // Register the already durable original before creating staging/final
            // copies, so a failed promotion remains discoverable after relaunch.
            try persist(draft)
            currentStory = draft
            let recordings = storageURL.appendingPathComponent("Recordings")
            try FileManager.default.createDirectory(at: recordings, withIntermediateDirectories: true)
            let audioName = "\(id.uuidString).m4a"
            let destination = recordings.appendingPathComponent(audioName)
            let staged = recordings.appendingPathComponent("\(id.uuidString).pending")
            // A failed copy may leave bytes behind. Only promote a fully copied take,
            // and overwrite any partial destination on retry from the retained capture.
            if FileManager.default.fileExists(atPath: staged.path) { try FileManager.default.removeItem(at: staged) }
            try FileManager.default.copyItem(at: url, to: staged)
            if FileManager.default.fileExists(atPath: destination.path) {
                _ = try FileManager.default.replaceItemAt(destination, withItemAt: staged)
            } else { try FileManager.default.moveItem(at: staged, to: destination) }
            draft.audioName = audioName
            try persist(draft)
            currentStory = draft
            try removeRedundantAudio(for: draft)
            clearPendingCapture()
            errorMessage = nil
        } catch {
            errorMessage = currentStory == nil
                ? "Your take has not been saved as a draft. Keep this screen open and retry. \(error.localizedDescription)"
                : "Your private draft is kept, but audio promotion or cleanup could not finish. Retry keeping or explicitly discard it. \(error.localizedDescription)"
        }
    }

    private func retainReplacement(of original: Story) {
        guard let url = captureURL, let duration = finalizedDuration else { return }
        do {
            guard duration > 0, (try url.resourceValues(forKeys: [.fileSizeKey]).fileSize ?? 0) > 0 else { throw StoryFailure.emptyRecording }
            let files = FileManager.default
            let recordings = storageURL.appendingPathComponent("Recordings")
            try files.createDirectory(at: recordings, withIntermediateDirectories: true)
            let name = url.deletingPathExtension().lastPathComponent
            let destination = recordings.appendingPathComponent("\(name).m4a")
            let staged = recordings.appendingPathComponent("\(name).pending")
            if files.fileExists(atPath: staged.path) { try files.removeItem(at: staged) }
            try files.copyItem(at: url, to: staged)
            if files.fileExists(atPath: destination.path) { try files.removeItem(at: destination) }
            try files.moveItem(at: staged, to: destination)
            try audio.validateRecording(at: destination)
            var replacement = original
            replacement.audioName = destination.lastPathComponent
            replacement.duration = duration; replacement.visibility = "private"; replacement.updatedAt = Date()
            // Keep the same story and authored metadata. Only the voice asset changes.
            try persist(replacement)
            currentStory = replacement
            replacementOriginal = nil
            try removeRedundantAudio(for: replacement)
            clearPendingCapture(); errorMessage = nil
        } catch {
            errorMessage = replacementOriginal != nil
                ? "The replacement has not been kept. Your original story is unchanged. Retry keeping this take or cancel the replacement. \(error.localizedDescription)"
                : "Your replacement is kept privately, but extra audio cleanup could not finish. Retry keeping. \(error.localizedDescription)"
        }
    }

    private func ownedAudioURLs(id: UUID) -> [URL] {
        var owned = [storageURL.appendingPathComponent("Captures/\(id.uuidString).m4a"),
                     storageURL.appendingPathComponent("Recordings/\(id.uuidString).m4a"),
                     storageURL.appendingPathComponent("Recordings/\(id.uuidString).pending")]
        // Replacement assets carry the stable story ID as well as a take ID, so
        // all copies remain owned after relaunch without a schema migration.
        for folder in ["Captures", "Recordings"] {
            let directory = storageURL.appendingPathComponent(folder)
            for url in (try? FileManager.default.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil)) ?? [] {
                let parts = url.deletingPathExtension().lastPathComponent.components(separatedBy: "--")
                if parts.count == 2, parts[0] == id.uuidString, UUID(uuidString: parts[1]) != nil,
                   ["m4a", "pending"].contains(url.pathExtension) { owned.append(url) }
            }
        }
        return owned
    }

    private func removeRedundantAudio(for story: Story) throws {
        let retained = currentAudioURL
        for url in ownedAudioURLs(id: story.id) where url != retained
            && !stories.contains(where: { $0.id != story.id && audioURL(for: $0) == url })
            && FileManager.default.fileExists(atPath: url.path) {
            try FileManager.default.removeItem(at: url)
        }
    }

    private func clearPendingCapture() {
        captureURL = nil; captureID = nil; finalizedDuration = nil
    }

    func keepDraft() { saveCurrent(markSaved: false) }
    func savePrivately() { saveCurrent(markSaved: true) }

    private func saveCurrent(markSaved: Bool) {
        if hasPendingRecording { retryKeepingRecording(); guard !hasPendingRecording else { return } }
        guard var story = currentStory else { return }
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { errorMessage = "Give your story a title before saving."; return }
        do {
            guard let url = currentAudioURL, FileManager.default.fileExists(atPath: url.path) else { throw StoryFailure.missingAudio }
            try audio.validateRecording(at: url)
            story.title = trimmed; story.isSaved = story.isSaved || markSaved; story.updatedAt = Date()
            story.creatorName = creatorName; story.theme = theme
            story.sourceLanguage = sourceLanguage; story.transcript = transcript
            try persist(story)
            currentStory = story; title = trimmed; errorMessage = nil
        } catch { errorMessage = "Your changes could not be saved. Your recording is kept; retry saving. \(error.localizedDescription)" }
    }

    func openStory(id: UUID) {
        selectedDemoStory = nil; demoPlaybackError = nil
        coaching.reset()
        audio.stopPlayback(); isPlaying = false
        currentStory = stories.first { $0.id == id }
        title = currentStory?.title ?? "My new story"
        loadReviewFields()
        captureState = .stopped; errorMessage = nil
        clearPendingCapture()
        if let story = currentStory {
            let source = ownedAudioURLs(id: story.id)[0]
            let needsPromotion = story.audioName.hasPrefix("Captures/")
            let redundantCopyExists = ownedAudioURLs(id: story.id).contains {
                $0 != currentAudioURL && FileManager.default.fileExists(atPath: $0.path)
            }
            do { try audio.validateRecording(at: audioURL(for: story)) }
            catch { errorMessage = "This recording is unavailable or could not be read. Your story details and text are kept. Restore the recording and retry, or record a confirmed replacement. \(error.localizedDescription)" }
            if needsPromotion || redundantCopyExists {
                captureID = story.id
                captureURL = FileManager.default.fileExists(atPath: source.path) ? source : nil
                finalizedDuration = story.duration
                if errorMessage == nil { errorMessage = "Your private draft is kept. Retry keeping to finish audio promotion or cleanup, or explicitly discard it." }
            }
        }
    }

    func openDemoStory(id: String) {
        guard captureState != .recording, captureState != .paused, captureState != .requestingPermission else { return }
        stopPlayback()
        selectedDemoStory = demoStories.first { $0.id == id }
        demoPlaybackError = nil
    }

    func playDemo(fromStart: Bool = false) {
        guard let story = selectedDemoStory,
              captureState != .recording, captureState != .paused, captureState != .requestingPermission else { return }
        guard let url = demoLibrary.audioURLs[story.id], FileManager.default.fileExists(atPath: url.path) else {
            stopPlayback()
            demoPlaybackError = "This demo recording is missing from the app. Choose another story or check for an app update. Your private recordings are unchanged."
            return
        }
        do {
            try audio.play(url: url, fromStart: fromStart)
            isPlaying = audio.isPlaying; demoPlaybackError = nil
        } catch {
            stopPlayback()
            demoPlaybackError = "This demo recording could not play. Try Play again or choose another story. \(error.localizedDescription)"
        }
    }

    func play(fromStart: Bool = false) {
        if selectedDemoStory != nil { stopPlayback(); selectedDemoStory = nil; demoPlaybackError = nil }
        guard let url = currentAudioURL else { return }
        do { try audio.play(url: url, fromStart: fromStart); isPlaying = audio.isPlaying; errorMessage = nil }
        catch { errorMessage = "This recording could not play. \(error.localizedDescription)"; isPlaying = false }
    }
    func pausePlayback() { audio.pausePlayback(); isPlaying = false }
    func refreshPlayback() { isPlaying = audio.isPlaying }
    func stopPlayback() { audio.stopPlayback(); isPlaying = false }

    private func persist(_ story: Story) throws {
        do {
            let records = try context.fetch(FetchDescriptor<StoryRecord>())
            if let record = records.first(where: { $0.id == story.id }) {
                record.title = story.title; record.audioName = story.audioName
                record.duration = story.duration; record.visibility = story.visibility
                record.isSaved = story.isSaved; record.updatedAt = story.updatedAt
                record.creatorName = story.creatorName; record.theme = story.theme
                record.sourceLanguage = story.sourceLanguage; record.transcript = story.transcript
            } else { context.insert(StoryRecord(story)) }
            try commitChanges(context)
            try refreshStories()
        } catch { context.rollback(); throw error }
    }
    private func refreshStories() throws {
        stories = try context.fetch(FetchDescriptor<StoryRecord>(sortBy: [SortDescriptor(\.updatedAt, order: .reverse)])).map(\.story)
    }

    private func loadReviewFields() {
        creatorName = currentStory?.creatorName ?? ""
        theme = currentStory?.theme ?? ""
        sourceLanguage = currentStory?.sourceLanguage ?? ""
        transcript = currentStory?.transcript ?? ""
    }
}

private enum StoryFailure: LocalizedError {
    case emptyRecording, missingAudio
    var errorDescription: String? {
        switch self {
        case .emptyRecording: "No audio was captured. Record a new take before saving."
        case .missingAudio: "The audio file is unavailable."
        }
    }
}
