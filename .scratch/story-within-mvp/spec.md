# Story Within: MVP implementation specification

Status: ready-for-agent
Approval: Specification and ticket breakdown approved by the user on 2026-11-12.
Implementation gate: Authorized by the user on 2026-11-12; follow the approved dependency graph and retain unmet external prerequisites.
GitHub publication: Published with 14 native sub-issues and their approved blocking relationships.
GitHub issue: https://github.com/octiv-fortune/story-within/issues/1
Version: 0.3
Date: 2026-11-12 (Africa/Johannesburg)
Source: [MVP implementation brief](../../docs/agents/product-brief.md) and the user's workflow and constraints.

## Problem Statement

Parents and caregivers want to tell original, culturally meaningful stories in their own voices, shaped around their children's interests and communication preferences. They may have an idea or a lived experience to draw on but need help finding characters, structure, and a way to begin. Writing an entire story for them would displace the authorship and oral storytelling this product exists to support.

Parents also need a dependable way to capture their narration, listen back, correct its text, and keep it. Language support and optional community discovery can make those stories accessible to more families, provided the product is honest about AI limitations and about who can access a recording.

## Solution

Build a native SwiftUI iOS application that guides a parent from an idea or child preference through short coaching exchanges, actual voice recording, review, and durable local saving. The parent can stop coaching at any point, pause recording for a prepared hint, and return later to play their story. AI remains the coach; the parent remains the storyteller.

The completed capstone journey adds live coaching, editable transcription, and editable text translation through replaceable service interfaces. A permission-cleared, playable community demo collection supports discovery from the local MVP onward. Actual cross-device publishing is a separate optional extension and must never be implied by a local visibility setting.

### Delivery milestones and definition of completion

| Capability | M1: working local MVP | M2: complete capstone language journey | M3: optional remote publishing |
| --- | --- | --- | --- |
| Native home, two starting approaches, coach | Functional UI with deterministic coaching labeled as demo | Real Apple on-device English coaching on eligible devices; explicit demo mode elsewhere. Cloud coaching may be revisited later. | Retained |
| Record, pause, resume, stop, replay | Real microphone capture and original voice playback | Retained | Retained |
| Prepared hints | Contextual deterministic cues, requested by parent while paused | May be prepared by live coaching; no live narration analysis | Retained |
| Drafts and personal library | Real local persistence and audio files | Retained | Retained |
| Transcript | Parent can type/edit; optional sample fixture explicitly labeled | Live audio transcription, editable before use | Retained |
| Translation | Optional sample fixtures for a known demo story, explicitly labeled | Live text translation for a tested language set, editable | Retained |
| Community browsing | Real playback of bundled, permission-cleared demo stories | Retained; live text results may be saved locally | Remote stories may also be discovered |
| Visibility and publishing | Private default; explicitly labeled local community preview after confirmation; withdraw locally | Same scope unless M3 is approved | Authenticated upload, cross-device discovery, ownership controls, withdrawal |
| Offline use | Create with mock coach, record, review, save, reopen, and browse bundled content | Local functions remain available when live requests fail | Local functions remain available; remote actions show connectivity failures |

M1 is a usable local MVP, not completion of the intended live capstone demonstration. M2 is part of this proposed specification and must not be silently dropped if integration is difficult. M3 requires a separate scope decision and backend details before tickets for it become executable. Without M3, the walkthrough must say that community publishing is a local preview and cannot demonstrate another device receiving a newly created story.

## User Stories

