import SwiftUI
import UIKit

struct StoryCreationView: View {
    @Bindable var workflow: StoryWorkflow
    @Environment(\.dismiss) private var dismiss
    @State private var approach: StoryStartingApproach?
    @State private var startingText = ""
    @State private var answer = ""
    @State private var showingStudio = false
    @FocusState private var editingText: Bool

    var body: some View {
        if showingStudio {
            RecordingStudio(workflow: workflow)
        } else {
            NavigationStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        Label(workflow.coaching.modeLabel, systemImage: "sparkle")
                            .font(.subheadline.weight(.semibold))
                        if let reason = workflow.coaching.availabilityMessage {
                            Text(reason).font(.footnote)
                        }
                        if workflow.coaching.context != nil { coach } else { start }
                        Text(workflow.coaching.authorshipMessage)
                            .font(.footnote)
                        if let message = workflow.coaching.modelContextMessage {
                            Text(message).font(.footnote)
                        }
                        Label("Preferences and this conversation stay in this session. They are not added to saved story details.", systemImage: "lock")
                            .font(.footnote)
                    }.padding(24).frame(maxWidth: 640).frame(maxWidth: .infinity)
                }
                .background(StoryPalette.ivory).foregroundStyle(StoryPalette.ink)
                .navigationTitle(workflow.coaching.context == nil ? "A story starts with you" : "Shape your story")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) { Button("Close") { dismiss() } }
                    ToolbarItemGroup(placement: .keyboard) {
                        Spacer()
                        Button("Done") { editingText = false }
                    }
                }
                .onChange(of: workflow.coaching.reply) { _, reply in
                    if let reply {
                        UIAccessibility.post(notification: .announcement, argument: [reply.guidance, reply.question].compactMap { $0 }.joined(separator: " "))
                    }
                }
                .onChange(of: workflow.coaching.errorMessage) { _, error in
                    if let error { UIAccessibility.post(notification: .announcement, argument: error) }
                }
                .safeAreaInset(edge: .bottom) {
                    VStack(spacing: 10) {
                        Button {
                            editingText = false
                            let thought = answer
                            answer = ""
                            Task {
                                if await workflow.prepareCoachedRecording(approach: approach, text: startingText, thought: thought) {
                                    showingStudio = true
                                }
                            }
                        } label: {
                            Label(workflow.coaching.isPreparingCues ? "Preparing cues…" : "Start Recording", systemImage: "mic.fill")
                                .frame(maxWidth: .infinity, minHeight: 36)
                        }.buttonStyle(StoryPrimaryButton()).disabled(workflow.coaching.isPreparingCues)
                        if workflow.coaching.isPreparingCues {
                            Button("Record without waiting") {
                                let thought = answer
                                answer = ""
                                workflow.prepareRecordingWithoutCues(thought: thought)
                                showingStudio = true
                            }.buttonStyle(.bordered).frame(minHeight: 44)
                        }
                    }.padding(16).background(StoryPalette.ivory)
                }
            }.tint(StoryPalette.forest)
        }
    }

    private var start: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Bring an idea, or begin with your listener.")
                .font(.title.bold()).fixedSize(horizontal: false, vertical: true)
            Text("Choose a starting point. You can go straight to recording whenever you like.")
            ForEach(StoryStartingApproach.allCases) { option in
                Button { approach = option } label: {
                    VStack(alignment: .leading, spacing: 8) {
                        Label(option.title, systemImage: approach == option ? "checkmark.circle.fill" : (option == .idea ? "lightbulb" : "heart"))
                            .font(.headline)
                        Text(option == .idea ? "A character, place, memory, or a spark of imagination." : "An interest, a feeling, or a way your child enjoys stories.")
                            .font(.subheadline)
                    }.frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
                        .padding(20).background(.white, in: RoundedRectangle(cornerRadius: 18))
                }.buttonStyle(.plain)
                    .accessibilityAddTraits(approach == option ? [.isSelected] : [])
            }
            if let approach {
                VStack(alignment: .leading, spacing: 10) {
                    Text(approach == .idea ? "Your idea" : "Your listener’s interests or preferences")
                        .font(.headline).accessibilityAddTraits(.isHeader)
                    TextField("Write a few words in your own way", text: $startingText, axis: .vertical)
                        .lineLimit(3...8).textFieldStyle(.roundedBorder).focused($editingText)
                        .accessibilityLabel(approach == .idea ? "Your story idea" : "Your listener’s interests or preferences")
                    Button("Explore this together") {
                        editingText = false
                        Task { await workflow.coaching.begin(approach: approach, text: startingText) }
                    }.buttonStyle(.bordered).frame(minHeight: 44)
                        .disabled(startingText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }

    private var coach: some View {
        VStack(alignment: .leading, spacing: 20) {
            if let context = workflow.coaching.context {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Your starting point").font(.headline).accessibilityAddTraits(.isHeader)
                    Text(context.initialText)
                    ForEach(context.turns) { turn in
                        if let text = turn.parentText { Text(text) }
                    }
                }.padding(20).frame(maxWidth: .infinity, alignment: .leading)
                    .background(.white, in: RoundedRectangle(cornerRadius: 18))
            }
            if workflow.coaching.isResponding { ProgressView(workflow.coaching.promptProgressLabel) }
            if let error = workflow.coaching.errorMessage {
                VStack(alignment: .leading, spacing: 12) {
                    Label(error, systemImage: "exclamationmark.triangle")
                    Button(workflow.coaching.retryLabel) { Task { await workflow.coaching.retry() } }
                        .buttonStyle(.bordered).frame(minHeight: 44)
                }.padding(18).background(.white, in: RoundedRectangle(cornerRadius: 18))
            }
            if let reply = workflow.coaching.reply {
                VStack(alignment: .leading, spacing: 12) {
                    Text(workflow.coaching.coachTitle).font(.headline).accessibilityAddTraits(.isHeader)
                    Text(reply.guidance)
                    if let question = reply.question { Text(question).font(.title3.weight(.semibold)) }
                }.accessibilityElement(children: .combine)
            }
            Button("Skip this question") {
                answer = ""; editingText = false
                Task { await workflow.coaching.skip() }
            }.buttonStyle(.bordered).frame(minHeight: 44).disabled(workflow.coaching.isResponding)
            TextField("Your next thought (optional)", text: $answer, axis: .vertical)
                .lineLimit(2...6).textFieldStyle(.roundedBorder).focused($editingText)
                .accessibilityLabel("Your next thought, optional")
            Button("Continue with my thought") {
                let text = answer
                answer = ""; editingText = false
                Task { await workflow.coaching.answer(text) }
            }.buttonStyle(.bordered).frame(minHeight: 44)
                .disabled(answer.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || workflow.coaching.isResponding)
        }
    }
}
