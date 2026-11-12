# Ticket 07: bundled human demo discovery and playback

Implemented in an isolated worktree on 2026-11-12. This evidence does not mark manual listening accepted or close the ticket.

## Content and provenance

Two original-host MP3 files are bundled unchanged: **Anansi and Wisdom** (source credited Ghanaian folktale) and **Goat, Dog, and Cow** (author Fabian Wakholi). Both have human narration by Darshan Soni, distributed by Storybooks Canada / Global Storybooks. Source author and narrator are separate visible credits. English source language and editorial themes appear on cards and detail. Both entries explicitly say demo. No source text, illustrations, AI transcription, translation, community publication, or cultural validation is supplied.

The accompanying `StoryWithin/DemoStories/ATTRIBUTION.md` and `DemoStories.json` preserve original publisher links, explicit per-story audio permission evidence, CC BY 3.0 links, acquisition date, byte count, SHA256, source author, narrator, provider, and no-changes notices. Files remain original MP3s, not conversions. Credits, source URL text and license name are visible offline; following external links needs a connection. Permission evidence was researched in `/private/tmp/story-within-research/demo-audio.md` and acquired by the root agent before implementation. Acquisition PCM decoding demonstrated nonzero audio, but neither file inspection nor automated playback establishes actual human listening.

## Interaction and separation

Explore uses the already inspected QUITTR collection hierarchy and pillowtalk entry-card structure, with OpenPhone’s distinct playback action structure, adapted to the existing forest/ivory Story Within theme. These are the actual prior inspections documented in ticket-01 evidence and `/private/tmp/story-within-research/ticket-01.md`, not new Mobbin research. No Mobbin call or new inspection was claimed here.

DemoLibrary is read-only bundled content with stable story IDs; it never enters SwiftData or parent-owned asset storage. Relaunch cannot duplicate its entries. Private draft selection survives demo browsing; demo errors do not overwrite personal review errors. All playback shares the existing StoryAudio instance. Selection does not autoplay; switching, entering capture, closing Explore, or backgrounding stops playback. Native AVAudioPlayer handles unchanged MP3s. Controls expose play/pause/replay, current time and duration. Missing recordings and playback errors offer retry or another story; an empty collection explains the absence. Cards/detail retain growing system type, wrapping content, native navigation, 44-point controls, readable colors, VoiceOver text/state, and no added motion or animated autoplay. Final interactive VoiceOver/large-type/device visual checks remain manual.

## TDD and automated evidence

The user-confirmed seam is the application workflow with real temporary SwiftData storage and deterministic microphone boundaries. Two vertical additions established red compiler failures for absent discovery and absent demo selection/playback APIs before their implementations, followed by green app-host tests. Recovery and capture-exclusion checks extend these as regressions. Native decode/playback uses real AVFoundation in the iOS app test host; deterministic recording doubles do not establish device microphone behavior.

- `/private/tmp/story-within-07-red1.log`: no demoStories workflow capability.
- `/private/tmp/story-within-07-green1.log`: stable bundled discovery, relaunch, private exclusion passed.
- `/private/tmp/story-within-07-red2.log`: no demo selection/playback capability.
- `/private/tmp/story-within-07-green2.log`: real AVAudioPlayer play, advancing clock, pause/resume/replay, switch, and measured durations for both MP3s passed on iOS 17.5 iPhone 15 Pro (477CD74B-6796-4DAF-9868-D9F6439EE6FE).
- `/private/tmp/story-within-07-all.log`: 22 tests passed (17 existing plus 5 demo workflow cases), including missing assets, retry after corrupt audio, capture stop, private exclusion and no autoplay.

A small Swift concurrency default-argument warning found during verification was removed by resolving the default library inside the main-actor workflow initializer. Final combined-integration testing and builds are recorded below after merging the latest integration tip.

## Remaining manual acceptance

Listen to both complete recordings on the actual iPhone, offline; confirm narration is audible, usable, and suitable, inspect all source/license credits, pause/resume/replay and switch stories, relaunch without duplicates, and begin recording to confirm playback stops. Automated app playback passed but **full human listening has not been performed by this agent**. Actual VoiceOver, accessibility text sizes, Reduce Motion, offline device UI, and physical audio route/interruption checks remain manual. Root owns review, tracker synchronization, integration, and device checks.

## Combined integration verification

Merged accepted integration `3cf2c25` (including ticket 06) into this branch as `738986d`. Initializer/declaration conflicts retained both the personal persistence failure boundary and the read-only demo library. No accepted library, review metadata or deletion behavior was removed.

- `/private/tmp/story-within-07-combined.log`: **28 tests passed**, including all 23 accepted recording/personal-library cases and all 5 demo workflow cases; real MP3 playback still passed after integration.
- `/private/tmp/story-within-07-release.log`: Release generic iOS build passed after the merge.
- Source SHA256 rechecked against acquisition manifest: `077db0eff3d74d75509790290df01ec8c635b3fa6da9efd909262b529a2cca65` (Anansi), `a5bb1cfa162883656fd6df83e7e21d5b6b15fd9080efaf38cb23643fc79231fb` (Goat).

Final copy clarifies that a damaged bundled catalog needs an app update or returning Home; reopening the same in-memory catalog is not presented as a repair. Manifest playback evidence now states the actual iOS app-host pass, preserving pending human-listening status. This is a copy/metadata clarification after the passing combined tests.

- `/private/tmp/story-within-07-debug-final.log`: final Debug generic iOS Simulator build passed.
- `/private/tmp/story-within-07-release-final.log`: final Release generic iOS build passed.
- Integration tip rechecked before handoff: `3cf2c25`, already merged. No remaining Swift source concurrency warnings; Apple tooling emits its unrelated AppIntents metadata-skip warning and SDK operating-system-build parsing diagnostics, while builds/tests succeed.
