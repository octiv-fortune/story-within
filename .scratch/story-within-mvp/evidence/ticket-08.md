# Ticket 08: local community preview and withdrawal

Implemented on `codex/story-within-ticket-08`, based on integration `e22459c`. The existing `StoryWorkflow` application seam was already approved. Used the TDD skill, deterministic audio boundary, and real isolated SwiftData/owned files. No account, upload, backend, public URL, live AI, invented translation, store reset, or dependency was added.

## Behavior and review decisions

- New recordings and ordinary saves remain private. A saved story with kept review edits can prepare a read-only snapshot of the actual title, creator attribution, language, theme, original recording and transcript. The sheet explicitly says that no translations are currently available; later language work must wire actual available/selected translations into this same consent review.
- Native confirmation separately names the original voice recording and this-device-only scope. Cancelling changes no visibility. Confirmation rechecks the saved snapshot, unsaved edits, pending recording and actual file availability. Failed persistence retains the prior visibility and gives retry/cancel guidance.
- Explore has separate read-only parent local previews and bundled licensed demos. Only saved stories with the explicit `localPreview` visibility enter the local query. Child preferences and coaching conversations are not story/discovery fields. Narrated or parent-entered personal details remain visible for review.
- Home, personal library and review labels reflect local preview visibility. Saving/keeping changes explicitly returns a preview to private; showing revised content requires fresh review and confirmation. A failed save leaves the prior visible version unchanged. Withdrawal keeps the saved personal copy, original narration and any still-unsaved review fields separate. Owned deletion also removes the local preview without changing bundled demos.
- `Story.visibility` is now mutable; the existing persisted String property and schema shape are retained. No SwiftData column was added by this ticket. Existing migration and legacy bare-UUID audio-path tests remain part of the passing suite.
- Reused Story Within native review, consent, card and audio controls. Structure-only evidence already inspected in `/private/tmp/story-within-research/ticket-01.md`: [OpenPhone audio review](https://mobbin.com/screens/5413e081-a207-47ef-9565-6b559855faa5) separates playback from keeping/discarding. No further Mobbin calls or screen copying. All new prominent playback controls retain explicit white foreground on forest; no inherited ink foreground regression. Text wraps with system fonts, action rows use `ViewThatFits`, new playback/action targets are at least 44 points, no automatic playback or custom motion was introduced.

## Red → green evidence

Assigned actual destination: iOS 17.5 iPhone 15 simulator `3F8ACDF0-BAF4-4402-AD84-7897260FA5FA`. Independent derived data: `/private/tmp/story-within-08-derived`. Native tests use `-parallel-testing-enabled NO -collect-test-diagnostics never`; expected reds do not trigger long diagnostic collection.

| Slice | Observed red | Observed green |
| --- | --- | --- |
| Saved private → review → cancel → confirm → relaunch | `/private/tmp/story-within-08-red1-authorized.log`: missing public workflow actions/state | `/private/tmp/story-within-08-green1.log`: focused test passed |
| Withdraw while keeping saved original | `/private/tmp/story-within-08-red2.log`: missing withdrawal action | `/private/tmp/story-within-08-green2.log`: focused test passed |
| Revised content must get fresh consent | `/private/tmp/story-within-08-red3.log`: runtime failure, edited story remained visible | `/private/tmp/story-within-08-green3.log`: focused test passed |
| Unavailable original must not be confirmed | `/private/tmp/story-within-08-red4.log`: runtime failure, empty recording accepted | `/private/tmp/story-within-08-green-full.log`: full suite passed |

Full native Debug test result: **43 tests, 0 failures**, including all 36 existing tests and seven local-preview cases. Additional regression scenarios cover failed confirm/save/withdraw commits followed by real relaunch, stale review consent, unsaved text, private draft exclusion, coaching context exclusion and owned deletion preserving demo discovery/playback. Simulator selection/relaunch does not autoplay. Initial sandbox-only Xcode could not reach CoreSimulator (`/private/tmp/story-within-08-red1.log`); authorized Xcode access ran the actual checks successfully. No simulator reset/erase was used.

## Remaining manual checks

Root retains the physical iPhone walkthrough and final review/merge. New-flow physical checks remain: private absence in Explore → cancel preview → exact-content/original voice consent → local discovery after relaunch → withdraw → replay personal copy → delete only owned content. Full VoiceOver focus/announcement, large Dynamic Type layout, contrast/touch inspection and Reduce Motion checks remain manual; source/compilation checks are not a physical accessibility pass. Existing user-confirmed original recording/playback, readable button and both-demo checks remain accepted and were not redone. CUA/Simulator/Mac-lock restrictions were respected; no UI bypass or phone action was attempted.

Final compilation checks passed: generic Debug iOS Simulator (`/private/tmp/story-within-08-debug.log`) and Release generic iOS, code signing disabled (`/private/tmp/story-within-08-release.log`, separate `/private/tmp/story-within-08-release` derived data). Both report **BUILD SUCCEEDED**. `git diff --check` passed. These are compile/test results, not installation or new-flow physical acceptance.
