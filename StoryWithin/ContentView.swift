import SwiftUI
import UIKit

private enum StoryPalette {
    static let forest = Color(red: 24/255, green: 62/255, blue: 52/255)
    static let ivory = Color(red: 248/255, green: 244/255, blue: 234/255)
    static let terracotta = Color(red: 196/255, green: 122/255, blue: 86/255)
    static let ink = Color(red: 36/255, green: 59/255, blue: 49/255)
}

struct ContentView: View {
    @Bindable var workflow: StoryWorkflow
    @State private var showingStudio = false
    @State private var showingExplore = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    VStack(alignment: .leading, spacing: 12) {
                        Image(systemName: "book.closed")
                            .font(.largeTitle).foregroundStyle(StoryPalette.forest)
                            .accessibilityHidden(true)
                        Text("Every voice holds a story.")
                            .font(.largeTitle.bold()).fixedSize(horizontal: false, vertical: true)
                        Text("Make room for your imagination. Tell a story in your own voice, and keep it close.")
                            .font(.body)
                    }
                    VStack(spacing: 12) {
                        Button { workflow.prepareNewRecording(); showingStudio = true } label: {
                            Label("Create a Story", systemImage: "mic.fill").frame(maxWidth: .infinity, minHeight: 36)
                        }.buttonStyle(StoryPrimaryButton())
                        Button { showingExplore = true } label: {
                            Label("Explore Stories", systemImage: "books.vertical").frame(maxWidth: .infinity, minHeight: 36)
                        }.buttonStyle(.bordered).tint(StoryPalette.forest)
                    }
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Your recent stories").font(.title2.bold()).accessibilityAddTraits(.isHeader)
                        if workflow.stories.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("A beginning is waiting.").font(.headline)
                                Text("Your private drafts and saved stories will appear here. You can record without an account or internet connection.")
                            }.padding(20).frame(maxWidth: .infinity, alignment: .leading)
                                .background(.white.opacity(0.7), in: RoundedRectangle(cornerRadius: 18))
                        } else {
                            ForEach(workflow.stories) { story in
                                Button {
                                    workflow.openStory(id: story.id); showingStudio = true
                                } label: {
                                    HStack(alignment: .top, spacing: 12) {
                                        Image(systemName: "waveform").font(.title2).accessibilityHidden(true)
                                        VStack(alignment: .leading, spacing: 6) {
                                            Text(story.title).font(.headline)
                                            Text("\(story.isSaved ? "Saved" : "Draft") · Private · \(timeLabel(story.duration))").font(.subheadline)
                                            Text(story.updatedAt, style: .date).font(.caption)
                                        }
                                        Spacer(minLength: 0)
                                        Image(systemName: "chevron.right").accessibilityHidden(true)
                                    }.foregroundStyle(StoryPalette.ink).padding(18)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .background(.white.opacity(0.8), in: RoundedRectangle(cornerRadius: 18))
                                }.buttonStyle(.plain)
                            }
                        }
                    }
                    Label("Your recordings stay on this device.", systemImage: "lock")
                        .font(.footnote).fixedSize(horizontal: false, vertical: true)
                }.padding(24).frame(maxWidth: 640)
                    .frame(maxWidth: .infinity)
            }
            .background(StoryPalette.ivory)
            .foregroundStyle(StoryPalette.ink)
            .navigationTitle("Story Within")
            .sheet(isPresented: $showingStudio) {
                RecordingStudio(workflow: workflow)
                    .interactiveDismissDisabled()
            }
            .sheet(isPresented: $showingExplore) {
                NavigationStack {
                    ContentUnavailableView("A collection to come", systemImage: "books.vertical", description: Text("There are no community demo stories on this device yet. Your recordings remain private."))
                        .navigationTitle("Explore Stories")
                        .toolbar { ToolbarItem(placement: .confirmationAction) { Button("Done") { showingExplore = false } } }
                }.tint(StoryPalette.forest)
            }
        }.tint(StoryPalette.forest)
    }
}

