import AVFoundation
import Foundation

/// The only hardware boundary. StoryWorkflow owns retention and user-visible state.
@MainActor
final class NativeStoryAudio: NSObject, StoryAudio, AVAudioRecorderDelegate {
    private var recorder: AVAudioRecorder?
    private var player: AVAudioPlayer?
    private var playingURL: URL?
    private var recordingError: Error?
    private var finalizedURL: URL?
    private var observers: [NSObjectProtocol] = []
    var onInterruption: (() -> Void)?
    var captureDuration: TimeInterval { recorder?.currentTime ?? 0 }
    var playbackTime: TimeInterval { player?.currentTime ?? 0 }
    var isPlaying: Bool { player?.isPlaying ?? false }

    override init() {
        super.init()
        let center = NotificationCenter.default
        observers.append(center.addObserver(forName: AVAudioSession.interruptionNotification, object: nil, queue: .main) { [weak self] notification in
            guard let raw = notification.userInfo?[AVAudioSessionInterruptionTypeKey] as? UInt,
                  AVAudioSession.InterruptionType(rawValue: raw) == .began else { return }
            Task { @MainActor [weak self] in self?.onInterruption?() }
        })
        observers.append(center.addObserver(forName: AVAudioSession.routeChangeNotification, object: nil, queue: .main) { [weak self] notification in
            guard let raw = notification.userInfo?[AVAudioSessionRouteChangeReasonKey] as? UInt,
                  AVAudioSession.RouteChangeReason(rawValue: raw) == .oldDeviceUnavailable else { return }
            Task { @MainActor [weak self] in self?.onInterruption?() }
        })
    }

    func requestPermission() async -> Bool {
        await AVAudioApplication.requestRecordPermission()
    }

    func startRecording(to url: URL) throws {
        guard recorder == nil else { throw AudioFailure.cannotRecord }
        stopPlayback()
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
        try session.setActive(true)
        do {
            let recorder = try AVAudioRecorder(url: url, settings: [
                AVFormatIDKey: kAudioFormatMPEG4AAC,
                AVSampleRateKey: 44_100,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ])
            recorder.delegate = self
            recordingError = nil; finalizedURL = nil
            guard recorder.prepareToRecord(), recorder.record(), recorder.isRecording else { throw AudioFailure.cannotRecord }
            self.recorder = recorder
        } catch {
            try? session.setActive(false, options: .notifyOthersOnDeactivation)
            throw error
        }
    }

    func pauseRecording() throws {
        guard let recorder else { throw AudioFailure.cannotRecord }
        recorder.pause()
        guard !recorder.isRecording else { throw AudioFailure.cannotRecord }
    }

    func resumeRecording() throws {
        guard let recorder else { throw AudioFailure.cannotRecord }
        if let recordingError { throw recordingError }
        try AVAudioSession.sharedInstance().setActive(true)
        // Reuse this recorder and its open file. Never prepare/create a new take here.
        guard recorder.record(), recorder.isRecording else {
            recorder.pause()
            throw AudioFailure.cannotRecord
        }
    }

    func finishRecording() throws -> TimeInterval {
        if let recorder {
            finalizedURL = recorder.url
            recorder.stop()
            self.recorder = nil
            try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        }
        if let recordingError { throw recordingError }
        guard let finalizedURL else { throw AudioFailure.cannotRecord }
        // Decode the finalized asset before reporting success; a header alone is not narration.
        let validation = try AVAudioPlayer(contentsOf: finalizedURL)
        guard validation.duration > 0 else { throw AudioFailure.emptyRecording }
        return validation.duration
    }

    func play(url: URL, fromStart: Bool) throws {
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.playback, mode: .spokenAudio)
        try session.setActive(true)
        if playingURL != url || player == nil {
            player?.stop()
            player = try AVAudioPlayer(contentsOf: url)
            playingURL = url
        }
        if fromStart { player?.currentTime = 0 }
        guard player?.play() == true else { throw AudioFailure.cannotPlay }
    }
    func pausePlayback() { player?.pause() }
    func stopPlayback() {
        player?.stop(); player = nil; playingURL = nil
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }

    nonisolated func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        Task { @MainActor [weak self] in
            self?.recordingError = error ?? AudioFailure.cannotRecord
            self?.onInterruption?()
        }
    }
}

private enum AudioFailure: LocalizedError {
    case cannotRecord, emptyRecording, cannotPlay
    var errorDescription: String? {
        switch self {
        case .cannotRecord: "The microphone could not capture audio. Try again."
        case .emptyRecording: "No playable audio was captured. Try a new recording."
        case .cannotPlay: "Playback could not start. Try again."
        }
    }
}
