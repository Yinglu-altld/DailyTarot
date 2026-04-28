import SwiftUI
import UIKit
import WidgetKit

struct DailyTarotWidgetView: View {
    @Environment(\.widgetFamily) private var family

    let entry: DailyTarotWidgetEntry

    private let keywordsSmallCardHeight: CGFloat = 76
    private let summarySmallCardHeight: CGFloat = 72
    private let metricsSmallCardHeight: CGFloat = 68
    private let keywordsMediumCardHeight: CGFloat = 102
    private let summaryMediumCardHeight: CGFloat = 104
    private let metricsMediumCardHeight: CGFloat = 96

    var body: some View {
        ZStack {
            backgroundView
            widgetContent
        }
        .containerBackground(for: .widget) {
            backgroundView
        }
    }

    @ViewBuilder
    private var widgetContent: some View {
        switch entry.style {
        case .keywords:
            switch family {
            case .systemSmall:
                keywordsSmallLayout
            default:
                keywordsMediumLayout
            }
        case .metrics:
            switch family {
            case .systemSmall:
                metricsSmallLayout
            default:
                metricsMediumLayout
            }
        case .summary:
            switch family {
            case .systemSmall:
                summarySmallLayout
            default:
                summaryMediumLayout
            }
        }
    }

    private var keywordsSmallLayout: some View {
        let cardWidth = keywordsSmallCardHeight * CGFloat(DailyTarotReading.imageAspectRatio)

        return VStack(alignment: .leading, spacing: 8) {
            headerRow(dateSize: 10)

            HStack(alignment: .top, spacing: 10) {
                cardArtwork
                    .frame(width: cardWidth, height: keywordsSmallCardHeight)

                VStack(alignment: .leading, spacing: 5) {
                    cardNameText(fontSize: 13, lines: 2)
                    orientationBadge(compact: true)
                    sectionLabel("Meaning", size: 8)

                    Text(entry.reading.referenceMeaning)
                        .font(.system(size: 9.5, weight: .medium))
                        .foregroundStyle(.white.opacity(0.84))
                        .lineLimit(3)
                        .minimumScaleFactor(0.82)
                }
            }
        }
        .padding(12)
    }

