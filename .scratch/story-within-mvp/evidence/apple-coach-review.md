# Apple coaching source review

Two independent axes reviewed the coaching delta from 8c2aed2, with follow-up through 3ff3d8d. The user then explicitly narrowed the deployment/demo target to iOS27 on iPhone15Pro; older-device and accessibility verification are not current gates. Root reviewed the four deployment-setting changes and final thought-capture delta. Actual native phone generation remains a separate acceptance check.

## Standards

# Standards review: Apple on-device coach

Reviewed stable candidate `93aea4f1d3d0646b0b22a8e390592fbe8e09968e` against `8c2aed2`, including the delta after previously reviewed `78d3fef`. Subsequent worktree changes are excluded.

**Documented violations: none found.**

The change follows the applicable documented rules:

- Approved spec §1 requires Swift/SwiftUI, Apple frameworks, iOS 17 compatibility, lightweight services, and explicit AI modes. The patch uses native FoundationModels behind the existing service seam, retains iOS 17 deployment, and guards actual generation with OS/model/English-locale availability.
- Approved spec §7 and ticket 10 prohibit cloud credentials/dependencies and silent demo substitution after live failure. No cloud integration or third-party package is added; unavailable initial selection is labeled demo, while live failures stay errors with retry/continue and labeled generic cues.
- Approved spec §2 and ticket 10 retain Start Recording at any point. The final delta exposes Record without waiting during cue preparation, invalidates superseded requests, and keeps late cues from replacing recording hints. Submitted thoughts remain in session exactly once when cue preparation is retried from the view.
- Approved spec Testing Decisions prefer workflow tests with temporary persistence and controlled services. Added cancellation, supersession, and bypass checks exercise parent-visible workflow state; separate native checks explicitly distinguish unavailable generation from success.
- `AGENTS.md` and `docs/agents/domain.md` require glossary/ADR vocabulary and conflict checks. Neither glossary nor ADR directory exists; no conflict was found.

**Smell heuristics:** no consequential refactor recommendation. Small typed native reply/cue operations and the controlled asynchronous test fixture do not justify additional abstractions.

`git diff 8c2aed2...93aea4f --check` passed. This read-only review ran no builds/tests or device checks. Root reports final 77-test and Debug/Release verification in progress; iOS 27 actual generation encountered an asset-load failure, so no model-quality/authorship pass is established. Actual phone evidence remains pending. Accessibility verification is explicitly user-deferred and is not a review gate.


## Spec

SPEC review — final source 3ff3d8dde9f20899b4b250e671d547455773b17e; spec v0.4 override recorded at 0412130

No remaining concrete source blockers found in the reviewed Apple coaching delta.

Resolved initial P1: cue preparation gated recording (78d3fef). Ticket 10:22–23 requires “never blocks recording or saving” and “preserve Start Recording at any point.” Record without waiting now selects explicitly generic cues and enters the recording studio without awaiting the model. Request identity invalidation rejects late cues.

Resolved initial P2: competing answer/skip left isPreparingCues permanently true. Ticket 10:25 requires “cancellation keep parent input and offer retry/continue.” Invalidation now clears preparation state; suspended-cue answer/skip regression cases protect recording continuity.

Resolved follow-up P2: thoughts typed while cues were pending disappeared on bypass (93aea4f). Final StoryCreationView captures and clears the current answer before calling prepareRecordingWithoutCues(thought:). The workflow keeps that thought before selecting generic cues and invalidating the pending request. The original submitted thought remains once, the fresh thought is appended once, and late model cues cannot replace paused hints. The focused regression asserts both thoughts survive.

Verification limitation remains explicit: ticket 10:27 says “Actual supported-device model scenarios establish genuine generation and parent-authorship behavior; doubles alone do not.” The Mac observed modelNotReady. A later iOS 27 native check attempted generation after ready availability but failed asset loading (UnifiedAssetFramework 5000, missing model catalog assets), obtaining no guidance. Actual generation/authorship on the demo iPhone remains pending; neither deterministic tests nor native compilation establish it.

The user’s spec v0.4 amendment narrows the immediate demo to iOS 27 on the existing iPhone 15 Pro, deferring older-device compatibility, accessibility checks and broader release validation. Those deferred checks are not remaining acceptance blockers or passed results. No cloud/key prerequisites or scope creep found. Read-only review; no builds/device actions performed.


Standards: no concrete violations. Spec: three source findings identified across revisions, all resolved in 3ff3d8d. Remaining real-model evidence is not a source-review pass.


## Demo-device result

After the reviewed source was signed/installed, the user confirmed actual on-device coaching and recording/save/replay on iPhone15Pro. Basic native-generation acceptance is met for the demo. Broader model-quality scenarios were not performed; the simulator asset-loading failure remains disclosed.