1. As a parent, I want a welcoming home with clear Create a Story and Explore Stories actions, so that I can choose my next activity quickly.
2. As a returning parent, I want to see recent saved stories, so that I can resume listening or editing.
3. As a parent with an idea, I want to describe it in my own words, so that coaching starts from my imagination.
4. As a parent starting with my child, I want to describe an interest, feeling, or communication preference, so that suggestions fit the intended listener.
5. As a parent, I want to provide preferences without creating a child account or profile, so that starting a story stays simple.
6. As a parent, I want the coach to ask one primary question at a time, so that I can develop the story at my own pace.
7. As a parent, I want suggestions to reflect my chosen characters, setting, and tone, so that my creative decisions are preserved.
8. As a parent, I want to skip a suggestion, so that I can continue without answering everything.
9. As a parent, I want to start recording at any point in coaching, so that the conversation does not gate my narration.
10. As a parent, I want short prompts and optional cues rather than a completed AI-written story, so that I remain the author.
11. As a parent, I want cultural suggestions framed as ideas rather than invented facts, so that I can bring my own knowledge and traditions.
12. As a parent, I want preferences treated as storytelling context without diagnostic or therapeutic claims, so that the app respects my child's individuality.
13. As a parent, I want to know when the coach is a deterministic demo service, so that I understand what is actually working.
14. As a parent, I want a meaningful microphone permission explanation, so that I can decide whether to record.
15. As a parent, I want to recover from denied microphone permission, so that I can return and record after changing access.
16. As a parent, I want a visible recording state and elapsed duration, so that I know my voice is being captured.
17. As a parent, I want to pause and resume one recording, so that breaks do not split my story or lose earlier narration.
18. As a parent, I want an optional prepared hint while paused, so that I can find inspiration without AI interrupting me.
19. As a parent, I want to stop recording and hear what I captured, so that I can decide whether to keep it.
20. As a parent, I want interruptions handled visibly, so that I do not mistakenly continue speaking when recording has stopped.
21. As a parent, I want confirmation before discarding or replacing a recording, so that an accidental tap does not erase it.
22. As a parent, I want a stopped recording kept as a draft before I leave review, so that I can return after relaunching the app.
23. As a parent, I want to edit the title, theme, and original language, so that the saved story accurately describes my narration.
24. As a parent, I want original audio playback controls, so that I can review and share my own performance deliberately.
25. As a parent, I want to enter or correct transcript text, so that service availability and transcription errors do not prevent saving.
26. As a parent, I want consent before recorded audio is sent for cloud transcription, so that I understand what leaves my device.
27. As a parent, I want transcription failure to preserve my recording and edits, so that I can retry or continue manually.
28. As a parent, I want to review detected language information and correct it, so that a service's guess does not override my knowledge.
29. As a parent, I want to choose from an explicitly supported translation language set, so that availability is clear.
30. As a parent, I want to review the exact source text before requesting a translation, so that I control what is sent.
31. As a parent, I want original and translated text visible together, so that I can compare them.
32. As a parent, I want to correct and save translations, so that I can improve wording without replacing the original text.
33. As a parent, I want generated, parent-edited, and sample text distinguishable, so that I can assess their provenance.
34. As a parent, I want source edits to flag an existing translation as needing review, so that outdated text is not silently treated as current.
35. As a parent, I want translation playback to remain my original recording, so that the app does not impersonate my voice in another language.
36. As a parent, I want stories private by default, so that recording and saving do not expose my family to others.
37. As a parent, I want saved audio, metadata, transcripts, and translations to survive relaunch, so that my personal library is dependable.
38. As a parent, I want to reopen and continue editing a saved story, so that saving does not end authorship.
39. As a parent, I want to remove my local story and its recording, so that I control what the app retains.
40. As a parent, I want a clear preview of attribution, text, and recording before choosing community visibility, so that I understand what I am exposing.
41. As a parent, I want separate publication confirmation mentioning the original voice recording, so that a save action cannot inadvertently publish it.
42. As a parent using a local demo, I want community actions labeled as a preview on this device, so that I do not mistake them for public sharing.
43. As a parent, I want to withdraw my story from the community preview, so that it can return to private visibility.
44. As a family browsing stories, I want title, creator, language, and theme on discoverable stories, so that I can choose what to hear.
45. As a listener, I want playable original demo recordings and available text translations, so that discovery demonstrates a complete listening experience.
46. As a listener, I want audio to start only after I choose to play it, so that the app respects my environment and sensory preferences.
47. As a parent using assistive technology, I want accessible text, controls, state announcements, and predictable navigation, so that I can complete the same journey.
48. As a parent, I want recoverable loading, cancellation, empty, and error states, so that a slow or unavailable service does not trap me.
49. As a parent, I want online features to explain which story content is sent, so that I can make an informed choice before using them.
50. As a demonstrator, I want service modes and limitations visible throughout the journey, so that the capstone accurately represents implemented capabilities.

