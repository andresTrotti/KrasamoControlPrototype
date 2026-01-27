//
//  MatterDeviceRepositoryImpl.swift
//  ControlPrototype
//
//  Created by Andres Trotti on 1/23/26.
//
@preconcurrency import Matter

@MainActor
final class MatterDeviceRepositoryImpl: MatterDeviceRepository, Sendable {
    // Firma actualizada
    // Asegúrate de que tu Repositorio o Clase tenga: import Matter

    func readAttribute(for deviceID: String, endpointID: UInt16, clusterID: UInt32, attributeID: UInt32) async throws -> any Sendable {
            
        // 1. Validar ID
        guard let nodeID = UInt64(deviceID) else {
            throw MatterError.invalidDeviceID
        }
        
        // 2. Preparar Dispositivo y Ruta
        let device = MTRDevice(nodeID: NSNumber(value: nodeID), controller: self.controller)
        let path = MTRAttributeRequestPath(endpointID: NSNumber(value: endpointID),
                                           clusterID: NSNumber(value: clusterID),
                                           attributeID: NSNumber(value: attributeID))
        
        // 3. Llamada al SDK (Devuelve un Array de diccionarios)
        // Usamos 'await' para esperar la respuesta del chip
        let reports = try await device.readAttributePaths([path])
        
        // ---------------------------------------------------------------
        // AQUÍ ESTABA EL ERROR: Definimos 'firstReport'
        // ---------------------------------------------------------------
        guard let firstReport = reports.first else {
            throw MatterError.attributeNotFound
        }
        
        guard let value = firstReport["data"] ?? firstReport["value"] else {
                throw MatterError.attributeNotFound
            }
            
            // 6. CORRECCIÓN: Validación por Tipos Concretos
            // En lugar de preguntar "¿eres Sendable?", preguntamos "¿eres un Número?".
            // Al devolver un tipo concreto que es Sendable, el compilador queda satisfecho.
            
            if let number = value as? NSNumber {
                return number // ✅ NSNumber es Sendable
            }
            else if let text = value as? String {
                return text // ✅ String es Sendable
            }
            else if let data = value as? Data {
                return data // ✅ Data es Sendable
            }
        
        // Si llega algo complejo (como un Array o Diccionario anidado), por ahora fallamos
            print("❌ Tipo de dato no soportado o no seguro: \(type(of: value))")
            throw MatterError.invalidDataFormat
    }
    
   
    
    func commissionDevice(fromQRCode qrString: String) async throws -> MatterDevice {
        let controller = await AppContainer.shared.matterController
        let setupPayload = try MTRSetupPayload(onboardingPayload: qrString)
        let nodeID = NSNumber(value: UInt64(Date().timeIntervalSince1970))
        
        print("Iniciando sesión de comisionamiento para el Nodo: \(nodeID)")

        // 1. Llamada corregida según la firma de tu SDK (sin await y sin parámetros extra)
        // Nota: Aunque la función es 'throws', al estar en un entorno async,
        // Swift permite usar 'try' directamente.
        try controller.setupCommissioningSession(with: setupPayload, newNodeID: nodeID)

        let myID = MatterDeviceID(rawValue: nodeID.uint64Value)

        return MatterDevice(
            deviceID: myID,
            name: "SiLabs Light",
            isOnline: false
        )
    }
    
   
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
