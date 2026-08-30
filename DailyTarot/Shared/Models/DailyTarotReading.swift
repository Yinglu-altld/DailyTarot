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

    static var demo: DailyTarotReading {
        demoReading(for: Date())
    }

    static func demoReading(for date: Date) -> DailyTarotReading {
        let seed = demoSeed(for: date)
        let card = demoCards[seed % demoCards.count]
        let isReversed = seed % 4 == 0

        return DailyTarotReading(
            title: "Daily Tarot",
            date: formattedDateString(for: date),
            cardName: card.name,
            cardShort: card.shortName,
            orientation: isReversed ? "reversed" : "upright",
            meaningUp: card.meaningUp,
            meaningRev: card.meaningRev,
            cardDescription: card.description,
            displayMeaning: card.meaning(isReversed: isReversed),
            shortSummary: card.summary(isReversed: isReversed),
            keywords: card.keywords,
            reading: card.reading(isReversed: isReversed),
            imageURL: card.imageURL,
            metrics: demoMetrics(seed: seed)
        )
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

    private struct DemoCard {
        let name: String
        let shortName: String
        let keywords: [String]
        let meaningUp: String
        let meaningRev: String
        let description: String
        let summaryUp: String
        let summaryRev: String
        let readingUp: String
        let readingRev: String

        var imageURL: URL {
            URL(string: "https://yinglu-altld.github.io/tarot-images/\(shortName).jpg")!
        }

        func meaning(isReversed: Bool) -> String {
            isReversed ? meaningRev : meaningUp
        }

        func summary(isReversed: Bool) -> String {
            isReversed ? summaryRev : summaryUp
        }

        func reading(isReversed: Bool) -> String {
            isReversed ? readingRev : readingUp
        }
    }

    private static let demoCards = [
        DemoCard(
            name: "The Fool",
            shortName: "ar00",
            keywords: ["Trust", "Start", "Openness"],
            meaningUp: "A fresh start, creative risk, and the courage to move before every detail is settled.",
            meaningRev: "Hesitation, scattered energy, and the need to ground a leap before taking it.",
            description: "A traveler steps toward a new path with light baggage and an open sky ahead.",
            summaryUp: "A day for beginning simply, trusting your instincts, and letting movement create clarity.",
            summaryRev: "A day to slow the leap, check your footing, and choose curiosity without recklessness.",
            readingUp: "Today opens a new path. The Fool encourages you to begin with less pressure and more curiosity, especially where overplanning has been keeping you still. In love, leave room for honest surprise. In career, a small first step will teach you more than another round of waiting.",
            readingRev: "Today asks you to separate courage from impulse. The Fool reversed does not block the path, but it does ask you to pause long enough to notice what support, timing, or information is missing. In love and work, grounded openness will serve you better than a dramatic leap."
        ),
        DemoCard(
            name: "The Magician",
            shortName: "ar01",
            keywords: ["Focus", "Skill", "Action"],
            meaningUp: "Focused willpower, practical skill, and turning available tools into visible progress.",
            meaningRev: "Untapped ability, distraction, or using energy without a clear aim.",
            description: "A figure stands between earth and sky, gathering tools into one deliberate act.",
            summaryUp: "A focused day for using what you already have and making your intention concrete.",
            summaryRev: "A day to reduce distractions and aim your effort before trying to do everything at once.",
            readingUp: "Today rewards focus. The Magician points to a moment where your tools, timing, and intention can align if you choose one clear priority. In love, say what you mean. In career, use the resources already in front of you and turn a vague idea into a concrete move.",
            readingRev: "Today highlights scattered power. The Magician reversed suggests that you may have enough ability, but your attention is split across too many signals. Before pushing harder, simplify the goal. One honest conversation or one finished task will restore momentum."
        ),
        DemoCard(
            name: "The High Priestess",
            shortName: "ar02",
            keywords: ["Intuition", "Patience", "Insight"],
            meaningUp: "Quiet intuition, inner knowledge, and trusting what is still unfolding beneath the surface.",
            meaningRev: "Ignoring your instincts, rushing an answer, or letting outside noise drown out inner clarity.",
            description: "A calm guardian sits between two pillars, holding a threshold between the known and unknown.",
            summaryUp: "A reflective day for listening closely before naming the answer too soon.",
            summaryRev: "A day to lower the noise and return to what your body and instincts already know.",
            readingUp: "Today favors quiet attention. The High Priestess suggests that not every answer needs to be forced into language immediately. In love, notice what is felt but unsaid. In career, observe the pattern before acting. The most useful guidance may arrive through patience.",
            readingRev: "Today asks you to stop outsourcing your certainty. The High Priestess reversed can appear when too many opinions are covering a simple inner signal. Step back from the noise, reread the situation calmly, and give your intuition enough space to become specific."
        ),
        DemoCard(
            name: "The Empress",
            shortName: "ar03",
            keywords: ["Care", "Growth", "Abundance"],
            meaningUp: "Nurturing growth, creative abundance, and building from comfort rather than pressure.",
            meaningRev: "Depletion, overgiving, or neglecting the care that makes growth sustainable.",
            description: "A grounded figure rests in a fertile landscape, surrounded by signs of growth and beauty.",
            summaryUp: "A generous day for creating, caring, and letting steady attention grow into results.",
            summaryRev: "A day to stop overgiving and restore the conditions that let your energy return.",
            readingUp: "Today asks for care as a strategy. The Empress brings attention to what grows when it is protected, nourished, and given enough time. In love, warmth matters more than performance. In career, create the conditions where good work can actually take root.",
            readingRev: "Today points to depletion. The Empress reversed suggests that giving more will not help if your own reserves are empty. Return to basics: rest, food, boundaries, and a gentler pace. Growth will resume when care is part of the plan."
        ),
        DemoCard(
            name: "The Chariot",
            shortName: "ar07",
            keywords: ["Direction", "Control", "Momentum"],
            meaningUp: "Determination, emotional discipline, and moving forward with a clear chosen direction.",
            meaningRev: "Competing priorities, forced momentum, or trying to steer without alignment.",
            description: "A determined rider moves forward, holding tension between opposing forces.",
            summaryUp: "A decisive day for choosing a direction and protecting your momentum.",
            summaryRev: "A day to realign your priorities before pushing harder.",
            readingUp: "Today supports a decisive move. The Chariot asks you to choose the direction instead of letting competing demands choose it for you. In love, clarity prevents mixed signals. In career, commit to the next useful milestone and keep your energy organized around it.",
            readingRev: "Today questions forced progress. The Chariot reversed suggests that motion alone is not the same as direction. If you feel pulled in multiple directions, slow down enough to name the real priority. Alignment will create more progress than pressure."
        ),
        DemoCard(
            name: "Strength",
            shortName: "ar08",
            keywords: ["Courage", "Patience", "Compassion"],
            meaningUp: "Gentle courage, self-command, and the patience to meet intensity without hardening.",
            meaningRev: "Self-doubt, emotional strain, or trying to control what needs compassion.",
            description: "A calm figure meets a powerful force with steadiness instead of fear.",
            summaryUp: "A steady day for soft confidence, patience, and quiet emotional strength.",
            summaryRev: "A day to treat self-doubt with patience instead of pushing through it harshly.",
            readingUp: "Today is about quiet strength. This card favors patience, emotional maturity, and confidence that does not need to dominate the room. In love, softness can be more powerful than defensiveness. In career, persistence will matter more than speed.",
            readingRev: "Today asks you to be kinder with your own fear. Strength reversed often shows up when self-doubt is being handled with too much force. You do not need to overpower the feeling. Regulate, simplify, and return to the task with steadier breath."
        ),
        DemoCard(
            name: "Justice",
            shortName: "ar11",
            keywords: ["Clarity", "Balance", "Truth"],
            meaningUp: "Clear judgment, accountability, and choosing what can stand up to scrutiny.",
            meaningRev: "Avoidance, imbalance, or a decision being shaped by incomplete information.",
            description: "A seated figure holds scales and a sword, weighing truth before action.",
            summaryUp: "A clear day for honest decisions, balanced judgment, and clean agreements.",
            summaryRev: "A day to revisit the facts before making or defending a decision.",
            readingUp: "Today favors clean judgment. Justice asks you to look directly at the facts and choose the option that can be explained without distortion. In love, fairness matters. In career, document the decision, clarify expectations, and let integrity guide the next step.",
            readingRev: "Today reveals where the picture may be incomplete. Justice reversed asks you not to rush a verdict just because a decision feels overdue. Check assumptions, correct an imbalance, and make sure your next move is based on truth rather than pressure."
        ),
        DemoCard(
            name: "The Hermit",
            shortName: "ar09",
            keywords: ["Reflection", "Wisdom", "Space"],
            meaningUp: "Solitude, inner guidance, and stepping back far enough to see the path clearly.",
            meaningRev: "Isolation, overthinking, or staying alone longer than reflection requires.",
            description: "A lone guide holds a lantern, lighting only the next few steps ahead.",
            summaryUp: "A thoughtful day for stepping back, listening inward, and choosing the next quiet step.",
            summaryRev: "A day to leave the loop of overthinking and reconnect with a trusted signal.",
            readingUp: "Today asks for space. The Hermit suggests that your next answer will be easier to hear away from urgency and comparison. In love, take enough quiet to know what you actually feel. In career, a focused review may reveal the simplest next step.",
            readingRev: "Today asks you to come back from too much solitude. The Hermit reversed can mark the point where reflection becomes a loop. Share one thought with someone trustworthy, return to practical movement, and let clarity become action."
        ),
        DemoCard(
            name: "Wheel of Fortune",
            shortName: "ar10",
            keywords: ["Timing", "Change", "Opportunity"],
            meaningUp: "A turning point, changing timing, and the chance to respond well to movement.",
            meaningRev: "Resistance to change, unstable timing, or trying to control every shift.",
            description: "A great wheel turns through cycles, reminding the viewer that timing is always moving.",
            summaryUp: "A changing day where adaptability may open the door faster than control.",
            summaryRev: "A day to stop fighting the shift and look for the choice still available to you.",
            readingUp: "Today brings a change in motion. The Wheel of Fortune suggests that timing is shifting, and your task is to respond with flexibility instead of fear. In love, stay open to a new pattern. In career, an unexpected turn may become useful if you adapt quickly.",
            readingRev: "Today shows resistance around change. The Wheel reversed does not mean you are powerless; it means control may be pointed at the wrong thing. Release the part that is already moving and focus on the response you can still choose."
        ),
        DemoCard(
            name: "The Star",
            shortName: "ar17",
            keywords: ["Hope", "Clarity", "Renewal"],
            meaningUp: "Hope, spiritual clarity, and gentle renewal after a difficult stretch.",
            meaningRev: "Doubt, emotional fatigue, and feeling briefly disconnected from your own light.",
            description: "A figure pours water beneath a radiant star, balancing earth and water in calm devotion.",
            summaryUp: "A hopeful day for emotional clarity, gentle confidence, and steady renewal.",
            summaryRev: "A day to rebuild hope through small, kind evidence instead of forcing optimism.",
            readingUp: "Today asks for quiet faith. The Star suggests healing after a demanding stretch, with enough light returning for you to trust your own direction again. In love, speak gently and let sincerity do the work. In career, keep moving toward the longer vision.",
            readingRev: "Today asks you to protect your hope. The Star reversed may point to fatigue rather than failure, especially if you have been measuring progress too harshly. Choose one small act that reconnects you with possibility and let that be enough for now."
        ),
        DemoCard(
            name: "The Moon",
            shortName: "ar18",
            keywords: ["Dreams", "Instinct", "Uncertainty"],
            meaningUp: "Dreams, uncertainty, and navigating by instinct when the full picture is not visible.",
            meaningRev: "Confusion lifting, hidden fears becoming clearer, or illusion beginning to dissolve.",
            description: "A moonlit path runs between watchful shapes, inviting careful movement through uncertainty.",
            summaryUp: "A sensitive day for trusting instinct while avoiding rushed conclusions.",
            summaryRev: "A day when confusion starts to clear and an old fear becomes easier to name.",
            readingUp: "Today is subtle. The Moon suggests that not everything is visible yet, so instinct and pacing matter. In love, avoid filling silence with assumptions. In career, check the facts before reacting. Your feelings are useful, but they need gentle interpretation.",
            readingRev: "Today brings a little more clarity. The Moon reversed suggests that something confusing is beginning to name itself. Do not force the whole truth at once. Notice what has become less frightening, then make the next decision from that steadier place."
        ),
        DemoCard(
            name: "The Sun",
            shortName: "ar19",
            keywords: ["Joy", "Confidence", "Vitality"],
            meaningUp: "Confidence, warmth, visibility, and the relief of seeing what is working.",
            meaningRev: "Muted joy, temporary self-doubt, or needing to let success feel real.",
            description: "A bright sun opens the scene with warmth, clarity, and simple vitality.",
            summaryUp: "A bright day for confidence, honest joy, and letting good momentum be visible.",
            summaryRev: "A day to let yourself receive progress even if it feels smaller than expected.",
            readingUp: "Today brings light. The Sun encourages confidence, openness, and celebrating what is actually working. In love, warmth can reset the tone. In career, let good work be seen instead of hiding it behind perfectionism. Clarity is available when you stop dimming it.",
            readingRev: "Today asks you not to minimize joy. The Sun reversed can show a good thing being discounted because it is not perfect yet. Let progress count. In love and work, receive the bright spots honestly and build from them without apologizing."
        )
    ]

    private static func demoMetrics(seed: Int) -> [DailyTarotMetric] {
        [
            DailyTarotMetric(key: "love", label: "Love", score: demoScore(seed: seed, salt: 11)),
            DailyTarotMetric(key: "career", label: "Career", score: demoScore(seed: seed, salt: 17)),
            DailyTarotMetric(key: "energy", label: "Energy", score: demoScore(seed: seed, salt: 23))
        ]
    }

    private static func demoScore(seed: Int, salt: Int) -> Int {
        48 + ((seed + salt * 37) % 43)
    }

    private static func demoSeed(for date: Date) -> Int {
        let components = Calendar.current.dateComponents([.year, .month, .day], from: date)
        let year = components.year ?? 2026
        let month = components.month ?? 1
        let day = components.day ?? 1
        return year * 372 + month * 31 + day
    }

    private static func formattedDateString(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.string(from: date)
    }

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
