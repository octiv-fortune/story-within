import SwiftUI

@main
struct StoryWithinApp: App {
    var body: some Scene {
        WindowGroup { AppRoot() }
    }
}

private struct AppRoot: View {
    @State private var workflow: StoryWorkflow?
    @State private var startupError: String?
    @State private var audio = NativeStoryAudio()

    var body: some View {
        Group {
            if let workflow { ContentView(workflow: workflow) }
            else if let startupError {
                ContentUnavailableView {
                    Label("Your stories couldn't open", systemImage: "externaldrive.badge.exclamationmark")
                } description: {
                    Text("Your existing recordings have not been removed. \(startupError)")
                } actions: { Button("Try again") { openStories() }.buttonStyle(.borderedProminent) }
            } else { ProgressView("Opening your stories…") }
        }.task { if workflow == nil { openStories() } }
    }

    private func openStories() {
        do {
            let base = try FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            let workflow = try StoryWorkflow(storageURL: base.appendingPathComponent("StoryWithin", isDirectory: true), audio: audio, coach: DemoStoryCoachService())
            audio.onInterruption = { [weak workflow] in workflow?.handleInterruption() }
            self.workflow = workflow; startupError = nil
        } catch { startupError = error.localizedDescription }
    }
}
