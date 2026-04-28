import Foundation

struct DailyTarotWidgetPayload {
    let reading: DailyTarotReading
    let imageData: Data?
}

struct TarotSpreadCard: Codable, Hashable, Identifiable {
    let position: String
    let cardName: String
    let cardShort: String
    let orientation: String
    let meaningUp: String
    let meaningRev: String
    let cardDescription: String
    let displayMeaning: String
    let imageURL: URL

    enum CodingKeys: String, CodingKey {
        case position
        case cardName = "card_name"
        case cardShort = "card_short"
        case orientation
        case meaningUp = "meaning_up"
        case meaningRev = "meaning_rev"
        case cardDescription = "desc"
        case displayMeaning = "display_meaning"
        case imageURL = "image_url"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let position = try container.decode(String.self, forKey: .position)
        let cardName = try container.decode(String.self, forKey: .cardName)
        let cardShort = try container.decodeIfPresent(String.self, forKey: .cardShort) ?? ""
        let orientation = try container.decode(String.self, forKey: .orientation)
        let meaningUp = try container.decodeIfPresent(String.self, forKey: .meaningUp) ?? ""
        let meaningRev = try container.decodeIfPresent(String.self, forKey: .meaningRev) ?? ""
        let cardDescription = try container.decodeIfPresent(String.self, forKey: .cardDescription) ?? ""
        let imageURL = try container.decode(URL.self, forKey: .imageURL)
        let displayMeaning = try container.decodeIfPresent(String.self, forKey: .displayMeaning)?.nonEmptyTrimmed
            ?? (orientation.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == "reversed" ? meaningRev : meaningUp)

        self.position = position
        self.cardName = cardName
        self.cardShort = cardShort
        self.orientation = orientation
        self.meaningUp = meaningUp
        self.meaningRev = meaningRev
        self.cardDescription = cardDescription
        self.displayMeaning = displayMeaning
        self.imageURL = imageURL
    }

    var id: String {
        "\(position)-\(cardShort.isEmpty ? cardName : cardShort)-\(orientation)"
    }

    var displayPosition: String {
        position.capitalized
    }

    var displayOrientation: String {
        orientation.capitalized
    }

    var isReversed: Bool {
        orientation.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == "reversed"
    }

    var referenceMeaning: String {
        displayMeaning.nonEmptyTrimmed
            ?? (isReversed ? meaningRev.nonEmptyTrimmed : meaningUp.nonEmptyTrimmed)
            ?? cardName
    }

    var referenceDescription: String? {
        cardDescription.nonEmptyTrimmed
    }
}

struct TarotQuestionReading: Codable, Hashable {
    let question: String
    let spreadType: String
    let cards: [TarotSpreadCard]
    let answer: String

    enum CodingKeys: String, CodingKey {
        case question
        case spreadType = "spread_type"
        case cards
        case answer
    }
}

enum DailyTarotAPIError: LocalizedError {
    case missingDailyWebhookURL
    case missingQuestionWebhookURL
    case invalidResponse
    case unexpectedStatusCode(Int)
    case imageDownloadFailed

    var errorDescription: String? {
        switch self {
        case .missingDailyWebhookURL:
            return "Set your daily tarot webhook URL in DailyTarotConfiguration.swift before running the app."
        case .missingQuestionWebhookURL:
            return "Set your ask-tarot webhook URL in DailyTarotConfiguration.swift before running the app."
        case .invalidResponse:
            return "The tarot service returned data in an unexpected format."
        case .unexpectedStatusCode(let statusCode):
            return "The tarot service returned HTTP \(statusCode)."
        case .imageDownloadFailed:
            return "The reading loaded, but the tarot image could not be downloaded."
        }
    }
}

struct DailyTarotClient {
    private let session: URLSession
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()

    init(session: URLSession? = nil) {
        if let session {
            self.session = session
        } else {
            let configuration = URLSessionConfiguration.ephemeral
            configuration.timeoutIntervalForRequest = 20
            configuration.timeoutIntervalForResource = 20
            configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
            self.session = URLSession(configuration: configuration)
        }
    }

    func fetchDailyReading() async throws -> DailyTarotReading {
        let request = try makeDailyRequest()
        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw DailyTarotAPIError.invalidResponse
        }

        guard 200..<300 ~= httpResponse.statusCode else {
            throw DailyTarotAPIError.unexpectedStatusCode(httpResponse.statusCode)
        }

        return try decoder.decode(DailyTarotReading.self, from: data)
    }

    func fetchReading() async throws -> DailyTarotReading {
        try await fetchDailyReading()
    }

    func askQuestion(_ question: String) async throws -> TarotQuestionReading {
        let request = try makeQuestionRequest(question: question)
        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw DailyTarotAPIError.invalidResponse
        }

        guard 200..<300 ~= httpResponse.statusCode else {
            throw DailyTarotAPIError.unexpectedStatusCode(httpResponse.statusCode)
        }

        return try decoder.decode(TarotQuestionReading.self, from: data)
    }

    func fetchWidgetPayload() async throws -> DailyTarotWidgetPayload {
        let reading = try await fetchDailyReading()

        do {
            let imageData = try await fetchImageData(from: reading.imageURL)
            return DailyTarotWidgetPayload(reading: reading, imageData: imageData)
        } catch {
            return DailyTarotWidgetPayload(reading: reading, imageData: nil)
        }
    }

    private func makeDailyRequest() throws -> URLRequest {
        guard let url = DailyTarotConfiguration.dailyWebhookURL else {
            throw DailyTarotAPIError.missingDailyWebhookURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 20
        request.cachePolicy = .reloadIgnoringLocalCacheData
        return request
    }

    private func makeQuestionRequest(question: String) throws -> URLRequest {
        guard let url = DailyTarotConfiguration.questionWebhookURL else {
            throw DailyTarotAPIError.missingQuestionWebhookURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = 20
        request.cachePolicy = .reloadIgnoringLocalCacheData
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try encoder.encode(AskTarotQuestionRequest(question: question))
        return request
    }

    private func fetchImageData(from url: URL) async throws -> Data {
        let (data, response) = try await session.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw DailyTarotAPIError.invalidResponse
        }

        guard 200..<300 ~= httpResponse.statusCode else {
            throw DailyTarotAPIError.imageDownloadFailed
        }

        return data
    }
}

private struct AskTarotQuestionRequest: Encodable {
    let question: String
}

private extension String {
    var nonEmptyTrimmed: String? {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}
