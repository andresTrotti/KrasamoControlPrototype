//
//  CommissionDeviceUseCase.swift
//  ControlPrototype
//
//  Created by Andres Trotti on 1/23/26.
//


// Domain

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

    func execute(deviceID: MatterDeviceID) async throws -> TemperatureReading {
        try await repository.readTemperature(for: deviceID)
    }
}
