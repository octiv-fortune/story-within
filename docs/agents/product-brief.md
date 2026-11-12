# Story Within — MVP Implementation Brief

**Platform:** Native iOS  
**Technology:** Swift, SwiftUI  
**Project type:** OpenAI × Andela African Storytelling Capstone  
**Primary track:** Creation & Craft  
**Supporting tracks:** Voices & Languages, Discovery & Audience  
**Status:** Implementation specification v1.0

## 1. Product Overview

**Story Within** is an AI-assisted African storytelling companion that helps parents create, narrate, translate, and share original stories inspired by African folklore, oral storytelling traditions, and lived experiences.

The application supports inclusive storytelling for children with different interests, communication preferences, and sensory needs, with particular consideration for autistic and other neurodivergent children.

Our guiding principle:

**AI doesn't tell the story. The parent does.**

AI acts as a storytelling coach, supporting the parent's imagination rather than replacing their creativity or cultural knowledge.

**Tagline:** African stories. Your voice. Their world.

## 2. Product Goals

The MVP must demonstrate that a parent can:

1. Start with a creative story idea or something their child is experiencing.
2. Receive conversational AI guidance on developing the story.
3. Record an original story in their own voice.
4. Request optional storytelling hints without being interrupted.
5. Review and play back the recording.
6. Transcribe the recording into editable text.
7. Translate the story into a selected African language.
8. Save the story privately or choose to publish it.
9. Browse and listen to stories in a community library.

The primary objective is a credible, end-to-end storytelling experience, not a production-ready social platform.

## 3. Target Users

### Primary user: Parent or caregiver

An African parent who wants to create meaningful, culturally relevant stories for their child but may not have formal storytelling or writing experience.

### Secondary user: Child

A child who listens to stories created by their parent or discovered through the community library.

Children are not required to create accounts or interact directly with the AI.

### Inclusive storytelling

Parents can describe preferences such as:

- Familiar and recurring characters
- Predictable story structures
- Shorter sentences
- Repetition
- Emotional themes
- Favourite animals, places, or interests
- Communication and sensory preferences

These preferences guide storytelling suggestions. The app must not infer a diagnosis, provide medical advice, or claim therapeutic outcomes.

## 4. Core User Journey

### Screen 1 — Home

A welcoming storytelling home screen.

**Elements:**
- Story Within branding
- Featured introductory message
- Primary action: **Create a Story**
- Secondary action: **Explore Stories**
- Recently created stories, if available

The visual presentation should feel warm, imaginative, and rooted in African storytelling rather than resembling a generic AI chatbot.

### Screen 2 — Start a Story

Offer two starting options:

**Start with an idea:** The parent already has a story concept.

Example: "I want to tell a story about a magical tortoise living near a river."

**Start with your child:** The parent has identified an interest, emotion, or preference.

Example: "My child loves animals and enjoys stories with familiar characters."

Both options lead to the same conversational storytelling coach.

### Screen 3 — AI Storytelling Coach

This is the application's defining feature.

The AI behaves as a conversational storytelling companion, asking one thoughtful question at a time.

It can guide the parent through:
- Setting and cultural context
- Characters and their personalities
- Conflict and adventure
- Humour and magical elements
- Emotional themes
- Storytelling structure and pacing
- Consideration of the child's preferences

**Interaction requirements:**
- Text-based conversation
- Contextual AI questions and suggestions
- One primary question at a time
- Ability to skip suggestions
- Ability to finish coaching and begin recording at any point
- Preserve the parent's creative decisions

**Important:** AI must not automatically write a complete story unless that capability is explicitly introduced in a future version.

The coach should encourage authentic cultural expression without inventing claims about particular African traditions.

### Screen 4 — Storytelling Studio

A distraction-free recording interface.

**Elements:**
- Working story title
- Record, pause, resume, and stop controls
- Recording duration
- Optional simple audio visualization
- Storytelling hint card
- "Need inspiration?" action

Parents narrate naturally in their preferred language.

The AI must never interrupt recording or automatically speak over the parent.

The parent can pause and request the next prepared storytelling hint, then resume recording.

**MVP simplification:** Prepare contextual hints from the initial coaching conversation. Real-time AI analysis of narration is not required.

Recording and playback must be functional, not simulated.

### Screen 5 — Review Your Story

After recording, display:

- Story title (editable)
- Original recording with playback controls
- Story theme
- Original language
- Editable transcript
- Translation action
- Save story action

The parent must be able to review the story before saving or publishing it.

Transcription errors must be editable.

### Screen 6 — Translation

Allow the parent to select a supported target language and generate a text translation.

