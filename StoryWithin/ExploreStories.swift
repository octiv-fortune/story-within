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
                    Text("A small collection of human-narrated demo stories, ready to play offline. Your personal recordings stay in your private library.")
                    if workflow.demoStories.isEmpty {
                        ContentUnavailableView("No demo stories available", systemImage: "books.vertical", description: Text(workflow.demoLibraryError ?? "Close Explore and try again, or record a story of your own from Home."))
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
                .frame(minWidth: 80, minHeight: 44)
        }.buttonStyle(.borderedProminent)
        Button { workflow.playDemo(fromStart: true) } label: {
            Label("Replay", systemImage: "arrow.counterclockwise").frame(minWidth: 80, minHeight: 44)
        }.buttonStyle(.bordered)
    }

    private func creditLink(_ title: String, _ url: URL) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Link(destination: url) { Label(title, systemImage: "arrow.up.right.square").frame(minHeight: 44, alignment: .leading) }
            Text(url.absoluteString).font(.caption).textSelection(.enabled)
        }
    }
}
