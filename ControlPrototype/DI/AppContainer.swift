//
//  AppContainer.swift
//  ControlPrototype
//
//  Created by Andres Trotti on 1/23/26.
//

import Foundation

final class AppContainer: ObservableObject {
    // Repos
    let matterRepository: MatterDeviceRepository

    // Use cases
    let commissionDeviceUseCase: CommissionDeviceUseCase
    let getKnownDevicesUseCase: GetKnownDevicesUseCase
    let toggleLedUseCase: ToggleLedUseCase
    let readTemperatureUseCase: ReadTemperatureUseCase
    let readHeaterStateUseCase: ReadHeaterStateUseCase
    let readCoolerStateUseCase: ReadCoolerStateUseCase

    init() {
        // Infrastructure
        let controller = MatterControllerFactory.makeController()

        // Data
        let matterRepo = MatterDeviceRepositoryImpl(controller: controller)

        self.matterRepository = matterRepo

        // Domain (use cases)
        self.commissionDeviceUseCase = CommissionDeviceUseCase(repository: matterRepo)
        self.getKnownDevicesUseCase = GetKnownDevicesUseCase(repository: matterRepo)
        self.toggleLedUseCase = ToggleLedUseCase(repository: matterRepo)
        self.readTemperatureUseCase = ReadTemperatureUseCase(repository: matterRepo)
        self.readHeaterStateUseCase = ReadHeaterStateUseCase(repository: matterRepo)
        self.readCoolerStateUseCase = ReadCoolerStateUseCase(repository: matterRepo)
    }

    // Factories de ViewModels
    func makeDeviceListViewModel() -> DeviceListViewModel {
        DeviceListViewModel(
            getKnownDevicesUseCase: getKnownDevicesUseCase
        )
    }

    func makeDeviceDetailViewModel(device: MatterDevice) -> DeviceDetailViewModel {
        DeviceDetailViewModel(
            device: device,
            toggleLedUseCase: toggleLedUseCase,
            readTemperatureUseCase: readTemperatureUseCase,
            readHeaterStateUseCase: readHeaterStateUseCase,
            readCoolerStateUseCase: readCoolerStateUseCase
        )
    }

    func makeQRScannerViewModel() -> QRScannerViewModel {
        QRScannerViewModel(
            commissionDeviceUseCase: commissionDeviceUseCase
        )
    }
}
