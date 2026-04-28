import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = DailyTarotHomeViewModel()
    @State private var activeSheet: ActiveSheet?
    @State private var isDailyCardFlipped = false
    @State private var showsDailyCardHint = true
    private let appCardHeight: CGFloat = 206

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [
                        Color(red: 0.08, green: 0.05, blue: 0.12),
                        Color(red: 0.18, green: 0.10, blue: 0.14),
                        Color(red: 0.38, green: 0.23, blue: 0.15)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        header
                        readingCard
                        metricsSection
                        readingSection
                        askSection
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Daily Tarot")
            .navigationBarTitleDisplayMode(.inline)
            .task {
                await viewModel.load()
                scheduleDailyCardHintFadeOut()
            }
            .onChange(of: viewModel.reading?.date) { _, _ in
                isDailyCardFlipped = false
                showsDailyCardHint = true
                scheduleDailyCardHintFadeOut()
            }
            .sheet(item: $activeSheet) { sheet in
                switch sheet {
                case .ask:
                    AskTarotQuestionView()
                }
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Daily Tarot")
                .font(.system(size: 32, weight: .semibold, design: .serif))
                .foregroundStyle(.white)

            Text("A calm, AI-guided tarot ritual for the day ahead.")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.72))
        }
    }

    private var readingCard: some View {
        let reading = viewModel.reading ?? .placeholder
        let appCardWidth = appCardHeight * CGFloat(DailyTarotReading.imageAspectRatio)

        return VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top, spacing: 16) {
                FlippableTarotPanel(isFlipped: isDailyCardFlipped) {
                    withAnimation {
                        isDailyCardFlipped.toggle()
                        showsDailyCardHint = false
                    }
                } front: {
                    dailyArtworkFront(reading)
                } back: {
                    dailyArtworkBack(reading)
                        .frame(width: appCardWidth, height: appCardHeight)
                }

                VStack(alignment: .leading, spacing: 10) {
                    Text(reading.displayDate)
                        .font(.caption.weight(.medium))
                        .foregroundStyle(Color(red: 0.95, green: 0.82, blue: 0.66))

                    Text(reading.cardName)
                        .font(.system(size: 24, weight: .semibold, design: .serif))
                        .foregroundStyle(.white)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(reading.displayOrientation)
                        .font(.footnote.weight(.semibold))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.white.opacity(0.10))
                        .clipShape(Capsule())
                        .foregroundStyle(.white.opacity(0.88))

                    Text("Meaning")
                        .font(.caption.weight(.bold))
                        .tracking(1)
                        .foregroundStyle(Color(red: 0.95, green: 0.82, blue: 0.66))

                    Text(reading.referenceMeaning)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.82))
                        .lineLimit(5)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 0)
            }

            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .font(.footnote)
                    .foregroundStyle(Color(red: 0.99, green: 0.86, blue: 0.74))
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(red: 0.41, green: 0.17, blue: 0.18).opacity(0.70))
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(.ultraThinMaterial.opacity(0.40))
        )
        .overlay {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(.white.opacity(0.12), lineWidth: 1)
        }
    }

    private func dailyArtworkFront(_ reading: DailyTarotReading) -> some View {
        TarotArtworkView(
            imageURL: reading.imageURL,
            isReversed: reading.isReversed,
            height: appCardHeight,
            cornerRadius: 18
        )
        .overlay(alignment: .bottom) {
            if showsDailyCardHint {
                dailyCardHintLabel(text: "Tap to reveal")
                    .padding(.bottom, 10)
                    .transition(.opacity)
            }
        }
    }

    private func dailyArtworkBack(_ reading: DailyTarotReading) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Imagery")
                .font(.caption2.weight(.bold))
                .tracking(0.8)
                .foregroundStyle(Color(red: 0.95, green: 0.82, blue: 0.66))

            ScrollView(showsIndicators: false) {
                Text(reading.referenceDescription ?? "No imagery description available for this card yet.")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.86))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.bottom, 28)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.white.opacity(0.06))
        )
        .overlay {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(.white.opacity(0.18), lineWidth: 1)
        }
        .overlay(alignment: .bottom) {
            if showsDailyCardHint {
                dailyCardHintLabel(text: "Tap to return")
                    .padding(.bottom, 10)
                    .transition(.opacity)
            }
        }
    }

    private func dailyCardHintLabel(text: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: "hand.tap.fill")
                .font(.caption2)
            Text(text)
                .font(.caption2.weight(.semibold))
        }
        .foregroundStyle(.white.opacity(0.86))
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color.black.opacity(0.18))
        .clipShape(Capsule())
    }

    private func scheduleDailyCardHintFadeOut() {
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 2_400_000_000)
            withAnimation(.easeOut(duration: 0.4)) {
                showsDailyCardHint = false
            }
        }
    }

    private var metricsSection: some View {
        let reading = viewModel.reading ?? .placeholder

        return VStack(alignment: .leading, spacing: 14) {
            Text("Today's energy")
                .font(.headline.weight(.semibold))
                .foregroundStyle(.white)

            ForEach(reading.orderedMetrics) { metric in
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(metric.label)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.white.opacity(0.82))

                        Spacer(minLength: 0)

                        Text("\(metric.clampedScore)")
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(metricColor(for: metric.key))
                    }

                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(.white.opacity(0.10))

                            Capsule()
                                .fill(metricColor(for: metric.key))
                                .frame(width: max(10, geometry.size.width * metric.normalizedScore))
                        }
                    }
                    .frame(height: 8)
                }
            }
        }
        .padding(18)
        .background(Color.white.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(.white.opacity(0.08), lineWidth: 1)
        }
    }

    private var readingSection: some View {
        let reading = viewModel.reading ?? .placeholder

        return VStack(alignment: .leading, spacing: 12) {
            Text("Full reading")
                .font(.headline.weight(.semibold))
                .foregroundStyle(.white)

            Text(reading.reading)
                .font(.body)
                .foregroundStyle(.white.opacity(0.82))
                .lineSpacing(5)
        }
        .padding(18)
        .background(Color.white.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(.white.opacity(0.08), lineWidth: 1)
        }
    }

    private var askSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Want deeper guidance?")
                .font(.headline.weight(.semibold))
                .foregroundStyle(.white)

            Text("Today's card stays fixed until tomorrow. Ask a focused question to draw a fresh three-card spread inside the app.")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.74))

            Button {
                activeSheet = .ask
            } label: {
                HStack {
                    Image(systemName: "questionmark.circle.fill")
                    Text("Ask the cards")
                        .fontWeight(.semibold)
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    LinearGradient(
                        colors: [
                            Color(red: 0.80, green: 0.59, blue: 0.40),
                            Color(red: 0.63, green: 0.37, blue: 0.24)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            }
            .buttonStyle(.plain)
        }
        .padding(18)
        .background(Color.white.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(.white.opacity(0.08), lineWidth: 1)
        }
    }

    private func metricColor(for key: String) -> Color {
        switch key.lowercased() {
        case "love":
            return Color(red: 0.92, green: 0.58, blue: 0.66)
        case "career":
            return Color(red: 0.88, green: 0.75, blue: 0.43)
        case "energy":
            return Color(red: 0.53, green: 0.79, blue: 0.76)
        default:
            return .white.opacity(0.75)
        }
    }
}

private enum ActiveSheet: String, Identifiable {
    case ask

    var id: String {
        rawValue
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
