import SwiftUI
import UIKit

struct ExploreStories: View {
    @Bindable var workflow: StoryWorkflow
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Stories to listen to.").font(.largeTitle.bold())
                    Text("Human-narrated demos and stories you explicitly chose to preview on this device. Private stories stay in your personal library.")
                    Text("Your previews on this device").font(.title2.bold()).accessibilityAddTraits(.isHeader)
                    if workflow.communityStories.isEmpty {
                        Text("No local previews yet. Save a story privately, then review and confirm its local preview from your personal library.")
                    }
                    ForEach(workflow.communityStories) { story in
                        NavigationLink {
                            LocalCommunityStoryDetail(workflow: workflow, story: story)
                        } label: {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("LOCAL PREVIEW · This device only").font(.caption.weight(.semibold))
                                Text(story.title).font(.title2.bold())
                                Text(story.creatorName.isEmpty ? "No creator display name provided" : "Creator: \(story.creatorName)")
                                if !story.sourceLanguage.isEmpty { Text(story.sourceLanguage) }
                                if !story.theme.isEmpty { Text(story.theme) }
                                Label("Listen and read", systemImage: "chevron.right")
                            }.padding(20).frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
                                .background(.white.opacity(0.8), in: RoundedRectangle(cornerRadius: 18))
                                .foregroundStyle(StoryPalette.ink)
                        }.buttonStyle(.plain)
                    }
                    Text("Bundled demos").font(.title2.bold()).accessibilityAddTraits(.isHeader)
                    if workflow.demoStories.isEmpty {
                        ContentUnavailableView("No demo stories available", systemImage: "books.vertical", description: Text(workflow.demoLibraryError ?? "Return Home to record a story of your own, or check for an app update."))
                    } else {
                        ForEach(workflow.demoStories) { story in
                            NavigationLink {
                                DemoStoryDetail(workflow: workflow, story: story)
                            } label: {
                                VStack(alignment: .leading, spacing: 10) {
                                    Text("DEMO · \(timeLabel(story.duration))").font(.caption.weight(.semibold))
                                    Text(story.title).font(.title2.bold())
                                    Text("Source: \(story.sourceAuthor)").font(.subheadline)
                                    Text("Narrated by \(story.narrator)").font(.subheadline)
                                    Text("\(story.language) · \(story.theme)").font(.subheadline)
                                    Label("Listen and view credits", systemImage: "chevron.right").font(.body.weight(.semibold))
                                }.frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
                                    .padding(20).background(.white.opacity(0.8), in: RoundedRectangle(cornerRadius: 18))
                                    .foregroundStyle(StoryPalette.ink)
                            }.buttonStyle(.plain)
                        }
                    }
                }.padding(24).frame(maxWidth: 640).frame(maxWidth: .infinity)
            }.background(StoryPalette.ivory).foregroundStyle(StoryPalette.ink)
                .navigationTitle("Explore Stories")
                .toolbar { ToolbarItem(placement: .confirmationAction) { Button("Done") { workflow.stopPlayback(); dismiss() }.frame(minHeight: 44) } }
        }.tint(StoryPalette.forest)
            .onDisappear { workflow.stopPlayback() }
    }
}

