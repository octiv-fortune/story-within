# Minimal live coaching proxy proposal

Status: parked for possible later cloud work. On 2026-11-12 the user selected Apple on-device English coaching first. No endpoint exists and no backend implementation or deployment is authorized by this proposal.
Related work: [ticket 10](issues/10-live-storytelling-coach.md), [approved specification](spec.md).

## Recommended hosting and authentication

Recommendation, 2026-11-12: **OpenAI Responses API + one Supabase Edge Function + Supabase Auth with pre-created email/password demo accounts.** This is a proposed backend scope for review, not an approved deployment.

| Component | Proposed setup |
| --- | --- |
| AI | One OpenAI API project and project service-account credential; keep the model configurable. Store the credential only in backend secrets. |
| Hosting | One Supabase project with a small TypeScript/Deno Edge Function implementing the two coaching operations. |
| Client authentication | Pre-create accounts for the owner and approved testers, disable public signup, and use managed user-session JWT validation before any model request. No shared app password or embedded provider key. |
| Native app | Swift/SwiftUI, Foundation URLSession for auth/coaching HTTP calls, and Keychain for session credentials. Login is needed only for live coaching; local recording, storage, playback and demo coaching stay available without it. |
| Cost controls | Bounded requests/output, timeout, and an atomic per-user daily usage counter in the existing Supabase project. No story or audio storage on the backend for this slice. |

Supabase provides [server-side Edge Functions](https://supabase.com/docs/guides/functions), [managed user authentication for those functions](https://supabase.com/docs/guides/functions/auth), and a switch to [allow only existing users to sign in](https://supabase.com/docs/guides/auth/general-configuration). Pre-created password accounts avoid adding email-delivery/OTP setup to this closed demonstration. The TypeScript function is a proposed server-side scope addition; the iOS app remains native Swift and gains no third-party SDK.

The user has **ChatGPT Plus**. The current [API-credit benefit](https://developers.openai.com/api/docs/guides/chatgpt-api-credits) applies to eligible Pro/Business subscriptions, not Plus. This API-key architecture therefore needs a separately funded OpenAI API project; tester ChatGPT subscriptions are not required.

[Sign in with ChatGPT](https://developers.openai.com/siwc/quickstart.md) can support subscription-backed requests in eligible integrations, but private-client access is limited. This repository is private with no open-source license recorded. The [open-source/local-app flow](https://developers.openai.com/siwc/token-sharing-open-source.md) is not evidence that this private native iOS app has access; do not reuse Codex credentials or make the repository public to bypass that decision. This recommendation avoids making such approval a prerequisite for the MVP.

OpenAI also offers [Sites hosting and browser sign-in](https://learn.chatgpt.com/docs/sites/data-and-connections.md). Its documented private-service bypass credential has no visitor identity and is intended for secret service storage; adapting that into native per-user authentication adds work. Supabase is the recommendation for this specific native-app proxy, rather than a claim that OpenAI offers no hosting.

Start with the [Supabase Free plan](https://supabase.com/pricing), subject to its quotas. Free projects can pause after a week of inactivity; check the project before a scheduled capstone demo. OpenAI model usage is separately metered. No account, resource, user credential, payment or deployment has been created.

## Next functional slice

A parent deliberately chooses live coaching, submits an idea or listener preference, receives a short contextual prompt, and enters the existing real recording/save/replay journey. The parent remains the author. Keep the current on-device demo mode available offline.

Implement live coaching first. Transcription and translation remain separate later slices; this proposal does not advertise either as available. Language reviewers are still required before claiming validated language support.

## Proposed app-facing contract

Both operations use HTTPS and JSON. Paths and limits below are proposals, not deployed services.

| Operation | Request | Successful result |
| --- | --- | --- |
| `POST /v1/coaching/respond` | `requestID`, context containing `approach` (`idea` or `listener`), `initialText`, and ordered turns with `parentText` (nullable for a skip) and the preceding `question` | Matching `requestID`, short `guidance`, optional single primary `question`, and explicit live provenance |
| `POST /v1/coaching/cues` | `requestID`, the same bounded context | Matching `requestID`, ordered short text `cues`, and explicit live provenance |

Map these operations behind the existing Swift `StoryCoachService.respond(to:)` and `prepareCues(for:)` methods. Use Foundation `URLSession`; no new iOS dependency is required.

Match the existing request boundary: at most 2,000 characters for initial parent text, the latest 12 turns, and at most 2,000 characters per parent answer. Add an agreed bound for included questions and an overall UTF-8 payload limit at both ends. Proposed response limits are 600 characters of guidance, one question of at most 240 characters, and at most five cues of at most 240 characters each. Final operational limits require review.

The proxy validates the response structure and size. Authorship and appropriate coaching still need actual scenario review: a valid JSON shape alone cannot establish that the service respects the parent's choices, avoids complete-story generation, or avoids unsupported cultural/diagnostic claims.

Prepare cues before microphone capture. Neither operation receives audio, runs during narration, speaks output, or starts recording. A cue failure can offer clearly labeled generic text cues. A coaching failure preserves parent input and offers retry or continue-to-recording; it never silently substitutes demo coaching as a live response.

## Errors and cancellation

Return a bounded error envelope containing `requestID`, a stable `code`, a safe `message`, and `retryable`. Handle invalid input, unauthorized requests, usage limits, provider unavailability, timeout and invalid results distinctly. Do not send raw provider errors or credentials to the app.

Propose a 30-second client timeout, server/provider timeouts below that limit, no automatic paid retry, and server-enforced request/usage caps. Cancelling a `URLSession` task stops the app waiting; it must not promise that provider processing or billing was cancelled. Keep the existing request-identity guards so late replies cannot overwrite a newer session.

## Data and secrets

- Show which parent text leaves the device and require a deliberate action before the first live request.
- Send only the bounded coaching context; omit audio, personal story-library contents, device contacts, account profiles and unrelated stored metadata.
- Keep provider credentials server-side. Do not put a provider key or shared proxy secret in the app.
- Choose and review client authentication and abuse controls before enabling live requests. A public unrestricted proxy is not a ready implementation.
- Do not persist coaching request/response bodies or include them in ordinary logs. Document the provider's actual retention behavior separately; this proposal makes no provider-retention guarantee.

## Decisions required before implementation

Confirm the proposed backend scope and owner, then record the actual project/endpoint, configuration delivery, authentication settings, provider/model capability, usage budget/enforced limits, and retention behavior. Ticket 10 explicitly requires reviewed backend scope if this project must create the proxy. The recommendation above has not created or authorized a hosting account, server-language exception, deployment, paid service or new framework.

The implementation demonstration must show parent action → actual live response → original recording/private save, followed by unavailable-service recovery without losing input. Until the required endpoint and decisions exist, keep ticket 10 `needs-info` and the installed app honestly labeled as demo coaching.
