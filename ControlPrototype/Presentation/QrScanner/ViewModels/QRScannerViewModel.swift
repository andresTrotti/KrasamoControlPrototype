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
        // 1. Bloqueo estricto
        guard !isProcessing else {
            print("Ignorando QR: Ya hay una operación en curso")
            return
        }

        isProcessing = true
        errorMessage = nil

        Task {
            defer {
                // 2. No desbloquees inmediatamente, espera un poco
                // para que el SDK de Matter limpie su estado interno.
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self.isProcessing = false
                }
            }
            
            do {
                let device = try await commissionDeviceUseCase.execute(qrString: qr)
                onDeviceCommissioned?(device)
            } catch {
                print("Error de Matter: \(error)")
                self.errorMessage = error.localizedDescription
            }
        }
    }
}
