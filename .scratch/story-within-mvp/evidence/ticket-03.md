# Ticket 03 implementation evidence

Date: 2026-11-12
Scope: two native starting approaches, deterministic on-device demo coaching, and prepared cue handoff into the existing studio. No cloud/provider/network dependency or hint consumption was added.

## Workflow and privacy

- Home Create opens a native starting choice; recent stories continue to open review directly.
- Idea and listener starts accept parent text into the same workflow. The demo echoes a bounded excerpt of the starting detail or latest parent choice and asks one fixed primary question. It offers prompts rather than a completed narrative, diagnostic/therapeutic advice, or cultural-authenticity claims.
- Skip advances without inventing a parent answer. Recording has no required exchange count and retains an unsubmitted starting point or next thought.
- `StoryCoachService` accepts selected approach, initial context and bounded prior turns (including their questions); it exposes a short reply and separate prepared text cues. App startup explicitly selects `DemoStoryCoachService`.
- Context and cues remain in `StoryWorkflow.coaching` memory. No persistent story or SwiftData schema fields were added. Reopening a story, closing creation, or starting a new creation clears that session. Story titles are not inferred from child preferences.
- Recording invalidates a pending coach reply, so a late reply cannot replace session state after handoff. A failed reply offers retry/skip/record; failed or empty cue preparation uses explicitly labeled generic demo cues and keeps recording available.
- The studio receives the same session and labels prepared/generic demo cues before recording. Ticket 04 still owns displaying/advancing cues while paused.

## Design evidence and limits

The two Mobbin coach searches failed with HTTP transport errors before this slice. The user explicitly approved: “Proceed with native patterns; revisit Mobbin.” No additional Mobbin call was made and no chat reference was inspected or invented. This screen uses native SwiftUI text fields, scrolling content, labeled choices and a persistent primary recording action, retaining the existing forest/ivory theme and action hierarchy. Future Mobbin inspection remains deferred.

New controls use system text styles, wrapping layouts, accessibility labels/selected state, headings and at least 44-point button regions. New replies/errors post VoiceOver announcements. No animation or autoplay was introduced, so Reduce Motion requires no alternative animation. Full interactive Dynamic Type/VoiceOver validation remains pending.

## TDD and native verification

Seam: the user-approved StoryWorkflow application boundary, deterministic coach/audio boundaries and real temporary SwiftData/assets. Tests do not prove physical microphone behavior.

One test was added and checked before each corresponding implementation slice. Red logs 1–6 and 8 establish the absent workflow API at compilation; red 7 executes and fails the pending-reply behavior before the request invalidation fix. Green logs verify each accumulated slice.

| Slice | Red log | Green log |
| --- | --- | --- |
| Idea context, demo label, one question | `/private/tmp/story-within-03-red1.log` | `/private/tmp/story-within-03-green1.log` |
| Child interest and parent choices | `/private/tmp/story-within-03-red2.log` | `/private/tmp/story-within-03-green2.log` |
| Skip and contextual cue handoff | `/private/tmp/story-within-03-red3.log` | `/private/tmp/story-within-03-green3.log` |
| Labeled generic cue failure and save | `/private/tmp/story-within-03-red4.log` | `/private/tmp/story-within-03-green4.log` |
| Immediate recording and save/reopen privacy | `/private/tmp/story-within-03-red5.log` | `/private/tmp/story-within-03-green5.log` |
| Recoverable coach failure | `/private/tmp/story-within-03-red6.log` | `/private/tmp/story-within-03-green6.log` |
| Record while awaiting a reply | `/private/tmp/story-within-03-red7.log` | `/private/tmp/story-within-03-green7-all.log` |
| Retain an unsubmitted next thought | `/private/tmp/story-within-03-red8.log` | `/private/tmp/story-within-03-green8-all.log` |

Assigned destination: iPhone 18 Pro, iOS 27.0, `6FED4861-30B3-4F1C-8E4D-DA91CC42787A`; isolated derived data `/private/tmp/story-within-03-derived`. Initial cold test-host launch took roughly 166 seconds; subsequent launches completed normally without reset. Xcode's nonblocking OS build-version parsing warning appears in the successful logs.

Pre-integration full suite: **20 tests, 0 failures**, including all 12 original recording/save/reopen regressions and eight coach workflow tests. Result bundle: `/private/tmp/story-within-03-derived/Logs/Test/Test-StoryWithin-2026.11.12_07-35-01-+0200.xcresult`.

Interactive native UI smoke was attempted through CUA. App-name lookup did not resolve Simulator; the subsequent app inventory explicitly reported that the Mac was locked and automatic unlock failed. No UI interaction bypass was attempted. Interactive typing/navigation, accessibility-size layout and actual VoiceOver traversal remain unverified until manual unlock permits them. No new physical microphone or language-quality verification is claimed.

Post-integration native tests and Debug/Release builds will be recorded below after merging the accepted pause/resume slice.
