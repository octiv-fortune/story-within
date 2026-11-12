import SwiftUI
import UIKit

enum StoryPalette {
    static let forest = Color(red: 24/255, green: 62/255, blue: 52/255)
    static let ivory = Color(red: 248/255, green: 244/255, blue: 234/255)
    static let terracotta = Color(red: 196/255, green: 122/255, blue: 86/255)
    static let ink = Color(red: 36/255, green: 59/255, blue: 49/255)
}

struct ContentView: View {
    @Bindable var workflow: StoryWorkflow
    @State private var showingCreation = false
    @State private var showingStudio = false
    @State private var showingExplore = false
    @State private var showingLibrary = false

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
                        Button { workflow.coaching.reset(); showingCreation = true } label: {
                            Label("Create a Story", systemImage: "mic.fill").frame(maxWidth: .infinity, minHeight: 36)
                        }.buttonStyle(StoryPrimaryButton())
                        Button { showingExplore = true } label: {
                            Label("Explore Stories", systemImage: "books.vertical").frame(maxWidth: .infinity, minHeight: 36)
                        }.buttonStyle(.bordered).tint(StoryPalette.forest)
                    }
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Your recent stories").font(.title2.bold()).accessibilityAddTraits(.isHeader)
                        Button { showingLibrary = true } label: {
                            Label("Your personal library", systemImage: "books.vertical.fill")
                                .frame(minHeight: 44)
                        }
                        if workflow.stories.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("A beginning is waiting.").font(.headline)
                                Text("Your private drafts and saved stories will appear here. You can record without an account or internet connection.")
                            }.padding(20).frame(maxWidth: .infinity, alignment: .leading)
                                .background(.white.opacity(0.7), in: RoundedRectangle(cornerRadius: 18))
                        } else {
                            ForEach(workflow.stories.prefix(3)) { story in
                                Button {
                                    workflow.openStory(id: story.id); showingStudio = true
                                } label: {
                                    HStack(alignment: .top, spacing: 12) {
                                        Image(systemName: "waveform").font(.title2).accessibilityHidden(true)
                                        VStack(alignment: .leading, spacing: 6) {
                                            Text(story.title).font(.headline)
                                            Text("\(story.isSaved ? "Saved" : "Draft") · \(story.visibilityLabel) · \(timeLabel(story.duration))").font(.subheadline)
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
            .sheet(isPresented: $showingCreation, onDismiss: { workflow.coaching.reset() }) {
                StoryCreationView(workflow: workflow)
                    .interactiveDismissDisabled()
            }
            .sheet(isPresented: $showingStudio) {
                RecordingStudio(workflow: workflow)
                    .interactiveDismissDisabled()
            }
            .sheet(isPresented: $showingLibrary) {
                PersonalStoryLibrary(workflow: workflow)
            }
            .sheet(isPresented: $showingExplore) {
                ExploreStories(workflow: workflow)
            }
        }.tint(StoryPalette.forest)
    }
}

private struct PersonalStoryLibrary: View {
    @Bindable var workflow: StoryWorkflow
    @Environment(\.dismiss) private var dismiss
    @State private var selection = "All"
    @State private var showingReview = false

    private var visibleStories: [Story] {
        workflow.stories.filter { selection == "All" || (selection == "Saved" ? $0.isSaved : !$0.isSaved) }
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Picker("Show stories", selection: $selection) {
                        Text("All").tag("All")
                        Text("Drafts").tag("Drafts")
                        Text("Saved").tag("Saved")
                    }.pickerStyle(.segmented)
                }
                if visibleStories.isEmpty {
                    ContentUnavailableView("No \(selection == "All" ? "stories" : selection.lowercased()) yet", systemImage: "book.closed",
                        description: Text("Your private recordings and details will appear here. Start a story from Home."))
                        .listRowBackground(Color.clear)
                } else {
                    ForEach(visibleStories) { story in
                        Button {
                            workflow.openStory(id: story.id)
                            showingReview = true
                        } label: {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(story.title).font(.headline)
                                Text("\(story.isSaved ? "Saved" : "Draft") · \(story.visibilityLabel) · \(timeLabel(story.duration))").font(.subheadline)
                                if !story.creatorName.isEmpty { Text(story.creatorName).font(.subheadline) }
                                if !story.sourceLanguage.isEmpty { Text(story.sourceLanguage).font(.subheadline) }
                                Text(story.updatedAt, style: .date).font(.caption)
                            }.padding(.vertical, 8).foregroundStyle(StoryPalette.ink)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }.buttonStyle(.plain)
                    }
                }
                Section {
                    Label("Your recordings stay on this device. Confirmed local previews also appear in Explore Stories on this device only.", systemImage: "lock")
                        .font(.footnote)
                }
            }
            .scrollContentBackground(.hidden).background(StoryPalette.ivory)
            .navigationTitle("Your personal library")
            .toolbar { ToolbarItem(placement: .confirmationAction) { Button("Done") { dismiss() } } }
            .sheet(isPresented: $showingReview) {
                RecordingStudio(workflow: workflow).interactiveDismissDisabled()
            }
        }.tint(StoryPalette.forest)
    }
}

