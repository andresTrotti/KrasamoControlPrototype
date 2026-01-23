// Data

final class MatterDeviceRepositoryImpl: MatterDeviceRepository {
    private let controller: MTRDeviceController // o el tipo actual del SDK

    init(controller: MTRDeviceController) {
        self.controller = controller
    }

    func commissionDevice(fromQRCode qrString: String) async throws -> MatterDevice {
        // 1. Parsear QR → setup payload
        // 2. Llamar a controller para commissioning
        // 3. Esperar resultado y mapear a MatterDevice

        // Pseudocódigo:
        /*
        let params = MTRCommissioningParameters()
        params.setupPayload = qrString
        let nodeID = try await controller.commissionDevice(with: params)
        return MatterDevice(id: MatterDeviceID(rawValue: nodeID),
                            name: "x917",
                            isOnline: true)
        */
        throw NSError(domain: "NotImplemented", code: -1)
    }

    func getKnownDevices() async throws -> [MatterDevice] {
        // Leer de storage local + validar con controller si siguen online
        []
    }

    func toggleLed(for device: MatterDeviceID, to state: LedState) async throws {
        // Usar clusters de Matter (OnOff cluster) para mandar comando
        /*
        let device = try await controller.device(forNodeID: device.rawValue)
        let onOffCluster = MTRClusterOnOff(device: device, endpoint: 1, queue: .main)
        if state == .on {
            try await onOffCluster.on()
        } else {
            try await onOffCluster.off()
        }
        */
    }

    func readTemperature(for device: MatterDeviceID) async throws -> TemperatureReading {
        /*
        let device = try await controller.device(forNodeID: device.rawValue)
        let tempCluster = MTRClusterTemperatureMeasurement(device: device, endpoint: 1, queue: .main)
        let attributes = try await tempCluster.readAttributes()
        let value = attributes.measuredValue
        return TemperatureReading(value: Double(value) / 100.0,
                                  unit: "°C",
                                  timestamp: Date())
        */
        throw NSError(domain: "NotImplemented", code: -1)
    }

    func readHeaterState(for device: MatterDeviceID) async throws -> HeaterState {
        // Leer cluster correspondiente (ej. Thermostat / HVAC)
        .off
    }

    func readCoolerState(for device: MatterDeviceID) async throws -> CoolerState {
        // Igual que arriba
        .off
    }
}
