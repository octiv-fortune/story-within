# 07: Discover and listen to original demo stories

Status: resolved
Approval: Ticket breakdown approved by the user on 2026-11-12; GitHub publication authorized.
Implementation gate: Authorized by the user on 2026-11-12; follow the approved dependency graph and retain unmet external prerequisites.
GitHub publication: Published and linked to the parent specification.
GitHub issue: https://github.com/octiv-fortune/story-within/issues/8
Milestone: M1
Blocked by: 01: Record, privately save, and replay a story
GitHub blockers: https://github.com/octiv-fortune/story-within/issues/2
External prerequisites: At least two original/permission-cleared human demo recordings with attribution and permission evidence. Content must be supplied or recorded with permission; never invent a license or reviewer.
Spec acceptance: AC-01, AC-12, AC-14, AC-15
Parent specification: [Approved Story Within specification](../spec.md) (approved in chat on 2026-11-12).

## What to build

A family can open Explore, choose a permission-cleared story, inspect attribution and language, and listen to an actual human recording without needing a network.

## Acceptance criteria

- [x] Bundle a small collection of at least two original or permission-cleared stories with actual human recordings and recorded content permissions/attribution; silence or generated placeholder audio does not satisfy this ticket.
- [x] Discovery cards and story detail expose title, creator, source language, and theme, plus any text/translation actually supplied with accurate provenance.
- [x] All bundled entries are identified as demo content; seed identities remain stable and relaunching never duplicates the collection.
- [x] Play, pause, replay, duration, and switching between stories work offline. Only one story plays at a time; entering capture stops playback; nothing autoplays.
- [x] Empty, missing-asset, and playback-error states are actionable and do not corrupt personal stories.
- [x] Workflow checks verify seed idempotence and discovery/player selection; manual listening confirms that every bundled recording is audible and permission-cleared.

## Demonstration

Open Explore offline, inspect two attributed stories, play each in turn, and relaunch to confirm the collection is not duplicated.

## Delivery constraints and verification

Use native Swift/SwiftUI and Apple frameworks only. Keep recording/playback real in the app. Inspect and document relevant Mobbin patterns before implementing a new primary screen; adapt interactions without screen copying. Apply Dynamic Type, VoiceOver, contrast, Reduce Motion, clear state and large touch targets to each changed flow. Verify the user-visible behavior at the agreed app-workflow seam with temporary storage/deterministic services, and keep the build and relevant checks green. Tests using audio doubles do not establish device microphone behavior.

Depends on 01 for the app navigation and functioning shared playback boundary; does not require personal text editing or coaching.

## Comments

- 2026-11-12: Proposed with to-tickets following specification approval. Ticket approval is pending. Dependencies are implementation prerequisites, not authorization to start. M1 delivery is prioritized before M2 rollout; independent M2 service paths intentionally do not block one another. External prerequisites remain real blockers even when not represented by ticket numbers. After approval, only sufficiently specified/unblocked work becomes ready-for-agent; unresolved service/content/device prerequisites remain visible. No feature implementation or GitHub publication has occurred.


- 2026-11-12: The user approved this ticket and the dependency graph and authorized GitHub publication. Implementation remains ON HOLD. The triage status describes specification/prerequisite readiness, not authorization to execute; needs-info tickets retain the external content, service, review, or device prerequisites stated above.

- 2026-11-12: Published as https://github.com/octiv-fortune/story-within/issues/8; native sub-issue and blocking relationships preserved. Implementation remains ON HOLD.

- 2026-11-12: The user resumed implementation with implement-spec, starting at the first unblocked ticket, and required native build verification before changes. The prior implementation hold is revoked.

- 2026-11-12: Original-publisher CC BY3.0 human recordings acquired unchanged from Storybooks Canada (Anansi and Wisdom; Goat, Dog, and Cow), with narrator/source credits, permission links and SHA256 metadata. Full Apple PCM decoding passed with nonzero signal. App playback/manual listening still require ticket verification. Ticket claimed in isolated worktree; acquisition does not by itself mark acceptance complete. Shared evidence/assets: /private/tmp/story-within-demo-audio and /private/tmp/story-within-research/demo-audio.md.

- 2026-11-12: No-ff merge `0d556cb81e7f9fbe40d8c50f586ba0f79b06398f` integrated candidate `1009f9f1266c687dbfa8c3c3889b614235784ac8` from `codex/story-within-ticket-07`, including accepted tickets 02/03/06 and the user-reported playback contrast correction. The merge was conflict-free; its committed tree exactly matched the reviewed candidate. The coordinating review found no concrete defect in read-only bundled discovery, shared player guards, separate personal storage, and source/narrator/license credits. The known root Xcode project formatting change was preserved byte-for-byte, remained unstaged, and has parsed-plist identity with the committed project; no other unexpected edits were present.

- 2026-11-12: The bundled unchanged MP3 human recordings are Anansi and Wisdom and Goat, Dog, and Cow, narrated by Darshan Soni. CC BY 3.0 permission/source links, separate author/narrator credits, acquisition metadata and SHA256 values are retained in [attribution](../../../StoryWithin/DemoStories/ATTRIBUTION.md), the bundled manifest, and [ticket 07 evidence](../evidence/ticket-07.md). Demo content stays read-only outside SwiftData/personal recording ownership. Automated native MP3 decode/playback does not establish human full-recording listening.

- 2026-11-12: Combined verification passed **36 native workflow tests**, including real AVAudioPlayer MP3 play/clock/pause/replay/switch/duration and every accepted recording/library/coaching case: `/private/tmp/story-within-07-coach-combined.log`. The later styling-only correction gives both personal/demo Play/Pause labels explicit white foreground and forest tint, and Replay explicit forest labels; no audio/state/storage behavior changed. Debug and Release builds passed after that correction. One merged integration generic Debug iOS Simulator build passed with signing disabled: `/private/tmp/story-within-integration-ticket07.log`; outputs: `/private/tmp/story-within-integration-ticket07`. Identical candidate source required no duplicate full-suite run.

- 2026-11-12: Status remains **claimed** pending human full-recording listening and device playback/credits verification. The user clarified recording works perfectly and reported only illegible Play colors; the corrected personal/demo controls still require rendered device recheck. Ticket 02 remains claimed until that follow-up. Physical/visual/VoiceOver/large-Dynamic-Type checks are not inferred from compilation or automated playback. The coordinating agent owns the corrected phone installation and user check; no phone or GitHub action occurred during this merge.

- 2026-11-12: Root verified original publisher CC BY3.0 permissions and unchanged asset hashes; full Apple PCM decode passed, actual AVAudioPlayer behavior tests passed in app on iOS17.5, combined36workflow tests/Debug/Release green. User confirmed both demo recordings audibly play with readable controls on physical iPhone. Whole-story cultural/linguistic verification and full VoiceOver walkthrough are not claimed.

## Answer

Resolved on codex/story-within-mvp after native automated checks and the user-observed physical verification above. See evidence/ticket-07.md and implementation.md.
