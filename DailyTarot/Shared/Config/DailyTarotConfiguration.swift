import Foundation

enum DailyTarotConfiguration {
    static let dailyWebhookURLString = "https://luyinggg.app.n8n.cloud/webhook/daily-tarot"
    static let questionWebhookURLString = "https://luyinggg.app.n8n.cloud/webhook/tarot-question"

    static var dailyWebhookURL: URL? {
        makeURL(from: dailyWebhookURLString)
    }

    static var questionWebhookURL: URL? {
        makeURL(from: questionWebhookURLString)
    }

    static var webhookURL: URL? {
        dailyWebhookURL
    }

    private static func makeURL(from string: String) -> URL? {
        let trimmed = string.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            return nil
        }
        return URL(string: trimmed)
    }
}
