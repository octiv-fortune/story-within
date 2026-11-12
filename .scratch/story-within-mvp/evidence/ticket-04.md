# Ticket 04 implementation evidence

Base: `e22459c`, isolated branch `codex/story-within-ticket-04`. Scope is consumption of existing demo-prepared cues during a paused narration. No service generation, persistence schema, network client, speech playback, or external dependency was added.

## Behavior

- `StoryWorkflow.pauseForInspiration()` uses the existing actual recorder pause action before it exposes a cue. Failed pause/finalization states cannot expose cues.
- `showNextCue()` accepts only paused capture, consumes the prepared list in order, and never requests coaching during capture. Direct recording uses local generic cues. Failed preparation retains its existing explicit generic/unavailable label.
- Successful explicit resume hides the cue; the next paused request continues the list. Exhaustion explains that the parent can continue in their own words or stop. Resume and Stop remain independently available.
- The native studio keeps its existing Pause/Resume and Stop controls, adds Pause for inspiration during capture, and offers optional Show a cue / Next cue while paused. Contextual and generic demo labels are visible. Nothing autoplays, speaks, animates, or resumes capture automatically.
- Cue content and cursor are session state only. `StoryRecord`, `Story`, review text, and discovery metadata do not acquire coaching fields.

## Design and accessibility

Reused the existing studio and the already-inspected Journal paused-state action separation in `/private/tmp/story-within-research/ticket-01.md`, notably [Journal paused recording](https://mobbin.com/screens/97abf03a-6428-4cbc-bcb2-60fee05f4b9a). No new screen or copied design. Native system text styles, wrapping text, a scrollable layout, minimum 44-point new controls, explicit forest label contrast on light bordered controls, grouped cue content, and VoiceOver action hints are present. Existing recording state announcements remain authoritative; cue text is not automatically announced aloud.

Interactive Simulator/CUA inspection was unavailable while the Mac was locked. Dynamic Type extremes, VoiceOver traversal, and the changed visual layout have not been manually verified. A physical narration → pause → contextual hint → resume → stop → replay demonstration is still required; deterministic captured text and prior phone recording checks do not establish the new device sequence.

## Checks

At the approved public StoryWorkflow seam, deterministic audio/coach boundaries and real temporary SwiftData/audio files were used.

- Red: first contextual cue test failed to compile because cue workflow APIs were missing. `/private/tmp/story-within-04-red-1.log`.
- Green: contextual cue after actual pause, discarded paused speech, explicit resume, complete saved/reopened narration. `/private/tmp/story-within-04-green-1.log`.
- Red: ordered/exhausted cue test failed to compile because next-cue/exhaustion APIs were missing. `/private/tmp/story-within-04-red-2.log`.
- Green: generic list order across resume/repause, exhaustion, no autoplay, retained Resume/Stop. `/private/tmp/story-within-04-green-2-retry.log`.
- Generic preparation failure display and no further coach request during capture passed. `/private/tmp/story-within-04-fallback.log`.
- Release generic iOS build, signing disabled, passed. `/private/tmp/story-within-04-release.log`.

The first ordered-cue run built but did not launch a test host for over four minutes; only its xcodebuild process was interrupted. Retrying on the same assigned iOS 27 iPhone 18 Pro simulator with `-parallel-testing-enabled NO` passed. No simulator resets, erases, phone operations, or UI input bypasses were used. All tests used `-collect-test-diagnostics never`.
- Failed pause and failed finalization never expose cues or a false paused state: passed. `/private/tmp/story-within-04-pause-failure.log`.

A first full-suite run on iOS 27 also stalled before launching its test host and was interrupted after more than four minutes. Final combined verification moves to the available iOS 17.5 iPhone 15 Pro simulator (`477CD74B-6796-4DAF-9868-D9F6439EE6FE`) after merging accepted integration work. The new failed-resume regression and combined full-suite result are pending at this checkpoint.
