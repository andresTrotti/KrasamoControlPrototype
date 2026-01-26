//
//  QRScannerViewModel.swift
//  ControlPrototype
//
//  Created by Andres Trotti on 1/23/26.
//


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

        // 1. Capturamos la referencia localmente
        let useCase = self.commissionDeviceUseCase
        
        isProcessing = true
        errorMessage = nil

        Task {
            defer { isProcessing = false }
            do {
                // 2. Usamos la referencia capturada
                let device = try await useCase.execute(qrString: qr)
                onDeviceCommissioned?(device)
            } catch {
                errorMessage = "Error al comisionar: \(error.localizedDescription)"
            }
        }
    }
}
