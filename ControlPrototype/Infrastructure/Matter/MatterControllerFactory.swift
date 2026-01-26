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



enum MatterControllerFactory {

    static func makeController() -> MTRDeviceController {
        let factory = MTRDeviceControllerFactory.sharedInstance()
        let storage = MatterStorage()
        let keypair = MatterKeypair()

        // Iniciar el factory si aún no está corriendo
        if !factory.isRunning {
            let factoryParams = MTRDeviceControllerFactoryParams(storage: storage)
            do {
                try factory.start(factoryParams)
            } catch {
                fatalError("No se pudo iniciar MTRDeviceControllerFactory: \(error)")
            }
        }

        // IPK binaria válida (16 bytes aleatorios)
        let ipk = Data((0..<16).map { _ in UInt8.random(in: 0...255) })

        let startupParams = MTRDeviceControllerStartupParams(
            ipk: ipk,
            fabricID: 1,
            nocSigner: keypair
        )
        startupParams.vendorID = 0xFFF1  // Vendor ID de prueba

        // Intentar reutilizar fabric existente; si no existe, crear uno nuevo
        do {
            return try factory.createController(onExistingFabric: startupParams)
        } catch {
            do {
                return try factory.createController(onNewFabric: startupParams)
            } catch {
                fatalError("Error crítico al crear Matter controller: \(error)")
            }
        }
    }
}

