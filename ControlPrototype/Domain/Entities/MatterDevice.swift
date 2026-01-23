//
//  MatterDeviceID.swift
//  ControlPrototype
//
//  Created by Andres Trotti on 1/23/26.
//

import Foundation




struct MatterDeviceID: Hashable {
    let rawValue: UInt64
}

struct MatterDevice {
    let id: MatterDeviceID
    let name: String
    let isOnline: Bool
}

enum LedState {
    case on
    case off
}

struct TemperatureReading {
    let value: Double
    let unit: String // "°C"
    let timestamp: Date
}

enum HeaterState {
    case off
    case heating
}

enum CoolerState {
    case off
    case cooling
}

protocol MatterDeviceRepository {
    func commissionDevice(fromQRCode qrString: String) async throws -> MatterDevice
    func getKnownDevices() async throws -> [MatterDevice]
    func toggleLed(for device: MatterDeviceID, to state: LedState) async throws
    func readTemperature(for device: MatterDeviceID) async throws -> TemperatureReading
    func readHeaterState(for device: MatterDeviceID) async throws -> HeaterState
    func readCoolerState(for device: MatterDeviceID) async throws -> CoolerState
}