    private var keywordsMediumLayout: some View {
        let cardWidth = keywordsMediumCardHeight * CGFloat(DailyTarotReading.imageAspectRatio)
        return VStack(alignment: .leading, spacing: 10) {
            headerRow(dateSize: 10)

            HStack(alignment: .top, spacing: 12) {
                cardArtwork
                    .frame(width: cardWidth, height: keywordsMediumCardHeight)

                VStack(alignment: .leading, spacing: 8) {
                    cardNameText(fontSize: 17, lines: 2)
                    orientationBadge(compact: false)
                    sectionLabel("Meaning", size: 9)

                    Text(entry.reading.referenceMeaning)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(.white.opacity(0.84))
                        .lineLimit(4)
                        .minimumScaleFactor(0.84)
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
    }

    private var summarySmallLayout: some View {
        let cardWidth = summarySmallCardHeight * CGFloat(DailyTarotReading.imageAspectRatio)

        return VStack(alignment: .leading, spacing: 8) {
            headerRow(dateSize: 10)

            HStack(alignment: .top, spacing: 10) {
                cardArtwork
                    .frame(width: cardWidth, height: summarySmallCardHeight)

                VStack(alignment: .leading, spacing: 5) {
                    cardNameText(fontSize: 12.5, lines: 2)
                    orientationBadge(compact: true)
                    sectionLabel("Summary", size: 8)

                    Text(entry.reading.shortSummary)
                        .font(.system(size: 9.5, weight: .medium))
                        .foregroundStyle(.white.opacity(0.84))
                        .lineLimit(4)
                        .minimumScaleFactor(0.8)
                }
            }
        }
        .padding(12)
    }

    private var summaryMediumLayout: some View {
        let cardWidth = summaryMediumCardHeight * CGFloat(DailyTarotReading.imageAspectRatio)

        return VStack(alignment: .leading, spacing: 10) {
            headerRow(dateSize: 10)

            HStack(alignment: .top, spacing: 12) {
                cardArtwork
                    .frame(width: cardWidth, height: summaryMediumCardHeight)

                VStack(alignment: .leading, spacing: 8) {
                    cardNameText(fontSize: 17, lines: 2)
                    orientationBadge(compact: false)
                    sectionLabel("Summary", size: 9)

                    Text(entry.reading.shortSummary)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(.white.opacity(0.84))
                        .lineLimit(4)
                        .minimumScaleFactor(0.84)
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
    }

    private var metricsSmallLayout: some View {
        let cardWidth = metricsSmallCardHeight * CGFloat(DailyTarotReading.imageAspectRatio)

        return VStack(alignment: .leading, spacing: 8) {
            headerRow(dateSize: 10)

            HStack(alignment: .center, spacing: 10) {
                cardArtwork
                    .frame(width: cardWidth, height: metricsSmallCardHeight)

                VStack(alignment: .leading, spacing: 5) {
                    cardNameText(fontSize: 12.5, lines: 2)
                    orientationBadge(compact: true)
                }

                Spacer(minLength: 0)
            }

            metricSection(
                limit: 3,
                stackSpacing: 4,
                rowSpacing: 2,
                barHeight: 4,
                labelFontSize: 7.5,
                scoreFontSize: 7.5,
                showsScore: false
            )
        }
        .padding(12)
    }

    private var metricsMediumLayout: some View {
        let cardWidth = metricsMediumCardHeight * CGFloat(DailyTarotReading.imageAspectRatio)

        return VStack(alignment: .leading, spacing: 10) {
            headerRow(dateSize: 10)

            HStack(alignment: .top, spacing: 12) {
                cardArtwork
                    .frame(width: cardWidth, height: metricsMediumCardHeight)

                VStack(alignment: .leading, spacing: 6) {
                    cardNameText(fontSize: 16, lines: 2)
                    orientationBadge(compact: false)

                    metricSection(
                        limit: 3,
                        stackSpacing: 5,
                        rowSpacing: 3,
                        barHeight: 5,
                        labelFontSize: 8.5,
                        scoreFontSize: 8.5,
                        showsScore: true
                    )
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
    }

    private func headerRow(dateSize: CGFloat) -> some View {
        HStack(alignment: .firstTextBaseline) {
            Text(entry.reading.displayDate)
                .font(.system(size: dateSize, weight: .semibold))
                .foregroundStyle(.white.opacity(0.78))
                .lineLimit(1)
                .minimumScaleFactor(0.85)

            Spacer(minLength: 0)

            if entry.isFallback {
                Image(systemName: "arrow.clockwise")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.62))
            }
        }
    }

    private func cardNameText(fontSize: CGFloat, lines: Int) -> some View {
        Text(entry.reading.cardName)
            .font(.system(size: fontSize, weight: .semibold, design: .serif))
            .foregroundStyle(.white)
            .lineLimit(lines)
            .minimumScaleFactor(0.72)
    }

    private func orientationBadge(compact: Bool) -> some View {
        Text(entry.reading.displayOrientation.uppercased())
            .font(.system(size: compact ? 9 : 10, weight: .bold))
            .foregroundStyle(Color(red: 0.96, green: 0.82, blue: 0.65))
            .padding(.horizontal, compact ? 7 : 8)
            .padding(.vertical, compact ? 4 : 5)
            .background(
                Capsule()
                    .fill(Color.white.opacity(0.08))
            )
    }

    private func sectionLabel(_ title: String, size: CGFloat) -> some View {
        Text(title.uppercased())
            .font(.system(size: size, weight: .bold))
            .tracking(0.8)
            .foregroundStyle(Color(red: 0.96, green: 0.82, blue: 0.65))
    }

    private func keywordPill(_ keyword: String, compact: Bool) -> some View {
        Text(keyword)
            .font(.system(size: compact ? 8.5 : 9.5, weight: .semibold))
            .foregroundStyle(.white)
            .lineLimit(1)
            .minimumScaleFactor(0.8)
            .padding(.horizontal, compact ? 8 : 10)
            .padding(.vertical, compact ? 5 : 6)
            .background(
                Capsule()
                    .fill(Color.white.opacity(0.10))
            )
            .overlay(
                Capsule()
                    .stroke(.white.opacity(0.12), lineWidth: 1)
            )
    }

    private var backgroundView: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.07, green: 0.05, blue: 0.11),
                    Color(red: 0.15, green: 0.10, blue: 0.16),
                    Color(red: 0.32, green: 0.19, blue: 0.14)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            Circle()
                .fill(Color(red: 0.82, green: 0.64, blue: 0.39).opacity(0.18))
                .frame(width: 110, height: 110)
                .offset(x: 72, y: -62)

            Circle()
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
                .frame(width: 134, height: 134)
                .offset(x: -76, y: 66)
        }
    }

    private func metricSection(
        limit: Int,
        stackSpacing: CGFloat,
        rowSpacing: CGFloat,
        barHeight: CGFloat,
        labelFontSize: CGFloat,
        scoreFontSize: CGFloat,
        showsScore: Bool
    ) -> some View {
        let visibleMetrics = Array(entry.reading.orderedMetrics.prefix(limit))

        return VStack(alignment: .leading, spacing: stackSpacing) {
            ForEach(visibleMetrics) { metric in
                metricRow(
                    metric,
                    rowSpacing: rowSpacing,
                    barHeight: barHeight,
                    labelFontSize: labelFontSize,
                    scoreFontSize: scoreFontSize,
                    showsScore: showsScore
                )
            }
        }
    }

    private func metricRow(
        _ metric: DailyTarotMetric,
        rowSpacing: CGFloat,
        barHeight: CGFloat,
        labelFontSize: CGFloat,
        scoreFontSize: CGFloat,
        showsScore: Bool
    ) -> some View {
        VStack(alignment: .leading, spacing: rowSpacing) {
            HStack(spacing: 6) {
                Text(metric.label)
                    .font(.system(size: labelFontSize, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.78))

                Spacer(minLength: 0)

                if showsScore {
                    Text("\(metric.clampedScore)")
                        .font(.system(size: scoreFontSize, weight: .bold))
                        .foregroundStyle(metricColor(for: metric.key))
                }
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(.white.opacity(0.10))

                    Capsule()
                        .fill(metricColor(for: metric.key))
                        .frame(width: max(8, geometry.size.width * metric.normalizedScore))
                }
            }
            .frame(height: barHeight)
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

    @ViewBuilder
    private var cardArtwork: some View {
        RoundedRectangle(cornerRadius: 14, style: .continuous)
            .fill(
                LinearGradient(
                    colors: [
                        Color(red: 0.42, green: 0.31, blue: 0.20),
                        Color(red: 0.18, green: 0.11, blue: 0.14)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .overlay {
                if let imageData = entry.imageData, let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .rotationEffect(.degrees(entry.reading.isReversed ? 180 : 0))
                        .padding(5)
                } else {
                    VStack(spacing: 6) {
                        Image(systemName: "sparkles.rectangle.stack.fill")
                            .font(.system(size: 20))
                        Text("Tarot")
                            .font(.caption2.weight(.semibold))
                    }
                    .foregroundStyle(.white.opacity(0.82))
                }
            }
            .overlay {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(.white.opacity(0.18), lineWidth: 1)
            }
    }
}
