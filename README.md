# Daily Tarot

Daily Tarot is a SwiftUI iOS app with a WidgetKit extension for daily tarot guidance. The app fetches a daily reading from an n8n webhook, renders the card artwork and interpretation in the main app, and exposes glanceable home-screen widgets for the same reading.

The project also includes an "Ask the Cards" flow that posts a user question to a separate webhook and renders a three-card past, present, and future spread.

## Features

- Daily tarot reading screen with card artwork, orientation, meaning, full reading text, keywords, and love/career/energy metrics.
- Flippable card views that reveal imagery and symbolism details.
- Question flow for three-card guidance backed by a POST webhook.
- WidgetKit extension with three widgets:
  - `DailyTarotKeywordsWidget`: small widget focused on the card meaning.
  - `DailyTarotMetricsWidget`: medium widget focused on love, career, and energy scores.
  - `DailyTarotSummaryWidget`: medium widget focused on a short reading summary.
- Shared model and networking code between the app target and widget target.
- Placeholder/fallback reading so the UI stays usable when the network or webhook fails.

## Repository Structure

```text
DailyTarot/
  DailyTarot.xcodeproj/
    xcshareddata/xcschemes/          Shared app and widget schemes
  DailyTarot/
    App/                            Main app views and view models
      ContentView.swift             Daily reading home screen
      AskTarotQuestionView.swift    Three-card question flow
      DailyTarotHomeViewModel.swift App-side daily reading loader
      TarotReferenceViews.swift     Shared card artwork and flip views
      DailyTarotApp.swift           App entry point
    Shared/
      Config/
        DailyTarotConfiguration.swift  Webhook URL configuration
      Models/
        DailyTarotReading.swift        Daily reading model, metrics, fallbacks
      Networking/
        DailyTarotClient.swift         Daily/question API client and image fetches
    Assets.xcassets/
  DailyTarotWidgetExtension/
    DailyTarotWidgetExtensionBundle.swift  Widget bundle entry point
    DailyTarotWidget.swift                 Widget definitions
    DailyTarotWidgetProvider.swift         Timeline provider and refresh policy
    DailyTarotWidgetEntry.swift            Timeline entry model
    DailyTarotWidgetView.swift             Small/medium widget layouts
    Assets.xcassets/
  docs/
    ios-widget-setup.md               Widget setup and troubleshooting notes
```

The git repository root is the nested `DailyTarot/` project folder. Local Xcode build products such as derived data should stay outside the repo.

## Requirements

- Xcode with SwiftUI and WidgetKit support.
- iOS target that supports WidgetKit and `containerBackground(for: .widget)`.
- Network access to the configured n8n webhook endpoints.
- No third-party package dependencies are currently used.

## Getting Started

1. Open `DailyTarot.xcodeproj` in Xcode.
2. Select the `DailyTarot` scheme.
3. Build and run the app on an iPhone simulator or device.
4. Confirm the daily reading loads.
5. Select one of the widget schemes (`DailyTarotKeywordsWidget`, `DailyTarotMetricsWidget`, or `DailyTarotSummaryWidget`) to run or preview widget behavior.

If the app or widget shows placeholder content, check the webhook URLs and JSON shape first.

## Webhook Configuration

Webhook URLs live in:

```text
DailyTarot/Shared/Config/DailyTarotConfiguration.swift
```

Current configuration keys:

- `dailyWebhookURLString`: GET endpoint for the daily reading.
- `questionWebhookURLString`: POST endpoint for the question-based spread.

Important: these URLs are committed in source and visible to anyone with access to the repo. Do not put secrets, private tokens, or admin-only webhook URLs in this file. If the project is distributed publicly, use endpoints that are safe for public clients or move sensitive logic behind a server-side proxy.

## Daily Reading API Contract

`DailyTarotClient.fetchDailyReading()` expects the daily webhook to return JSON compatible with `DailyTarotReading`.

Expected fields include:

```json
{
  "title": "Daily Tarot",
  "date": "2026-03-15",
  "card_name": "The Star",
  "card_short": "ar17",
  "orientation": "upright",
  "meaning_up": "Hope, spiritual clarity, and renewal.",
  "meaning_rev": "Doubt, fatigue, and disconnection.",
  "desc": "A visual description of the card.",
  "display_meaning": "Meaning selected for the current orientation.",
  "short_summary": "A compact summary for widgets.",
  "keywords": ["Hope", "Clarity", "Renewal"],
  "reading": "The full daily reading text.",
  "image_url": "https://example.com/card.jpg",
  "metrics": [
    { "key": "love", "label": "Love", "score": 78 },
    { "key": "career", "label": "Career", "score": 64 },
    { "key": "energy", "label": "Energy", "score": 83 }
  ]
}
```

Notes:

- `date` is parsed as `yyyy-MM-dd`.
- `orientation` is treated as reversed only when its trimmed lowercase value is `reversed`; all other values render upright.
- Metric scores are clamped to `0...100`.
- If metrics are missing, love/career/energy default to `50`.
- `keywords` may be an array or a delimited string; the model sanitizes and falls back when needed.
- `image_url` must be reachable by the app and widget. Widgets download image data during timeline creation.

## Question API Contract

`DailyTarotClient.askQuestion(_:)` sends:

```json
{
  "question": "Should I accept this opportunity?"
}
```

The question webhook should return:

```json
{
  "question": "Should I accept this opportunity?",
  "spread_type": "past-present-future",
  "cards": [
    {
      "position": "past",
      "card_name": "The Star",
      "card_short": "ar17",
      "orientation": "upright",
      "meaning_up": "Hope and renewal.",
      "meaning_rev": "Doubt and disconnection.",
      "desc": "A visual description of the card.",
      "display_meaning": "Hope and renewal.",
      "image_url": "https://example.com/card.jpg"
    }
  ],
  "answer": "A concise synthesized answer for the spread."
}
```

The UI is designed around three cards, but the view iterates over the returned `cards` array.

## Widget Behavior

- The widget extension shares `DailyTarotConfiguration`, `DailyTarotReading`, and `DailyTarotClient` with the main app target.
- `DailyTarotWidgetProvider` fetches a reading and image data for each timeline entry.
- Successful widget timelines request the next refresh five minutes after the next local midnight.
- Fallback timelines retry after 30 minutes.
- iOS controls the final widget refresh timing, so the widget may not update exactly at midnight.
- The app calls `WidgetCenter.shared.reloadAllTimelines()` after a successful daily reading load.

There is no App Group cache yet. The app and widget can currently make separate network requests. A practical future improvement is to cache the latest reading in an App Group so both targets share one fetched result.

## Maintenance Notes

- Keep shared models and networking code in `DailyTarot/Shared/` so the app and widgets decode the same backend contract.
- When adding files under `DailyTarot/Shared/`, ensure target membership includes both the app target and widget extension target.
- Keep widget UI compact. Widget text should tolerate long card names, missing images, and fallback data.
- Avoid committing Xcode derived data, simulator logs, build products, or local-only provisioning artifacts.
- See `docs/ios-widget-setup.md` for widget setup details and common troubleshooting cases.
