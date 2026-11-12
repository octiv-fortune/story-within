import XCTest
import SwiftData
@testable import StoryWithin

@MainActor
final class StoryWorkflowTests: XCTestCase {
    func testStoppedReplacementSurvivesFailedCommitRelaunchAndRetryKeeping() async throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        var failWrites = false
        let audio = PausableAudio()
        let workflow = try StoryWorkflow(storageURL: root, audio: audio, commitChanges: { context in
            if failWrites { throw CocoaError(.fileWriteNoPermission) }
            try context.save()
        })
        await workflow.startRecording()
        try audio.speak("original voice", lasting: 2)
        workflow.stopRecording()
        workflow.title = "The moon garden"
        workflow.creatorName = "Mama"
        workflow.theme = "Kindness"
        workflow.sourceLanguage = "English"
        workflow.transcript = "My manual text"
        workflow.savePrivately()
        let original = try XCTUnwrap(workflow.currentStory)
        await workflow.startReplacementRecording(confirmed: true)
        try audio.speak("new finalized voice", lasting: 7)
        let capture = try XCTUnwrap(FileManager.default.contentsOfDirectory(at: root.appendingPathComponent("Captures"), includingPropertiesForKeys: nil).first)
        failWrites = true
        workflow.stopRecording()
        XCTAssertNotNil(workflow.errorMessage)
        let reopened = try StoryWorkflow(storageURL: root, audio: PausableAudio())
        reopened.openStory(id: original.id)
        XCTAssertEqual(reopened.currentStory, original)
        XCTAssertTrue(reopened.hasPendingRecording)
        reopened.retryKeepingRecording()
        XCTAssertNil(reopened.errorMessage)
        XCTAssertFalse(reopened.hasPendingRecording)
        let retained = try XCTUnwrap(reopened.currentStory)
        XCTAssertEqual(retained.id, original.id)
        XCTAssertEqual(retained.audioName, capture.lastPathComponent)
        XCTAssertEqual(retained.duration, 7)
        XCTAssertEqual(retained.createdAt, original.createdAt)
        XCTAssertEqual(retained.title, "The moon garden")
        XCTAssertEqual(retained.creatorName, "Mama")
        XCTAssertEqual(retained.theme, "Kindness")
        XCTAssertEqual(retained.sourceLanguage, "English")
        XCTAssertEqual(retained.transcript, "My manual text")
        XCTAssertTrue(retained.isSaved)
        XCTAssertEqual(retained.visibility, "private")
        XCTAssertEqual(try Data(contentsOf: XCTUnwrap(reopened.currentAudioURL)), Data("new finalized voice ".utf8))
        let relaunchedAgain = try StoryWorkflow(storageURL: root, audio: PausableAudio())
        relaunchedAgain.openStory(id: original.id)
        XCTAssertEqual(relaunchedAgain.currentStory, retained)
        XCTAssertFalse(relaunchedAgain.hasPendingRecording)
    }

    func testCancellingRecoveredReplacementKeepsOriginalAndRemovesOnlyOwnedRecovery() async throws {
        let (root, original) = try await makeFailedStoppedReplacement()
        let unrelated = root.appendingPathComponent("Recordings/\(original.id.uuidString)--not-a-take.m4a")
        try Data("unrelated recording".utf8).write(to: unrelated)
        let reopened = try StoryWorkflow(storageURL: root, audio: PausableAudio())
        reopened.openStory(id: original.id)
        reopened.cancelReplacementRecording()
        XCTAssertNil(reopened.errorMessage)
        XCTAssertFalse(reopened.hasPendingRecording)
        XCTAssertEqual(reopened.currentStory, original)
        XCTAssertEqual(try Data(contentsOf: XCTUnwrap(reopened.currentAudioURL)), Data("original voice ".utf8))
        XCTAssertEqual(try Data(contentsOf: unrelated), Data("unrelated recording".utf8))
        XCTAssertFalse(FileManager.default.fileExists(atPath: root.appendingPathComponent("Recovery/\(original.id.uuidString).json").path))
        XCTAssertTrue(try FileManager.default.contentsOfDirectory(atPath: root.appendingPathComponent("Captures").path).isEmpty)
        XCTAssertEqual(try FileManager.default.contentsOfDirectory(atPath: root.appendingPathComponent("Recordings").path).sorted(), [original.audioName, unrelated.lastPathComponent].sorted())
        let relaunchedAgain = try StoryWorkflow(storageURL: root, audio: PausableAudio())
        relaunchedAgain.openStory(id: original.id)
        XCTAssertEqual(relaunchedAgain.currentStory, original)
        XCTAssertFalse(relaunchedAgain.hasPendingRecording)
    }

    func testMissingReplacementRecoveryDetailsNeverTurnRetryIntoAudioCleanup() async throws {
        let (root, original) = try await makeFailedStoppedReplacement()
        let marker = root.appendingPathComponent("Recovery/\(original.id.uuidString).json")
        try FileManager.default.removeItem(at: marker)
        let source = try XCTUnwrap(FileManager.default.contentsOfDirectory(at: root.appendingPathComponent("Captures"), includingPropertiesForKeys: nil).first)
        let promoted = root.appendingPathComponent("Recordings/\(source.lastPathComponent)")
        let reopened = try StoryWorkflow(storageURL: root, audio: PausableAudio())
        reopened.openStory(id: original.id)
        reopened.retryKeepingRecording()
        XCTAssertNotNil(reopened.errorMessage)
        XCTAssertTrue(reopened.hasPendingRecording)
        XCTAssertFalse(reopened.canLeaveReview)
        XCTAssertEqual(reopened.currentStory, original)
        XCTAssertEqual(try Data(contentsOf: source), Data("new finalized voice ".utf8))
        XCTAssertEqual(try Data(contentsOf: promoted), Data("new finalized voice ".utf8))
        reopened.cancelReplacementRecording()
        XCTAssertNil(reopened.errorMessage)
        XCTAssertEqual(reopened.currentStory, original)
        XCTAssertFalse(FileManager.default.fileExists(atPath: source.path))
        XCTAssertFalse(FileManager.default.fileExists(atPath: promoted.path))
    }

    func testCorruptOrForeignReplacementRecoveryDetailsPreserveAllVoicesAndOwnedPaths() async throws {
        for corruption in ["invalid JSON", "foreign identity", "foreign path"] {
            let (root, original) = try await makeFailedStoppedReplacement()
            let marker = root.appendingPathComponent("Recovery/\(original.id.uuidString).json")
            let unrelated = root.appendingPathComponent("outside.m4a")
            try Data("other recording".utf8).write(to: unrelated)
            if corruption == "invalid JSON" {
                try Data("broken recovery details".utf8).write(to: marker)
            } else {
                var fields = try XCTUnwrap(JSONSerialization.jsonObject(with: Data(contentsOf: marker)) as? [String: Any])
                if corruption == "foreign identity" { fields["storyID"] = UUID().uuidString }
                else { fields["originalAudioName"] = "../outside.m4a" }
                try JSONSerialization.data(withJSONObject: fields).write(to: marker)
            }
            let source = try XCTUnwrap(FileManager.default.contentsOfDirectory(at: root.appendingPathComponent("Captures"), includingPropertiesForKeys: nil).first)
            let reopened = try StoryWorkflow(storageURL: root, audio: PausableAudio())
            reopened.openStory(id: original.id)
            reopened.retryKeepingRecording()
            XCTAssertNotNil(reopened.errorMessage, corruption)
            XCTAssertTrue(reopened.hasPendingRecording, corruption)
            XCTAssertEqual(reopened.currentStory, original, corruption)
            XCTAssertEqual(try Data(contentsOf: source), Data("new finalized voice ".utf8), corruption)
            XCTAssertTrue(FileManager.default.fileExists(atPath: marker.path), corruption)
            reopened.cancelReplacementRecording()
            XCTAssertNil(reopened.errorMessage, corruption)
            XCTAssertEqual(try Data(contentsOf: XCTUnwrap(reopened.currentAudioURL)), Data("original voice ".utf8), corruption)
            XCTAssertFalse(FileManager.default.fileExists(atPath: marker.path), corruption)
            XCTAssertEqual(try Data(contentsOf: unrelated), Data("other recording".utf8), corruption)
        }
    }

    func testReplacementRecoveryCanKeepThePromotedCopyWhenItsCaptureIsUnavailable() async throws {
        let (root, original) = try await makeFailedStoppedReplacement()
        let source = try XCTUnwrap(FileManager.default.contentsOfDirectory(at: root.appendingPathComponent("Captures"), includingPropertiesForKeys: nil).first)
        try FileManager.default.removeItem(at: source)
        let reopened = try StoryWorkflow(storageURL: root, audio: PausableAudio())
        reopened.openStory(id: original.id)
        reopened.retryKeepingRecording()
        XCTAssertNil(reopened.errorMessage)
        XCTAssertEqual(reopened.currentStory?.audioName, source.lastPathComponent)
        XCTAssertEqual(reopened.currentStory?.duration, 7)
        XCTAssertEqual(try Data(contentsOf: XCTUnwrap(reopened.currentAudioURL)), Data("new finalized voice ".utf8))
    }

    func testMarkerLeftAfterSuccessfulReplacementCommitOnlyFinishesCleanupAndIsDeletedWithStory() async throws {
        let (root, original) = try await makeFailedStoppedReplacement()
        let captures = root.appendingPathComponent("Captures")
        let marker = root.appendingPathComponent("Recovery/\(original.id.uuidString).json")
        let markerBytes = try Data(contentsOf: marker)
        defer { try? FileManager.default.setAttributes([.posixPermissions: 0o700], ofItemAtPath: captures.path) }
        let reopened = try StoryWorkflow(storageURL: root, audio: PausableAudio())
        reopened.openStory(id: original.id)
        try FileManager.default.setAttributes([.posixPermissions: 0o500], ofItemAtPath: captures.path)
        reopened.retryKeepingRecording()
        XCTAssertNotNil(reopened.errorMessage)
        let committed = try XCTUnwrap(reopened.currentStory)
        XCTAssertEqual(committed.duration, 7)
        XCTAssertTrue(FileManager.default.fileExists(atPath: marker.path))
        try FileManager.default.setAttributes([.posixPermissions: 0o700], ofItemAtPath: captures.path)
        let relaunchedAgain = try StoryWorkflow(storageURL: root, audio: PausableAudio())
        relaunchedAgain.openStory(id: original.id)
        XCTAssertFalse(relaunchedAgain.isReplacingRecording)
        relaunchedAgain.retryKeepingRecording()
        XCTAssertNil(relaunchedAgain.errorMessage)
        XCTAssertEqual(relaunchedAgain.currentStory, committed)
        XCTAssertEqual(try Data(contentsOf: XCTUnwrap(relaunchedAgain.currentAudioURL)), Data("new finalized voice ".utf8))
        XCTAssertFalse(FileManager.default.fileExists(atPath: marker.path))
        // Simulate a successful metadata commit followed immediately by termination.
        try markerBytes.write(to: marker)
        relaunchedAgain.openStory(id: original.id)
        relaunchedAgain.deleteCurrentStory(confirmed: true)
        XCTAssertNil(relaunchedAgain.errorMessage)
        XCTAssertFalse(FileManager.default.fileExists(atPath: marker.path))
        XCTAssertTrue(relaunchedAgain.stories.isEmpty)
    }

    func testOlderStaleReplacementMarkerNeverReappliesAnEarlierVoice() async throws {
        let (root, original) = try await makeFailedStoppedReplacement()
        let marker = root.appendingPathComponent("Recovery/\(original.id.uuidString).json")
        let oldMarker = try Data(contentsOf: marker)
        let audio = PausableAudio()
        let workflow = try StoryWorkflow(storageURL: root, audio: audio)
        workflow.openStory(id: original.id)
        workflow.retryKeepingRecording()
        XCTAssertNil(workflow.errorMessage)
        await workflow.startReplacementRecording(confirmed: true)
        try audio.speak("latest kept voice", lasting: 11)
        workflow.stopRecording()
        let latest = try XCTUnwrap(workflow.currentStory)
        XCTAssertNil(workflow.errorMessage)
        try oldMarker.write(to: marker)
        let reopened = try StoryWorkflow(storageURL: root, audio: PausableAudio())
        reopened.openStory(id: original.id)
        reopened.retryKeepingRecording()
        XCTAssertNotNil(reopened.errorMessage)
        XCTAssertEqual(reopened.currentStory, latest)
        XCTAssertEqual(reopened.currentStory?.duration, 11)
        XCTAssertEqual(try Data(contentsOf: XCTUnwrap(reopened.currentAudioURL)), Data("latest kept voice ".utf8))
        reopened.cancelReplacementRecording()
        XCTAssertNil(reopened.errorMessage)
        XCTAssertEqual(reopened.currentStory, latest)
        XCTAssertFalse(FileManager.default.fileExists(atPath: marker.path))
    }

    func testCancellingUnknownReplacementRecoveryPreservesOriginalBackupWhenRetainedAudioIsMissingOrCorrupt() async throws {
        for corruptOriginal in [false, true] {
            let (root, original) = try await makeFailedStoppedReplacement()
            let retained = root.appendingPathComponent("Recordings/\(original.audioName)")
            let backup = root.appendingPathComponent("Captures/\(original.audioName)")
            let marker = root.appendingPathComponent("Recovery/\(original.id.uuidString).json")
            try FileManager.default.copyItem(at: retained, to: backup)
            if corruptOriginal { try Data().write(to: retained) }
            else { try FileManager.default.removeItem(at: retained) }
            try Data("unreadable marker".utf8).write(to: marker)
            let reopened = try StoryWorkflow(storageURL: root, audio: PausableAudio())
            reopened.openStory(id: original.id)
            reopened.cancelReplacementRecording()
            XCTAssertNil(reopened.errorMessage)
            XCTAssertEqual(reopened.currentStory, original)
            XCTAssertEqual(try Data(contentsOf: backup), Data("original voice ".utf8))
            XCTAssertFalse(FileManager.default.fileExists(atPath: marker.path))
            XCTAssertEqual(try FileManager.default.contentsOfDirectory(atPath: root.appendingPathComponent("Captures").path), [original.audioName])
            // Once the original retained path is restored, ordinary cleanup is safe.
            try Data(contentsOf: backup).write(to: retained)
            let restored = try StoryWorkflow(storageURL: root, audio: PausableAudio())
            restored.openStory(id: original.id)
            restored.retryKeepingRecording()
            XCTAssertNil(restored.errorMessage)
            XCTAssertEqual(try Data(contentsOf: XCTUnwrap(restored.currentAudioURL)), Data("original voice ".utf8))
        }
    }

    private func makeFailedStoppedReplacement() async throws -> (URL, Story) {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        var failWrites = false
        let audio = PausableAudio()
        let workflow = try StoryWorkflow(storageURL: root, audio: audio, commitChanges: { context in
            if failWrites { throw CocoaError(.fileWriteNoPermission) }
            try context.save()
        })
        await workflow.startRecording()
        try audio.speak("original voice", lasting: 2)
        workflow.stopRecording()
        workflow.title = "My family garden"
        workflow.transcript = "Keep my manual words"
        workflow.savePrivately()
        let original = try XCTUnwrap(workflow.currentStory)
        await workflow.startReplacementRecording(confirmed: true)
        try audio.speak("new finalized voice", lasting: 7)
        failWrites = true
        workflow.stopRecording()
        XCTAssertNotNil(workflow.errorMessage)
        XCTAssertEqual(workflow.currentStory, original)
        return (root, original)
    }

    func testReplacementPreservesOldPreviewOnCancelOrFailureAndRequiresFreshConsentForNewVoice() async throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        var failWrites = false
        let audio = PausableAudio()
        let workflow = try StoryWorkflow(storageURL: root, audio: audio, commitChanges: { context in
            if failWrites { throw CocoaError(.fileWriteNoPermission) }
            try context.save()
        })
        await workflow.startRecording()
        try audio.speak("reviewed original voice", lasting: 3)
        workflow.stopRecording()
        workflow.title = "The family garden"
        workflow.creatorName = "Mama"
        workflow.transcript = "My manual story text"
        workflow.savePrivately()
        XCTAssertTrue(workflow.prepareCommunityPreview())
        workflow.confirmCommunityPreview(confirmed: true)
        let original = try XCTUnwrap(workflow.currentStory)
        XCTAssertEqual(original.visibility, "localPreview")
        await workflow.startReplacementRecording(confirmed: true)
        try audio.speak("cancelled voice", lasting: 2)
        workflow.cancelReplacementRecording()
        XCTAssertEqual(workflow.currentStory, original)
        XCTAssertEqual(workflow.communityStories, [original])
        XCTAssertTrue(workflow.prepareCommunityPreview())
        await workflow.startReplacementRecording(confirmed: true)
        try audio.speak("new private voice", lasting: 5)
        failWrites = true
        workflow.stopRecording()
        XCTAssertNotNil(workflow.errorMessage)
        XCTAssertEqual(workflow.currentStory, original)
        XCTAssertEqual(workflow.communityStories, [original])
        let unchanged = try StoryWorkflow(storageURL: root, audio: PausableAudio())
        XCTAssertEqual(unchanged.communityStories, [original])
        failWrites = false
        workflow.retryKeepingRecording()
        XCTAssertNil(workflow.errorMessage)
        XCTAssertEqual(workflow.currentStory?.id, original.id)
        XCTAssertEqual(workflow.currentStory?.visibility, "private")
        XCTAssertTrue(workflow.communityStories.isEmpty)
        workflow.confirmCommunityPreview(confirmed: true)
        XCTAssertNotNil(workflow.errorMessage, "An earlier review cannot authorize replacement voice")
        XCTAssertEqual(workflow.currentStory?.visibility, "private")
        let reopened = try StoryWorkflow(storageURL: root, audio: PausableAudio())
        reopened.openStory(id: original.id)
        XCTAssertEqual(reopened.currentStory?.visibility, "private")
        XCTAssertEqual(reopened.title, "The family garden")
        XCTAssertEqual(reopened.creatorName, "Mama")
        XCTAssertEqual(reopened.transcript, "My manual story text")
        XCTAssertEqual(try Data(contentsOf: XCTUnwrap(reopened.currentAudioURL)), Data("new private voice ".utf8))
        XCTAssertTrue(reopened.prepareCommunityPreview())
        reopened.confirmCommunityPreview(confirmed: true)
        XCTAssertNil(reopened.errorMessage)
        XCTAssertEqual(reopened.communityStories.map(\.id), [original.id])
    }

    func testCorruptAudioCannotBeConfirmedFromAnEarlierCommunityReview() async throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let initial = try StoryWorkflow(storageURL: root, audio: DeterministicAudio())
        await initial.startRecording()
        initial.stopRecording()
        let id = try XCTUnwrap(initial.currentStory?.id)
        let url = try XCTUnwrap(initial.currentAudioURL)
        let bundled = try XCTUnwrap(DemoLibrary.bundled().audioURLs.values.first)
        let goodAudio = try Data(contentsOf: bundled)
        try goodAudio.write(to: url)
        let workflow = try StoryWorkflow(storageURL: root, audio: NativeStoryAudio())
        workflow.openStory(id: id)
        workflow.savePrivately()
        XCTAssertTrue(workflow.prepareCommunityPreview())
        try Data("not playable, despite having bytes".utf8).write(to: url)
        workflow.confirmCommunityPreview(confirmed: true)
        XCTAssertNotNil(workflow.errorMessage)
        XCTAssertEqual(workflow.currentStory?.visibility, "private")
        XCTAssertTrue(workflow.communityStories.isEmpty)
        XCTAssertFalse(workflow.prepareCommunityPreview())
        try goodAudio.write(to: url)
        XCTAssertTrue(workflow.prepareCommunityPreview())
        workflow.confirmCommunityPreview(confirmed: true)
        XCTAssertNil(workflow.errorMessage)
        XCTAssertEqual(workflow.communityStories.map(\.id), [id])
    }

    func testFailedReplacementCopyAndEmptyTakeKeepOriginalForCancellationAndRelaunch() async throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let recordings = root.appendingPathComponent("Recordings")
        defer { try? FileManager.default.setAttributes([.posixPermissions: 0o700], ofItemAtPath: recordings.path) }
        let audio = PausableAudio()
        let workflow = try StoryWorkflow(storageURL: root, audio: audio)
        await workflow.startRecording()
        try audio.speak("irreplaceable first voice", lasting: 3)
        workflow.stopRecording()
        workflow.title = "My kept story"
        workflow.savePrivately()
        let original = try XCTUnwrap(workflow.currentStory)
        let originalURL = try XCTUnwrap(workflow.currentAudioURL)
        await workflow.startReplacementRecording(confirmed: true)
        try audio.speak("failed copy voice", lasting: 5)
        try FileManager.default.setAttributes([.posixPermissions: 0o500], ofItemAtPath: recordings.path)
        workflow.stopRecording()
        XCTAssertNotNil(workflow.errorMessage)
        XCTAssertEqual(workflow.currentStory, original)
        XCTAssertEqual(try Data(contentsOf: originalURL), Data("irreplaceable first voice ".utf8))
        let reopened = try StoryWorkflow(storageURL: root, audio: PausableAudio())
        reopened.openStory(id: original.id)
        XCTAssertEqual(reopened.currentStory, original)
        XCTAssertEqual(try Data(contentsOf: XCTUnwrap(reopened.currentAudioURL)), Data("irreplaceable first voice ".utf8))
        try FileManager.default.setAttributes([.posixPermissions: 0o700], ofItemAtPath: recordings.path)
        workflow.cancelReplacementRecording()
        XCTAssertNil(workflow.errorMessage)
        await workflow.startReplacementRecording(confirmed: true)
        workflow.stopRecording()
        XCTAssertNotNil(workflow.errorMessage)
        XCTAssertEqual(workflow.currentStory, original)
        workflow.cancelReplacementRecording()
        XCTAssertNil(workflow.errorMessage)
        XCTAssertEqual(workflow.currentStory, original)
        XCTAssertFalse(workflow.hasPendingRecording)
        XCTAssertEqual(try Data(contentsOf: originalURL), Data("irreplaceable first voice ".utf8))
    }

    func testReplacementRecoveryNeverDeletesLastOwnedCopyWhenRetainedAssetIsMissing() async throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let captures = root.appendingPathComponent("Captures")
        defer { try? FileManager.default.setAttributes([.posixPermissions: 0o700], ofItemAtPath: captures.path) }
        let audio = PausableAudio()
        let workflow = try StoryWorkflow(storageURL: root, audio: audio)
        await workflow.startRecording()
        try audio.speak("old voice", lasting: 2)
        workflow.stopRecording()
        let id = try XCTUnwrap(workflow.currentStory?.id)
        await workflow.startReplacementRecording(confirmed: true)
        try audio.speak("replacement worth keeping", lasting: 4)
        try FileManager.default.setAttributes([.posixPermissions: 0o500], ofItemAtPath: captures.path)
        workflow.stopRecording()
        XCTAssertNotNil(workflow.errorMessage)
        let retained = try XCTUnwrap(workflow.currentAudioURL)
        let source = try XCTUnwrap(FileManager.default.contentsOfDirectory(at: captures, includingPropertiesForKeys: nil).first)
        let pending = retained.deletingPathExtension().appendingPathExtension("pending")
        try Data("extra owned staging bytes".utf8).write(to: pending)
        let unavailable = root.appendingPathComponent("unavailable.m4a")
        try FileManager.default.moveItem(at: retained, to: unavailable)
        let reopened = try StoryWorkflow(storageURL: root, audio: PausableAudio())
        reopened.openStory(id: id)
        XCTAssertNotNil(reopened.errorMessage)
        try FileManager.default.setAttributes([.posixPermissions: 0o700], ofItemAtPath: captures.path)
        reopened.retryKeepingRecording()
        XCTAssertNotNil(reopened.errorMessage)
        XCTAssertTrue(reopened.hasPendingRecording)
        XCTAssertEqual(try Data(contentsOf: source), Data("replacement worth keeping ".utf8))
        XCTAssertTrue(FileManager.default.fileExists(atPath: pending.path))
        try FileManager.default.moveItem(at: unavailable, to: retained)
        reopened.retryKeepingRecording()
        XCTAssertNil(reopened.errorMessage)
        XCTAssertFalse(reopened.hasPendingRecording)
        XCTAssertEqual(try Data(contentsOf: XCTUnwrap(reopened.currentAudioURL)), Data("replacement worth keeping ".utf8))
        XCTAssertFalse(FileManager.default.fileExists(atPath: source.path))
        XCTAssertFalse(FileManager.default.fileExists(atPath: pending.path))
    }

    func testInterruptionDuringPermissionRequestRequiresANewParentRecordAction() async throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let audio = DeterministicAudio()
        let requested = expectation(description: "Microphone permission requested")
        var permissionResponse: CheckedContinuation<Bool, Never>?
        audio.permissionRequest = {
            await withCheckedContinuation { continuation in
                permissionResponse = continuation
                requested.fulfill()
            }
        }
        let workflow = try StoryWorkflow(storageURL: root, audio: audio)
        let starting = Task { await workflow.startRecording() }
        await fulfillment(of: [requested], timeout: 2)
        XCTAssertEqual(workflow.captureState, .requestingPermission)
        workflow.handleInterruption()
        permissionResponse?.resume(returning: true)
        await starting.value
        XCTAssertEqual(workflow.captureState, .idle)
        XCTAssertNotNil(workflow.errorMessage)
        XCTAssertFalse(workflow.hasPendingRecording)
        XCTAssertTrue(workflow.stories.isEmpty)
        audio.permissionRequest = nil
        await workflow.startRecording()
        XCTAssertEqual(workflow.captureState, .recording)
        workflow.stopRecording()
        XCTAssertNotNil(workflow.currentStory)
    }

    func testCorruptRetainedAudioIsReportedOnOpenAndCannotClaimSuccessfulSave() async throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let initial = try StoryWorkflow(storageURL: root, audio: DeterministicAudio())
        await initial.startRecording()
        initial.stopRecording()
        let id = try XCTUnwrap(initial.currentStory?.id)
        let url = try XCTUnwrap(initial.currentAudioURL)
        let bundled = try XCTUnwrap(DemoLibrary.bundled().audioURLs.values.first)
        let goodAudio = try Data(contentsOf: bundled)
        try Data("corrupt audio header".utf8).write(to: url)
        let workflow = try StoryWorkflow(storageURL: root, audio: NativeStoryAudio())
        workflow.openStory(id: id)
        XCTAssertNotNil(workflow.errorMessage)
        XCTAssertFalse(workflow.isPlaying)
        workflow.title = "My recovered story"
        workflow.transcript = "Keep my manual text"
        workflow.savePrivately()
        XCTAssertNotNil(workflow.errorMessage)
        XCTAssertEqual(workflow.currentStory?.isSaved, false)
        XCTAssertEqual(workflow.transcript, "Keep my manual text")
        try goodAudio.write(to: url)
        workflow.savePrivately()
        XCTAssertNil(workflow.errorMessage)
        let reopened = try StoryWorkflow(storageURL: root, audio: NativeStoryAudio())
        reopened.openStory(id: id)
        XCTAssertNil(reopened.errorMessage)
        XCTAssertEqual(reopened.title, "My recovered story")
        XCTAssertEqual(reopened.transcript, "Keep my manual text")
        XCTAssertEqual(reopened.currentStory?.isSaved, true)
        XCTAssertFalse(reopened.isPlaying)
    }

    func testFailedReplacementCommitPreservesOriginalUntilRetryDurablyRetainsNewVoice() async throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        var failWrites = false
        let audio = PausableAudio()
        let workflow = try StoryWorkflow(storageURL: root, audio: audio, commitChanges: { context in
            if failWrites { throw CocoaError(.fileWriteNoPermission) }
            try context.save()
        })
        await workflow.startRecording()
        try audio.speak("first take", lasting: 2)
        workflow.stopRecording()
        workflow.title = "The moon garden"
        workflow.creatorName = "Mama"
        workflow.theme = "Kindness"
        workflow.sourceLanguage = "English"
        workflow.transcript = "My manual text"
        workflow.savePrivately()
        let original = try XCTUnwrap(workflow.currentStory)
        let originalURL = try XCTUnwrap(workflow.currentAudioURL)
        await workflow.startReplacementRecording(confirmed: true)
        try audio.speak("second longer take", lasting: 5)
        failWrites = true
        workflow.handleInterruption()
        XCTAssertNotNil(workflow.errorMessage)
        XCTAssertFalse(workflow.errorMessage?.contains("kept as a private draft") == true)
        XCTAssertEqual(workflow.currentStory, original)
        XCTAssertTrue(workflow.hasPendingRecording)
        let unchanged = try StoryWorkflow(storageURL: root, audio: PausableAudio())
        unchanged.openStory(id: original.id)
        XCTAssertEqual(unchanged.currentStory, original)
        XCTAssertEqual(try Data(contentsOf: originalURL), Data("first take ".utf8))
        failWrites = false
        workflow.retryKeepingRecording()
        XCTAssertNil(workflow.errorMessage)
        XCTAssertFalse(workflow.hasPendingRecording)
        XCTAssertEqual(workflow.currentStory?.id, original.id)
        XCTAssertEqual(workflow.currentStory?.duration, 5)
        XCTAssertEqual(workflow.currentStory?.visibility, "private")
        let reopened = try StoryWorkflow(storageURL: root, audio: PausableAudio())
        reopened.openStory(id: original.id)
        XCTAssertEqual(reopened.stories.count, 1)
        XCTAssertEqual(reopened.currentStory?.duration, 5)
        XCTAssertEqual(reopened.currentStory?.createdAt, original.createdAt)
        XCTAssertEqual(reopened.title, "The moon garden")
        XCTAssertEqual(reopened.creatorName, "Mama")
        XCTAssertEqual(reopened.theme, "Kindness")
        XCTAssertEqual(reopened.sourceLanguage, "English")
        XCTAssertEqual(reopened.transcript, "My manual text")
        XCTAssertEqual(reopened.currentStory?.isSaved, true)
        XCTAssertEqual(try Data(contentsOf: XCTUnwrap(reopened.currentAudioURL)), Data("second longer take ".utf8))
        XCTAssertFalse(FileManager.default.fileExists(atPath: originalURL.path))
        reopened.deleteCurrentStory(confirmed: true)
        XCTAssertNil(reopened.errorMessage)
        for folder in ["Captures", "Recordings"] {
            XCTAssertEqual(try FileManager.default.contentsOfDirectory(atPath: root.appendingPathComponent(folder).path), [])
        }
    }

    func testReplacementRequiresConfirmationAndCancellationPreservesOriginalAndReviewEdits() async throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let audio = PausableAudio()
        let workflow = try StoryWorkflow(storageURL: root, audio: audio)
        await workflow.startRecording()
        try audio.speak("original voice", lasting: 2)
        workflow.stopRecording()
        workflow.title = "A family story"
        workflow.creatorName = "Mama"
        workflow.theme = "Courage"
        workflow.sourceLanguage = "English"
        workflow.transcript = "My own words"
        workflow.savePrivately()
        let original = try XCTUnwrap(workflow.currentStory)
        let originalURL = try XCTUnwrap(workflow.currentAudioURL)
        workflow.transcript = "An unfinished correction"
        await workflow.startReplacementRecording(confirmed: false)
        XCTAssertEqual(workflow.captureState, .stopped)
        XCTAssertFalse(workflow.hasPendingRecording)
        await workflow.startReplacementRecording(confirmed: true)
        try audio.speak("replacement voice", lasting: 4)
        XCTAssertEqual(workflow.currentStory, original)
        XCTAssertEqual(try Data(contentsOf: originalURL), Data("original voice ".utf8))
        workflow.cancelReplacementRecording()
        XCTAssertNil(workflow.errorMessage)
        XCTAssertEqual(workflow.currentStory, original)
        XCTAssertEqual(workflow.transcript, "An unfinished correction")
        XCTAssertFalse(workflow.hasPendingRecording)
        let reopened = try StoryWorkflow(storageURL: root, audio: PausableAudio())
        reopened.openStory(id: original.id)
        XCTAssertEqual(reopened.currentStory, original)
        XCTAssertEqual(try Data(contentsOf: XCTUnwrap(reopened.currentAudioURL)), Data("original voice ".utf8))
    }

    func testSavedPrivateStoryRequiresReviewAndConfirmationBeforeLocalDiscovery() async throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let workflow = try StoryWorkflow(storageURL: root, audio: DeterministicAudio())
        await workflow.startRecording()
        workflow.stopRecording()
        workflow.title = "The moon's garden"
        workflow.creatorName = "Mama"
        workflow.transcript = "The hare planted a seed."
        workflow.savePrivately()
        let saved = try XCTUnwrap(workflow.currentStory)
        XCTAssertTrue(workflow.communityStories.isEmpty)
        XCTAssertTrue(workflow.prepareCommunityPreview())
        XCTAssertEqual(workflow.communityPreview, saved)
        workflow.confirmCommunityPreview(confirmed: false)
        XCTAssertTrue(workflow.communityStories.isEmpty)
        XCTAssertEqual(workflow.currentStory?.visibility, "private")
        XCTAssertTrue(workflow.prepareCommunityPreview())
        workflow.confirmCommunityPreview(confirmed: true)
        XCTAssertNil(workflow.errorMessage)
        XCTAssertEqual(workflow.communityStories.map(\.id), [saved.id])
        let reopened = try StoryWorkflow(storageURL: root, audio: DeterministicAudio())
        XCTAssertEqual(reopened.communityStories.first?.title, "The moon's garden")
        XCTAssertEqual(reopened.communityStories.first?.creatorName, "Mama")
        XCTAssertEqual(reopened.communityStories.first?.transcript, "The hare planted a seed.")
        XCTAssertFalse(reopened.isPlaying)
    }

    func testWithdrawalRemovesDiscoveryAndRetainsPrivatePersonalCopyAfterRelaunch() async throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let workflow = try StoryWorkflow(storageURL: root, audio: DeterministicAudio())
        await workflow.startRecording(); workflow.stopRecording(); workflow.savePrivately()
        let id = try XCTUnwrap(workflow.currentStory?.id)
        XCTAssertTrue(workflow.prepareCommunityPreview())
        workflow.confirmCommunityPreview(confirmed: true)
        workflow.withdrawCommunityPreview()
        XCTAssertNil(workflow.errorMessage)
        XCTAssertTrue(workflow.communityStories.isEmpty)
        let reopened = try StoryWorkflow(storageURL: root, audio: DeterministicAudio())
        reopened.openStory(id: id)
        XCTAssertEqual(reopened.currentStory?.visibility, "private")
        XCTAssertEqual(reopened.currentStory?.isSaved, true)
        XCTAssertTrue(reopened.communityStories.isEmpty)
        XCTAssertEqual(try Data(contentsOf: XCTUnwrap(reopened.currentAudioURL)), Data("spoken narration".utf8))
    }

    func testKeepingEditsWithdrawsPreviouslyPreviewedContentUntilFreshReviewAndConsent() async throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let workflow = try StoryWorkflow(storageURL: root, audio: DeterministicAudio())
        await workflow.startRecording(); workflow.stopRecording(); workflow.savePrivately()
        XCTAssertTrue(workflow.prepareCommunityPreview())
        workflow.confirmCommunityPreview(confirmed: true)
        workflow.title = "A different story title"
        workflow.transcript = "Unreviewed personal details"
        XCTAssertEqual(workflow.communityStories.first?.title, "My new story")
        XCTAssertFalse(workflow.prepareCommunityPreview())
        XCTAssertTrue(workflow.resolveReviewExit(.keepChanges))
        XCTAssertTrue(workflow.communityStories.isEmpty)
        XCTAssertEqual(workflow.currentStory?.visibility, "private")
        let reopened = try StoryWorkflow(storageURL: root, audio: DeterministicAudio())
        XCTAssertTrue(reopened.communityStories.isEmpty)
        workflow.savePrivately()
        XCTAssertTrue(workflow.prepareCommunityPreview())
        XCTAssertEqual(workflow.communityPreview?.transcript, "Unreviewed personal details")
        workflow.confirmCommunityPreview(confirmed: true)
        XCTAssertEqual(workflow.communityStories.first?.title, "A different story title")
        XCTAssertEqual(workflow.communityStories.first?.transcript, "Unreviewed personal details")
    }

    func testEmptyOrMissingOriginalAudioCannotBecomeACommunityPreview() async throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let workflow = try StoryWorkflow(storageURL: root, audio: DeterministicAudio())
        await workflow.startRecording(); workflow.stopRecording(); workflow.savePrivately()
        let audioURL = try XCTUnwrap(workflow.currentAudioURL)
        try Data().write(to: audioURL)
        XCTAssertFalse(workflow.prepareCommunityPreview())
        XCTAssertNil(workflow.communityPreview)
        XCTAssertTrue(workflow.communityStories.isEmpty)
        try Data("spoken narration".utf8).write(to: audioURL)
        XCTAssertTrue(workflow.prepareCommunityPreview())
        try FileManager.default.removeItem(at: audioURL)
        workflow.confirmCommunityPreview(confirmed: true)
        XCTAssertNotNil(workflow.errorMessage)
        XCTAssertTrue(workflow.communityStories.isEmpty)
        XCTAssertEqual(workflow.currentStory?.visibility, "private")
    }

    func testFailedPreviewAndWithdrawalWritesNeverClaimChangedVisibility() async throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        var storageUnavailable = false
        let workflow = try StoryWorkflow(storageURL: root, audio: DeterministicAudio(), commitChanges: { context in
            if storageUnavailable { throw CocoaError(.fileWriteNoPermission) }
            try context.save()
        })
        await workflow.startRecording(); workflow.stopRecording(); workflow.savePrivately()
        XCTAssertTrue(workflow.prepareCommunityPreview())
        storageUnavailable = true
        workflow.confirmCommunityPreview(confirmed: true)
        XCTAssertNotNil(workflow.errorMessage)
        XCTAssertEqual(workflow.currentStory?.visibility, "private")
        XCTAssertTrue(workflow.communityStories.isEmpty)
        XCTAssertTrue(try StoryWorkflow(storageURL: root, audio: DeterministicAudio()).communityStories.isEmpty)
        storageUnavailable = false
        workflow.confirmCommunityPreview(confirmed: true)
        XCTAssertNil(workflow.errorMessage)
        XCTAssertEqual(workflow.communityStories.count, 1)
        storageUnavailable = true
        workflow.transcript = "Unsaved new personal content"
        workflow.savePrivately()
        XCTAssertNotNil(workflow.errorMessage)
        XCTAssertEqual(workflow.communityStories.first?.transcript, "")
        XCTAssertEqual(workflow.currentStory?.visibility, "localPreview")
        workflow.withdrawCommunityPreview()
        XCTAssertNotNil(workflow.errorMessage)
        XCTAssertEqual(workflow.communityStories.count, 1)
        XCTAssertEqual(try StoryWorkflow(storageURL: root, audio: DeterministicAudio()).communityStories.count, 1)
        storageUnavailable = false
        workflow.withdrawCommunityPreview()
        XCTAssertNil(workflow.errorMessage)
        XCTAssertTrue(workflow.communityStories.isEmpty)
        XCTAssertEqual(workflow.currentStory?.transcript, "")
        XCTAssertEqual(workflow.transcript, "Unsaved new personal content")
        XCTAssertTrue(workflow.hasUnsavedReviewChanges)
    }

    func testDraftAndStaleReviewCannotBypassFreshConsentOrIncludeCoachingContext() async throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let workflow = try StoryWorkflow(storageURL: root, audio: DeterministicAudio())
        await workflow.coaching.begin(approach: .listener, text: "PRIVATE child preference")
        await workflow.coaching.answer("PRIVATE coaching answer")
        await workflow.startRecording(); workflow.stopRecording()
        XCTAssertFalse(workflow.prepareCommunityPreview())
        workflow.savePrivately()
        XCTAssertTrue(workflow.prepareCommunityPreview())
        workflow.transcript = "New personal text has not been reviewed"
        workflow.confirmCommunityPreview(confirmed: true)
        XCTAssertNotNil(workflow.errorMessage)
        XCTAssertNil(workflow.communityPreview)
        XCTAssertTrue(workflow.communityStories.isEmpty)
        XCTAssertTrue(workflow.resolveReviewExit(.discardChanges))
        XCTAssertTrue(workflow.prepareCommunityPreview())
        workflow.confirmCommunityPreview(confirmed: true)
        let visible = try XCTUnwrap(workflow.communityStories.first)
        XCTAssertEqual(visible.title, "My new story")
        XCTAssertEqual(visible.creatorName, "")
        XCTAssertEqual(visible.theme, "")
        XCTAssertEqual(visible.sourceLanguage, "")
        XCTAssertEqual(visible.transcript, "")
        let reopened = try StoryWorkflow(storageURL: root, audio: DeterministicAudio())
        XCTAssertEqual(reopened.communityStories, [visible])
        XCTAssertNil(reopened.coaching.context)
    }

    func testDeletingAnOwnedPreviewRequiresConfirmationAndNeverDeletesBundledDemos() async throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let workflow = try StoryWorkflow(storageURL: root, audio: DeterministicAudio())
        let demos = workflow.demoStories
        await workflow.startRecording(); workflow.stopRecording(); workflow.savePrivately()
        let audioURL = try XCTUnwrap(workflow.currentAudioURL)
        XCTAssertTrue(workflow.prepareCommunityPreview())
        workflow.confirmCommunityPreview(confirmed: true)
        workflow.deleteCurrentStory(confirmed: false)
        XCTAssertEqual(workflow.communityStories.count, 1)
        XCTAssertTrue(FileManager.default.fileExists(atPath: audioURL.path))
        workflow.deleteCurrentStory(confirmed: true)
        XCTAssertNil(workflow.errorMessage)
        XCTAssertTrue(workflow.communityStories.isEmpty)
        XCTAssertTrue(workflow.stories.isEmpty)
        XCTAssertFalse(FileManager.default.fileExists(atPath: audioURL.path))
        XCTAssertEqual(workflow.demoStories, demos)
        for demo in demos {
            workflow.openDemoStory(id: demo.id)
            workflow.playDemo()
            XCTAssertNil(workflow.demoPlaybackError)
            XCTAssertTrue(workflow.isPlaying)
        }
        let reopened = try StoryWorkflow(storageURL: root, audio: DeterministicAudio())
        XCTAssertTrue(reopened.communityStories.isEmpty)
        XCTAssertEqual(reopened.demoStories, demos)
    }

    func testFailedDeleteRestoresOwnedAudioAndTextUntilDeletionCanBeRetried() async throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        var storageUnavailable = false
        let workflow = try StoryWorkflow(storageURL: root, audio: DeterministicAudio(), commitChanges: { context in
            if storageUnavailable { throw CocoaError(.fileWriteNoPermission) }
            try context.save()
        })
        await workflow.startRecording()
        workflow.stopRecording()
        workflow.title = "A story worth keeping"
        workflow.transcript = "The hare came home."
        workflow.savePrivately()
        let id = try XCTUnwrap(workflow.currentStory?.id)
        let audioURL = try XCTUnwrap(workflow.currentAudioURL)
        storageUnavailable = true
        workflow.deleteCurrentStory(confirmed: true)
        XCTAssertNotNil(workflow.errorMessage)
        XCTAssertEqual(workflow.currentStory?.id, id)
        let unchanged = try StoryWorkflow(storageURL: root, audio: DeterministicAudio())
        unchanged.openStory(id: id)
        XCTAssertEqual(unchanged.title, "A story worth keeping")
        XCTAssertEqual(unchanged.transcript, "The hare came home.")
        XCTAssertEqual(try Data(contentsOf: audioURL), Data("spoken narration".utf8))
        storageUnavailable = false
        workflow.deleteCurrentStory(confirmed: true)
        XCTAssertNil(workflow.errorMessage)
        XCTAssertNil(workflow.currentStory)
        XCTAssertFalse(FileManager.default.fileExists(atPath: audioURL.path))
        let reopened = try StoryWorkflow(storageURL: root, audio: DeterministicAudio())
        XCTAssertTrue(reopened.stories.isEmpty)
    }

    func testBlankTitleValidationKeepsReviewEditsAndRecordingForCorrection() async throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let workflow = try StoryWorkflow(storageURL: root, audio: DeterministicAudio())
        await workflow.startRecording()
        workflow.stopRecording()
        workflow.title = " \n "
        workflow.transcript = "My own text"
        workflow.savePrivately()
        XCTAssertNotNil(workflow.errorMessage)
        XCTAssertEqual(workflow.currentStory?.isSaved, false)
        XCTAssertEqual(workflow.transcript, "My own text")
        workflow.title = "The first seed"
        workflow.savePrivately()
        XCTAssertNil(workflow.errorMessage)
        XCTAssertEqual(workflow.currentStory?.isSaved, true)
        XCTAssertEqual(try Data(contentsOf: XCTUnwrap(workflow.currentAudioURL)), Data("spoken narration".utf8))
    }
    func testDeletionRequiresConfirmationAndPreservesSharedAndDemoAssets() async throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let initial = try StoryWorkflow(storageURL: root, audio: DeterministicAudio())
        await initial.startRecording()
        initial.stopRecording()
        let original = try XCTUnwrap(initial.currentStory)
        let sharedURL = try XCTUnwrap(initial.currentAudioURL)
        let demoURL = root.appendingPathComponent("Recordings/Demo/shared.m4a")
        try FileManager.default.createDirectory(at: demoURL.deletingLastPathComponent(), withIntermediateDirectories: true)
        try Data("permission-cleared demo".utf8).write(to: demoURL)
        let container = try ModelContainer(for: StoryRecord.self, configurations:
            ModelConfiguration(url: root.appendingPathComponent("Stories.sqlite"), cloudKitDatabase: .none))
        let context = ModelContext(container)
        let shared = Story(id: UUID(), title: "Shared recording", audioName: original.audioName, duration: 3,
                       isSaved: true, visibility: "private", createdAt: Date(), updatedAt: Date())
        let demo = Story(id: UUID(), title: "Demo", audioName: "Demo/shared.m4a", duration: 3,
                         isSaved: true, visibility: "private", createdAt: Date(), updatedAt: Date())
        context.insert(StoryRecord(shared)); context.insert(StoryRecord(demo))
        try context.save()
        let workflow = try StoryWorkflow(storageURL: root, audio: DeterministicAudio())
        workflow.openStory(id: original.id)
        workflow.deleteCurrentStory(confirmed: false)
        XCTAssertEqual(workflow.currentStory?.id, original.id)
        XCTAssertEqual(workflow.stories.count, 3)
        workflow.deleteCurrentStory(confirmed: true)
        XCTAssertNil(workflow.errorMessage)
        XCTAssertFalse(workflow.stories.contains { $0.id == original.id })
        XCTAssertEqual(try Data(contentsOf: sharedURL), Data("spoken narration".utf8))
        workflow.openStory(id: demo.id)
        workflow.deleteCurrentStory(confirmed: true)
        XCTAssertNil(workflow.errorMessage)
        XCTAssertEqual(try Data(contentsOf: demoURL), Data("permission-cleared demo".utf8))
        XCTAssertEqual(workflow.stories.map(\.id), [shared.id])
    }
    func testFailedMetadataWriteKeepsEditsForRetryAndNeverClaimsSuccessfulExit() async throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        var storageUnavailable = false
        let workflow = try StoryWorkflow(storageURL: root, audio: DeterministicAudio(), commitChanges: { context in
            if storageUnavailable { throw CocoaError(.fileWriteNoPermission) }
            try context.save()
        })
        await workflow.startRecording()
        workflow.stopRecording()
        let id = try XCTUnwrap(workflow.currentStory?.id)
        workflow.title = "Tomorrow's story"
        workflow.transcript = "The garden woke."
        storageUnavailable = true
        XCTAssertFalse(workflow.resolveReviewExit(.keepChanges))
        XCTAssertNotNil(workflow.errorMessage)
        XCTAssertEqual(workflow.transcript, "The garden woke.")
        XCTAssertTrue(workflow.hasUnsavedReviewChanges)
        let unchanged = try StoryWorkflow(storageURL: root, audio: DeterministicAudio())
        unchanged.openStory(id: id)
        XCTAssertEqual(unchanged.title, "My new story")
        XCTAssertEqual(unchanged.transcript, "")
        XCTAssertEqual(unchanged.currentStory?.isSaved, false)
        storageUnavailable = false
        XCTAssertTrue(workflow.resolveReviewExit(.keepChanges))
        let reopened = try StoryWorkflow(storageURL: root, audio: DeterministicAudio())
        reopened.openStory(id: id)
        XCTAssertEqual(reopened.title, "Tomorrow's story")
        XCTAssertEqual(reopened.transcript, "The garden woke.")
        XCTAssertEqual(reopened.currentStory?.isSaved, false)
    }
    func testReviewExitCancelPreservesEditsAndDiscardOnlyRemovesUnsavedChanges() async throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let workflow = try StoryWorkflow(storageURL: root, audio: DeterministicAudio())
        await workflow.startRecording()
        workflow.stopRecording()
        workflow.title = "Kept title"
        workflow.transcript = "Kept text"
        workflow.savePrivately()
        let id = try XCTUnwrap(workflow.currentStory?.id)
        workflow.title = "Unfinished title"
        workflow.transcript = "Unfinished text"
        XCTAssertTrue(workflow.hasUnsavedReviewChanges)
        XCTAssertFalse(workflow.resolveReviewExit(.cancel))
        XCTAssertEqual(workflow.transcript, "Unfinished text")
        XCTAssertTrue(workflow.resolveReviewExit(.discardChanges))
        XCTAssertEqual(workflow.title, "Kept title")
        XCTAssertEqual(workflow.transcript, "Kept text")
        XCTAssertFalse(workflow.hasUnsavedReviewChanges)
        let reopened = try StoryWorkflow(storageURL: root, audio: DeterministicAudio())
        reopened.openStory(id: id)
        XCTAssertEqual(reopened.currentStory?.isSaved, true)
        XCTAssertEqual(reopened.transcript, "Kept text")
        XCTAssertEqual(try Data(contentsOf: XCTUnwrap(reopened.currentAudioURL)), Data("spoken narration".utf8))
    }
    func testManualReviewEditsSaveAndReopenWithoutChangingOriginalNarration() async throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let workflow = try StoryWorkflow(storageURL: root, audio: DeterministicAudio())
        await workflow.startRecording()
        workflow.stopRecording()
        let id = try XCTUnwrap(workflow.currentStory?.id)
        workflow.title = "The moon's garden"
        workflow.creatorName = "Mama"
        workflow.theme = "Kindness"
        workflow.sourceLanguage = "isiZulu"
        workflow.transcript = "A little hare planted a seed."
        workflow.savePrivately()
        let reopened = try StoryWorkflow(storageURL: root, audio: DeterministicAudio())
        reopened.openStory(id: id)
        XCTAssertEqual(reopened.title, "The moon's garden")
        XCTAssertEqual(reopened.creatorName, "Mama")
        XCTAssertEqual(reopened.theme, "Kindness")
        XCTAssertEqual(reopened.sourceLanguage, "isiZulu")
        XCTAssertEqual(reopened.transcript, "A little hare planted a seed.")
        XCTAssertEqual(reopened.currentStory?.isSaved, true)
        XCTAssertEqual(reopened.currentStory?.visibility, "private")
        XCTAssertEqual(try Data(contentsOf: XCTUnwrap(reopened.currentAudioURL)), Data("spoken narration".utf8))
    }
    // Each case has an isolated OS-temporary workspace. Do not unlink live SQLite
    // files in defer: SwiftData may retain their descriptors until host teardown.

    func testPauseResumeKeepsBothSegmentsInOneSavedNarrationAndExcludesTheBreak() async throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let audio = PausableAudio()
        let workflow = try StoryWorkflow(storageURL: root, audio: audio)
        await workflow.startRecording()
        try audio.speak("beginning", lasting: 2)
        workflow.pauseRecording()
        XCTAssertEqual(workflow.captureState, .paused)
        XCTAssertEqual(workflow.elapsedRecording, 2)
        XCTAssertFalse(workflow.canLeaveReview)
        audio.wait(seconds: 7)
        XCTAssertEqual(workflow.elapsedRecording, 2)
        workflow.resumeRecording()
        XCTAssertEqual(workflow.captureState, .recording)
        try audio.speak("ending", lasting: 3)
        workflow.stopRecording()
        let draft = try XCTUnwrap(workflow.currentStory)
        XCTAssertEqual(draft.duration, 5)
        workflow.savePrivately()
        let reopened = try StoryWorkflow(storageURL: root, audio: PausableAudio())
        XCTAssertEqual(reopened.stories.count, 1)
        reopened.openStory(id: draft.id)
        XCTAssertEqual(reopened.currentStory?.duration, 5)
        XCTAssertEqual(try Data(contentsOf: XCTUnwrap(reopened.currentAudioURL)), Data("beginning ending ".utf8))
    }

    func testInterruptionWhilePausedKeepsTheTakeWithoutRestartingTheMicrophone() async throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let audio = PausableAudio()
        let workflow = try StoryWorkflow(storageURL: root, audio: audio)
        await workflow.startRecording()
        try audio.speak("before interruption", lasting: 2)
        workflow.pauseRecording()
        workflow.handleInterruption()
        XCTAssertEqual(workflow.captureState, .stopped)
        XCTAssertNotNil(workflow.errorMessage)
        let draft = try XCTUnwrap(workflow.currentStory)
        XCTAssertEqual(draft.duration, 2)
        workflow.resumeRecording()
        XCTAssertEqual(workflow.captureState, .stopped)
        XCTAssertEqual(try Data(contentsOf: XCTUnwrap(workflow.currentAudioURL)), Data("before interruption ".utf8))
    }

    func testDiscardingAPausedTakeClosesCaptureBeforeStartingAnotherStory() async throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let audio = PausableAudio()
        let workflow = try StoryWorkflow(storageURL: root, audio: audio)
        await workflow.startRecording()
        try audio.speak("discard me", lasting: 2)
        workflow.pauseRecording()
        workflow.discardRecording()
        XCTAssertEqual(workflow.captureState, .idle)
        await workflow.startRecording()
        XCTAssertEqual(workflow.captureState, .recording)
        try audio.speak("keep me", lasting: 3)
        workflow.stopRecording()
        XCTAssertEqual(workflow.stories.count, 1)
        XCTAssertEqual(try Data(contentsOf: XCTUnwrap(workflow.currentAudioURL)), Data("keep me ".utf8))
    }

    func testRepeatedAndOutOfOrderActionsPreserveTheActiveNarration() async throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let audio = PausableAudio()
        let workflow = try StoryWorkflow(storageURL: root, audio: audio)
        workflow.pauseRecording(); workflow.resumeRecording(); workflow.stopRecording()
        await workflow.startRecording()
        workflow.resumeRecording()
        try audio.speak("beginning", lasting: 2)
        workflow.retryKeepingRecording()
        XCTAssertEqual(workflow.captureState, .recording)
        XCTAssertNil(workflow.currentStory)
        workflow.pauseRecording(); workflow.pauseRecording()
        await workflow.startRecording()
        workflow.keepDraft(); workflow.savePrivately()
        XCTAssertEqual(workflow.captureState, .paused)
        XCTAssertNil(workflow.currentStory)
        workflow.resumeRecording(); workflow.resumeRecording()
        try audio.speak("ending", lasting: 3)
        workflow.stopRecording(); workflow.stopRecording(); workflow.resumeRecording()
        XCTAssertEqual(workflow.captureState, .stopped)
        XCTAssertEqual(workflow.stories.count, 1)
        XCTAssertEqual(workflow.currentStory?.duration, 5)
        XCTAssertEqual(try Data(contentsOf: XCTUnwrap(workflow.currentAudioURL)), Data("beginning ending ".utf8))
    }

    func testPauseFailurePreservesFinalizationErrorAndTheTakeCanBeRecovered() async throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let audio = PausableAudio()
        let workflow = try StoryWorkflow(storageURL: root, audio: audio)
        await workflow.startRecording()
        try audio.speak("keep this narration", lasting: 2)
        audio.pauseError = NSError(domain: "AudioBoundary", code: 1, userInfo: [NSLocalizedDescriptionKey: "Pause unavailable"])
        audio.finishError = NSError(domain: "AudioBoundary", code: 2, userInfo: [NSLocalizedDescriptionKey: "Finalization unavailable"])
        workflow.pauseRecording()
        XCTAssertEqual(workflow.captureState, .failed)
        XCTAssertNil(workflow.currentStory)
        XCTAssertTrue(workflow.hasPendingRecording)
        XCTAssertTrue(workflow.errorMessage?.contains("Finalization unavailable") == true)
        audio.finishError = nil
        workflow.retryKeepingRecording()
        XCTAssertNil(workflow.errorMessage)
        XCTAssertEqual(workflow.captureState, .stopped)
        XCTAssertEqual(workflow.currentStory?.duration, 2)
        XCTAssertEqual(try Data(contentsOf: XCTUnwrap(workflow.currentAudioURL)), Data("keep this narration ".utf8))
    }

    func testFailedDraftWriteCanBeRetriedWithoutLosingTheTakeOrIdentity() async throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let workflow = try StoryWorkflow(storageURL: root, audio: DeterministicAudio())
        await workflow.startRecording()
        // An actual filesystem obstruction, rather than mocking our repository.
        let recordings = root.appendingPathComponent("Recordings")
        try Data("blocked directory".utf8).write(to: recordings)
        workflow.stopRecording()
        let recoverableDraft = try XCTUnwrap(workflow.currentStory)
        XCTAssertNotNil(workflow.errorMessage)
        XCTAssertTrue(workflow.hasPendingRecording)
        XCTAssertFalse(workflow.canLeaveReview)
        try FileManager.default.removeItem(at: recordings)
        workflow.retryKeepingRecording()
        let draft = try XCTUnwrap(workflow.currentStory)
        XCTAssertNil(workflow.errorMessage)
        XCTAssertTrue(workflow.canLeaveReview)
        let reopened = try StoryWorkflow(storageURL: root, audio: DeterministicAudio())
        reopened.openStory(id: draft.id)
        XCTAssertEqual(reopened.currentStory, draft)
        XCTAssertEqual(draft.id, recoverableDraft.id)
        XCTAssertEqual(try Data(contentsOf: XCTUnwrap(reopened.currentAudioURL)), Data("spoken narration".utf8))
    }

    func testKeepingReviewEditsRetainsPrivateDraftBeforeRelaunch() async throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let workflow = try StoryWorkflow(storageURL: root, audio: DeterministicAudio())
        await workflow.startRecording()
        workflow.stopRecording()
        let id = try XCTUnwrap(workflow.currentStory?.id)
        workflow.title = "A story for tomorrow"
        workflow.keepDraft()
        let reopened = try StoryWorkflow(storageURL: root, audio: DeterministicAudio())
        reopened.openStory(id: id)
        XCTAssertEqual(reopened.title, "A story for tomorrow")
        XCTAssertEqual(reopened.currentStory?.isSaved, false)
        XCTAssertEqual(reopened.currentStory?.visibility, "private")
    }

    func testExplicitDiscardRemovesTheDraftAndItsOwnedRecording() async throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let workflow = try StoryWorkflow(storageURL: root, audio: DeterministicAudio())
        await workflow.startRecording()
        workflow.stopRecording()
        let audioURL = try XCTUnwrap(workflow.currentAudioURL)
        workflow.discardRecording()
        XCTAssertNil(workflow.currentStory)
        XCTAssertFalse(FileManager.default.fileExists(atPath: audioURL.path))
        let reopened = try StoryWorkflow(storageURL: root, audio: DeterministicAudio())
        XCTAssertTrue(reopened.stories.isEmpty)
    }

    func testDeniedMicrophoneNeverEntersRecordingAndCanRetryAfterAccessChanges() async throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let audio = DeterministicAudio()
        audio.permissionGranted = false
        let workflow = try StoryWorkflow(storageURL: root, audio: audio)
        await workflow.startRecording()
        XCTAssertEqual(workflow.captureState, .idle)
        XCTAssertTrue(workflow.permissionDenied)
        XCTAssertNotNil(workflow.errorMessage)
        XCTAssertFalse(workflow.hasPendingRecording)
        XCTAssertTrue(workflow.stories.isEmpty)
        audio.permissionGranted = true
        await workflow.startRecording()
        XCTAssertEqual(workflow.captureState, .recording)
        XCTAssertFalse(workflow.permissionDenied)
        workflow.stopRecording()
        XCTAssertNotNil(workflow.currentStory)
    }

    func testEmptyTakeCannotBeSavedAndExplicitDiscardAllowsANewRecording() async throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let audio = DeterministicAudio()
        audio.captureDuration = 0
        let workflow = try StoryWorkflow(storageURL: root, audio: audio)
        await workflow.startRecording()
        workflow.stopRecording()
        workflow.savePrivately()
        XCTAssertNil(workflow.currentStory)
        XCTAssertNotNil(workflow.errorMessage)
        XCTAssertTrue(workflow.stories.isEmpty)
        workflow.discardRecording()
        audio.captureDuration = 3
        await workflow.startRecording()
        workflow.stopRecording()
        XCTAssertNotNil(workflow.currentStory)
        XCTAssertNil(workflow.errorMessage)
    }

    func testUnavailableAudioDoesNotClaimASuccessfulSaveAndCanRetryWithTheSameDraft() async throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let workflow = try StoryWorkflow(storageURL: root, audio: DeterministicAudio())
        await workflow.startRecording()
        workflow.stopRecording()
        let draft = try XCTUnwrap(workflow.currentStory)
        let audioURL = try XCTUnwrap(workflow.currentAudioURL)
        let unavailable = root.appendingPathComponent("unavailable.m4a")
        try FileManager.default.moveItem(at: audioURL, to: unavailable)
        workflow.title = "Still my story"
        workflow.savePrivately()
        XCTAssertNotNil(workflow.errorMessage)
        XCTAssertEqual(workflow.currentStory?.isSaved, false)
        XCTAssertEqual(workflow.title, "Still my story")
        try FileManager.default.moveItem(at: unavailable, to: audioURL)
        workflow.savePrivately()
        let reopened = try StoryWorkflow(storageURL: root, audio: DeterministicAudio())
        reopened.openStory(id: draft.id)
        XCTAssertEqual(reopened.currentStory?.isSaved, true)
        XCTAssertEqual(reopened.title, "Still my story")
        XCTAssertEqual(try Data(contentsOf: XCTUnwrap(reopened.currentAudioURL)), Data("spoken narration".utf8))
    }

    func testFailedDiscardKeepsTheDraftAndAudioAvailable() async throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let recordings = root.appendingPathComponent("Recordings")
        defer {
            try? FileManager.default.setAttributes([.posixPermissions: 0o700], ofItemAtPath: recordings.path)
        }
        let workflow = try StoryWorkflow(storageURL: root, audio: DeterministicAudio())
        await workflow.startRecording()
        workflow.stopRecording()
        let id = try XCTUnwrap(workflow.currentStory?.id)
        try FileManager.default.setAttributes([.posixPermissions: 0o500], ofItemAtPath: recordings.path)
        workflow.discardRecording()
        XCTAssertNotNil(workflow.errorMessage)
        XCTAssertEqual(workflow.currentStory?.id, id)
        let reopened = try StoryWorkflow(storageURL: root, audio: DeterministicAudio())
        reopened.openStory(id: id)
        XCTAssertEqual(reopened.currentStory?.id, id)
        XCTAssertEqual(try Data(contentsOf: XCTUnwrap(reopened.currentAudioURL)), Data("spoken narration".utf8))
    }

    func testPartialDestinationIsNeverReportedAsTheRetainedNarration() async throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let workflow = try StoryWorkflow(storageURL: root, audio: DeterministicAudio())
        await workflow.startRecording()
        let capture = try XCTUnwrap(FileManager.default.contentsOfDirectory(at: root.appendingPathComponent("Captures"), includingPropertiesForKeys: nil).first)
        let recordings = root.appendingPathComponent("Recordings")
        try FileManager.default.createDirectory(at: recordings, withIntermediateDirectories: true)
        try Data("part".utf8).write(to: recordings.appendingPathComponent(capture.lastPathComponent))
        workflow.stopRecording()
        XCTAssertNil(workflow.errorMessage)
        XCTAssertEqual(try Data(contentsOf: XCTUnwrap(workflow.currentAudioURL)), Data("spoken narration".utf8))
    }

    func testSourceCleanupFailureRemainsOwnedAfterRelaunchAndExplicitDiscard() async throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let captures = root.appendingPathComponent("Captures")
        defer { try? FileManager.default.setAttributes([.posixPermissions: 0o700], ofItemAtPath: captures.path) }
        let workflow = try StoryWorkflow(storageURL: root, audio: DeterministicAudio())
        await workflow.startRecording()
        let original = try XCTUnwrap(FileManager.default.contentsOfDirectory(at: captures, includingPropertiesForKeys: nil).first)
        try FileManager.default.setAttributes([.posixPermissions: 0o500], ofItemAtPath: captures.path)
        workflow.stopRecording()
        let draft = try XCTUnwrap(workflow.currentStory)
        XCTAssertNotNil(workflow.errorMessage)
        XCTAssertEqual(try Data(contentsOf: XCTUnwrap(workflow.currentAudioURL)), Data("spoken narration".utf8))
        let staging = root.appendingPathComponent("Recordings/\(draft.id.uuidString).pending")
        try Data("retained staging narration".utf8).write(to: staging)
        let reopened = try StoryWorkflow(storageURL: root, audio: DeterministicAudio())
        reopened.openStory(id: draft.id)
        reopened.discardRecording()
        XCTAssertNotNil(reopened.errorMessage)
        XCTAssertEqual(reopened.currentStory?.id, draft.id)
        XCTAssertTrue(FileManager.default.fileExists(atPath: original.path))
        XCTAssertTrue(FileManager.default.fileExists(atPath: staging.path))
        try FileManager.default.setAttributes([.posixPermissions: 0o700], ofItemAtPath: captures.path)
        reopened.discardRecording()
        XCTAssertNil(reopened.errorMessage)
        XCTAssertFalse(FileManager.default.fileExists(atPath: original.path))
        XCTAssertFalse(FileManager.default.fileExists(atPath: staging.path))
        XCTAssertTrue(reopened.stories.isEmpty)
    }

    func testFailedPromotionStagingRemainsOwnedAfterRelaunchAndExplicitDiscard() async throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let recordings = root.appendingPathComponent("Recordings")
        defer { try? FileManager.default.setAttributes([.posixPermissions: 0o700], ofItemAtPath: recordings.path) }
        let workflow = try StoryWorkflow(storageURL: root, audio: DeterministicAudio())
        await workflow.startRecording()
        let original = try XCTUnwrap(FileManager.default.contentsOfDirectory(at: root.appendingPathComponent("Captures"), includingPropertiesForKeys: nil).first)
        let staging = recordings.appendingPathComponent(original.deletingPathExtension().lastPathComponent + ".pending")
        try FileManager.default.createDirectory(at: recordings, withIntermediateDirectories: true)
        try Data("partial spoken narration".utf8).write(to: staging)
        try FileManager.default.setAttributes([.posixPermissions: 0o500], ofItemAtPath: recordings.path)
        workflow.stopRecording()
        let draft = try XCTUnwrap(workflow.currentStory)
        XCTAssertNotNil(workflow.errorMessage)
        let reopened = try StoryWorkflow(storageURL: root, audio: DeterministicAudio())
        reopened.openStory(id: draft.id)
        XCTAssertEqual(try Data(contentsOf: XCTUnwrap(reopened.currentAudioURL)), Data("spoken narration".utf8))
        reopened.discardRecording()
        XCTAssertNotNil(reopened.errorMessage)
        XCTAssertEqual(reopened.currentStory?.id, draft.id)
        XCTAssertTrue(FileManager.default.fileExists(atPath: staging.path))
        try FileManager.default.setAttributes([.posixPermissions: 0o700], ofItemAtPath: recordings.path)
        reopened.discardRecording()
        XCTAssertNil(reopened.errorMessage)
        XCTAssertFalse(FileManager.default.fileExists(atPath: staging.path))
        XCTAssertFalse(FileManager.default.fileExists(atPath: original.path))
        XCTAssertTrue(reopened.stories.isEmpty)
    }

    func testFirstInstalledAppRecordingAndEditsReopenWithoutResettingItsStore() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let id = UUID(uuidString: "113F70C1-DF52-4D97-A2B5-E090CDE63D31")!
        let originalTitle = "My first recorded family story"
        let filename = id.uuidString + ".m4a"
        let folder = root.appendingPathComponent("Recordings")
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        try Data("original installed-app narration".utf8).write(to: folder.appendingPathComponent(filename))
        let date = Date(timeIntervalSince1970: 1_795_000_000)
        // Persist the actual original entity shape, then release its container.
        // This catches incompatible additions rather than merely testing new rows.
        try autoreleasepool {
            let legacyContainer = try ModelContainer(for: FirstInstalledModel.StoryRecord.self, configurations:
                ModelConfiguration(url: root.appendingPathComponent("Stories.sqlite"), cloudKitDatabase: .none))
            let legacyContext = ModelContext(legacyContainer)
            legacyContext.insert(FirstInstalledModel.StoryRecord(id: id, title: originalTitle, audioName: filename, date: date))
            try legacyContext.save()
        }
        let workflow = try StoryWorkflow(storageURL: root, audio: DeterministicAudio())
        workflow.openStory(id: id)
        XCTAssertEqual(workflow.title, originalTitle)
        XCTAssertEqual(workflow.currentStory?.visibility, "private")
        XCTAssertEqual(workflow.currentStory?.createdAt, date)
        XCTAssertEqual(workflow.currentStory?.isSaved, true)
        XCTAssertEqual(workflow.creatorName, "")
        XCTAssertEqual(workflow.theme, "")
        XCTAssertEqual(workflow.sourceLanguage, "")
        XCTAssertEqual(workflow.transcript, "")
        XCTAssertEqual(try Data(contentsOf: XCTUnwrap(workflow.currentAudioURL)), Data("original installed-app narration".utf8))
        workflow.title = "My edited family story"
        workflow.savePrivately()
        let reopened = try StoryWorkflow(storageURL: root, audio: DeterministicAudio())
        reopened.openStory(id: id)
        XCTAssertEqual(reopened.title, "My edited family story")
        XCTAssertEqual(reopened.currentStory?.id, id)
        XCTAssertEqual(reopened.currentStory?.visibility, "private")
        XCTAssertEqual(try Data(contentsOf: XCTUnwrap(reopened.currentAudioURL)), Data("original installed-app narration".utf8))
    }

    func testStoppedNarrationIsPrivateAndSurvivesSaveAndRelaunch() async throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let audio = DeterministicAudio()
        let workflow = try StoryWorkflow(storageURL: root, audio: audio)
        await workflow.startRecording()
        XCTAssertEqual(workflow.captureState, .recording)
        workflow.stopRecording()
        let draft = try XCTUnwrap(workflow.currentStory)
        XCTAssertFalse(draft.isSaved)
        XCTAssertEqual(draft.visibility, "private")
        workflow.title = "The brave little hare"
        workflow.savePrivately()
        XCTAssertNil(workflow.errorMessage)
        let reopened = try StoryWorkflow(storageURL: root, audio: DeterministicAudio())
        reopened.openStory(id: draft.id)
        XCTAssertEqual(reopened.currentStory?.id, draft.id)
        XCTAssertEqual(reopened.title, "The brave little hare")
        XCTAssertEqual(reopened.currentStory?.isSaved, true)
        XCTAssertEqual(try Data(contentsOf: XCTUnwrap(reopened.currentAudioURL)), Data("spoken narration".utf8))
        XCTAssertFalse(reopened.isPlaying)
        reopened.play()
        XCTAssertTrue(reopened.isPlaying)
    }
}