The following stories apply only if M3 is separately approved:

51. As a parent, I want authenticated publishing with my attribution and explicit consent, so that other families can discover a story I own.
52. As a listener on another device, I want to discover and play a successfully published story, so that sharing is functional across devices.
53. As a parent, I want to withdraw my remote story and control its stored assets, so that community visibility remains under my control.

## Implementation Decisions

These implementation decisions were approved in review. No changes have been made to the application.

### 1. Platform and architecture

- Use Swift and SwiftUI exclusively for the native application. Use Apple frameworks: AVFoundation for audio, SwiftData for local metadata, Foundation and URLSession for networking, and native accessibility facilities. Add no third-party dependencies without a demonstrated need and scope approval.
- Target iOS 17 or later, with the primary demo on iPhone. Keep layouts usable on iPad where the existing target supports it; a separate iPad experience is outside scope. Restrict the app target to iOS rather than carrying unrequested macOS and visionOS features.
- Retain the initialized Xcode project. Adjust deployment/platform settings and replace starter content only after the review gate. Avoid APIs that would raise the approved minimum OS.
- Organize lightweight features around Home, Story Start/Coach, Recording, Review/Translation, and Libraries. Views render state and dispatch actions; application workflows coordinate services. Avoid a generic plugin, dependency-injection, or state-management framework.
- Compose service implementations at app startup. AI mode is explicit per capability: demo, live, or unavailable. Never silently fall back to demo output after a live failure.

### 2. Navigation and ownership of a story

- Home exposes Create a Story, Explore Stories, and recent personal stories. Personal library access is available from Home. Story Start offers the two starting approaches and passes their input into the same coach workflow.
- The coach offers Skip and Start Recording without requiring a minimum exchange count. A working title can use a local default until the parent edits it.
- A draft owns its recording and review edits. Finalizing a recording creates or updates a private recoverable draft before presenting review. A draft and a saved story share stable identity; draft/saved lifecycle is separate from private/community visibility.
- Saving is available without AI output, a transcript, or a translation. A valid recording and a nonblank title are required for a saved audio story; use an editable default title rather than preventing entry to recording.
- Back navigation while recording or leaving unsaved review edits offers a clear keep/discard choice. Do not silently discard audio. Coaching context may remain session-scoped; restoring an unfinished coaching conversation is not required.

### 3. Coach and prepared hints

- Coaching receives the selected starting approach, parent-entered text, conversation history, and relevant story decisions. It returns a short response containing at most one primary question and optional concise cues.
- The coach preserves parent decisions; skipping advances without requiring an answer. Contextual demo responses must reflect at least the selected approach and parent-provided details; label the deterministic coach as a demo rather than implying live model reasoning.
- Neither mock nor live coaching produces a complete story. Do not offer automatic story completion. Cultural knowledge should come from the parent or be presented as a tentative creative suggestion, without unsupported claims of authenticity.
- Prepare a small ordered set of cues before recording. If cue preparation fails, recording remains available with generic cues labeled accordingly. No cloud response is required during microphone capture.
- While actively recording, offer Pause for inspiration. A hint is shown only after capture pauses. The next cue is text only, advances on request, and never speaks or resumes recording automatically. Exhausting the cue list leaves recording usable.

### 4. Actual audio lifecycle

- Request microphone access at the first record action, with a purpose explanation. Denied or restricted access presents an actionable state and never animates a false recording.
- The audio service exposes idle, requesting permission, recording, paused, finalized, and recoverable failure states. Controls, duration, and accessibility announcements derive from the actual service state.
- Record one original narration into an app-owned audio asset using an Apple-supported compressed format suitable for playback and later upload. Pause/resume preserves a continuous recording; elapsed duration excludes paused time.
- Stop finalizes the audio and makes it reviewable. Empty or failed recordings cannot be passed off as a successful story. Re-recording requires confirmation and preserves the existing finalized asset until a replacement is successfully retained.
- Interruption, backgrounding, or loss of the active audio route pauses or safely finalizes capture and tells the parent what happened. Do not automatically restart the microphone. Background recording and lock-screen controls are outside the MVP.
- Keep finalized audio in durable app storage, referenced through app-relative identity rather than an absolute sandbox path. Temporary assets become durable before a draft is reported as recoverable. Interrupted writes produce an error and retain recoverable audio for retry; do not show a successful save until metadata and audio agree.
- The app plays one story at a time. Starting capture stops playback. Changing stories stops the previous player. Minimum playback controls are play, pause, replay, elapsed time, and duration; seeking and waveform visualization are optional.
- Relaunch recovery is required for finalized/stopped drafts and saved stories. Recovery of an in-flight recording after forced termination is best effort and must not be promised in the UI.

