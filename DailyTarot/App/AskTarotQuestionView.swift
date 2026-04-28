import Combine
import SwiftUI

struct AskTarotQuestionView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = AskTarotQuestionViewModel()
    @FocusState private var isQuestionEditorFocused: Bool
    @State private var selectedCard: TarotSpreadCard?

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
                    VStack(alignment: .leading, spacing: 20) {
                        introCard
                        questionComposer

                        if let errorMessage = viewModel.errorMessage {
                            errorBanner(errorMessage)
                        }

                        if let result = viewModel.result {
                            spreadSection(result)
                            answerSection(result)
                        }
                    }
                    .padding(20)
                }
                .scrollDismissesKeyboard(.interactively)
                .simultaneousGesture(
                    TapGesture().onEnded {
                        isQuestionEditorFocused = false
                    }
                )
            }
            .navigationTitle("Ask the Cards")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundStyle(.white)
                }

                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()

                    Button("Hide Keyboard") {
                        isQuestionEditorFocused = false
                    }
                }
            }
            .sheet(item: $selectedCard) { card in
                TarotSpreadCardDetailSheet(card: card)
            }
        }
    }

    private var introCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Three-card guidance")
                .font(.system(size: 28, weight: .semibold, design: .serif))
                .foregroundStyle(.white)

            Text("Ask a focused question and the app will draw a past, present, and future spread.")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.76))
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(.white.opacity(0.08), lineWidth: 1)
        }
    }

    private var questionComposer: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Your question")
                .font(.headline.weight(.semibold))
                .foregroundStyle(.white)

            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color.white.opacity(0.07))

                if viewModel.question.isEmpty {
                    Text("Should I accept this opportunity? What should I focus on in love right now?")
                        .font(.body)
                        .foregroundStyle(.white.opacity(0.32))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 18)
                }

                TextEditor(text: $viewModel.question)
                    .scrollContentBackground(.hidden)
                    .foregroundStyle(.white)
                    .font(.body)
                    .focused($isQuestionEditorFocused)
                    .frame(minHeight: 120)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(Color.clear)
            }
            .overlay {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(.white.opacity(0.10), lineWidth: 1)
            }

            Button {
                Task {
                    isQuestionEditorFocused = false
                    await viewModel.submitQuestion()
                }
            } label: {
                HStack {
                    if viewModel.isSubmitting {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Image(systemName: "sparkles")
                    }

                    Text(viewModel.isSubmitting ? "Reading the spread..." : "Ask the cards")
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
            .disabled(viewModel.isSubmitting)
        }
        .padding(18)
        .background(Color.white.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(.white.opacity(0.08), lineWidth: 1)
        }
    }

    private func errorBanner(_ message: String) -> some View {
        Text(message)
            .font(.footnote)
            .foregroundStyle(Color(red: 0.99, green: 0.86, blue: 0.74))
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(red: 0.41, green: 0.17, blue: 0.18).opacity(0.70))
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private func spreadSection(_ result: TarotQuestionReading) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Your spread")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(.white)

                Text("Tap any card to open a larger view and turn it over for meaning and imagery.")
                    .font(.footnote)
                    .foregroundStyle(.white.opacity(0.60))
            }

            ViewThatFits(in: .horizontal) {
                HStack(alignment: .top, spacing: 10) {
                    ForEach(result.cards) { card in
                        spreadGridCard(card)
                    }
                }

                VStack(spacing: 14) {
                    ForEach(result.cards) { card in
                        spreadListCard(card)
                    }
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

    private func spreadGridCard(_ card: TarotSpreadCard) -> some View {
        let cardHeight: CGFloat = 138
        let frameWidth: CGFloat = 98

        return Button {
            selectedCard = card
        } label: {
            VStack(alignment: .center, spacing: 10) {
                Text(card.displayPosition.uppercased())
                    .font(.caption2.weight(.bold))
                    .tracking(0.9)
                    .foregroundStyle(Color(red: 0.95, green: 0.82, blue: 0.66))
                    .frame(maxWidth: .infinity, alignment: .center)

                TarotArtworkView(
                    imageURL: card.imageURL,
                    isReversed: card.isReversed,
                    height: cardHeight,
                    cornerRadius: 18,
                    placeholderFontSize: 24
                )
                .frame(maxWidth: .infinity)

                Text(card.cardName)
                    .font(.system(size: 15, weight: .semibold, design: .serif))
                    .foregroundStyle(.white)
                    .lineLimit(2)
                    .minimumScaleFactor(0.74)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)

                Text(card.displayOrientation)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.72))
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            .frame(width: max(frameWidth, cardHeight * CGFloat(DailyTarotReading.imageAspectRatio)), alignment: .top)
            .padding(.vertical, 2)
        }
        .buttonStyle(.plain)
    }

    private func spreadListCard(_ card: TarotSpreadCard) -> some View {
        let cardHeight: CGFloat = 112

        return Button {
            selectedCard = card
        } label: {
            HStack(alignment: .top, spacing: 14) {
                TarotArtworkView(
                    imageURL: card.imageURL,
                    isReversed: card.isReversed,
                    height: cardHeight,
                    cornerRadius: 16,
                    placeholderFontSize: 22
                )

                VStack(alignment: .leading, spacing: 6) {
                    Text(card.displayPosition.uppercased())
                        .font(.caption2.weight(.bold))
                        .tracking(0.9)
                        .foregroundStyle(Color(red: 0.95, green: 0.82, blue: 0.66))

                    Text(card.cardName)
                        .font(.system(size: 17, weight: .semibold, design: .serif))
                        .foregroundStyle(.white)
                        .lineLimit(2)

                    Text(card.displayOrientation)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.72))
                }

                Spacer(minLength: 0)

                Image(systemName: "chevron.right")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.white.opacity(0.32))
                    .padding(.top, 6)
            }
            .padding(12)
            .background(Color.white.opacity(0.05))
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private func answerSection(_ result: TarotQuestionReading) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Reading")
                .font(.headline.weight(.semibold))
                .foregroundStyle(.white)

            Text(result.answer)
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
}

@MainActor
final class AskTarotQuestionViewModel: ObservableObject {
    @Published var question = ""
    @Published private(set) var result: TarotQuestionReading?
    @Published private(set) var isSubmitting = false
    @Published private(set) var errorMessage: String?

    private let client: DailyTarotClient

    init(client: DailyTarotClient) {
        self.client = client
    }

    convenience init() {
        self.init(client: DailyTarotClient())
    }

    func submitQuestion() async {
        let trimmedQuestion = question.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedQuestion.isEmpty else {
            errorMessage = "Enter a question before asking the cards."
            return
        }

        guard !isSubmitting else {
            return
        }

        isSubmitting = true
        errorMessage = nil

        defer {
            isSubmitting = false
        }

        do {
            result = try await client.askQuestion(trimmedQuestion)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

struct AskTarotQuestionView_Previews: PreviewProvider {
    static var previews: some View {
        AskTarotQuestionView()
    }
}
