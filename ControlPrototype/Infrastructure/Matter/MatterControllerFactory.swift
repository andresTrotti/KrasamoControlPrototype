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
        // 1. Parsear el QR
        let payload = try MTRSetupPayload(setupPasscodeString: qrString)
        
        // 2. Iniciar el Commissioning (Antes setupDevice)
        // Este método busca el dispositivo via BLE, lo une a la red y lo configura
        try controller.setupNode(forNodeID: NSNumber(value: nodeId),
                                 onboardingPayload: payload)
        
        print("Proceso de Commissioning iniciado para el nodo \(nodeId)")
        
    } catch {
        print("Error al iniciar el emparejamiento: \(error.localizedDescription)")
    }
}



enum MatterControllerFactory {
    static func makeController() -> MTRDeviceController {
        let factory = MTRDeviceControllerFactory.sharedInstance()
        let storage = MatterStorage()
        let keypair = MatterKeypair() // Instanciamos nuestro firmante
        
        let factoryParams = MTRDeviceControllerFactoryParams(storage: storage)
        
        // Iniciamos la fábrica (solo una vez en el ciclo de vida de la app)
        if !factory.isRunning {
            try? factory.start(factoryParams)
        }

        let ipk = Data(count: 16)
        
        // CORRECCIÓN: Usamos nocSigner y fabricID
        // El sellerID/VendorID se configura opcionalmente después si es necesario
        let startupParams = MTRDeviceControllerStartupParams(ipk: ipk, fabricID: 1, nocSigner: keypair)
        startupParams.vendorID = 0xFFF1 // Opcional: ID de prueba de Matter
        
        do {
            // Si el fabric ya existe, usamos 'onExistingFabric'
            // Si es la primera vez, se puede usar 'createController'
            let controller = try factory.createController(onExistingFabric: startupParams)
            return controller
        } catch {
            // Manejo de error más limpio para escalabilidad
            print("Fallo al crear controlador: \(error)")
            fatalError("Detalle: \(error.localizedDescription)")
        }
    }
}
