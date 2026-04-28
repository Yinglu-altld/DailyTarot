# Daily Tarot iOS Widget Setup

This project now has a shared tarot model and API client inside the app target. The widget extension should reuse those files instead of creating a second network layer.

## Recommended structure

```text
DailyTarot/
  DailyTarot/
    App/
      ContentView.swift
      DailyTarotApp.swift
      DailyTarotHomeViewModel.swift
    Shared/
      Config/
        DailyTarotConfiguration.swift
      Models/
        DailyTarotReading.swift
      Networking/
        DailyTarotClient.swift
    Assets.xcassets
  DailyTarotWidgetExtension/
    DailyTarotWidget.swift
    DailyTarotWidgetEntry.swift
    DailyTarotWidgetProvider.swift
    DailyTarotWidgetView.swift
  docs/
    ios-widget-setup.md
```

## 1. Connect your production webhook

Open `DailyTarot/DailyTarot/Shared/Config/DailyTarotConfiguration.swift` and replace the empty string:

```swift
static let webhookURLString = "https://YOUR-PRODUCTION-N8N-WEBHOOK-URL"
```

Use the real HTTPS production webhook URL from n8n. Do not use HTTP unless you also add an App Transport Security exception.

## 2. Create the Widget Extension target in Xcode

1. Open `DailyTarot.xcodeproj`.
2. In Xcode choose `File > New > Target...`
3. Choose `Widget Extension`.
4. Name it `DailyTarotWidgetExtension`.
5. Keep it as a SwiftUI widget.
6. Turn off any configuration intent option if Xcode offers it. This widget does not need user configuration yet.
7. Finish the wizard.

Xcode will generate a few widget files. You can delete the generated source files after the target is created.

## 3. Replace the generated widget code

Copy the files from the local folder `DailyTarot/DailyTarotWidgetExtension/` into the new widget target folder in Xcode, or drag that whole folder into the project navigator and add it to the widget target.

Use these files:

- `DailyTarotWidget.swift`
- `DailyTarotWidgetEntry.swift`
- `DailyTarotWidgetProvider.swift`
- `DailyTarotWidgetView.swift`

## 4. Share the existing model and client with the widget

The widget depends on these existing files:

- `DailyTarot/DailyTarot/Shared/Config/DailyTarotConfiguration.swift`
- `DailyTarot/DailyTarot/Shared/Models/DailyTarotReading.swift`
- `DailyTarot/DailyTarot/Shared/Networking/DailyTarotClient.swift`

In Xcode:

1. Select each shared file.
2. Open the File Inspector on the right.
3. Under `Target Membership`, check both:
   - `DailyTarot`
   - `DailyTarotWidgetExtension`

This is the key step that lets the widget compile without duplicating model or networking code.

## 5. Run the app first

Before testing the widget, run the main app once:

1. Select the `DailyTarot` scheme.
2. Build and run.
3. Confirm the app can fetch a tarot reading from your webhook.

If the app fails here, the widget will fail too. Fix the webhook URL or JSON shape first.

## 6. Run and preview the widget

1. Select the widget extension scheme in Xcode.
2. Run it on an iPhone simulator.
3. When the widget gallery appears, add `Daily Tarot`.
4. Test both `systemSmall` and `systemMedium`.

## Why the widget is built this way

- `DailyTarotReading.swift`: decodes your n8n JSON payload into Swift types.
- `DailyTarotClient.swift`: fetches the webhook JSON and downloads the tarot image.
- `DailyTarotWidgetProvider.swift`: asks WidgetKit for a timeline entry and schedules the next refresh.
- `DailyTarotWidgetView.swift`: renders a polished small or medium widget with glanceable content.
- `ContentView.swift`: gives you an app-side preview screen that uses the same backend and helps debug API issues before the widget is involved.

## Likely issues and what they mean

- Widget shows placeholder data:
  - The webhook URL is missing or invalid.
  - The network call failed.
  - The JSON shape no longer matches `DailyTarotReading`.

- Widget text updates but image is blank:
  - The `image_url` is wrong.
  - GitHub Pages returned an error.
  - The image download timed out.

- Widget does not refresh exactly at midnight:
  - This is normal. WidgetKit decides the actual refresh time.
  - The code requests a refresh shortly after the next midnight, but iOS still controls the final schedule.

- Widget never seems to refresh:
  - The extension may not have been added to the correct target membership.
  - The widget was not reloaded after code changes.
  - The simulator sometimes caches old timelines aggressively.

## Best next milestone after the first widget works

Build a simple full-screen reading page in the app and deep-link the widget into it. That gives you:

- a better portfolio story because the widget leads into a real product surface
- a place to show the full 120 to 180 word reading
- a clear foundation for later settings like refresh mode, saved history, and reading categories

After that, the next practical upgrade is caching the latest reading in an App Group so the app and widget can share one fetched result instead of hitting the webhook separately.