For the prototype, begin with a small, explicitly tested set of languages. Prioritize isiZulu and at least one additional African language, but validate transcription and translation quality before committing to a language pair.

**Requirements:**
- Display original text alongside translated text
- Permit manual corrections
- Preserve the original language version
- Clearly distinguish AI-generated translations from reviewed content
- Never claim that a translation is culturally or linguistically verified without actual review

Audio playback remains in the original parent's voice. Translated speech and voice cloning are outside the MVP.

### Screen 7 — Save or Publish

The parent chooses between:

**Private:** Save the story to their personal library.

**Community:** Publish the story so other families can discover it.

Publishing must require explicit confirmation and a clear explanation that the original voice recording may become accessible to others.

Parents retain attribution and control over their stories.

### Screen 8 — Community Library

A browsable collection of African-inspired stories.

**Elements:**
- Story cards
- Story title
- Creator attribution
- Language
- Theme or category
- Audio playback
- Available text translations

Provide a small collection of original, permission-cleared demo stories.

For the first proof of concept, a local seeded community library is acceptable. If cross-device publishing is demonstrated, it must use a functional backend rather than simulated sharing.

## 5. Visual Design Direction — Mobbin

Use Mobbin as the primary design research resource.

We have identified these initial iOS references:

- [Comet — conversational AI interface](https://mobbin.com/screens/53bbb46b-728b-435d-8565-935d856601a7)
- [5 Minute Journal — journaling/recording interface](https://mobbin.com/screens/8e6b4db2-01af-4cff-8b41-779db7096c50)
- [Apple Books — book discovery interface](https://mobbin.com/screens/b836f3da-8d07-48b4-8f20-e3c40ec6b30c)
- [Duolingo ABC — child-focused reading interface](https://mobbin.com/screens/de3f7d7f-5d0c-4603-b313-84bcbe110833)

Before implementing each primary screen, inspect relevant Mobbin examples and document useful interaction and layout patterns.

The objective is to learn from established iOS patterns, not replicate those screens.

### Proposed brand direction

**Mood:** Warm, imaginative, approachable, premium, culturally grounded.

**Initial colour palette:**
- Deep forest green: `#183E34`
- Warm ivory: `#F8F4EA`
- Terracotta accent: `#C47A56`
- Dark text: `#243B31`

Use Apple's system typography with rounded accents where appropriate.

Prefer generous spacing, clear hierarchy, tactile story cards, and restrained illustration.

Avoid excessive animation or visually overwhelming interfaces.

### Accessibility

Support:
- Dynamic Type
- VoiceOver labels
- Sufficient colour contrast
- Reduced motion
- Clear recording states
- Predictable navigation
- No autoplaying audio
- Large, understandable touch targets

These features should support the experience for all users, not be presented as a one-size-fits-all solution for autistic children.

## 6. Technical Architecture

### Native iOS

Use:

- **SwiftUI** — user interface and navigation
- **Swift** — application logic
- **AVFoundation** — audio recording and playback
- **SwiftData** — local story and draft persistence
- **URLSession** — networking
- **MVVM or similarly lightweight feature-based architecture** — separation of presentation and application logic

Target iOS 17 or later for the initial proof of concept.

Avoid unnecessary third-party libraries.

### Suggested project organization

```text
StoryWithin/
  App/
  Core/
    Theme/
    Components/
    Networking/
    Models/
  Features/
    Home/
    StoryCoach/
    Recording/
    StoryReview/
    Translation/
    Library/
  Services/
    AudioRecordingService.swift
    AudioPlaybackService.swift
    StoryCoachService.swift
    TranscriptionService.swift
    TranslationService.swift
    StoryRepository.swift
  Resources/
```

Service boundaries matter more than an elaborate architecture.

### AI integration

Define service protocols with live and mock implementations.

**StoryCoachService**
- Receives parent input and relevant story context
- Returns a conversational response and optional storytelling cues

**TranscriptionService**
- Receives recorded audio
- Returns editable transcript text and language information where supported

**TranslationService**
- Receives source text and target language
- Returns an editable translation

Start with deterministic mock implementations to build and test the UI.

Integrate real AI services after the core journey works.

For real cloud AI calls, use a secure backend proxy. Never embed provider API secrets in the iOS application.

Do not present simulated AI or translated output as live functionality during the capstone demonstration.

### Persistence

Store story drafts locally.

A story should minimally contain:
- ID
- Title
- Creator display name
- Source language
- Theme
- Audio file reference
- Original transcript
- Optional translations
- Visibility: private or community
- Created/updated timestamps

Coaching context can remain session-scoped. The MVP does not require detailed child profiles.

### Optional backend

If time permits, add a lightweight backend for:
- Published story metadata
- Audio storage
- Community browsing
- AI service proxies

A managed backend such as Supabase is a reasonable option, but is not required for the initial local proof of concept.

If remote publishing is implemented, authentication, access controls, and storage permissions must be functional.

## 7. Safety, Privacy and Authorship

- Stories are private by default.
- Publishing requires explicit parental consent.
- Clearly identify when audio is publicly shared.
- Do not collect unnecessary personal information about children.
- Do not publish child-specific descriptions supplied during coaching without explicit review and consent.
- Never use a parent's recording for voice cloning.
- Preserve creator attribution.
- Only use original or properly licensed story content.
- Provide a means to withdraw published stories.
- Do not make unsupported educational or therapeutic claims.
- Treat AI transcription, translation, and cultural suggestions as fallible and reviewable.

## 8. Scope and Priorities

### P0 — Essential demonstration

- Native SwiftUI project
- Cohesive branded UI
- Create story from an idea or child preference
- Conversational coach, with mock support initially
- Prepared storytelling hints
- Functional audio recording
- Pause, resume, stop, playback
- Story review
- Local draft persistence
- Community library populated with original demo content

### P1 — Complete capstone experience

- Real AI coaching integration
- Audio transcription
- Editable translations
- Private/published story workflow
- Real backend publishing and cross-device discovery, if achievable

The intended final demonstration includes transcription and translation. These should be prioritized after the recording and coaching flows are stable.

### Explicitly out of scope

- Automatic adaptation of copyrighted folktales
- AI-generated complete stories
- AI-generated illustrations
- Voice cloning
- Real-time AI analysis during narration
- Medical or developmental assessments
- Subscriptions and payments
- Child-facing AI chat
- Complex recommendation algorithms

## 9. Acceptance Criteria

The prototype is ready for demonstration when:

1. A parent can open Story Within and begin a story.
2. They can choose either starting approach.
3. The coach provides understandable, contextual guidance.
4. They can enter the recording studio and record actual audio.
5. They can pause, resume, and request hints without losing the recording.
6. They can replay the recorded story.
7. They can save and reopen their story.
8. They can view and edit a transcript when transcription is available.
9. They can view and edit an explicitly labeled translation when available.
10. They can choose private or community visibility.
11. They can browse and play demo stories in the community library.
12. The app does not crash during the complete demo journey.

Any capabilities still using mocks must be clearly identified.

## 10. Implementation Sequence for Codex

**Phase 1 — Foundation and design**
- Create a native Xcode project.
- Define theme, components, navigation, and sample models.
- Inspect relevant Mobbin references.
- Implement home and story-start screens.

**Phase 2 — Storytelling coach**
- Build conversational UI.
- Implement a mock coaching service.
- Support both starting approaches.
- Generate or prepare optional story prompts.

**Phase 3 — Recording studio**
- Implement real recording, pause, resume, and playback.
- Integrate prepared storytelling prompts.
- Save audio to local storage.

**Phase 4 — Story review and language services**
- Build review and editing screens.
- Integrate transcription and translation services.
- Allow corrections before saving or sharing.

**Phase 5 — Library and publishing**
- Implement personal story storage.
- Build the community library with demo content.
- Add publishing controls.
- Introduce real backend sharing if time allows.

**Phase 6 — Demo readiness**
- Polish navigation and accessibility.
- Test on iOS Simulator and physical iPhone.
- Prepare one complete sample storytelling journey.
- Record a walkthrough for the judges.

## 11. Demo Scenario

A parent wants to create a story for their child, who enjoys magical animals and familiar, predictable storytelling.

They open Story Within, describe a magical tortoise in a South African setting, and explain their child's preferences.

The AI coach asks a few helpful questions.

The parent begins narrating, pauses once to request inspiration, and completes their story.

They listen to their recording, review its transcript, generate a translation, and save the story.

Finally, they choose to publish it and show how another family could discover and listen to it.

**The central demonstration is not AI generating a story. It is AI helping an African parent become the author of one.**

## 12. Instructions for Codex

Build incrementally and prioritize a working vertical slice over unnecessary abstraction.

Before each implementation phase:

1. Explain the intended changes briefly.
2. Identify which features will be real and which will use mocks.
3. Use Mobbin references to inform relevant screen designs.
4. Implement and validate the smallest meaningful portion.
5. Check for build errors and regressions.
6. Keep the project runnable throughout development.

Do not expand scope without approval.

Do not replace native SwiftUI with a web-based interface or cross-platform framework.

Maintain Story Within's central principle throughout implementation:

**AI supports the storyteller. It never replaces them.**
