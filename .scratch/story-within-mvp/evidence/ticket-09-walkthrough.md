# Local MVP verification walkthrough

Status: in progress. This is a verification record, not a declaration of M1 readiness.

## Confirmed evidence

- The unmodified native project built before implementation. The final ticket-05 candidate (`9113572`) passed 56 combined native tests on iPhone 13 / iOS 17.5, Debug simulator compilation, and Release iOS compilation. Logs are linked in [ticket 05 evidence](ticket-05.md).
- Earlier iPhone 15 Pro / iOS 27.0.1 checks, reported by the user: actual narration and title survive save/reopening; recording and pause/resume work; corrected playback buttons are readable; both human demo recordings play audibly. These observations precede the final hints, replacement and preview integration.
- An interactive iOS 27.0 simulator smoke check traversed Home → Create → listener preferences → contextual demo coach → Skip → Start Recording → studio ready at 0:00. The typed fictitious preference remained visible. Entering the studio did not activate capture. No actual microphone recording was performed during this smoke check.
- The studio renders at the largest accessibility text size. Reachability of the lower controls was inconclusive through Device Hub's CUA scroll/drag interaction; a complete large-text journey is still required. The simulator's original text size was restored afterward. No VoiceOver traversal or audible announcement result is claimed. A later attempt to check the other starting route could see Home visually, but Device Hub no longer exposed the simulator app accessibility tree; that second route was not interactively verified.

## Updated iPhone journey

Use a disposable new story for replacement, deletion and permission tests. Preserve existing personal stories. Keep the device offline for the local journey if practical; all M1 coaching and bundled audio are on-device.

1. Open an existing story and check its title/audio. Start a new story through either starting approach. Enter an idea/preference, answer or skip a demo question, and start recording.
2. Say “before the hint,” request inspiration, and check that capture pauses and the timer stops. Read a cue, choose Resume, say “after the hint,” then Stop. Play both segments; the paused break should be excluded. Edit the title and optional manual transcript, save privately, close/reopen and replay.
3. On this disposable story, confirm Re-record, speak briefly, then cancel replacement. Check that the original title/text/audio remain. Try again and stop a successful replacement; check its audio and retained story details. A previous local-preview consent must not carry to the new recording.
4. For another short disposable take, background the app while recording. Return: capture should be stopped, the microphone should stay off, and captured audio should remain reviewable. If a headset route or incoming call is available, repeat with that interruption and report the exact route/event. Reopen the finalized draft and replay it. Do not force-terminate an in-flight take as a promised recovery case.
5. Save privately and open Explore: the story must be absent from the local preview section. Review the exact story for community preview, cancel once, then confirm the explicit on-device voice/text consent. Check it appears locally; withdraw it and check it disappears. Nothing is uploaded or visible to another device.

## Remaining accessibility and recovery checks

- Complete creation, capture, hint/resume, review, save/reopen, and preview/withdrawal with accessibility-size Dynamic Type and VoiceOver. Check controls remain reachable, focus and state announcements are useful, and no playback starts automatically. Test Reduce Motion and restore the original setting.
- Check denied microphone access using the disposable workflow, then restore the original permission. A denial must give a clear recovery path without pretending to record.
- Failed/retried save, missing/corrupt assets, preview commit failures, cancelled/failed replacement, metadata migration and owned-file deletion have deterministic workflow evidence. Hardware/storage failure injection has not been performed on the user's phone; do not equate those tests with a physical failure result.
- Full-story cultural/linguistic review is not established by audible demo playback. The bundled English human recordings have documented publisher licensing/attribution, not an isiZulu/isiXhosa language review.

## Capability boundary

Real: AVFoundation capture/pause/resume/playback; local SwiftData/audio storage; editable parent-authored text; bundled licensed human demo audio; explicit local preview and withdrawal.

Demo: deterministic on-device coach and prepared text cues. No live AI, automatic transcription, live translation, or remote community publishing is claimed. M2 remains blocked on a secure proxy contract and competent language reviewers.
