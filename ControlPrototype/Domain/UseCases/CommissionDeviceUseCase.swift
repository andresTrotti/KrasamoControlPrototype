//
//  CommissionDeviceUseCase.swift
//  ControlPrototype
//
//  Created by Andres Trotti on 1/23/26.
//


// Domain

import Matter

@MainActor
final class CommissionDeviceUseCase {
    private let repository: MatterDeviceRepository

    init(repository: MatterDeviceRepository) {
        self.repository = repository
    }

    func execute(qrString: String) async throws -> MatterDevice {
        try await repository.commissionDevice(fromQRCode: qrString)
    }
}

final class ToggleLedUseCase {
    private let repository: MatterDeviceRepository

    init(repository: MatterDeviceRepository) {
        self.repository = repository
    }

    func execute(deviceID: MatterDeviceID, to state: LedState) async throws {
        try await repository.toggleLed(for: deviceID, to: state)
    }
}




final class ReadTemperatureUseCase {
    private let repository: MatterDeviceRepository

    init(repository: MatterDeviceRepository) {
        self.repository = repository
    }

    func execute(deviceID: String) async throws -> Double {
        // 1. Definimos los IDs específicos para Temperatura
        let temperatureCluster: UInt32 = 0x0402
        let measuredValueAttribute: UInt32 = 0x0000
        let endpoint: UInt16 = 1 // Ajusta según tu configuración en el SiWG917

        // 2. Llamamos al repositorio con todos los argumentos requeridos
        let rawValue = try await repository.readAttribute(
            for: deviceID,
            endpointID: endpoint,
            clusterID: temperatureCluster,
            attributeID: measuredValueAttribute
        )
        
        // 3. Conversión segura
        // Matter entrega la temperatura en centésimas de grado (ej: 2550 = 25.50°C)
        if let nsNumber = rawValue as? NSNumber {
            return nsNumber.doubleValue / 100.0
        } else if let intValue = rawValue as? Int {
            return Double(intValue) / 100.0
        }
        
        throw MatterError.attributeNotFound
    }
}