### 5. Local persistence and content identity

- Story data includes stable ID, draft/saved lifecycle, editable title, creator display name, source language, theme, audio reference and duration, original transcript, translations, visibility, creation time, and update time. Local visibility defaults to private.
- Persist transcript and translation provenance: sample fixture versus generated result, service mode, and whether the parent has edited the text. Preserve a source revision/snapshot for each translation and flag it when the original transcript changes.
- Coaching messages and child-specific preferences remain session-scoped and are excluded from story metadata, discovery cards, and publication payloads. A parent's chosen recording or text can still include personal content, so the final review must show the actual content being shared.
- Store personal stories and edits through a repository backed by SwiftData and durable audio storage. A failed write preserves the draft for retry; an unsuccessful delete is not reported as completed.
- Seed demo stories with stable identities once, without duplicating them on relaunch. Keep bundled demo assets separate from recordings owned by a parent. Removing a parent's story must not delete shared or bundled demo content.
- Deleting a local story requires confirmation, removes its owned audio and text, and removes it from the local community preview. M3 would require a separate remote withdrawal/delete flow; local deletion alone must not claim remote deletion.

### 6. Review, transcription, and translation

- Review exposes title, theme, source language, original playback, editable transcript, translation actions, and saving. Source language starts as parent-selected or unknown; service detection is a suggestion that the parent can correct.
- Transcription is opt-in after capture. Send the finalized audio only after explaining cloud processing. Preserve the recording regardless of request success. Do not overwrite parent-edited text when a delayed response arrives; offer the result for review/replacement.
- The local MVP supports manual transcript entry. Mock transcription is a known sample fixture, never a claim to have recognized arbitrary microphone audio. If fixture text is offered for an arbitrary recording, label it as sample text unrelated to that recording and require deliberate use. Prefer the known bundled demo story for fixture demonstrations.
- Translation operates on the parent-reviewed transcript, not directly on audio. Disable the request for empty source text. Explain that the selected text and language are sent to the service; send no unrelated coaching history.
- Use English as the initial controlled source-language test fixture. Prioritize isiZulu and propose isiXhosa as the second African target-language candidate. These are candidates, not validated support claims. Recording itself is language-independent; transcription availability must be declared separately from translation availability.
- Finalize the supported language set only after end-to-end service checks and review by competent speakers. Record sample text/audio, direction, reviewer, observed errors, and limitations. If a candidate fails, retain its unavailable state and return the scope decision for review rather than advertise unsupported quality.
- Show original and translated text together, using a stacked layout where screen size or Dynamic Type requires it. Allow correction and persistence of each translation without changing the original. Replacing a manually corrected translation requires confirmation.
- Label machine output as AI-generated and not linguistically/culturally verified. Parent editing changes the label to parent-edited; it does not imply independent verification. Known reviewed demo fixtures may identify their actual review provenance only when that review occurred.
- Transcript edits mark existing translations as needing review. Language changes flag incompatible results. A late result for a previous source revision cannot replace current work silently.
- Audio always remains the parent's original recording. Translation is text only. Saving and local playback remain functional after network errors or unsupported-language responses.

### 7. Service boundaries and live integration