private struct DemoStoryDetail: View {
    @Bindable var workflow: StoryWorkflow
    let story: DemoStory
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Label("Bundled demo · Human narration", systemImage: "books.vertical").font(.subheadline)
                Text(story.title).font(.largeTitle.bold()).fixedSize(horizontal: false, vertical: true)
                VStack(alignment: .leading, spacing: 8) {
                    Text("Source: \(story.sourceAuthor)")
                    Text("Narrator: \(story.narrator)")
                    Text("Language: \(story.language)")
                    Text("Theme: \(story.theme)")
                    Text("Theme selected by Story Within.").font(.caption)
                }
                VStack(alignment: .leading, spacing: 16) {
                    Text("Original English recording").font(.headline)
                    TimelineView(.periodic(from: .now, by: 0.5)) { _ in
                        Text("\(timeLabel(workflow.playbackTime)) / \(timeLabel(story.duration))")
                            .font(.title2.monospacedDigit())
                            .accessibilityLabel("Playback time \(timeLabel(workflow.playbackTime)) of \(timeLabel(story.duration))")
                    }
                    Text(workflow.isPlaying ? "Playing" : workflow.playbackTime > 0 ? "Paused" : "Ready to play").font(.subheadline)
                    ViewThatFits(in: .horizontal) {
                        HStack(spacing: 16) { playbackButtons }
                        VStack(alignment: .leading, spacing: 12) { playbackButtons }
                    }
                    if let error = workflow.demoPlaybackError {
                        Label(error, systemImage: "exclamationmark.triangle")
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }.padding(20).frame(maxWidth: .infinity, alignment: .leading)
                    .background(.white.opacity(0.8), in: RoundedRectangle(cornerRadius: 20))
                VStack(alignment: .leading, spacing: 12) {
                    Text("Source and license").font(.title2.bold()).accessibilityAddTraits(.isHeader)
                    Text(story.provider)
                    Text("Recorded at UBC Studios. Mixed and processed by Craig Carpenter. Story content from African Storybook.")
                    Text("Recording licensed under Creative Commons Attribution 3.0 (CC BY 3.0).")
                    Text(story.changes)
                    creditLink("Story and recording source", story.sourceURL)
                    creditLink("CC BY 3.0 license", story.licenseURL)
                    creditLink("Publisher audio permissions", story.permissionSource)
                    Text("Credits are available offline. Opening a source or license website needs a connection.").font(.footnote)
                }
            }.padding(24).frame(maxWidth: 640).frame(maxWidth: .infinity)
        }.background(StoryPalette.ivory).foregroundStyle(StoryPalette.ink)
            .navigationTitle("Demo story").navigationBarTitleDisplayMode(.inline)
            .onAppear { workflow.openDemoStory(id: story.id) }
            .onDisappear { workflow.stopPlayback() }
            .onChange(of: scenePhase) { _, phase in if phase == .background { workflow.stopPlayback() } }
            .onChange(of: workflow.demoPlaybackError) { _, error in
                if let error { UIAccessibility.post(notification: .announcement, argument: error) }
            }
            .task {
                while !Task.isCancelled {
                    workflow.refreshPlayback()
                    try? await Task.sleep(for: .milliseconds(400))
                }
            }
    }

    @ViewBuilder private var playbackButtons: some View {
        Button {
            if workflow.isPlaying { workflow.pausePlayback() } else { workflow.playDemo() }
        } label: {
            Label(workflow.isPlaying ? "Pause" : "Play", systemImage: workflow.isPlaying ? "pause.fill" : "play.fill")
                .foregroundStyle(.white)
                .frame(minWidth: 80, minHeight: 44)
        }.buttonStyle(.borderedProminent).tint(StoryPalette.forest)
        Button { workflow.playDemo(fromStart: true) } label: {
            Label("Replay", systemImage: "arrow.counterclockwise").foregroundStyle(StoryPalette.forest).frame(minWidth: 80, minHeight: 44)
        }.buttonStyle(.bordered)
    }

    private func creditLink(_ title: String, _ url: URL) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Link(destination: url) { Label(title, systemImage: "arrow.up.right.square").frame(minHeight: 44, alignment: .leading) }
            Text(url.absoluteString).font(.caption).textSelection(.enabled)
        }
    }
}

