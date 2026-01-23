//
//  ControlPrototypeApp.swift
//  ControlPrototype
//
//  Created by Andres Trotti on 1/23/26.
//

import SwiftUI

@main
struct ControlPrototypeApp: App {
        let matterController = MatterControllerFactory.makeController()
        let repository: MatterDeviceRepository
        
        // 2. Capa de Domain (Use Cases)
        let getDevicesUseCase: GetKnownDevicesUseCase
        let getTempUseCase: GetTemperatureUseCase

        init() {
            self.repository = MatterDeviceRepositoryImpl(controller: matterController)
            self.getDevicesUseCase = GetKnownDevicesUseCaseImpl(repository: repository)
            self.getTempUseCase = GetTemperatureUseCaseImpl(repository: repository)
        }

        @StateObject private var container = AppContainer()

        var body: some Scene {
            WindowGroup {
                // El AppRouter es la raíz de tu interfaz
                AppRouter(container: container)
            }
        }
}
