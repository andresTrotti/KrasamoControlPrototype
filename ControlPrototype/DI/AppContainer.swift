//
//  AppContainer.swift
//  ControlPrototype
//
//  Created by Andres Trotti on 1/23/26.
//

import Foundation
import Matter

@MainActor
final class AppContainer: NSObject, ObservableObject {
    
        static let shared = AppContainer()
    
    // 1. Dependencias de bajo nivel (SDK de Matter)
     let matterController: MTRDeviceController
    
    

    // 2. Repositorios
    private let deviceRepository: MatterDeviceRepository

    override init() { // Agrega 'override' porque ahora heredamos de NSObject
            // 1. Crear el controlador
            let controller = MatterControllerFactory.makeController()
            self.matterController = controller
            
            // 2. Inicializar repositorio
            self.deviceRepository = MatterDeviceRepositoryImpl(controller: controller)
            
            super.init() // Llamada obligatoria al padre NSObject

            // 3. CONEXIÓN CLAVE: Conectamos los "oídos"
            // Usamos la cola principal para que los eventos lleguen directos a la UI
            self.matterController.setDeviceControllerDelegate(self, queue: DispatchQueue.main)

            // Log de depuración
            if let id = matterController.controllerNodeID {
                print("✅ Matter Controller listo en AppContainer. Node ID: \(id)")
            }
        }

    // --- Creadores de ViewModels (Para el Router) ---

    func makeDeviceListViewModel() -> DeviceListViewModel {
        // Aquí es donde nace el 'getKnownDevicesUseCase'
        let useCase = GetKnownDevicesUseCaseImpl(repository: deviceRepository)
        return DeviceListViewModel(getKnownDevicesUseCase: useCase)
    }

    func makeDeviceDetailViewModel(device: MatterDevice) -> DeviceDetailViewModel {
        return DeviceDetailViewModel(
            device: device,
            toggleLedUseCase: ToggleLedUseCase(repository: deviceRepository),
            readTemperatureUseCase: ReadTemperatureUseCase(repository: deviceRepository)
        )
    }

    func makeQRScannerViewModel() -> QRScannerViewModel {
        let useCase = CommissionDeviceUseCase(repository: deviceRepository)
        return QRScannerViewModel(commissionDeviceUseCase: useCase)
    }
}


// MARK: - MTRDeviceControllerDelegate
extension AppContainer: MTRDeviceControllerDelegate {
    
    // 1. Para ver el progreso paso a paso (Configurando red, verificando certificados, etc.)
    nonisolated func controller(_ controller: MTRDeviceController, statusUpdate status: MTRCommissioningStatus) {
        print("Estado del comisionamiento: \(status.rawValue)")
    }

    // 2. Para saber cuándo terminó la fase PASE (Bluetooth/Seguridad inicial)
    nonisolated func controller(_ controller: MTRDeviceController, commissioningSessionEstablishmentDone error: Error?) {
        if let error = error {
            print("❌ Error en fase Bluetooth (PASE): \(error.localizedDescription)")
            return
        }
        print("🔵 Bluetooth establecido y seguro. Enviando credenciales Wi-Fi al x917...")
    }

        
     
    
    
     func controller(_ controller: MTRDeviceController, commissioningSessionEstablishmentDone error: Error?, statusUpdate status: MTRCommissioningStatus) {
        // Como es nonisolated, no podemos tocar propiedades de 'self' directamente sin 'await'
        // Pero los print son seguros.
        print("Estado del comisionamiento: \(status.rawValue)")
        
        if let error = error {
            print("❌ Error en fase Bluetooth (PASE): \(error.localizedDescription)")
            return
        }
        print("🔵 Bluetooth establecido. Enviando credenciales Wi-Fi al x917...")
    }

    
    nonisolated func controller(_ controller: MTRDeviceController, commissioningComplete error: Error?, nodeID: NSNumber?) {
        print(">>> Bluetooth en modo PASE (CASE).\n")
        
        if let error = error {
            print("❌ Error en fase Wi-Fi/Certificados (CASE): \(error.localizedDescription)")
            return
        }
        
        guard let nodeID = nodeID else { return }
        print("🎉 ¡COMISIONAMIENTO EXITOSO! Nuevo dispositivo ID: \(nodeID)")
        
        // IMPORTANTE: Si necesitas actualizar una variable @Published de AppContainer
        // o notificar a la UI, debes volver explícitamente al MainActor:
        Task { @MainActor in
            // Aquí dentro ya puedes tocar 'self.devices' o enviar notificaciones
            // self.refreshDevices()
        }
    }
}
