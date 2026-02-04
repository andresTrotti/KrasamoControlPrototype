//
//  MatterManager.swift
//  ControlPrototype
//
//  Created by Andres Trotti on 2/2/26.
//


import Foundation
import Matter

class MTRKeypairImpl: NSObject, MTRKeypair {
    private let key: SecKey

    override init() {
        // Configuración ECC (Curva Elíptica) P256 - Estándar Matter
        let attributes: [String: Any] = [
            kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
            kSecAttrKeySizeInBits as String: 256
        ]
        
        var error: Unmanaged<CFError>?
        guard let privateKey = SecKeyCreateRandomKey(attributes as CFDictionary, &error) else {
            fatalError("Error generando llaves ECC: \(error!.takeRetainedValue())")
        }
        self.key = privateKey
        super.init()
    }

    // CORRECCIÓN DEFINITIVA:
    // 1. Es una 'func' (no var) para cumplir con el protocolo.
    // 2. Tiene '@objc' para que Matter la encuentre y no crashee.
    @objc func publicKey() -> SecKey {
        return SecKeyCopyPublicKey(key)!
    }

    // Firma digital
    @objc func signMessageECDSA_DER(_ message: Data) -> Data {
        var error: Unmanaged<CFError>?
        guard let signature = SecKeyCreateSignature(key, .ecdsaSignatureMessageX962SHA256, message as CFData, &error) else {
            print("Error firmando: \(error!.takeRetainedValue())")
            return Data()
        }
        return signature as Data
    }
}


class MatterManager: NSObject, MTRDeviceControllerDelegate {
    @MainActor  static let shared = MatterManager()
    
    private var controller: MTRDeviceController?
    
    // Variables temporales
    private var pendingNodeID: NSNumber?
    private var wifiSSID: String = ""
    private var wifiPass: String = ""
    private var commissionContinuation: CheckedContinuation<Void, Error>?
    
    override init() {
        super.init()
        
        // 1. SOLUCIÓN AL ERROR DE NOMBRE: Usamos 'LocalMatterStorage' en lugar de 'MTRStorage'
        let storage = LocalMatterStorage()
        let factory = MTRDeviceControllerFactory.sharedInstance()
        
        // Inicializamos la fábrica
        let factoryParams = MTRDeviceControllerFactoryParams(storage: storage)
        do {
            try factory.start(factoryParams)
        } catch {
            print("❌ Error fatal iniciando Factory: \(error)")
            return
        }
        
        // 2. SOLUCIÓN AL ERROR DE 'NIL': Creamos parámetros de inicio reales
        // Generamos claves básicas para un entorno de desarrollo (Fabric ID 1)
        let keys = MTRKeypairImpl() // Usamos nuestra clase auxiliar de claves (ver abajo)
        let ipk = Data(repeating: 0, count: 16) // Clave IPK de prueba (16 bytes vacíos)
        
        let startupParams = MTRDeviceControllerStartupParams(ipk: ipk, fabricID: 1, nocSigner: keys)
        startupParams.vendorID = 0xFFF1 // Vendor ID de pruebas estándar
        
        // Creamos el controlador con los parámetros (ya no es nil)
        do {
            self.controller = try factory.createController(onNewFabric: startupParams)
            print("✅ Matter Controller creado exitosamente")
        } catch {
            print("❌ Error creando controlador: \(error)")
        }
        
        // Nos ponemos como delegados
        self.controller?.setDeviceControllerDelegate(self, queue: DispatchQueue.main)
    }
    
    // --- FUNCIÓN PÚBLICA PARA INICIAR ---
    func startCommissioning(qrCode: String, wifiName: String, wifiPassword: String) async throws {
        self.wifiSSID = wifiName
        self.wifiPass = wifiPassword
        self.pendingNodeID = NSNumber(value: UInt64(Date().timeIntervalSince1970))
        
        guard let payload = MTRSetupPayload(payload: qrCode) else {
            throw NSError(domain: "App", code: -1, userInfo: [NSLocalizedDescriptionKey: "QR Inválido"])
        }
        
        guard let controller = self.controller, let nodeID = self.pendingNodeID else {
            throw NSError(domain: "App", code: -2, userInfo: [NSLocalizedDescriptionKey: "Controlador no inicializado"])
        }
        
        print("1️⃣ Iniciando Bluetooth (PASE)...")
        
        try await withCheckedThrowingContinuation { continuation in
            self.commissionContinuation = continuation
            do {
                try controller.setupCommissioningSession(with: payload, newNodeID: nodeID)
            } catch {
                continuation.resume(throwing: error)
                self.commissionContinuation = nil
            }
        }
    }
    
    // --- DELEGATES ---
    func controller(_ controller: MTRDeviceController, commissioningSessionEstablishmentDone error: Error?) {
        if let error = error {
            print("❌ Error en Bluetooth: \(error.localizedDescription)")
            commissionContinuation?.resume(throwing: error)
            commissionContinuation = nil
            return
        }
        
        print("2️⃣ Bluetooth Conectado. Enviando Wi-Fi: \(wifiSSID)")
        
        let params = MTRCommissioningParameters()
        if let ssidData = wifiSSID.data(using: .utf8),
           let passData = wifiPass.data(using: .utf8) {
            params.wifiSSID = ssidData
            params.wifiCredentials = passData
        }
        
        do {
            try self.controller?.commissionNode(withID: pendingNodeID!, commissioningParams: params)
        } catch {
            commissionContinuation?.resume(throwing: error)
            commissionContinuation = nil
        }
    }
    
    func controller(_ controller: MTRDeviceController, commissioningComplete error: Error?, nodeID: NSNumber?) {
        if let error = error {
            print("❌ Falló el comisionamiento final: \(error.localizedDescription)")
            commissionContinuation?.resume(throwing: error)
        } else {
            print("🎉 ¡ÉXITO TOTAL! Dispositivo Matter agregado.")
            commissionContinuation?.resume()
        }
        commissionContinuation = nil
    }
}

// ----------------------------------------------------------------
// CLASES AUXILIARES (Pégalas al final del archivo)
// ----------------------------------------------------------------

// 1. Storage con nombre único para evitar conflictos
class LocalMatterStorage: NSObject, MTRStorage {
    func storageData(forKey key: String) -> Data? {
        return UserDefaults.standard.data(forKey: "matter_" + key)
    }
    
    func setStorageData(_ value: Data, forKey key: String) -> Bool {
        UserDefaults.standard.set(value, forKey: "matter_" + key)
        return true
    }
    
    func removeStorageData(forKey key: String) -> Bool {
        UserDefaults.standard.removeObject(forKey: "matter_" + key)
        return true
    }
}


