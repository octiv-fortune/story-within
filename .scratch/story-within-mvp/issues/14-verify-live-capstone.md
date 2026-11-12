# 14: Verify and demonstrate the complete live capstone journey

Status: needs-info
Approval: Ticket breakdown approved by the user on 2026-11-12; GitHub publication authorized.
Implementation gate: Authorized by the user on 2026-11-12; follow the approved dependency graph and retain unmet external prerequisites.
GitHub publication: Published and linked to the parent specification.
GitHub issue: https://github.com/octiv-fortune/story-within/issues/15
Milestone: M2 verification gate
Blocked by: 09: Verify the complete local MVP on simulator and iPhone; 10: Coach a parent's story through the live service; 11: Transcribe a real recording and preserve parent corrections; 13: Offer isiXhosa as a second validated African translation target
GitHub blockers: https://github.com/octiv-fortune/story-within/issues/10, https://github.com/octiv-fortune/story-within/issues/11, https://github.com/octiv-fortune/story-within/issues/12, https://github.com/octiv-fortune/story-within/issues/14
External prerequisites: Physical iPhone, live proxy operations for all three AI capabilities, qualified language reviews, and permission-cleared human demo content.
Spec acceptance: AC-04, AC-14, AC-15, AC-16, AC-17, AC-18, AC-19, AC-20, AC-21, AC-22, AC-23, AC-24
Parent specification: [Approved Story Within specification](../spec.md) (approved in chat on 2026-11-12).

## What to build

A parent can complete the intended capstone journey with real narration, live language services, durable edits, and accurately scoped community discovery, with reproducible demonstration evidence.

## Acceptance criteria

- [ ] On a physical iPhone, complete idea/child preference → live coaching → real recording → pause/hint/resume → playback → consented live transcription → edit → live translation → correction → private save/relaunch → local preview/withdrawal and bundled discovery without crashing.
- [ ] Both validated African translation targets and claimed transcription languages have recorded service checks and competent review; sample fixtures remain labeled and no unavailable capability is presented as live.
- [ ] Exercise slow/failing/cancelled live requests, denied audio access, offline local fallback chosen explicitly by the parent, stale text responses, and save failures without losing recordings, parent edits, or privacy.
- [ ] Native workflow/contract checks, UI smoke journey, Debug simulator build, and Release iOS compilation pass. Record oldest-OS/device/signing gaps and recheck Dynamic Type, VoiceOver, contrast/targets, Reduce Motion, and no autoplay through the added screens.
- [ ] Verify provider secrets are absent from the device bundle and content-bearing logs; verify cloud disclosure and private defaults, and confirm coaching/child context is absent from discoverable metadata.
- [ ] Prepare a walkthrough and real/demo/unavailable capability inventory. Explicitly state that new community stories are local previews, so no second-device publishing claim is made.
- [ ] Record remaining limitations and evidence links; do not mark the milestone complete when live service, language review, device audio, or other required acceptance evidence is missing.

## Demonstration

Run and record the capstone tortoise-story scenario with live text services and real parent audio, then demonstrate a service failure and the retained private story.

## Delivery constraints and verification

Use native Swift/SwiftUI and Apple frameworks only. Keep recording/playback real in the app. Inspect and document relevant Mobbin patterns before implementing a new primary screen; adapt interactions without screen copying. Apply Dynamic Type, VoiceOver, contrast, Reduce Motion, clear state and large touch targets to each changed flow. Verify the user-visible behavior at the agreed app-workflow seam with temporary storage/deterministic services, and keep the build and relevant checks green. Tests using audio doubles do not establish device microphone behavior.

M3 remote publication/cross-device discovery remains conditional and is not ticketed or authorized by this plan. This gate verifies the integrated result; tests, accessibility, and privacy behavior belong in their individual slices from the start.

## Comments

- 2026-11-12: Proposed with to-tickets following specification approval. Ticket approval is pending. Dependencies are implementation prerequisites, not authorization to start. M1 delivery is prioritized before M2 rollout; independent M2 service paths intentionally do not block one another. External prerequisites remain real blockers even when not represented by ticket numbers. After approval, only sufficiently specified/unblocked work becomes ready-for-agent; unresolved service/content/device prerequisites remain visible. No feature implementation or GitHub publication has occurred.


- 2026-11-12: The user approved this ticket and the dependency graph and authorized GitHub publication. Implementation remains ON HOLD. The triage status describes specification/prerequisite readiness, not authorization to execute; needs-info tickets retain the external content, service, review, or device prerequisites stated above.

- 2026-11-12: Published as https://github.com/octiv-fortune/story-within/issues/15; native sub-issue and blocking relationships preserved. Implementation remains ON HOLD.

- 2026-11-12: The user resumed implementation with implement-spec, starting at the first unblocked ticket, and required native build verification before changes. The prior implementation hold is revoked.
