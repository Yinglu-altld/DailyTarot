import Combine
import Foundation
import WidgetKit

@MainActor
final class DailyTarotHomeViewModel: ObservableObject {
    @Published private(set) var reading: DailyTarotReading?
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    private let client: DailyTarotClient

    init(client: DailyTarotClient) {
        self.client = client
    }

    convenience init() {
        self.init(client: DailyTarotClient())
    }

    func load() async {
        if isLoading {
            return
        }

        if reading != nil {
            return
        }

        isLoading = true
        errorMessage = nil

        defer {
            isLoading = false
        }

        do {
            reading = try await client.fetchDailyReading()
            WidgetCenter.shared.reloadAllTimelines()
        } catch {
            if reading == nil {
                reading = .placeholder
            }
            errorMessage = error.localizedDescription
        }
    }
}