private enum FirstInstalledModel {
    @Model final class StoryRecord {
        @Attribute(.unique) var id: UUID
        var title: String
        var audioName: String
        var duration: TimeInterval
        var isSaved: Bool
        var visibility: String
        var createdAt: Date
        var updatedAt: Date

        init(id: UUID, title: String, audioName: String, date: Date) {
            self.id = id; self.title = title; self.audioName = audioName
            duration = 8; isSaved = true; visibility = "private"
            createdAt = date; updatedAt = date
        }
    }
}

@MainActor
final class DeterministicAudio: StoryAudio {
    var captureDuration: TimeInterval = 3
    var playbackTime: TimeInterval = 0
    var isPlaying = false
    var permissionGranted = true
    var permissionRequest: (() async -> Bool)?
    private var outputURL: URL?
    func requestPermission() async -> Bool {
        if let permissionRequest { return await permissionRequest() }
        return permissionGranted
    }
    func startRecording(to url: URL) throws {
        outputURL = url
        try Data("spoken narration".utf8).write(to: url)
    }
    func pauseRecording() throws { }
    func resumeRecording() throws { }
    func finishRecording() throws -> TimeInterval { captureDuration }
    func play(url: URL, fromStart: Bool) throws { isPlaying = true }
    func pausePlayback() { isPlaying = false }
    func stopPlayback() { isPlaying = false; playbackTime = 0 }
}

