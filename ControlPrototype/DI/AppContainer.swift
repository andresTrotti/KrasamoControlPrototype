//
//  AppContainer.swift
//  ControlPrototype
//
//  Created by Andres Trotti on 1/23/26.
//

import Foundation
import Matter

@MainActor
final class AppContainer: ObservableObject {
    // 1. Dependencias de bajo nivel (SDK de Matter)
    private let matterController: MTRDeviceController

    // 2. Repositorios
    private let deviceRepository: MatterDeviceRepository

    init() {
        // Inicializamos el controlador usando tu factory
        self.matterController = MatterControllerFactory.makeController()
        
        // Inicializamos el repositorio real
        self.deviceRepository = MatterDeviceRepositoryImpl(controller: matterController)
    }

    // --- Creadores de ViewModels (Para el Router) ---

    func makeDeviceListViewModel() -> DeviceListViewModel {
        // Aquí es donde nace el 'getKnownDevicesUseCase'
        let useCase = GetKnownDevicesUseCaseImpl(repository: deviceRepository)
        return DeviceListViewModel(getKnownDevicesUseCase: useCase)
    }

    func makeDeviceDetailViewModel(device: MatterDevice) -> DeviceDetailViewModel {
        return DeviceDetailViewModel(
            device: device,
            toggleLedUseCase: ToggleLedUseCase(repository: deviceRepository),
            readTemperatureUseCase: ReadTemperatureUseCase(repository: deviceRepository)
        )
    }

    func makeQRScannerViewModel() -> QRScannerViewModel {
        let useCase = CommissionDeviceUseCase(repository: deviceRepository)
        return QRScannerViewModel(commissionDeviceUseCase: useCase)
    }
}
