import SwiftUI
import WidgetKit

struct DailyTarotKeywordsWidget: Widget {
    let kind = "DailyTarotKeywordsWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: DailyTarotWidgetProvider(style: .keywords)) { entry in
            DailyTarotWidgetView(entry: entry)
        }
        .configurationDisplayName("Daily Tarot Meaning")
        .description("A compact tarot card with its core meaning.")
        .supportedFamilies([.systemSmall])
        .contentMarginsDisabled()
    }
}

struct DailyTarotMetricsWidget: Widget {
    let kind = "DailyTarotMetricsWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: DailyTarotWidgetProvider(style: .metrics)) { entry in
            DailyTarotWidgetView(entry: entry)
        }
        .configurationDisplayName("Daily Tarot Metrics")
        .description("Today's card with glanceable love, career, and energy scores.")
        .supportedFamilies([.systemMedium])
        .contentMarginsDisabled()
    }
}

struct DailyTarotSummaryWidget: Widget {
    let kind = "DailyTarotSummaryWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: DailyTarotWidgetProvider(style: .summary)) { entry in
            DailyTarotWidgetView(entry: entry)
        }
        .configurationDisplayName("Daily Tarot Summary")
        .description("Today's card with a fuller one-sentence reading summary.")
        .supportedFamilies([.systemMedium])
        .contentMarginsDisabled()
    }
}

struct DailyTarotWidget_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            DailyTarotWidgetView(
                entry: DailyTarotWidgetEntry(
                    date: .now,
                    reading: .placeholder,
                    imageData: nil,
                    isFallback: false,
                    style: .keywords
                )
            )
            .previewContext(WidgetPreviewContext(family: .systemSmall))

            DailyTarotWidgetView(
                entry: DailyTarotWidgetEntry(
                    date: .now,
                    reading: .placeholder,
                    imageData: nil,
                    isFallback: false,
                    style: .metrics
                )
            )
            .previewContext(WidgetPreviewContext(family: .systemMedium))

            DailyTarotWidgetView(
                entry: DailyTarotWidgetEntry(
                    date: .now,
                    reading: .placeholder,
                    imageData: nil,
                    isFallback: false,
                    style: .summary
                )
            )
            .previewContext(WidgetPreviewContext(family: .systemMedium))
        }
    }
}
