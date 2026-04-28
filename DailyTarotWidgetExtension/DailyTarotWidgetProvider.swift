import Foundation
import WidgetKit

struct DailyTarotWidgetProvider: TimelineProvider {
    typealias Entry = DailyTarotWidgetEntry

    private let client = DailyTarotClient()
    private let style: DailyTarotWidgetStyleChoice

    init(style: DailyTarotWidgetStyleChoice) {
        self.style = style
    }

    func placeholder(in context: Context) -> DailyTarotWidgetEntry {
        DailyTarotWidgetEntry(
            date: .now,
            reading: .placeholder,
            imageData: nil,
            isFallback: false,
            style: style
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (DailyTarotWidgetEntry) -> Void) {
        Task {
            if context.isPreview {
                completion(placeholder(in: context))
                return
            }

            completion(await loadEntry())
        }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<DailyTarotWidgetEntry>) -> Void) {
        Task {
            let entry = await loadEntry()
            let refreshDate = entry.isFallback ? Date().addingTimeInterval(30 * 60) : nextRefreshDate(after: Date())
            completion(Timeline(entries: [entry], policy: .after(refreshDate)))
        }
    }

    private func loadEntry() async -> DailyTarotWidgetEntry {
        do {
            let payload = try await client.fetchWidgetPayload()
            return DailyTarotWidgetEntry(
                date: .now,
                reading: payload.reading,
                imageData: payload.imageData,
                isFallback: false,
                style: style
            )
        } catch {
            return DailyTarotWidgetEntry(
                date: .now,
                reading: .placeholder,
                imageData: nil,
                isFallback: true,
                style: style
            )
        }
    }

    private func nextRefreshDate(after currentDate: Date) -> Date {
        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: currentDate)
        let startOfTomorrow = calendar.date(byAdding: .day, value: 1, to: startOfToday) ?? currentDate.addingTimeInterval(24 * 60 * 60)
        return calendar.date(byAdding: .minute, value: 5, to: startOfTomorrow) ?? currentDate.addingTimeInterval(6 * 60 * 60)
    }
}