private struct RecordingStudio: View {
    @Bindable var workflow: StoryWorkflow
    @Environment(\.dismiss) private var dismiss
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.openURL) private var openURL
    @State private var confirmingLeave = false
    @State private var confirmingDiscard = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    if let story = workflow.currentStory {
                        review(story)
                    } else {
                        capture
                    }
                    if let error = workflow.errorMessage {
                        VStack(alignment: .leading, spacing: 12) {
                            Label(error, systemImage: "exclamationmark.triangle")
                                .fixedSize(horizontal: false, vertical: true)
                            if workflow.permissionDenied {
                                Button("Open Settings") {
                                    if let url = URL(string: UIApplication.openSettingsURLString) { openURL(url) }
                                }.buttonStyle(.bordered)
                            }
                            if workflow.hasPendingRecording && workflow.captureState != .recording && workflow.captureState != .paused {
                                Button("Retry keeping this take") { workflow.retryKeepingRecording() }.buttonStyle(.bordered)
                                Button("Discard this take", role: .destructive) { confirmingDiscard = true }.frame(minHeight: 44)
                            }
                        }.padding(18).background(.white, in: RoundedRectangle(cornerRadius: 16))
                            .accessibilityElement(children: .contain)
                    }
                }.padding(24).frame(maxWidth: 640).frame(maxWidth: .infinity)
            }
            .background(StoryPalette.ivory).foregroundStyle(StoryPalette.ink)
            .navigationTitle(workflow.currentStory == nil ? "Your recording studio" : "Listen to your story")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        if workflow.captureState == .requestingPermission { return }
                        if workflow.currentStory != nil || workflow.hasPendingRecording { confirmingLeave = true }
                        else { dismiss() }
                    }.disabled(workflow.captureState == .requestingPermission)
                }
            }
            .confirmationDialog("Keep your story before leaving?", isPresented: $confirmingLeave, titleVisibility: .visible) {
                Button((workflow.captureState == .recording || workflow.captureState == .paused) ? "Stop and keep draft" : "Keep on this device") {
                    if workflow.captureState == .recording || workflow.captureState == .paused { workflow.stopRecording() }
                    if workflow.hasPendingRecording { workflow.retryKeepingRecording() }
                    if workflow.currentStory != nil { workflow.keepDraft() }
                    if workflow.canLeaveReview && workflow.errorMessage == nil { workflow.stopPlayback(); dismiss() }
                }
                Button("Discard recording", role: .destructive) { confirmingDiscard = true }
                Button("Keep reviewing", role: .cancel) { }
            } message: { Text("Keeping retains your recording privately on this device. Discarding permanently removes this recording.") }
            .confirmationDialog("Permanently discard this recording?", isPresented: $confirmingDiscard, titleVisibility: .visible) {
                Button("Discard recording", role: .destructive) {
                    workflow.discardRecording()
                    if workflow.errorMessage == nil { dismiss() }
                }
                Button("Cancel", role: .cancel) { }
            } message: { Text("This removes this story and its original voice recording from this device.") }
            .onChange(of: scenePhase) { _, phase in
                if phase == .background { workflow.handleInterruption() }
            }
            .onChange(of: recordingAnnouncement) { _, announcement in
                guard !announcement.isEmpty else { return }
                UIAccessibility.post(notification: .announcement, argument: announcement)
            }
            .onDisappear { workflow.stopPlayback() }
        }.tint(StoryPalette.forest)
    }

    // Observe significant service/error transitions, never elapsed-time ticks.
    private var recordingAnnouncement: String {
        if let error = workflow.errorMessage { return error }
        switch workflow.captureState {
        case .idle: return ""
        case .requestingPermission: return "Requesting microphone access."
        case .recording: return "Recording. Your microphone is capturing your voice."
        case .paused: return "Recording paused. Your microphone is not recording. Resume when you are ready."
        case .stopped: return workflow.currentStory == nil ? "Recording stopped." : "Recording stopped. Your private draft is kept on this device."
        case .failed: return "Recording could not finish. Review the error and retry or discard the take."
        }
    }

    private var capture: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text(workflow.captureState == .paused ? "Take your time." : workflow.captureState == .recording ? "Your voice, your story." : "Begin with your own voice.")
                .font(.largeTitle.bold()).fixedSize(horizontal: false, vertical: true)
            Text(workflow.captureState == .paused
                 ? "Your microphone is paused. Resume when you are ready to continue the same story."
                 : workflow.captureState == .recording
                 ? "Your microphone is capturing your voice. You can pause for a break or stop to listen."
                 : "Your microphone captures your voice. Your audio stays on this device. Tap Record to choose microphone access.")
            VStack(spacing: 20) {
                Image(systemName: workflow.captureState == .paused ? "pause.circle" : workflow.captureState == .recording ? "mic.fill" : "mic")
                    .font(.system(size: 56)).foregroundStyle(StoryPalette.forest).accessibilityHidden(true)
                TimelineView(.periodic(from: .now, by: 0.5)) { _ in
                    Text(timeLabel(workflow.elapsedRecording))
                        .font(.largeTitle.monospacedDigit()).accessibilityLabel("Recording time")
                        .accessibilityValue(timeLabel(workflow.elapsedRecording))
                }
                Text(workflow.captureState == .paused ? "Paused" : workflow.captureState == .recording ? "Recording" : workflow.hasPendingRecording ? "Take needs attention" : "Ready when you are")
                    .font(.headline)
                if workflow.captureState == .recording || workflow.captureState == .paused {
                    Button {
                        if workflow.captureState == .paused { workflow.resumeRecording() }
                        else { workflow.pauseRecording() }
                    } label: {
                        Label(workflow.captureState == .paused ? "Resume recording" : "Pause recording",
                              systemImage: workflow.captureState == .paused ? "mic.fill" : "pause.fill")
                            .frame(maxWidth: .infinity, minHeight: 36)
                    }.buttonStyle(StoryPrimaryButton())
                        .accessibilityHint(workflow.captureState == .paused ? "Continues the same recording." : "Takes a break without ending your story.")
                    Button { workflow.stopRecording() } label: {
                        Label("Stop and review", systemImage: "stop.fill").frame(maxWidth: .infinity, minHeight: 44)
                    }.buttonStyle(.bordered).frame(maxWidth: .infinity)
                } else if !workflow.hasPendingRecording {
                    Button { Task { await workflow.startRecording() } } label: {
                        Label(workflow.captureState == .requestingPermission ? "Requesting access…" : "Record", systemImage: "mic.fill")
                            .frame(maxWidth: .infinity, minHeight: 36)
                    }.buttonStyle(StoryPrimaryButton()).disabled(workflow.captureState == .requestingPermission)
                }
            }.padding(24).frame(maxWidth: .infinity)
                .background(.white.opacity(0.8), in: RoundedRectangle(cornerRadius: 24))
            Text("When you stop, your take is kept as a private draft before you review it. Keeping a stopped draft does not share it.")
                .font(.footnote)
        }
    }

    private func review(_ story: Story) -> some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("Made with your voice.").font(.largeTitle.bold()).fixedSize(horizontal: false, vertical: true)
            Label(story.isSaved ? "Saved privately on this device" : "Private draft kept on this device", systemImage: "lock.fill").font(.subheadline)
            VStack(alignment: .leading, spacing: 16) {
                Text("Original recording").font(.headline)
                TimelineView(.periodic(from: .now, by: 0.5)) { _ in
                    Text("\(timeLabel(workflow.playbackTime)) / \(timeLabel(story.duration))")
                        .font(.title2.monospacedDigit())
                        .accessibilityLabel("Playback time \(timeLabel(workflow.playbackTime)) of \(timeLabel(story.duration))")
                }
                ViewThatFits(in: .horizontal) {
                    HStack(spacing: 16) { playbackButtons }
                    VStack(alignment: .leading, spacing: 12) { playbackButtons }
                }
            }.padding(20).frame(maxWidth: .infinity, alignment: .leading)
                .background(.white.opacity(0.8), in: RoundedRectangle(cornerRadius: 20))
            VStack(alignment: .leading, spacing: 8) {
                Text("Story title").font(.headline)
                TextField("Story title", text: $workflow.title, axis: .vertical)
                    .textFieldStyle(.roundedBorder).accessibilityLabel("Story title")
            }
            Button {
                workflow.savePrivately()
                if workflow.errorMessage == nil { workflow.stopPlayback(); dismiss() }
            } label: {
                Label("Save privately", systemImage: "lock.fill").frame(maxWidth: .infinity, minHeight: 36)
            }.buttonStyle(StoryPrimaryButton())
            Text("You can return from Home to listen again. No account, internet, transcript, or AI result is needed.").font(.footnote)
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
                .frame(minWidth: 80, minHeight: 32)
        }.buttonStyle(.borderedProminent)
        Button { workflow.play(fromStart: true) } label: {
            Label("Replay", systemImage: "arrow.counterclockwise").frame(minWidth: 80, minHeight: 32)
        }.buttonStyle(.bordered)
    }
}

private struct StoryPrimaryButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label.font(.headline).padding(12)
            .foregroundStyle(.white)
            .background(StoryPalette.forest.opacity(configuration.isPressed ? 0.8 : 1), in: RoundedRectangle(cornerRadius: 16))
    }
}

private func timeLabel(_ seconds: TimeInterval) -> String {
    let value = max(0, Int(seconds.isFinite ? seconds : 0))
    return String(format: "%d:%02d", value / 60, value % 60)
}