| Boundary | Input | Observable output and responsibilities |
| --- | --- | --- |
| StoryCoachService | Starting approach, parent message, bounded conversation and story context | Coach response, at most one primary question, optional prepared cues, explicit mode; cancellation and recoverable failure |
| TranscriptionService | Finalized audio asset, optional parent-selected language | Transcript, optional detected language, provenance; bounded upload, cancellation, unsupported input and transport failures |
| TranslationService | Reviewed source text, source language, target language, source revision | Translation and provenance tied to that revision; cancellation, unsupported-language and transport failures |
| Audio recording/playback services | Parent actions and owned audio references | Actual capture/player state, elapsed duration, finalized asset, interruptions, permission and file failures |
| StoryRepository | Draft/story edits, owned assets, library queries | Durable writes, stable identity, fetch/reopen/delete, meaningful errors |

- Define Swift protocols and deterministic mock AI implementations before live implementations. Do not mock recording in the normal app journey. Test doubles for audio are allowed in automated workflow tests; device verification must use AVFoundation.
- User-approved amendment (2026-11-12): implement real English coaching first using Apple Foundation Models on eligible iOS 26+ devices, behind StoryCoachService. Check runtime/model/language availability; keep the app target iOS 17+ with explicitly labeled demo coaching on unsupported devices. Do not silently switch a failed real-model response to demo output. This slice needs no cloud account, API key, authentication server or proxy. Other live cloud implementations use URLSession and a secure backend proxy. Provider credentials must not be embedded in source, app configuration shipped to devices, logs, or the app bundle. Backend endpoint, authentication/abuse controls, deployment ownership, provider capabilities, limits, and deletion/retention behavior must be established before live integration tickets are ready.
- The iOS application stays Swift-only. No backend provider or additional framework is selected by this spec; the proxy is an integration prerequisite with a separate reviewed implementation/deployment decision if this repository must supply it. A remote community backend is not a prerequisite for a private AI proxy.
- Specify and verify the proxy request/response contract in the live-integration tickets, including request identity, service operation, language information, result provenance, error categories, upload limits, cancellation/timeout behavior, and source revision. Do not select an unverified provider model or promise language coverage now.
- Cloud processing requires a clear, deliberate action after disclosure. Cancellation and errors preserve local content. Avoid logging recordings, full coaching conversations, transcripts, or child-specific preferences.
- Live results must meet the same authorship and review rules as mock results. A service failure shows retry/continue options; it never produces a pretend successful transcription, translation, or publication.

### 8. Community preview and optional publishing

- Bundle a small permission-cleared collection of original stories with playable human recordings, title, attribution, source language, theme, and any reviewed text translations. Content sourcing/recording and permission evidence are implementation prerequisites for seeding; placeholder silent or synthetic files do not satisfy demo playback.
- The community library visibly identifies bundled demo content. Locally previewed parent stories are also labeled as available on this device only. Private stories never appear in community queries.
- A story is saved privately first. Community preview is a separate deliberate action showing title, attribution, original audio, transcript, and selected translations. Explain the scope and mention the voice recording. Confirming changes local preview visibility; cancelling changes nothing.
- Permit withdrawal to private visibility without deleting the personal copy. Retain creator attribution in all discovery presentations. No share button or success message may imply actual public access in M1/M2.
- M3, if approved, requires authenticated ownership, private-by-default storage, access controls for metadata and recordings, explicit publication consent, cross-device retrieval, and functional withdrawal. Failed uploads or metadata writes must not mark a story as remotely published. Withdrawal must stop new discovery and playback access through the service, while explaining that already-downloaded copies cannot be recalled.

### 9. Design and accessibility

