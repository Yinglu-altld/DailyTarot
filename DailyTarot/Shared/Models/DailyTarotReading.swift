import Foundation

struct DailyTarotMetric: Codable, Hashable, Identifiable {
    let key: String
    let label: String
    let score: Int

    var id: String { key }

    var normalizedScore: Double {
        Double(clampedScore) / 100.0
    }

    var clampedScore: Int {
        min(max(score, 0), 100)
    }
}

struct DailyTarotReading: Codable, Hashable {
    static let imageAspectRatio = 228.0 / 390.0

    let title: String
    let date: String
    let cardName: String
    let cardShort: String
    let orientation: String
    let meaningUp: String
    let meaningRev: String
    let cardDescription: String
    let displayMeaning: String
    let shortSummary: String
    let keywords: [String]
    let reading: String
    let imageURL: URL
    let metrics: [DailyTarotMetric]

    enum CodingKeys: String, CodingKey {
        case title
        case date
        case cardName = "card_name"
        case cardShort = "card_short"
        case orientation
        case meaningUp = "meaning_up"
        case meaningRev = "meaning_rev"
        case cardDescription = "desc"
        case displayMeaning = "display_meaning"
        case shortSummary = "short_summary"
        case keywords
        case reading
        case imageURL = "image_url"
        case metrics
    }

    init(
        title: String,
        date: String,
        cardName: String,
        cardShort: String,
        orientation: String,
        meaningUp: String,
        meaningRev: String,
        cardDescription: String,
        displayMeaning: String,
        shortSummary: String,
        keywords: [String],
        reading: String,
        imageURL: URL,
        metrics: [DailyTarotMetric]
    ) {
        self.title = title
        self.date = date
        self.cardName = cardName
        self.cardShort = cardShort
        self.orientation = orientation
        self.meaningUp = meaningUp
        self.meaningRev = meaningRev
        self.cardDescription = cardDescription
        self.displayMeaning = displayMeaning
        self.shortSummary = shortSummary
        self.keywords = keywords
        self.reading = reading
        self.imageURL = imageURL
        self.metrics = metrics
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let title = try container.decode(String.self, forKey: .title)
        let date = try container.decode(String.self, forKey: .date)
        let cardName = try container.decode(String.self, forKey: .cardName)
        let cardShort = try container.decodeIfPresent(String.self, forKey: .cardShort) ?? ""
        let orientation = try container.decode(String.self, forKey: .orientation)
        let meaningUp = try container.decodeIfPresent(String.self, forKey: .meaningUp) ?? ""
        let meaningRev = try container.decodeIfPresent(String.self, forKey: .meaningRev) ?? ""
        let cardDescription = try container.decodeIfPresent(String.self, forKey: .cardDescription) ?? ""
        let reading = try container.decode(String.self, forKey: .reading)
        let imageURL = try container.decode(URL.self, forKey: .imageURL)
        let shortSummary = try container.decodeIfPresent(String.self, forKey: .shortSummary)
        let resolvedShortSummary = shortSummary?.nonEmptyTrimmed ?? reading.trimmedExcerpt(maxLength: 80)
        let metrics = try container.decodeIfPresent([DailyTarotMetric].self, forKey: .metrics) ?? []
        let displayMeaning = try container.decodeIfPresent(String.self, forKey: .displayMeaning)?.nonEmptyTrimmed
            ?? (orientation.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == "reversed" ? meaningRev : meaningUp)
        let keywords = Self.decodeKeywords(from: container, fallbackText: resolvedShortSummary)

        self.init(
            title: title,
            date: date,
            cardName: cardName,
            cardShort: cardShort,
            orientation: orientation,
            meaningUp: meaningUp,
            meaningRev: meaningRev,
            cardDescription: cardDescription,
            displayMeaning: displayMeaning,
            shortSummary: resolvedShortSummary,
            keywords: keywords,
            reading: reading,
            imageURL: imageURL,
            metrics: metrics
        )
    }

    var displayDate: String {
        let parser = DateFormatter()
        parser.dateFormat = "yyyy-MM-dd"
        parser.locale = Locale(identifier: "en_US_POSIX")

        guard let parsedDate = parser.date(from: date) else {
            return date
        }

        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter.string(from: parsedDate)
    }

    var displayOrientation: String {
        orientation.capitalized
    }

    var referenceMeaning: String {
        displayMeaning.nonEmptyTrimmed
            ?? (isReversed ? meaningRev.nonEmptyTrimmed : meaningUp.nonEmptyTrimmed)
            ?? shortSummary
    }

    var referenceDescription: String? {
        cardDescription.nonEmptyTrimmed
    }

    var isReversed: Bool {
        orientation.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == "reversed"
    }

    var orderedMetrics: [DailyTarotMetric] {
        let defaults = Self.defaultMetrics

        return defaults.map { defaultMetric in
            guard let found = metrics.first(where: { $0.key.lowercased() == defaultMetric.key }) else {
                return defaultMetric
            }

            return DailyTarotMetric(
                key: defaultMetric.key,
                label: defaultMetric.label,
                score: found.clampedScore
            )
        }
    }

