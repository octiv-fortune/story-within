import Foundation

/// Read-only publisher content. Never inserted into the personal SwiftData store.
struct DemoStory: Identifiable, Decodable, Equatable {
    let id: String
    let title: String
    let sourceAuthor: String
    let narrator: String
    let provider: String
    let language: String
    let theme: String
    let file: String
    let duration: TimeInterval
    let sourceURL: URL
    let assetURL: URL
    let license: String
    let licenseURL: URL
    let permissionSource: URL
    let changes: String
}

struct DemoLibrary {
    let stories: [DemoStory]
    let audioURLs: [String: URL]
    var errorMessage: String?

    static func bundled(in bundle: Bundle = .main) -> DemoLibrary {
        func resource(_ name: String, extension ext: String) -> URL? {
            bundle.url(forResource: name, withExtension: ext)
                ?? bundle.url(forResource: name, withExtension: ext, subdirectory: "DemoStories")
        }
        do {
            guard let manifest = resource("DemoStories", extension: "json") else { throw CocoaError(.fileNoSuchFile) }
            let stories = try JSONDecoder().decode([DemoStory].self, from: Data(contentsOf: manifest))
            guard Set(stories.map(\.id)).count == stories.count else { throw CocoaError(.fileReadCorruptFile) }
            var audioURLs: [String: URL] = [:]
            for story in stories {
                let name = story.file as NSString
                audioURLs[story.id] = resource(name.deletingPathExtension, extension: name.pathExtension)
            }
            return DemoLibrary(stories: stories, audioURLs: audioURLs)
        } catch {
            return DemoLibrary(stories: [], audioURLs: [:], errorMessage: "The bundled collection could not open. Close Explore and try again. If this continues, check for an app update. Your private stories remain in your personal library.")
        }
    }
}