struct RecordingStudio: View {
    @Bindable var workflow: StoryWorkflow
    @Environment(\.dismiss) private var dismiss
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.openURL) private var openURL
    @State private var confirmingLeave = false
    @State private var confirmingDiscard = false
    @State private var confirmingReviewExit = false
    @State private var showingCommunityPreview = false
    @State private var previewStory: Story?

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
            .navigationTitle(workflow.currentStory == nil ? "Your recording studio" : "Review your story")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        if workflow.captureState == .requestingPermission { return }
                        if workflow.hasPendingRecording { confirmingLeave = true }
                        else if workflow.currentStory != nil {
                            if workflow.hasUnsavedReviewChanges { confirmingReviewExit = true }
                            else { workflow.stopPlayback(); dismiss() }
                        }
                        else { dismiss() }
                    }.disabled(workflow.captureState == .requestingPermission)
                }
            }
            .confirmationDialog("Keep your changes?", isPresented: $confirmingReviewExit, titleVisibility: .visible) {
                Button(workflow.currentStory?.visibility == "localPreview" ? "Keep changes privately and withdraw preview" : "Keep changes") { leaveReview(.keepChanges) }
                Button("Discard changes", role: .destructive) { leaveReview(.discardChanges) }
                Button("Cancel", role: .cancel) { _ = workflow.resolveReviewExit(.cancel) }
            } message: { Text("Discarding changes restores the last kept details and text. Your original recording stays in your library.") }
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
            .confirmationDialog(workflow.currentStory == nil ? "Permanently discard this recording?" : "Permanently delete this story?", isPresented: $confirmingDiscard, titleVisibility: .visible) {
                Button(workflow.currentStory == nil ? "Discard recording" : "Delete story", role: .destructive) {
                    if workflow.currentStory != nil { workflow.deleteCurrentStory(confirmed: true) }
                    else { workflow.discardRecording() }
                    if workflow.errorMessage == nil { dismiss() }
                }
                Button("Cancel", role: .cancel) { }
            } message: { Text("This removes this story, its text, and its owned original voice recording from this device. This cannot be undone.") }
            .sheet(isPresented: $showingCommunityPreview) {
                if let story = previewStory {
                    CommunityPreviewReview(workflow: workflow, story: story)
                }
            }
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
            if workflow.captureState == .idle, !workflow.coaching.preparedCues.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text(workflow.coaching.cueLabel).font(.headline)
                    if let context = workflow.coaching.context { Text("Starting point: \(context.initialText)") }
                    Text(workflow.coaching.usingGenericCues
                         ? "Simple starting cues are ready. Recording is available."
                         : "Your starting point and optional text cues are ready for this session.")
                        .font(.subheadline)
                }.padding(18).frame(maxWidth: .infinity, alignment: .leading)
                    .background(.white, in: RoundedRectangle(cornerRadius: 18))
            }
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
                    if workflow.captureState == .recording {
                        Button { workflow.pauseForInspiration() } label: {
                            Label("Pause for inspiration", systemImage: "lightbulb")
                                .foregroundStyle(StoryPalette.forest)
                                .frame(maxWidth: .infinity, minHeight: 44)
                        }.buttonStyle(.bordered)
                            .accessibilityHint("Pauses your microphone before showing an optional text cue.")
                    }
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
            if workflow.captureState == .paused { inspiration }
            Text("When you stop, your take is kept as a private draft before you review it. Keeping a stopped draft does not share it.")
                .font(.footnote)
        }
    }

    private var inspiration: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(workflow.inspirationLabel).font(.headline).accessibilityAddTraits(.isHeader)
            if let cue = workflow.currentCue {
                Text(cue).font(.title3).fixedSize(horizontal: false, vertical: true)
            } else if let message = workflow.inspirationMessage {
                Text(message).fixedSize(horizontal: false, vertical: true)
            } else {
                Text("Would a little inspiration help? Show a cue whenever you choose.")
            }
            Text("Text only. Your microphone stays paused until you tap Resume recording.")
                .font(.subheadline).fixedSize(horizontal: false, vertical: true)
            if workflow.inspirationMessage == nil {
                Button { workflow.showNextCue() } label: {
                    Label(workflow.currentCue == nil ? "Show a cue" : "Next cue", systemImage: "lightbulb")
                        .foregroundStyle(StoryPalette.forest)
                        .frame(maxWidth: .infinity, minHeight: 44)
                }.buttonStyle(.bordered)
                    .accessibilityHint("Shows the next text cue. Recording stays paused.")
            }
        }.padding(20).frame(maxWidth: .infinity, alignment: .leading)
            .background(.white, in: RoundedRectangle(cornerRadius: 20))
            .accessibilityElement(children: .contain)
    }

    private func review(_ story: Story) -> some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("Made with your voice.").font(.largeTitle.bold()).fixedSize(horizontal: false, vertical: true)
            Label(story.visibility == "localPreview" ? "Community preview · This device only" : story.isSaved ? "Saved privately on this device" : "Private draft kept on this device", systemImage: story.visibility == "localPreview" ? "books.vertical" : "lock.fill").font(.subheadline)
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
            VStack(alignment: .leading, spacing: 16) {
                reviewField("Creator display name", text: $workflow.creatorName, prompt: "Optional name")
                reviewField("Theme", text: $workflow.theme, prompt: "For example, courage or kindness")
                reviewField("Original language", text: $workflow.sourceLanguage, prompt: "Unknown or your chosen language")
                VStack(alignment: .leading, spacing: 8) {
                    Text("Your transcript").font(.headline)
                    Text("Type the words from your recording, if you like. This is your own text; no AI transcription has been run.")
                        .font(.footnote)
                    TextEditor(text: $workflow.transcript)
                        .frame(minHeight: 180).padding(8)
                        .background(.white, in: RoundedRectangle(cornerRadius: 12))
                        .accessibilityLabel("Your manually entered transcript")
                }
            }
            Button {
                workflow.savePrivately()
                if workflow.errorMessage == nil { workflow.stopPlayback(); dismiss() }
            } label: {
                Label(story.visibility == "localPreview" ? "Save changes privately and withdraw preview" : "Save privately", systemImage: "lock.fill").frame(maxWidth: .infinity, minHeight: 36)
            }.buttonStyle(StoryPrimaryButton())
            if story.visibility == "localPreview" {
                Text("Saving edits returns this story to private visibility. Review and confirm again to include the changed story in the local community preview.").font(.footnote)
                Button("Withdraw local preview") { workflow.withdrawCommunityPreview() }
                    .buttonStyle(.bordered).frame(minHeight: 44)
            } else if story.isSaved {
                Button {
                    if workflow.prepareCommunityPreview() { previewStory = workflow.communityPreview; showingCommunityPreview = true }
                } label: {
                    Label("Review for local community preview", systemImage: "books.vertical")
                        .frame(maxWidth: .infinity, minHeight: 44)
                }.buttonStyle(.bordered)
                Text("Save any changes privately first. Then review the exact recording and text before confirming a preview on this device only.").font(.footnote)
            }
            Text("You can return from Home to listen again. No account, internet, transcript, or AI result is needed.").font(.footnote)
            Button("Delete story from this device", role: .destructive) { confirmingDiscard = true }
                .frame(minHeight: 44)
        }.task {
            while !Task.isCancelled {
                workflow.refreshPlayback()
                try? await Task.sleep(for: .milliseconds(400))
            }
        }
    }

    private func reviewField(_ label: String, text: Binding<String>, prompt: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label).font(.headline)
            TextField(prompt, text: text, axis: .vertical)
                .textFieldStyle(.roundedBorder).accessibilityLabel(label)
        }
    }

    private func leaveReview(_ choice: ReviewExitChoice) {
        if workflow.resolveReviewExit(choice) { workflow.stopPlayback(); dismiss() }
    }

    @ViewBuilder private var playbackButtons: some View {
        Button {
            if workflow.isPlaying { workflow.pausePlayback() } else { workflow.play() }
        } label: {
            Label(workflow.isPlaying ? "Pause" : "Play", systemImage: workflow.isPlaying ? "pause.fill" : "play.fill")
                .foregroundStyle(.white)
                .frame(minWidth: 80, minHeight: 32)
        }.buttonStyle(.borderedProminent).tint(StoryPalette.forest)
        Button { workflow.play(fromStart: true) } label: {
            Label("Replay", systemImage: "arrow.counterclockwise").foregroundStyle(StoryPalette.forest).frame(minWidth: 80, minHeight: 32)
        }.buttonStyle(.bordered)
    }
}

struct StoryPrimaryButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label.font(.headline).padding(12)
            .foregroundStyle(.white)
            .background(StoryPalette.forest.opacity(configuration.isPressed ? 0.8 : 1), in: RoundedRectangle(cornerRadius: 16))
    }
}

func timeLabel(_ seconds: TimeInterval) -> String {
    let value = max(0, Int(seconds.isFinite ? seconds : 0))
    return String(format: "%d:%02d", value / 60, value % 60)
}
