//
//  MatterDeviceRepository.swift
//  ControlPrototype
//
//  Created by Andres Trotti on 1/23/26.
//


import Foundation
import Matter

protocol MatterDeviceRepository {
    func commissionDevice(fromQRCode qrString: String) async throws -> MatterDevice
    func getKnownDevices() async throws -> [MatterDevice]
    func toggleLed(for device: MatterDeviceID, to state: LedState) async throws
    func readTemperature(for device: MatterDeviceID) async throws -> TemperatureReading
    func readHeaterState(for device: MatterDeviceID) async throws -> HeaterState
    func readCoolerState(for device: MatterDeviceID) async throws -> CoolerState
}

extension MatterDeviceRepository {
    
    // Valor por defecto para dispositivos conocidos (lista vacía)
    func getKnownDevices() async throws -> [MatterDevice] {
        return []
    }


    func commissionDevice(fromQRCode qrString: String) async throws -> MatterDevice {
        // 1. Parsear QR
        let setupPayload = try MTRSetupPayload(onboardingPayload: qrString)

        // 2. Crear parámetros
        let params = MTRCommissioningParameters()

        // 3. Obtener controller
        let controller = MatterControllerFactory.makeController()

        // 4. NodeID
        let nodeID: UInt64 = 0x1234

        // 5. Llamar al método correcto (el único que tu SDK soporta)
        try controller.commissionDevice(nodeID, commissioningParams: params)

        // 6. Devolver tu modelo
        return MatterDevice(
            deviceID: MatterDeviceID(rawValue: nodeID),
            name: "Matter Device",
            isOnline: true
        )
    }




    // Valor por defecto para el LED (no hace nada)
    func toggleLed(for device: MatterDeviceID, to state: LedState) async throws {
        print("Log: toggleLed no implementado aún para \(device)")
    }

    // Valor por defecto para Temperatura
    func readTemperature(for device: MatterDeviceID) async throws -> TemperatureReading {
        return TemperatureReading(value: 0.0, unit: "°C", timestamp: Date())
    }

    // Valores por defecto para Climatización
    func readHeaterState(for device: MatterDeviceID) async throws -> HeaterState {
        return .off
    }

    func readCoolerState(for device: MatterDeviceID) async throws -> CoolerState {
        return .off
    }
}
