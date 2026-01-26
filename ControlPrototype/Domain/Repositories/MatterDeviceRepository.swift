//
//  MatterDeviceRepository.swift
//  ControlPrototype
//
//  Created by Andres Trotti on 1/23/26.
//


import Foundation
import Matter

protocol MatterDeviceRepository: Sendable {
    func commissionDevice(fromQRCode qrString: String) async throws -> MatterDevice
    func getKnownDevices() async throws -> [MatterDevice]
    func toggleLed(for device: MatterDeviceID, to state: LedState) async throws
    func readTemperature(for device: MatterDeviceID) async throws -> TemperatureReading
    func readHeaterState(for device: MatterDeviceID) async throws -> HeaterState
    func readCoolerState(for device: MatterDeviceID) async throws -> CoolerState
    func readAttribute(for deviceID: String, endpointID: UInt16, clusterID: UInt32, attributeID: UInt32) async throws -> any Sendable
}

extension MatterDeviceRepository {
    
    // Valor por defecto para dispositivos conocidos (lista vacía)
    func getKnownDevices() async throws -> [MatterDevice] {
        return []
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
