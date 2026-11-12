# 10: Coach a parent's story with Apple on-device intelligence

Status: resolved
Approval: Ticket breakdown approved by the user on 2026-11-12; GitHub publication authorized.
Implementation gate: Authorized by the user on 2026-11-12; follow the approved dependency graph and retain unmet external prerequisites.
GitHub publication: Published and linked to the parent specification.
GitHub issue: https://github.com/octiv-fortune/story-within/issues/11
Milestone: M2
Blocked by: 03: Develop an idea through the demo storytelling coach
GitHub blockers: https://github.com/octiv-fortune/story-within/issues/4
External prerequisites: Eligible Apple Intelligence device/model availability for actual local-model verification. No secure proxy, paid API account, or cloud credentials are needed for the user-selected slice.
Spec acceptance: AC-03, AC-04, AC-14, AC-15, AC-16, AC-21
Parent specification: [Approved Story Within specification](../spec.md) (approved in chat on 2026-11-12).

## What to build

Generate real short English coaching and prepared text cues with Apple Foundation Models behind StoryCoachService. Keep the parent as author, existing real recording/review/save journey, and an explicit demo mode for devices that cannot use the system model. Target iOS 27 on the current iPhone 15 Pro; runtime/model availability must still be handled honestly.

## Acceptance criteria

- [x] On an eligible device with a ready model, the coach uses real on-device generation with a clear Apple Intelligence/on-device mode label. Check runtime and supported language before requests; do not promise capability from device identity alone.
- [x] Unavailable device/model state uses clearly labeled deterministic demo coaching, explains the limitation where useful, and never blocks recording or saving. No cloud account, API credentials, backend or third-party iOS dependency is introduced.
- [x] Responses contain short guidance and at most one primary question, honor the parent's choices and skips, avoid whole-story writing and unsupported diagnostic/cultural claims, and preserve Start Recording at any point.
- [x] Prepare bounded contextual text cues before capture. Never request analysis of live narration, send audio to the model, autoplay a hint or automatically resume recording. Bound prompts to the model context window without mutating the parent's full session text.
- [x] Real-model errors, unavailability changes, unsupported language, invalid/oversized output and cancellation keep parent input and offer retry/continue. A failed real response is not replaced with demo guidance while presented as actual AI. Generic cue fallback remains explicitly labeled.
- [x] Correct all demo-specific labels/actions in the real-provider journey. Keep preferences/conversation session-only and absent from discovery metadata.
- [x] At the agreed application-workflow/service seam, deterministic tests cover provider selection, valid responses/cues, failure/cancellation/stale results and recording continuity. Actual supported-device model scenarios establish genuine generation and parent-authorship behavior; doubles alone do not.
- [x] Debug simulator and Release iOS builds and the relevant deterministic workflow tests remain green on iOS 27. No further iOS 17 compatibility work is required. Real native-generation checks remain separate from deterministic doubles and must be verified on the iPhone 15 Pro. Preserve existing stories/audio when updating the iPhone.

## Demonstration

On a supported device, enter a fictitious English tortoise idea, receive an actual contextual single-question prompt, skip/answer, prepare cues and enter the same recording/save/replay path. When the system model is unavailable show labeled demo coaching. Report actual model availability and any unperformed real-model scenarios truthfully.

## Delivery constraints and verification

Use native Swift/SwiftUI and Apple frameworks only. Keep recording/playback real in the app. Inspect and document relevant Mobbin patterns before implementing a new primary screen; adapt interactions without screen copying. Apply Dynamic Type, VoiceOver, contrast, Reduce Motion, clear state and large touch targets to each changed flow. Verify the user-visible behavior at the agreed app-workflow seam with temporary storage/deterministic services, and keep the build and relevant checks green. Tests using audio doubles do not establish device microphone behavior.

Technical blocker is the existing coach workflow, not transcription or community publication. Prioritize M1 delivery before M2 rollout.

## Comments

- 2026-11-12: Proposed with to-tickets following specification approval. Ticket approval is pending. Dependencies are implementation prerequisites, not authorization to start. M1 delivery is prioritized before M2 rollout; independent M2 service paths intentionally do not block one another. External prerequisites remain real blockers even when not represented by ticket numbers. After approval, only sufficiently specified/unblocked work becomes ready-for-agent; unresolved service/content/device prerequisites remain visible. No feature implementation or GitHub publication has occurred.


- 2026-11-12: The user approved this ticket and the dependency graph and authorized GitHub publication. Implementation remains ON HOLD. The triage status describes specification/prerequisite readiness, not authorization to execute; needs-info tickets retain the external content, service, review, or device prerequisites stated above.

- 2026-11-12: Published as https://github.com/octiv-fortune/story-within/issues/11; native sub-issue and blocking relationships preserved. Implementation remains ON HOLD.

- 2026-11-12: The user resumed implementation with implement-spec, starting at the first unblocked ticket, and required native build verification before changes. The prior implementation hold is revoked.


- 2026-11-12: Following the user's direction to prioritize MVP functionality and defer accessibility checks, a [minimal coaching proxy contract proposal](../live-coaching-proxy-proposal.md) was drafted for review. It maps to the existing Swift StoryCoachService and keeps live coaching as the next functional slice. It is not an available endpoint or approved backend deployment; status remains needs-info until the stated owner/hosting/authentication/provider/limits/retention decisions and service are available.

- 2026-11-12: On the user's hosting/authentication recommendation request, official documentation was checked and the proposal now recommends OpenAI Responses API behind one Supabase Edge Function, with Supabase Auth pre-created email/password demo users and public signup disabled. The user confirmed ChatGPT Plus; current API-credit benefits do not cover that plan, so separate API funding is required for this architecture. Private-client Sign in with ChatGPT access is limited; it is not assumed available for this private repository. The server-side TypeScript scope addition remains a recommendation pending review, with no resources, accounts or deployment created.


- 2026-11-12: The user explicitly chose Apple on-device English coaching first, with demo mode on unsupported devices. Prior proxy/cloud-auth requirements in historical comments are superseded for this slice. Claimed from integration 29ec22c after the unchanged native Debug simulator build passed (/private/tmp/story-within-coach-baseline.log). No cloud deployment or credential setup is performed. Full accessibility checks remain user-deferred.


- 2026-11-12: User explicitly narrowed the demo to iOS 27 on the existing iPhone 15 Pro. Stop older-device testing and unnecessary validation work. Prior iOS17 compatibility criteria are superseded for this demo. Source review found cue-wait/busy-state issues (fixed in progress) and a newly typed thought omitted by bypass (demo-critical preservation fix pending). Simulator native generation attempted but failed to load assets; no real-model result is claimed. Prioritize final signed install and actual phone coaching/record/save/replay.


## Demo acceptance and answer

Resolved for the user-approved iOS27/iPhone15Pro demo. Source `3ff3d8d`, candidate `6581746`, integrated via `53e59d9`. All 76 deterministic iOS27 checks, Debug simulator, Release iOS and signed Debug iPhone builds passed. The iPhone was updated in place; user confirmed “Actual on-device coach responds; recording/save/replay work.” This establishes basic English generation and the core recording demo on the real phone. The failed simulator asset-loading attempt remains recorded; broader semantic/adversarial and language-quality validation was not performed and is outside the narrowed demo scope. No backend/accounts/API keys were needed. See [evidence](../evidence/apple-coach.md) and [source review](../evidence/apple-coach-review.md).