/// Deterministic microphone/clock boundary: only captured speech consumes duration.
@MainActor
final class PausableAudio: StoryAudio {
    var pauseError: Error?
    var resumeError: Error?
    var finishError: Error?
    var captureDuration: TimeInterval = 0
    var playbackTime: TimeInterval = 0
    var isPlaying = false
    private var outputURL: URL?
    private var capturing = false
    func requestPermission() async -> Bool { true }
    func startRecording(to url: URL) throws {
        guard outputURL == nil else { throw CocoaError(.fileWriteFileExists) }
        outputURL = url; capturing = true; captureDuration = 0
        try Data().write(to: url)
    }
    func pauseRecording() throws {
        if let pauseError { throw pauseError }
        capturing = false
    }
    func resumeRecording() throws {
        if let resumeError { throw resumeError }
        capturing = true
    }
    func speak(_ words: String, lasting seconds: TimeInterval) throws {
        guard capturing, let outputURL else { return }
        let file = try FileHandle(forWritingTo: outputURL)
        defer { try? file.close() }
        try file.seekToEnd()
        try file.write(contentsOf: Data((words + " ").utf8))
        captureDuration += seconds
    }
    func wait(seconds: TimeInterval) { if capturing { captureDuration += seconds } }
    func finishRecording() throws -> TimeInterval {
        capturing = false; outputURL = nil
        if let finishError { throw finishError }
        return captureDuration
    }
    func play(url: URL, fromStart: Bool) throws { isPlaying = true }
    func pausePlayback() { isPlaying = false }
    func stopPlayback() { isPlaying = false; playbackTime = 0 }
}
