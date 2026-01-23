import Foundation

@MainActor
final class DeviceListViewModel: ObservableObject {
    @Published var devices: [MatterDevice] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let getKnownDevicesUseCase: GetKnownDevicesUseCase

    init(getKnownDevicesUseCase: GetKnownDevicesUseCase) {
        self.getKnownDevicesUseCase = getKnownDevicesUseCase
    }

    func load() {
        Task {
            isLoading = true
            defer { isLoading = false }

            do {
                devices = try await getKnownDevicesUseCase.execute()
            } catch {
                errorMessage = "No se pudieron cargar los dispositivos"
            }
        }
    }
}
