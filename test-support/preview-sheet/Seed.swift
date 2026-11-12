import Foundation
import SwiftData
import AVFoundation

@main struct Seed {
    @MainActor static func main() throws {
        let args = CommandLine.arguments
        guard args.count == 3 else { fatalError("Usage: seed APP_DATA BUNDLED_MP3") }
        let root = URL(fileURLWithPath: args[1]).appendingPathComponent("Library/Application Support/StoryWithin")
        let audioSource = URL(fileURLWithPath: args[2])
        try FileManager.default.createDirectory(at: root.appendingPathComponent("Recordings"), withIntermediateDirectories: true)
        let container = try ModelContainer(for: StoryRecord.self, configurations: ModelConfiguration(url: root.appendingPathComponent("Stories.sqlite"), cloudKitDatabase: .none))
        let context = ModelContext(container)
        context.autosaveEnabled = false
        let before = try context.fetch(FetchDescriptor<StoryRecord>())
        let id = UUID(uuidString: "F14D6472-95F5-4D34-BE66-616371821008")!
        if before.contains(where: { $0.id == id }) {
            print("Fixture already present; preserved all \(before.count) stories")
            return
        }
        let name = "\(id.uuidString).mp3"
        let target = root.appendingPathComponent("Recordings/\(name)")
        guard !FileManager.default.fileExists(atPath: target.path) else { fatalError("Fixture audio exists without metadata; inspect manually") }
        try FileManager.default.copyItem(at: audioSource, to: target)
        let duration = try AVAudioPlayer(contentsOf: target).duration
        guard duration > 0 else { fatalError("Fixture audio invalid") }
        let now = Date()
        let story = Story(id: id, title: "Preview Regression — Goat", audioName: name, duration: duration, isSaved: true, visibility: "private", createdAt: now, updatedAt: now, creatorName: "Simulator Fixture", theme: "Courage", sourceLanguage: "English", transcript: "Disposable simulator fixture using the bundled licensed Goat story recording. No personal recording or private text.")
        context.insert(StoryRecord(story))
        try context.save()
        let after = try context.fetch(FetchDescriptor<StoryRecord>())
        guard after.count == before.count + 1, before.allSatisfy({ existing in after.contains(where: { $0.id == existing.id }) }) else { fatalError("Existing story preservation check failed") }
        print("Inserted \(story.title); playable duration=\(duration); stories before=\(before.count), after=\(after.count); existing identities preserved")
    }
}
