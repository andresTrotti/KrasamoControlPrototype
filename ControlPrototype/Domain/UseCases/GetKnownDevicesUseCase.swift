//
//  GetKnownDevicesUseCase.swift
//  ControlPrototype
//
//  Created by Andres Trotti on 1/23/26.
//


import Foundation

protocol GetKnownDevicesUseCase {
    func execute() async throws -> [MatterDevice]
}

final class GetKnownDevicesUseCaseImpl: GetKnownDevicesUseCase {
    private let repository: MatterDeviceRepository

    init(repository: MatterDeviceRepository) {
        self.repository = repository
    }

    func execute() async throws -> [MatterDevice] {
        // Aquí puedes añadir lógica de negocio adicional (filtrado, ordenamiento)
        // antes de devolver los dispositivos del repositorio.
        return try await repository.getKnownDevices()
    }
}