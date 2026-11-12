# Minimal live coaching proxy proposal

Status: draft for review; no endpoint exists and no backend implementation or deployment is authorized by this proposal.
Related work: [ticket 10](issues/10-live-storytelling-coach.md), [approved specification](spec.md).

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

Record the backend owner and approved hosting/runtime, endpoint/configuration delivery, client authentication method, provider/model capability, usage budget and enforced limits, and actual retention behavior. Ticket 10 explicitly requires reviewed backend scope if this project must create the proxy. No hosting account, language/runtime exception, deployment, paid service or new framework is selected here.

The implementation demonstration must show parent action → actual live response → original recording/private save, followed by unavailable-service recovery without losing input. Until the required endpoint and decisions exist, keep ticket 10 `needs-info` and the installed app honestly labeled as demo coaching.
