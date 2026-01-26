//
//  GetTemperatureUseCase.swift
//  ControlPrototype
//
//  Created by Andres Trotti on 1/23/26.
//


// Caso de Uso para la Temperatura
protocol GetTemperatureUseCase {
    func execute(for deviceID: MatterDeviceID) async throws -> TemperatureReading
}

final class GetTemperatureUseCaseImpl: GetTemperatureUseCase {
    private let repository: MatterDeviceRepository
    init(repository: MatterDeviceRepository) { self.repository = repository }

    func execute(for deviceID: MatterDeviceID) async throws -> TemperatureReading {
        return try await repository.readTemperature(for: deviceID)
    }
}
