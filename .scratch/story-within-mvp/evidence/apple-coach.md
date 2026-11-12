# Apple on-device English coach: implementation evidence

Date: 2026-11-12. Ticket: [10](../issues/10-live-storytelling-coach.md). Current iOS 27 app/test/project source: `3ff3d8dde9f20899b4b250e671d547455773b17e` on `codex/story-within-apple-coach`, with the current demo-scope metadata from integration `0412130` merged as `7130338`. Ticket remains **claimed**: actual supported-phone generation/authorship verification is outstanding.

## Current demo scope

The user subsequently chose iOS 27 for the current iPhone demo and stopped further iOS 17 compatibility work. All four deployment-target settings are now 27.0, with no unrelated project-setting changes. Historical iOS 17 results below describe the earlier candidate only; they are not a current compatibility claim. Harmless existing availability guards remain. No cloud fallback was introduced.

The iOS 27 bypass preserves the thought originally submitted for preparation and any new thought typed while waiting, each once. The button captures and clears the field before entering the studio. Focused regression: `/private/tmp/apple-coach-red11-pending-thought-ios27.log` then `/private/tmp/apple-coach-green11-pending-thought-ios27.log` (**TEST SUCCEEDED**).

## Implemented behavior

The actual app entry point uses the preferred StoryCoachService provider. The current iOS 27 target checks `SystemLanguageModel.default.availability` and English `supportsLocale(en_US)` before selecting Apple Intelligence. Unavailable model/language selects explicitly labeled deterministic demo coaching with an explanation. Selection stays fixed for the session; the explanation tells parents to reopen the app after enabling Apple Intelligence or model preparation. A selected real provider rechecks before each request and never switches a failed response to demo output.

The native adapter explicitly uses SystemLanguageModel and fresh LanguageModelSession instances, with guided Swift response/cue types and no tools, audio, cloud model, account, key, backend, third-party package or CLI. Responses are validated as short guidance and at most one short question; prepared cues are short text. Invalid output and native errors retain parent input and offer retry/continue. Output shape validation and instructions do not prove semantic safety or model quality.

Full parent input remains session-only. Model requests separately serialize a small excerpt: up to 400 UTF-8 bytes of the starting point and three recent turns, each with a bounded answer/question and explicit skip marker, with a final 1,500-byte JSON limit. Instructions are under 1,100 bytes; output is capped at 240 tokens. On iOS 26.4+, actual prompt, instructions and schema token counts are checked with the output allowance and 512 tokens reserved for framework overhead against at most 4,096 total. Earlier iOS 26 uses the conservative small request and schema; authoritative framework context-limit failures remain recoverable. This does not claim a character-to-token conversion is exact. The UI discloses that the model sees an excerpt.

Cues are requested before capture. While preparation is pending the parent can choose **Record without waiting**, retaining their thought once and using explicitly non-AI generic cues. Late/canceled/superseded results cannot enter the studio or replace a paused hint. Recording has no new model requests, narration analysis, autoplay, model audio or automatic resume. Existing accessible support is retained; user-deferred accessibility verification was not performed. Existing screens were extended; no new primary screen was introduced.

## Current iOS 27 verification

App/test/project source `3ff3d8d` (later merged metadata only from `0412130`):

- `/private/tmp/apple-coach-final-ios27-deterministic.log`: **76 tests, 0 failures**, `TEST SUCCEEDED`, on existing iPhone 18 Pro / iOS 27.0 simulator `6FED4861-30B3-4F1C-8E4D-DA91CC42787A`. All 64 existing tests and 11 new deterministic model/workflow tests pass, along with the native provider metadata check. Existing demo tests explicitly inject the deterministic demo service; they do not invoke the native model.
- The actual-generation test was explicitly excluded with `-skip-testing:StoryWithinTests/NativeCoachingAvailabilityTests/testActualNativeEnglishGenerationWhenModelIsReady`. The earlier asset error below is preserved; this deterministic run is not an actual-generation pass.
- `/private/tmp/apple-coach-ios27-release.log`: current-target Release generic iOS **BUILD SUCCEEDED**, signing disabled.
- `/private/tmp/apple-coach-ios27-debug-sim.log`: current-target Debug generic iOS Simulator **BUILD SUCCEEDED**.
- Physical-phone signing, installation and actual coaching verification belong to the root/user. This implementer performed no phone actions.

## Historical compatibility checks before iOS 27 steering

Earlier app/test source `93aea4f`, iPhone 13 simulator / iOS 17.5 (`26D1BB68-2093-4A28-B84A-495BC17B094A`):

- `/private/tmp/apple-coach-final-ios17.log`: **77 tests, 1 skipped, 0 failures**, `TEST SUCCEEDED`. This includes all 64 existing tests, 11 new deterministic model/workflow checks, and two native checks (one native availability pass and one explicit actual-generation skip).
- `/private/tmp/apple-coach-final-debug-sim.log`: Debug generic iOS Simulator **BUILD SUCCEEDED**.
- `/private/tmp/apple-coach-final-release-ios.log`: Release generic iOS **BUILD SUCCEEDED**, signing disabled.
- `/private/tmp/apple-coach-weak-link.txt`: the built Debug app's code dylib lists FoundationModels as `LC_LOAD_WEAK_DYLIB`. The iOS 17.5 test host actually launched and exercised the workflow; compatibility is not inferred only from newer-OS compilation.

