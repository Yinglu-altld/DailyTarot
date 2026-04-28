import SwiftUI

struct TarotArtworkView: View {
    let imageURL: URL
    let isReversed: Bool
    let height: CGFloat
    let cornerRadius: CGFloat
    var placeholderFontSize: CGFloat = 28

    private var width: CGFloat {
        height * CGFloat(DailyTarotReading.imageAspectRatio)
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.46, green: 0.35, blue: 0.23),
                    Color(red: 0.16, green: 0.12, blue: 0.16)
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            AsyncImage(url: imageURL) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFit()
                        .rotationEffect(.degrees(isReversed ? 180 : 0))
                        .padding(8)
                default:
                    Image(systemName: "sparkles.rectangle.stack.fill")
                        .font(.system(size: placeholderFontSize))
                        .foregroundStyle(.white.opacity(0.85))
                }
            }
        }
        .frame(width: width, height: height)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .stroke(.white.opacity(0.18), lineWidth: 1)
        }
    }
}

struct FlippableTarotPanel<Front: View, Back: View>: View {
    let isFlipped: Bool
    let onTap: () -> Void
    let front: Front
    let back: Back

    init(
        isFlipped: Bool,
        onTap: @escaping () -> Void,
        @ViewBuilder front: () -> Front,
        @ViewBuilder back: () -> Back
    ) {
        self.isFlipped = isFlipped
        self.onTap = onTap
        self.front = front()
        self.back = back()
    }

    var body: some View {
        ZStack {
            front
                .opacity(isFlipped ? 0 : 1)
                .rotation3DEffect(.degrees(isFlipped ? 180 : 0), axis: (x: 0, y: 1, z: 0))

            back
                .opacity(isFlipped ? 1 : 0)
                .rotation3DEffect(.degrees(isFlipped ? 0 : -180), axis: (x: 0, y: 1, z: 0))
        }
        .animation(.spring(response: 0.42, dampingFraction: 0.84), value: isFlipped)
        .contentShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .onTapGesture(perform: onTap)
        .accessibilityAddTraits(.isButton)
    }
}

struct TarotReferenceBackView: View {
    let eyebrow: String?
    let title: String
    let orientation: String
    let meaning: String
    let description: String?
    var helperText: String = "Tap again to return to the card."

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if let eyebrow, !eyebrow.isEmpty {
                Text(eyebrow)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(Color(red: 0.95, green: 0.82, blue: 0.66))
            }

            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 10) {
                    Text(title)
                        .font(.system(size: 28, weight: .semibold, design: .serif))
                        .foregroundStyle(.white)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(orientation)
                        .font(.footnote.weight(.semibold))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.white.opacity(0.10))
                        .clipShape(Capsule())
                        .foregroundStyle(.white.opacity(0.88))
                }
            }

            TarotReferenceSection(
                title: "Meaning",
                bodyText: meaning
            )

            if let description, !description.isEmpty {
                TarotReferenceSection(
                    title: "Imagery",
                    bodyText: description
                )
            }

            Text(helperText)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.48))
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color.white.opacity(0.06))
        )
        .overlay {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(.white.opacity(0.10), lineWidth: 1)
        }
    }
}

struct TarotSpreadCardDetailSheet: View {
    @Environment(\.dismiss) private var dismiss

    let card: TarotSpreadCard
    @State private var isFlipped = false
    @State private var showsHint = true

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [
                        Color(red: 0.08, green: 0.05, blue: 0.12),
                        Color(red: 0.16, green: 0.09, blue: 0.15),
                        Color(red: 0.30, green: 0.18, blue: 0.15)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        FlippableTarotPanel(isFlipped: isFlipped) {
                            withAnimation {
                                isFlipped.toggle()
                                showsHint = false
                            }
                        } front: {
                            detailFront
                        } back: {
                            TarotReferenceBackView(
                                eyebrow: card.displayPosition.uppercased(),
                                title: card.cardName,
                                orientation: card.displayOrientation,
                                meaning: card.referenceMeaning,
                                description: card.referenceDescription
                            )
                        }

                        if showsHint {
                            Text("Tap the card to turn it over and explore the symbolism behind this position in your spread.")
                                .font(.footnote)
                                .foregroundStyle(.white.opacity(0.60))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .transition(.opacity)
                        }
                    }
                    .padding(20)
                }
            }
            .navigationTitle(card.displayPosition)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundStyle(.white)
                }
            }
            .task {
                scheduleHintFadeOut()
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }

    private var detailFront: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(card.displayPosition.uppercased())
                        .font(.caption.weight(.bold))
                        .tracking(1.2)
                        .foregroundStyle(Color(red: 0.95, green: 0.82, blue: 0.66))

                    Text(card.cardName)
                        .font(.system(size: 30, weight: .semibold, design: .serif))
                        .foregroundStyle(.white)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(card.displayOrientation)
                        .font(.footnote.weight(.semibold))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.white.opacity(0.10))
                        .clipShape(Capsule())
                        .foregroundStyle(.white.opacity(0.88))
                }
            }

            TarotArtworkView(
                imageURL: card.imageURL,
                isReversed: card.isReversed,
                height: 280,
                cornerRadius: 22,
                placeholderFontSize: 34
            )
            .frame(maxWidth: .infinity)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color.white.opacity(0.06))
        )
        .overlay {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(.white.opacity(0.10), lineWidth: 1)
        }
    }

    private func scheduleHintFadeOut() {
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 2_400_000_000)
            withAnimation(.easeOut(duration: 0.4)) {
                showsHint = false
            }
        }
    }
}

private struct TarotReferenceSection: View {
    let title: String
    let bodyText: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title.uppercased())
                .font(.caption.weight(.bold))
                .tracking(1.1)
                .foregroundStyle(Color(red: 0.95, green: 0.82, blue: 0.66))

            Text(bodyText)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.82))
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
