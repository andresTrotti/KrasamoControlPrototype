import Foundation

@MainActor
final class QRScannerViewModel: ObservableObject {
    @Published var isProcessing = false
    @Published var errorMessage: String?

    private let commissionDeviceUseCase: CommissionDeviceUseCase

    // Callback para cerrar el scanner y devolver el dispositivo
    var onDeviceCommissioned: ((MatterDevice) -> Void)?

    init(commissionDeviceUseCase: CommissionDeviceUseCase) {
        self.commissionDeviceUseCase = commissionDeviceUseCase
    }

    func handleScannedCode(_ qr: String) {
        guard !isProcessing else { return }

        isProcessing = true
        errorMessage = nil

        Task {
            do {
                let device = try await commissionDeviceUseCase.execute(qrString: qr)
                onDeviceCommissioned?(device)
            } catch {
                errorMessage = "Error al comisionar: \(error.localizedDescription)"
            }

            isProcessing = false
        }
    }
}
