# Apple on-device coaching: approved MVP route

Decision: on 2026-11-12 the user chose Apple on-device English coaching first, retaining clearly labeled demo mode on unsupported devices. See [ticket 10](issues/10-live-storytelling-coach.md).

Apple's [Foundation Models framework](https://developer.apple.com/foundation-models-framework/) exposes on-device text generation through Swift. That is the relevant in-app coaching API; a Siri interaction is not needed for this slice. Short contextual guidance, one question, and prepared text cues are a suitable architectural fit, subject to actual prompt/output scenario testing.

The framework was introduced with iOS 26 and can run offline without per-request inference charges on eligible devices when Apple Intelligence is available. [Apple's introduction](https://www.apple.com/newsroom/2025/09/apples-foundation-models-framework-unlocks-new-intelligent-app-experiences/)

The user's iPhone 15 Pro is eligible hardware, but this is not an observed runtime availability result. Check the model in the actual app. [Device and language requirements](https://support.apple.com/en-us/121115)

Use availability-guarded native code so the iOS 17 app still launches with demo coaching on older devices. Model availability can change; failed real requests need truthful retry/continue handling. The documented on-device context limit is 4,096 tokens across instructions, input and output, so adapt the existing bounded context to this smaller model budget. [Generation and availability](https://developer.apple.com/documentation/foundationmodels/generating-content-and-performing-tasks-with-foundation-models.md)

English is the current coaching scope. isiZulu/isiXhosa are not listed in the current supported-language set, so this decision does not validate African-language translation. Preserve the separate language-service tickets. [Language handling](https://developer.apple.com/documentation/foundationmodels/supporting-languages-and-locales-with-foundation-models.md)

No cloud account, API key, authentication service or proxy is needed for this local coaching slice. Preferences and conversation stay session-only on device; recording remains AVFoundation and the parent remains the storyteller. Accessibility checks remain explicitly deferred by the user.
