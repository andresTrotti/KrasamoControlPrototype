//
//  DeviceDetailViewModel 2.swift
//  ControlPrototype
//
//  Created by Andres Trotti on 1/23/26.
//

import Foundation


@MainActor
final class DeviceDetailViewModel: ObservableObject {
    @Published var device: MatterDevice
    @Published var ledState: LedState = .off
    @Published var temperature: TemperatureReading?
    @Published var heaterState: HeaterState = .off
    @Published var coolerState: CoolerState = .off
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let toggleLedUseCase: ToggleLedUseCase
    private let readTemperatureUseCase: ReadTemperatureUseCase
    
    

    init(
        device: MatterDevice,
        toggleLedUseCase: ToggleLedUseCase,
        readTemperatureUseCase: ReadTemperatureUseCase,
        
        
    ) {
        self.device = device
        self.toggleLedUseCase = toggleLedUseCase
        self.readTemperatureUseCase = readTemperatureUseCase
       
    }

    func onAppear() {
        Task { await refreshAll() }
    }

    func refreshAll() async {
        /*let useCase = self.readTemperatureUseCase
        let deviceIDString = String(describing: device.deviceID)

        isLoading = true
        defer { isLoading = false }

        do {
            let value = try await useCase.execute(deviceID: deviceIDString)
            
            // CORRECCIÓN: Creamos el objeto TemperatureReading
            // Asumo que tu struct tiene un inicializador que acepta el valor y quizás la fecha
            self.temperature = TemperatureReading(value: value, unit: "Unit", timestamp: Date())
            
        } catch {
            errorMessage = "Error al actualizar estados"
        }*/
    }
    
   

    func toggleLed() {
        // 1. Capturamos las propiedades fuera de la Task
        let useCase = self.toggleLedUseCase
        let deviceID = device.deviceID
        let targetState: LedState = (ledState == .on) ? .off : .on

        Task {
            isLoading = true
            defer { isLoading = false }

            do {
                // 2. Usamos las constantes capturadas
                try await useCase.execute(deviceID: deviceID, to: targetState)
                ledState = targetState
            } catch {
                errorMessage = "No se pudo cambiar el LED"
            }
        }
    }
}
