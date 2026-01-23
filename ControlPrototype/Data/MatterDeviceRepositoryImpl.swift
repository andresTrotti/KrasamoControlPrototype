//
//  MatterDeviceRepositoryImpl.swift
//  ControlPrototype
//
//  Created by Andres Trotti on 1/23/26.
//
import Matter

final class MatterDeviceRepositoryImpl: MatterDeviceRepository {
    
    
    
    private let controller: MTRDeviceController

    init(controller: MTRDeviceController) {
        self.controller = controller
    }
    
   
    
    

    // FEATURE: Control de LED (OnOff)
    func toggleLed(for deviceID: MatterDeviceID, to state: LedState) async throws {
        let device = MTRDevice(nodeID: NSNumber(value: deviceID.rawValue), controller: self.controller)
        
        // Desenvolver el clúster opcional
        guard let onOffCluster = MTRClusterOnOff(device: device, endpointID: 1, queue: .main) else {
            throw NSError(domain: "Matter", code: -1, userInfo: [NSLocalizedDescriptionKey: "No se pudo instanciar el clúster OnOff"])
        }
        
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            let completion: (Error?) -> Void = { error in
                if let error = error { continuation.resume(throwing: error) }
                else { continuation.resume() }
            }
            
            // Xcode 16.4+ prefiere este formato para comandos
            if state == .on {
                onOffCluster.on(with: nil, expectedValues: nil, expectedValueInterval: nil, completion: completion)
            } else {
                onOffCluster.off(with: nil, expectedValues: nil, expectedValueInterval: nil, completion: completion)
            }
        }
    }

    func readTemperature(for deviceID: MatterDeviceID) async throws -> TemperatureReading {
        let device = MTRDevice(nodeID: NSNumber(value: deviceID.rawValue), controller: self.controller)
        guard let tempCluster = MTRClusterTemperatureMeasurement(device: device, endpointID: 1, queue: .main) else {
            throw NSError(domain: "Matter", code: -1)
        }

        let value = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<NSNumber, Error>) in
            // El completion DEBE ir dentro del paréntesis para evitar el "Extra trailing closure"
            tempCluster.readAttributeMeasuredValue(with: nil)
        }

        return TemperatureReading(
            value: Double(truncating: value) / 100.0,
            unit: "°C",
            timestamp: Date()
        )
    }

    // FEATURE: Revisar Estados de Heater (Thermostat)
    func readHeaterState(for deviceID: MatterDeviceID) async throws -> HeaterState {
        let device = MTRDevice(nodeID: NSNumber(value: deviceID.rawValue), controller: self.controller)
        
        guard let thermostatCluster = MTRClusterThermostat(device: device, endpointID: 1, queue: .main) else {
            return .off
        }
        
        let mode = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<NSNumber, Error>) in
            thermostatCluster.readAttributeSystemMode(with: nil)
        }
        
        // Ajusta esto según cómo hayas definido tu enum HeaterState
        // 4 = Heat en el estándar Matter
        return Int(truncating: mode) == 4 ? .on : .off
    }
}
