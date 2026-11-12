# Story Within app icon

An ivory open book with a terracotta voice rising from its spine, on the app's forest-green background. The mark represents the parent's voice and imagination.

Generated with the built-in imagegen tool, then downsampled to a 1024 × 1024 opaque PNG with macOS `sips`. The same asset is used in the README. iOS applies the Home Screen corner mask; the source artwork remains square. Debug and Release select the `AppIcon` asset set. This uses Apple's [single-image asset-catalog configuration](https://developer.apple.com/documentation/xcode/configuring-your-app-icon).

## Verification

On 2026-11-12, the unchanged merged main branch passed a Debug simulator build before this change. The icon build then passed signed Debug iOS and unsigned Release iOS builds. Both built app bundles contain `AppIcon` primary-icon metadata for iPhone and iPad, plus compiled icon PNGs. The 1024 × 1024 source PNG has no alpha channel; its small-size preview was visually checked. The signed build was installed in place on the existing demo iPhone 15 Pro.

## Generation prompt

```text
Use case: logo-brand. Asset type: production iOS app icon for Story Within, a parent-led oral storytelling and recording app. Create ONE polished square icon, 1024 by 1024 pixels, full bleed opaque background, no external margins and no pre-rounded app-icon corners. Flat vector-like geometric design with subtle warm depth: a bold ivory open book at the lower center, its two curved pages forming a welcoming cradle, and above its central spine a small terracotta flowing speech/voice flame made of two graceful curved shapes, suggesting a story rising from someone's own voice. Deep forest green background #183E34, warm ivory #F8F4EA, restrained terracotta #C47A56. The silhouette should be distinctive, calm, human and beautifully legible at 60 pixels. Central composition, generous internal safe margin about 18 percent, just one integrated book-and-voice mark. Rounded confident shapes, sophisticated minimal editorial character. No words, no lettering, no microphones, no people, no sparkle stars, no gradients, no tiny details, no border, no device mockup, no shadows outside the icon, no branding from other apps. Deliver just the icon artwork filling the square.
```