- Use Mobbin for interaction and layout inspiration before implementing each primary screen; document the screens inspected, the observed pattern, and the Story Within adaptation. Never copy a reference screen's branding, illustrations, story content, or full layout.
- The brief's Comet, 5 Minute Journal, Apple Books, and Duolingo ABC links remain proposed research starting points. They have not been visually inspected in this specification pass. Inspect relevant references during the approved screen slices rather than claim those links have already informed a design.
- Initial recording research inspected iOS previews from [Apple Notes](https://mobbin.com/screens/0d114d69-8313-4f4d-acc3-71b875eadc11) and [Journal](https://mobbin.com/screens/97abf03a-6428-4cbc-bcb2-60fee05f4b9a). Both show a prominent elapsed duration with a labeled Resume action and a separate completion action in the paused state. These are recording references for structure; neither is a storytelling reference. Adapt the separation of resume and finish, visible time, and restrained controls to Story Within's own studio and optional text hint.
- Use the proposed forest green, warm ivory, terracotta, and dark text palette with system typography and restrained rounded accents. Validate contrast before treating any foreground/background combination as approved.
- Support Dynamic Type without clipped actions, VoiceOver labels and recording-state announcements, logical focus order, sufficient contrast, Reduce Motion, and at least 44-point primary touch targets. Do not encode recording state only through color or animation.
- Keep navigation predictable, avoid compulsory animation and autoplaying audio, and allow story preferences without presenting a universal solution for neurodivergent children.

## Current MVP verification amendment

2026-11-12: The user explicitly deferred accessibility checks for now to prioritize MVP functionality. Full accessibility-size Dynamic Type, VoiceOver, Reduce Motion, focus and target/contrast verification are deferred and do not block the current M1 functional milestone. Existing accessible controls/support remain in the app. Deferred checks are not reported as passed. The earlier pending large-text request is withdrawn. Other functional acceptance and real-audio requirements remain in force; M2 live services are still part of the approved scope and retain their external prerequisites.

## Testing Decisions

The user confirmed this test boundary on 2026-11-12: exercise the create → record → review → save/reopen journey through the application workflow with deterministic AI services and temporary storage, plus physical iPhone verification for actual audio.

- Prefer one high application-workflow seam: drive parent-visible actions with injected services and assert resulting state and saved/reopened content. Use the real local repository with temporary storage where feasible, deterministic AI responses, and controlled audio results in automated tests.
- Test externally meaningful behavior: preserving narration across pause/resume and review, saving privately, reopening edits, excluding private stories from discovery, handling stale text responses, and preventing false success after service or persistence errors. Avoid tests of private helper structure, exact SwiftUI hierarchies, or implementation-mirroring mocks.
- Add focused lower-level checks only for behaviors the workflow cannot establish adequately, such as repository asset cleanup or live-proxy contract handling. Introduce tests with the slices they protect; do not build an extensive test framework first.
- There are no existing test targets or test conventions in the starter. Add native test targets and minimal fixture support as part of the first behavior requiring automated verification. Use Apple-provided testing tools only.
- Use a small UI smoke journey to verify navigation, typing, recording-control presentation, review, and reopening. A workflow test using an audio double does not prove microphone capture or playback.
- On a physical iPhone, record speech, pause, request a hint, resume, stop, play the actual audio, save, force-close/relaunch, and play again. Verify narration on both sides of the pause, permission denial, interruption/background handling, and a failed/retried save. Record observed results before claiming device readiness.
- Check the app on the oldest available compatible simulator and the primary current simulator. If an iOS 17 runtime/device is unavailable, record that compatibility remains unverified rather than treating a newer-OS build as proof.
- Validate live coach authorship and single-question behavior with a small scenario set. Validate transcription and each offered translation direction with actual provider calls and competent speaker review. Contract fixtures do not prove language quality.
- Deferred for the current MVP by the user on 2026-11-12: complete-journey Dynamic Type, VoiceOver, Reduce Motion, focus and touch-target/contrast verification. Retain implemented support and revisit verification later. Functional no-autoplay, empty/loading/unavailable, cancellation and retry behavior remains in scope.
- Build after each vertical slice and before merge to the integration branch. Keep required tests green. Run a final Debug simulator build and a Release iOS compilation check; signing/device installation is an additional check when a device is available.

### Acceptance criteria

| ID | Milestone | Observable acceptance |
| --- | --- | --- |
| AC-01 | M1 | The app builds as a native SwiftUI iOS application and launches into branded Home with Create, Explore, and an appropriate recent-story empty state. |
| AC-02 | M1 | Both starting approaches accept parent text and enter the same coach; their context affects clearly labeled demo guidance. |
| AC-03 | M1 | The coach presents at most one primary question per response, allows skipping, and allows recording without completing a fixed questionnaire. |
| AC-04 | M1/M2 | The coach preserves the parent's choices, never writes a complete story, and avoids diagnostic, therapeutic, or unsupported cultural claims in the tested scenarios. |
| AC-05 | M1 | Granting microphone access records real audible speech; denial shows recovery guidance and never enters a false recording state. |
| AC-06 | M1 | Pause, hint request, resume, and stop retain speech from before and after the pause in one playable story; duration excludes the pause. |
| AC-07 | M1 | Hints appear only after capture pauses; they never autoplay, talk over the parent, or automatically restart capture. |
| AC-08 | M1 | Background/interruption handling leaves a truthful recording state and recoverable captured content; resuming requires a parent action. |
| AC-09 | M1 | Review plays actual captured audio and permits title, theme, source-language, and manual transcript edits. |
| AC-10 | M1 | Stopping creates a recoverable private draft. Saving and relaunching restores the same audio, metadata, and edits; failure is reported without losing the recording. |
| AC-11 | M1 | Parents can reopen, edit, save, and delete their stories with discard/delete confirmation and appropriate owned-asset cleanup. |
| AC-12 | M1 | The bundled community demo contains original or permission-cleared human recordings that actually play, with visible attribution, language, and theme. |
| AC-13 | M1 | Private stories are absent from community results. Local preview requires confirmation naming the voice recording and its on-device scope; cancellation preserves privacy and withdrawal removes the preview. |
| AC-14 | M1/M2 | Demo coaching, sample transcripts/translations, and local community previews are labeled where used; no live failure silently substitutes a sample as a real result. |
| AC-15 | M1/M2 | Save and playback work without network access, AI results, or a translation. Missing/unavailable content has a recoverable state. |
| AC-16 | M2 coaching, amended | Eligible devices generate contextual short English coaching and prepared text cues with Apple Foundation Models on-device. Keep at most one primary question, parent authorship, explicit mode/availability, retry/continue on failure and labeled demo support on other iOS 17+ devices. No provider secrets, cloud account or proxy is required for this slice. |
| AC-17 | M2 | Consented live transcription uses the parent's finalized recording, returns editable text, and preserves the recording and manual edits on timeout, cancellation, or failure. |
| AC-18 | M2 | Translation requests use reviewed source text and a validated language direction; original and generated text are visible and manually editable. |
| AC-19 | M2 | Transcript and translation edits survive relaunch. Source edits flag stale translations and delayed responses cannot silently overwrite newer parent work. |
| AC-20 | M2 | The supported language list has recorded service checks and competent speaker review. isiZulu and the second African target are not claimed as supported until this passes. |
| AC-21 | M1/M2 | Preferences and coaching history are absent from discovery/publication metadata, while the parent can inspect the actual audio and text selected for visibility changes. |
| AC-22 | Verification deferred for current MVP | Retain implemented Dynamic Type/VoiceOver/Reduce Motion/contrast/target support. Full accessibility verification is explicitly deferred by the user on 2026-11-12 and is not an M1 release gate. Functional no-autoplay behavior remains required. |
| AC-23 | M1/M2 | Automated workflow checks pass and the physical iPhone narration → hint → playback → save/relaunch journey has recorded results. |
| AC-24 | M2 | A full demo completes create → coach → real recording → review/transcription → translation → save/reopen → community discovery without crashing, with any remaining limitations disclosed. |
| AC-25 | M3 only | A second device discovers and plays a newly published recording only after explicit consent and authenticated upload; unowned changes are denied and withdrawal removes service access. |

## Out of Scope

- AI-written complete stories, automatic adaptation of copyrighted folktales, and AI-generated illustrations.
- Voice cloning, translated speech, synthetic substitutes for parents' recordings, and real-time AI analysis during narration.
- Child accounts, child-facing AI chat, detailed persistent child profiles, medical assessment, and claims of therapeutic or educational efficacy.
- Payments, subscriptions, complex recommendation systems, social graphs, comments, likes, and production social-platform features.
- A separate macOS/visionOS product, a web or cross-platform replacement, extensive iPad-specific design, background recording, and lock-screen media controls.
- Mandatory accounts, remote story sync, or cross-device publication in M1/M2. M3 is conditional and requires its own reviewed backend scope, including content handling and operating responsibility.
- A large component framework, speculative abstractions, unnecessary third-party packages, and language-quality claims without evidence.

## Further Notes

### Repository baseline and build verification

- The brief is actually located at `docs/agents/product-brief.md`; the requested `docs/product-brief.md` does not exist. The source brief has been left untouched and was already untracked when this task started.
- The repository begins with a SwiftUI Hello World view, app entry point, and asset catalog. No domain glossary, ADR directory, app services, persistence model, or tests are present. No existing domain decisions conflict with this proposal.
- The existing target is configured for iOS 27.0 and also lists macOS/visionOS. The proposed iOS 17+ scope requires project-setting changes after approval; it is not what the baseline build verified.
- Baseline verification on 2026-11-12 used Xcode 27.1, scheme StoryWithin, Debug, generic iOS Simulator, and code signing disabled. Result: **BUILD SUCCEEDED**, exit code 0. This proves simulator compilation of the unchanged starter, not launch, iOS 17 compatibility, signed device installation, or microphone behavior.
- The full baseline build log is at `/private/tmp/story-within-baseline-20261112.log`; temporary build products are at `/private/tmp/story-within-baseline-20261112`. Xcode emitted a nonblocking App Intents metadata warning because this starter has no App Intents dependency.
- Initial sandboxed simulator enumeration was denied. The build succeeded with the developer-cache/simulator access required by Xcode. No source or project-setting changes were made for the check.

### Review decisions

1. Confirm the milestone boundary: deliver M1 first, include M2 live coaching/transcription/translation in the capstone scope, and keep M3 genuine remote publishing conditional. This resolves the brief's tension between an acceptable local proof of concept and the final cross-device example.
2. Confirm iOS 17+ with iPhone as the primary demo device, using the existing project.
3. Confirm English-source fixtures with isiZulu and isiXhosa as candidate translation targets, subject to service and speaker validation. The final supported set remains an evidence-based decision.
4. The proposed test boundary has already been confirmed by the user. Physical device availability, qualified language reviewers, original human demo recordings/permissions, and a secure live proxy remain external prerequisites to their respective acceptance criteria.
5. Confirm the specification before generating the ticket proposal. Approving this specification alone does not authorize feature implementation; the ticket breakdown has its own review gate.

### Workflow after specification review

1. Use to-tickets to propose small, independently demonstrable vertical slices with explicit blockers, acceptance criteria, and a verification/demo path. The first functional slice should reach actual recording, private saving, and replay early; subsequent slices deepen that working journey. Avoid separate horizontal tickets for models, services, and views.
2. Review ticket granularity and blocking edges with the user. On approval, save one ticket per Markdown file under the configured local tracker, numbered in dependency order. Keep M1, M2, and any conditional M3 work distinguishable.
3. Publish only the approved specification/tickets to the configured GitHub repository (`octiv-fortune/story-within`), with parent links, acceptance criteria, blocker references/native relationships where available, and the repository's triage labels. Record remote identifiers back into the local tracker and avoid duplicate publication.
4. Only after both reviews, use implement-spec on an integration branch, follow the approved task graph, keep native builds green, and verify the full journey. Recheck the baseline if the project changes between this review and implementation.

The `ready-for-agent` triage label follows to-spec's convention. Specification and ticket approval authorize publication; implementation remains ON HOLD by explicit user instruction.

## Comments

- 2026-11-12: The user approved the specification, then approved all 14 tickets and their dependencies. GitHub publication is authorized. The user explicitly instructed: "Don't start implementation yet." No feature work is authorized.

- 2026-11-12: Published as https://github.com/octiv-fortune/story-within/issues/1 with all 14 approved tickets; implementation remains ON HOLD.

- 2026-11-12: The user resumed implementation with implement-spec, starting at the first unblocked ticket, and required native build verification before changes. The prior implementation hold is revoked.


- 2026-11-12: User direction: “Remember this is an MVP, I think let's skip the accessibility checks for now and focus on the functionality.” This amends the current MVP verification gate only; no accessibility pass, removal of existing support, M2 cancellation, backend implementation or deployment is implied.


- 2026-11-12: User selected “Apple on-device coaching first — no backend or API credentials; keep demo mode on unsupported devices.” This supersedes the immediate Supabase/OpenAI coaching proposal. It does not establish African-language translation quality or silently cancel the later transcription/translation scope. Cloud setup is not executed for this slice.