/// The same read-only content is shown before consent and after local discovery.
private struct LocalCommunityStoryContent: View {
    @Bindable var workflow: StoryWorkflow
    let story: Story

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Label("Community preview · This device only", systemImage: "iphone").font(.subheadline)
            Text(story.title).font(.largeTitle.bold()).fixedSize(horizontal: false, vertical: true)
            Text(story.creatorName.isEmpty ? "Creator: No display name provided" : "Creator: \(story.creatorName)")
            Text(story.sourceLanguage.isEmpty ? "Original language: Not provided" : "Original language: \(story.sourceLanguage)")
            Text(story.theme.isEmpty ? "Theme: Not provided" : "Theme: \(story.theme)")
            VStack(alignment: .leading, spacing: 12) {
                Text("Original voice recording").font(.headline)
                Text("Your actual narration is included. Playback always uses this original recording, never a translated or generated voice.").font(.footnote)
                TimelineView(.periodic(from: .now, by: 0.5)) { _ in
                    Text("\(timeLabel(workflow.playbackTime)) / \(timeLabel(story.duration))").monospacedDigit()
                        .accessibilityLabel("Playback time \(timeLabel(workflow.playbackTime)) of \(timeLabel(story.duration))")
                }
                ViewThatFits(in: .horizontal) {
                    HStack(spacing: 16) { playbackButtons }
                    VStack(alignment: .leading, spacing: 12) { playbackButtons }
                }
            }.padding(20).frame(maxWidth: .infinity, alignment: .leading)
                .background(.white, in: RoundedRectangle(cornerRadius: 20))
            Text("Transcript").font(.title2.bold()).accessibilityAddTraits(.isHeader)
            Text(story.transcript.isEmpty ? "No transcript included." : story.transcript).textSelection(.enabled)
            Text("Translations").font(.title2.bold()).accessibilityAddTraits(.isHeader)
            Text("No translations are available for this story. No translated text is included.")
        }.task {
            while !Task.isCancelled {
                workflow.refreshPlayback()
                try? await Task.sleep(for: .milliseconds(400))
            }
        }
    }

    @ViewBuilder private var playbackButtons: some View {
        Button {
            if workflow.isPlaying { workflow.pausePlayback() } else { workflow.play() }
        } label: {
            Label(workflow.isPlaying ? "Pause" : "Play", systemImage: workflow.isPlaying ? "pause.fill" : "play.fill")
                .foregroundStyle(.white).frame(minWidth: 80, minHeight: 44)
        }.buttonStyle(.borderedProminent).tint(StoryPalette.forest)
        Button { workflow.play(fromStart: true) } label: {
            Label("Replay", systemImage: "arrow.counterclockwise").foregroundStyle(StoryPalette.forest)
                .frame(minWidth: 80, minHeight: 44)
        }.buttonStyle(.bordered)
    }
}

struct CommunityPreviewReview: View {
    @Bindable var workflow: StoryWorkflow
    let story: Story
    @Environment(\.dismiss) private var dismiss
    @State private var confirming = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Text("Review what will be visible").font(.title2.bold())
                    Text("This preview appears only in Explore Stories on this device. Nothing is uploaded or published to other families. Listen and check the text for personal details before confirming.")
                    LocalCommunityStoryContent(workflow: workflow, story: story)
                    Text("Child preferences and coaching conversations are excluded. Personal details you narrated or entered in the text above remain part of this story.").font(.footnote)
                    if let error = workflow.errorMessage { Label(error, systemImage: "exclamationmark.triangle") }
                    Button { confirming = true } label: {
                        Text("Continue to confirmation").frame(maxWidth: .infinity, minHeight: 36)
                    }.buttonStyle(StoryPrimaryButton())
                }.padding(24).frame(maxWidth: 640).frame(maxWidth: .infinity)
            }.background(StoryPalette.ivory).foregroundStyle(StoryPalette.ink)
                .navigationTitle("Review local preview").navigationBarTitleDisplayMode(.inline)
                .toolbar { ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() }.frame(minHeight: 44) } }
                .confirmationDialog("Include your original voice recording?", isPresented: $confirming, titleVisibility: .visible) {
                    Button("Confirm preview on this device") {
                        workflow.confirmCommunityPreview(confirmed: true)
                        if workflow.errorMessage == nil && workflow.communityPreview == nil { dismiss() }
                    }
                    Button("Keep reviewing", role: .cancel) { }
                } message: {
                    Text("Your original voice recording, title, creator attribution and the text shown in this review will appear in this device's community preview. Nothing is uploaded. You can withdraw the preview and keep your personal copy.")
                }
        }.tint(StoryPalette.forest)
            .interactiveDismissDisabled()
            .onDisappear { workflow.confirmCommunityPreview(confirmed: false); workflow.stopPlayback() }
    }
}

private struct LocalCommunityStoryDetail: View {
    @Bindable var workflow: StoryWorkflow
    let story: Story
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                LocalCommunityStoryContent(workflow: workflow, story: story)
                if let error = workflow.errorMessage { Label(error, systemImage: "exclamationmark.triangle") }
                Text("This is your local preview. Manage or withdraw it from your personal library. Nothing is uploaded or published to other devices.").font(.footnote)
            }.padding(24).frame(maxWidth: 640).frame(maxWidth: .infinity)
        }.background(StoryPalette.ivory).foregroundStyle(StoryPalette.ink)
            .navigationTitle("Local preview").navigationBarTitleDisplayMode(.inline)
            .onAppear { workflow.openStory(id: story.id) }
            .onDisappear { workflow.stopPlayback() }
            .onChange(of: scenePhase) { _, phase in if phase == .background { workflow.stopPlayback() } }
    }
}
