//
//  CommissioningWorker.swift
//  ControlPrototype
//
//  Created by Andres Trotti on 2/2/26.
//


import Matter

class CommissioningWorker: NSObject, MTRDeviceControllerDelegate {
    private let controller: MTRDeviceController
    private let nodeID: NSNumber
    private let wifiSSID: String
    private let wifiPass: String
    private var continuation: CheckedContinuation<Void, Error>?
    private var retainSelf: CommissioningWorker? // Truco para mantenerse vivo en memoria

    init(controller: MTRDeviceController, nodeID: NSNumber, ssid: String, pass: String) {
        self.controller = controller
        self.nodeID = nodeID
        self.wifiSSID = ssid
        self.wifiPass = pass
        super.init()
    }

    func start(payload: MTRSetupPayload) async throws {
        // Nos guardamos a nosotros mismos para no morir antes de que acabe el delegate
        self.retainSelf = self
        
        return try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation
            
            // 1. Nos ponemos como "El Jefe" (Delegate) para escuchar los eventos
            controller.setDeviceControllerDelegate(self, queue: DispatchQueue.main)
            
            do {
                // 2. Iniciamos el Bluetooth (PASE)
                try controller.setupCommissioningSession(with: payload, newNodeID: nodeID)
            } catch {
                continuation.resume(throwing: error)
                self.retainSelf = nil
            }
        }
    }

    // --- ESTE ES EL MOMENTO MÁGICO ---
    // El controlador nos llama aquí cuando el Bluetooth YA conectó
    func controller(_ controller: MTRDeviceController, commissioningSessionEstablishmentDone error: Error?) {
        if let error = error {
            continuation?.resume(throwing: error)
            retainSelf = nil
            return
        }

        // 3. ¡AHORA SÍ! Estamos conectados. Inyectamos el Wi-Fi.
        print("✅ Bluetooth Conectado. Enviando credenciales Wi-Fi...")
        
        let params = MTRCommissioningParameters()
        if let ssidData = wifiSSID.data(using: .utf8),
           let passData = wifiPass.data(using: .utf8) {
            params.wifiSSID = ssidData
            params.wifiCredentials = passData
            
        }

        do {
            try controller.commissionNode(withID: nodeID, commissioningParams: params)
            // Si llegamos aquí sin error, damos por bueno este paso
            continuation?.resume()
        } catch {
            continuation?.resume(throwing: error)
        }
        
        retainSelf = nil // Trabajo terminado, podemos desaparecer
    }
    
    func controller(_ controller: MTRDeviceController, commissioningComplete error: Error?, nodeID: NSNumber?) {
        // Este es opcional, pero bueno para depurar
        if let error = error {
            print("❌ Error final de comisionamiento: \(error)")
        } else {
            print("🎉 ¡COMISIONAMIENTO COMPLETADO EXITOSAMENTE!")
        }
    }
}
