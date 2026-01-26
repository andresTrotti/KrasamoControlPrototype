//
//  MatterControllerFactory 2.swift
//  ControlPrototype
//
//  Created by Andres Trotti on 1/23/26.
//


import Matter

class MatterStorage: NSObject, MTRStorage {
    func storageData(forKey key: String) -> Data? {
        UserDefaults.standard.data(forKey: "matter.\(key)")
    }

    func setStorageData(_ data: Data, forKey key: String) -> Bool {
        UserDefaults.standard.set(data, forKey: "matter.\(key)")
        return true
    }

    func removeStorageData(forKey key: String) -> Bool {
        UserDefaults.standard.removeObject(forKey: "matter.\(key)")
        return true
    }
}

func commissionMyX917(qrString: String, nodeId: UInt64) {
    let controller = MatterControllerFactory.makeController()
    
    do {
        // 1. Corrección del inicializador: Se usa 'onboardingPayload:' (o el string directo en versiones nuevas)
        // Si 'onboardingPayload' falla, usa MTRSetupPayload(setupPasscodeString:) pero asegúrate de importar Matter correctamente.
        let payload = try MTRSetupPayload(onboardingPayload: qrString)
        
        // 2. Corrección del método: En Xcode 16.4 el controlador usa setupCommissioningSession
        // o el método de conveniencia para emparejamiento directo.
        try controller.setupCommissioningSession(with: payload,
                                                 newNodeID: NSNumber(value: nodeId))
        
        print("Sesión de emparejamiento abierta para el nodo \(nodeId)")
        
    } catch {
        print("Error en el emparejamiento: \(error.localizedDescription)")
    }
}




import Foundation
import Matter

enum MatterControllerFactory {
    static func makeController() -> MTRDeviceController {
        let storage = MatterStorage()
        let keypair = MatterKeypair()
        let ipk = Data([0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07,
                        0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F])

        // 1. Inicialización obligatoria (IPK, FabricID, Keypair)
        let params = MTRDeviceControllerStartupParams(ipk: ipk, fabricID: 1, nocSigner: keypair)
        params.vendorID = NSNumber(value: 0xFFF1)

        do {
            let factory = MTRDeviceControllerFactory.sharedInstance()
            
            // 2. Iniciar la factoría si no está corriendo
            if !factory.isRunning {
                let factoryParams = MTRDeviceControllerFactoryParams(storage: storage)
                try factory.start(factoryParams)
            }
            
            // 3. CORRECCIÓN: createController(with: params)
            // Asegúrate de usar 'try' y que 'params' sea exactamente el objeto de arriba
            return try factory.createController(onNewFabric: params)
            
        } catch {
            fatalError("Error crítico: \(error.localizedDescription)")
        }
    }
}