Observed iOS 17 selection:

> Native coach selection: Demo coaching · On this device; reason: On-device Apple Intelligence coaching requires iOS 26 or later and a ready, eligible model. You can use demo prompts or record your own story.

The agreed workflow/service seam uses a deterministic model boundary plus real temporary SwiftData/audio-file storage. It checks provider selection, labels, replies/cues, save/reopen, full-input preservation and bounded requests, rejected output, changed availability, typed context/language failures, cancellation/retry, no requests during capture, recording bypass, and late response suppression. Audio doubles do not establish microphone or physical-device playback.

Red/green logs are `/private/tmp/apple-coach-red{1...9}.log` and corresponding `green` logs (budget fixture correction: `green4-fixed`). Red 8 exposed cancellation incorrectly becoming successful generic preparation. The review's busy-state race was reproduced against the previous invalidation behavior in `/private/tmp/apple-coach-red10-supersession.log` (four failed assertions across answer and skip); `/private/tmp/apple-coach-green10-supersession.log` passes after invalidating both busy flags. This regression also proves a late cue result returns false and preserves newer parent choices.

## Actual model attempt: not a quality pass

Development Mac probe (root evidence): `/private/tmp/story-within-apple-availability.log` reported `modelNotReady`; it made no generation request. No CLI license/terms were accepted or model settings changed.

An actual native scenario attempt ran on the existing iPhone 18 Pro / iOS 27.0 simulator (`6FED4861-30B3-4F1C-8E4D-DA91CC42787A`), using the committed native adapter. `/private/tmp/apple-coach-native-ios27.log` records:

> Native coach selection: Apple Intelligence · On-device English coaching; reason: model ready with English support

But its first request failed:

> Error Domain=com.apple.UnifiedAssetFramework Code=5000 "There are no underlying assets (neither atomic instance nor asset roots) for consistency token for asset set com.apple.modelcatalog"

The actual scenario test failed with `generationFailed`; the metadata test passed. The attempted native adapter was introduced in `4381310` (based on `78d3fef` during this run); subsequent recording/target changes did not change its generation logic. Availability advertised ready but the framework could not complete the request. **No actual generated guidance/cues were produced.** This is preserved as a failed attempt, not converted to a skip or a successful model-quality result. Production uses the same truthful failure/retry path and has no simulator-specific fallback.

`NativeCoachingAvailabilityTests.testActualNativeEnglishGenerationWhenModelIsReady` is separate from deterministic checks. It logs only fictitious English scenarios and attempts a gentle tortoise with explicit constraints, a calm train listener preference, an invented tale without cultural-authenticity claims, skips, and prepared text cues. Its actual generation is skipped only when selection is unavailable; advertised-ready request failures fail honestly. A full test run on a model-capable OS can therefore include this nondeterministic check; use `-skip-testing:StoryWithinTests/NativeCoachingAvailabilityTests/testActualNativeEnglishGenerationWhenModelIsReady` for strictly deterministic CI, and run it explicitly for actual-model verification.

Pending root/user verification for the current iPhone demo: observe actual mode/readiness and short English coaching, retain the parent's choices and skips, prepare cues, and complete the real record/save/playback journey. Neither simulator doubles nor a metadata-ready flag establish actual generation. No phone install, microphone action, data reset, publishing or deployment was performed by this implementer.

## Primary sources and source preservation

Apple documentation retrieved 2026-11-12:

- [Generating content and availability](https://developer.apple.com/documentation/foundationmodels/generating-content-and-performing-tasks-with-foundation-models.md): availability before use and the total 4,096-token context.
- [Managing the context window](https://developer.apple.com/documentation/foundationmodels/managing-the-context-window.md): schemas count too; actual token counting, small outputs/fresh sessions, and recoverable limit failures.
- [Supporting languages/locales](https://developer.apple.com/documentation/foundationmodels/supporting-languages-and-locales-with-foundation-models.md): runtime `supportsLocale` and unsupported-language errors.
- Installed Xcode 27.1 SDK interface: `/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk/System/Library/Frameworks/FoundationModels.framework/Modules/FoundationModels.swiftmodule/arm64e-apple-ios.swiftinterface`. Confirmed iOS 26 availability, guided generation, iOS 26.4 token-count APIs, and iOS 26/27 error types used by the adapter.

The current isolated project file differs from `8c2aed2` only in four `IPHONEOS_DEPLOYMENT_TARGET` values (17.0→27.0), as explicitly requested by the user. Its SHA-256 is `5cabc5c4bb090b06f6b6d54b459bc4f77784582febe0d834c418696d925ec906`. The integration working copy's existing uncommitted project-format delta remained read-only during implementation and last checked as `1b66df8e503b6b2c326fc54b4de4f03f5b0415016165f3b69438ea9cd32079b3`; the root/merger owns preserving its formatting while applying the approved target change.