    var excerpt: String {
        reading.trimmedExcerpt(maxLength: 120)
    }

    var keywordLine: String {
        keywords.joined(separator: " • ")
    }

    static let placeholder = DailyTarotReading(
        title: "Daily Tarot",
        date: "2026-03-15",
        cardName: "The Star",
        cardShort: "ar17",
        orientation: "upright",
        meaningUp: "Hope, spiritual clarity, and gentle renewal after a difficult stretch.",
        meaningRev: "Doubt, emotional fatigue, and feeling briefly disconnected from your own light.",
        cardDescription: "A naked maiden pours water beneath a radiant star, balancing earth and water in calm devotion.",
        displayMeaning: "Hope, spiritual clarity, and gentle renewal after a difficult stretch.",
        shortSummary: "A hopeful day for emotional clarity, gentle confidence, and steady renewal.",
        keywords: ["Hope", "Clarity", "Renewal"],
        reading: "Today asks for quiet faith. The Star suggests healing after a demanding stretch, with enough light returning for you to trust your own direction again. In love, speak gently and let sincerity do the work. In career, keep moving toward the longer vision rather than reacting to short-term noise. Small hopeful actions will matter more than dramatic moves.",
        imageURL: URL(string: "https://yinglu-altld.github.io/tarot-images/ar17.jpg")!,
        metrics: [
            DailyTarotMetric(key: "love", label: "Love", score: 78),
            DailyTarotMetric(key: "career", label: "Career", score: 64),
            DailyTarotMetric(key: "energy", label: "Energy", score: 83)
        ]
    )

    private static let defaultMetrics = [
        DailyTarotMetric(key: "love", label: "Love", score: 50),
        DailyTarotMetric(key: "career", label: "Career", score: 50),
        DailyTarotMetric(key: "energy", label: "Energy", score: 50)
    ]

    private static func decodeKeywords(
        from container: KeyedDecodingContainer<CodingKeys>,
        fallbackText: String
    ) -> [String] {
        if let values = try? container.decodeIfPresent([String].self, forKey: .keywords),
           !values.isEmpty {
            return sanitizeKeywords(values)
        }

        if let value = try? container.decodeIfPresent(String.self, forKey: .keywords),
           !value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            let trimmedValue = value.trimmingCharacters(in: .whitespacesAndNewlines)

            if trimmedValue.hasPrefix("["),
               let data = trimmedValue.data(using: .utf8),
               let parsedValues = try? JSONDecoder().decode([String].self, from: data),
               !parsedValues.isEmpty {
                return sanitizeKeywords(parsedValues)
            }

            return sanitizeKeywords(trimmedValue.components(separatedBy: CharacterSet(charactersIn: ",/|;")))
        }

        return fallbackKeywords(from: fallbackText)
    }

    private static func sanitizeKeywords(_ values: [String]) -> [String] {
        var seen = Set<String>()

        return values
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .map { $0.replacingOccurrences(of: ".", with: "") }
            .filter { keyword in
                let normalized = keyword.lowercased()
                guard !seen.contains(normalized) else {
                    return false
                }
                seen.insert(normalized)
                return true
            }
            .prefix(4)
            .map { $0.capitalized }
    }

    private static func fallbackKeywords(from text: String) -> [String] {
        let stopWords: Set<String> = [
            "about", "after", "again", "ahead", "allow", "also", "and", "around", "away", "back",
            "because", "before", "being", "between", "beyond", "briefly", "bring", "card", "could",
            "daily", "does", "down", "each", "feel", "focus", "from", "full", "have", "into",
            "itself", "more", "move", "must", "need", "open", "overall", "past", "present", "reading",
            "should", "small", "some", "still", "that", "their", "them", "then",
            "there", "these", "they", "this", "through", "today", "toward", "very", "what",
            "when", "with", "your"
        ]

        let tokens = text
            .lowercased()
            .components(separatedBy: CharacterSet.letters.inverted)
            .filter { $0.count >= 4 && !stopWords.contains($0) }

        let rawKeywords = Array(NSOrderedSet(array: tokens)) as? [String] ?? []
        let resolved = rawKeywords.prefix(3).map { $0.capitalized }

        if resolved.isEmpty {
            return ["Insight", "Reflection", "Momentum"]
        }

        return resolved
    }
}

private extension String {
    var nonEmptyTrimmed: String? {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }

    func trimmedExcerpt(maxLength: Int) -> String {
        guard count > maxLength else {
            return self
        }

        let endIndex = index(startIndex, offsetBy: maxLength)
        let clipped = String(self[..<endIndex])

        guard let lastSpace = clipped.lastIndex(of: " ") else {
            return clipped + "..."
        }

        return String(clipped[..<lastSpace]) + "..."
    }
}
