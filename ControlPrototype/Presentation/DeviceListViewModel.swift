//
//  DeviceListViewModel.swift
//  ControlPrototype
//
//  Created by Andres Trotti on 1/23/26.
//

// DeviceListViewModel.swift
import Foundation

@MainActor
final class DeviceListViewModel: ObservableObject {
    @Published var devices: [MatterDevice] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let getKnownDevicesUseCase: GetKnownDevicesUseCase

    init(getKnownDevicesUseCase: GetKnownDevicesUseCase) {
        self.getKnownDevicesUseCase = getKnownDevicesUseCase
        
        // Precargar datos de ejemplo inmediatamente
        loadMockDevices()
    }

    func load() {
        Task {
            isLoading = true
            defer { isLoading = false }
            
            /*do {
                // Intentar cargar dispositivos reales
                let realDevices = try await getKnownDevicesUseCase.execute()
                
                if !realDevices.isEmpty {
                    // Si hay dispositivos reales, reemplazar los mocks
                    devices = realDevices
                } else {
                    // Si no hay dispositivos, mantener los mocks
                    print("No se encontraron dispositivos reales")
                }
                
            } catch {
                errorMessage = "Error al cargar dispositivos: \(error.localizedDescription)"
                // Mantener dispositivos mock en caso de error
            }*/
        }
    }
    
     func loadMockDevices() {
        // Datos de ejemplo para desarrollo
        devices = [
            MatterDevice(
                deviceID: MatterDeviceID(rawValue: 0xF001),
                name: "Termostato Sala",
                isOnline: true
            ),
            MatterDevice(
                deviceID: MatterDeviceID(rawValue: 0xF002),
                name: "Luz Cocina",
                isOnline: true
            ),
            MatterDevice(
                deviceID: MatterDeviceID(rawValue: 0xF003),
                name: "Ventilador Dormitorio",
                isOnline: false
            ),
            MatterDevice(
                deviceID: MatterDeviceID(rawValue: 0xF004),
                name: "Sensor Puerta",
                isOnline: true
            ),
            MatterDevice(
                deviceID: MatterDeviceID(rawValue: 0xF005),
                name: "Enchufe Inteligente",
                isOnline: true
            ),
            MatterDevice(
                deviceID: MatterDeviceID(rawValue: 0xF006),
                name: "Cámara Seguridad",
                isOnline: false
            )
        ]
    }
    
    // Función para añadir dispositivo mock (para testing)
    func addMockDevice() {
        let newDevice = MatterDevice(
            deviceID: MatterDeviceID(rawValue: UInt64.random(in: 0xF100...0xF999)),
            name: "Nuevo Dispositivo",
            isOnline: Bool.random()
        )
        devices.append(newDevice)
    }
}

