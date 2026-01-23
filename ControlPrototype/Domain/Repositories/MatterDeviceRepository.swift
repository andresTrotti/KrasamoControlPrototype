//
//  MatterDeviceRepository.swift
//  ControlPrototype
//
//  Created by Andres Trotti on 1/23/26.
//


import Foundation

protocol MatterDeviceRepository {
    func commissionDevice(fromQRCode qrString: String) async throws -> MatterDevice
    func getKnownDevices() async throws -> [MatterDevice]

    func toggleLed(for device: MatterDeviceID, to state: LedState) async throws
    func readTemperature(for device: MatterDeviceID) async throws -> TemperatureReading
    func readHeaterState(for device: MatterDeviceID) async throws -> HeaterState
    func readCoolerState(for device: MatterDeviceID) async throws -> CoolerState
}
