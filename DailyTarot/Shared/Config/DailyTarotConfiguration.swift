import Foundation

enum DailyTarotConfiguration {
    static let usesLiveWebhooks = false
    static let usesDemoDataWhenWebhookFails = true

    static let tarotImageBaseURLString = "https://raw.githubusercontent.com/yinglu-dev/tarot-images/main"

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

    static func tarotImageURL(for cardShort: String) -> URL {
        let trimmedBase = tarotImageBaseURLString.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        return URL(string: "\(trimmedBase)/\(cardShort).jpg")!
    }

    private static func makeURL(from string: String) -> URL? {
        let trimmed = string.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            return nil
        }
        return URL(string: trimmed)
    }
}
