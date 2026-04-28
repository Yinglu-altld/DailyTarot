import Foundation
import WidgetKit

struct DailyTarotWidgetEntry: TimelineEntry {
    let date: Date
    let reading: DailyTarotReading
    let imageData: Data?
    let isFallback: Bool
    let style: DailyTarotWidgetStyleChoice

    static let placeholder = DailyTarotWidgetEntry(
        date: .now,
        reading: .placeholder,
        imageData: nil,
        isFallback: false,
        style: .keywords
    )
}
