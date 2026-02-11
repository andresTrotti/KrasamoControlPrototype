//
//  DeviceDetailViewModel 2.swift
//  ControlPrototype
//
//  Created by Andres Trotti on 1/23/26.
//

import Foundation

// MARK: - Enums y Structs auxiliares (fuera de @MainActor)
enum DeviceFeature: String, CaseIterable, Identifiable {
    case temperature = "Temperature"
    case humidity = "Humidity"
    case light = "Light"
    case brightness = "Brightness"
    case heater = "Heater"
    case cooler = "Cooler"
    case fan = "Fan"
    case speed = "Speed"
    case power = "Power Consumption"
    case battery = "Battery"
    case connectivity = "Connectivity"
    case lastSeen = "Last Seen"
    
    var id: String { self.rawValue }
    
    var icon: String {
        switch self {
        case .temperature: return "thermometer"
        case .humidity: return "humidity"
        case .light: return "lightbulb"
        case .brightness: return "sun.max"
        case .heater: return "flame"
        case .cooler: return "snowflake"
        case .fan: return "wind"
        case .speed: return "speedometer"
        case .power: return "bolt"
        case .battery: return "battery.50"
        case .connectivity: return "wifi"
        case .lastSeen: return "clock"
        }
    }
    
    var unit: String {
        switch self {
        case .temperature: return "°C"
        case .humidity: return "%"
        case .brightness: return "%"
        case .power: return "kWh"
        case .battery: return "%"
        default: return ""
        }
    }
}

struct FeatureState {
    var isAvailable: Bool
    var value: Any
    var lastUpdated: Date?
}

// MARK: - ViewModel principal (@MainActor)
@MainActor
final class DeviceDetailViewModel: ObservableObject {
    @Published var device: MatterDevice
    @Published var ledState: LedState = .off
    @Published var temperature: TemperatureReading?
    @Published var heaterState: HeaterState = .off
    @Published var coolerState: CoolerState = .off
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // Nuevas propiedades
    @Published var humidity: Double?
    @Published var powerConsumption: Double?
    @Published var brightness: Int = 50
    @Published var fanSpeed: Int = 2
    @Published var isConnected: Bool = true
    @Published var batteryLevel: Int?
    @Published var lastSeen: Date?

    private let toggleLedUseCase: ToggleLedUseCase
    private let readTemperatureUseCase: ReadTemperatureUseCase
    
    
  
    private let deviceIDString: String
    
    var availableFeatures: [DeviceFeature] = []
    @Published var features: [DeviceFeature: FeatureState] = [:]

    init(
        device: MatterDevice,
        toggleLedUseCase: ToggleLedUseCase,
        readTemperatureUseCase: ReadTemperatureUseCase
    ) {
        
      
        
        self.device = device
        self.toggleLedUseCase = toggleLedUseCase
        self.readTemperatureUseCase = readTemperatureUseCase
        self.deviceIDString = String(describing: device.deviceID.rawValue)
        
      
          
       
    }

    func onAppear() {
        Task { await refreshAll() }
        precargarDatosEjemplo()
        setupAvailableFeatures()
    }

   

    
    // MARK: - Executor thread-safe
    final class TemperatureUseCaseExecutor: Sendable {
        /*private let useCase: ReadTemperatureUseCase
        
        init(useCase: ReadTemperatureUseCase) {
            self.useCase = useCase
        }
        
        func execute(deviceID: String) async throws -> Double {
            try await useCase.execute(deviceID: deviceID)
        }*/
    }
    
    func refreshAll() async {
            await MainActor.run {
                self.isLoading = true
            }
            
            defer {
                Task { @MainActor in
                    self.isLoading = false
                }
            }
            
            do {
                /*let tempValue = try await temperatureUseCaseExecutor.execute(
                    deviceID: deviceIDString
                )
                
                await MainActor.run {
                    self.temperature = TemperatureReading(
                        value: tempValue,
                        unit: "°C",
                        timestamp: Date()
                    )
                    self.isConnected = true
                    self.lastSeen = Date()
                    self.updateMockFeatures()
                }*/
                
            } catch {
                await MainActor.run {
                    self.errorMessage = "Error: \(error.localizedDescription)"
                    self.isConnected = false
                }
            }
        }
    
    private func precargarDatosEjemplo() {
        let deviceName = device.name.lowercased()
        
        if deviceName.contains("termo") || deviceName.contains("clima") {
            self.temperature = TemperatureReading(
                value: 22.5,
                unit: "°C",
                timestamp: Date().addingTimeInterval(-300)
            )
            self.humidity = 65.0
            self.heaterState = .on
            self.coolerState = .off
            self.powerConsumption = 1.2
            self.batteryLevel = 85
            
        } else if deviceName.contains("luz") || deviceName.contains("light") || deviceName.contains("led") {
            self.ledState = .on
            self.brightness = 75
            self.powerConsumption = 0.1
            self.isConnected = true
            
        } else if deviceName.contains("ventilador") || deviceName.contains("fan") {
            self.fanSpeed = 2
            self.powerConsumption = 0.5
            self.coolerState = .on
            
        } else if deviceName.contains("enchufe") || deviceName.contains("plug") {
            self.ledState = .off
            self.powerConsumption = 0.0
            self.isConnected = true
            
        } else if deviceName.contains("sensor") {
            self.temperature = TemperatureReading(
                value: 23.1,
                unit: "°C",
                timestamp: Date()
            )
            self.humidity = 60.0
            self.batteryLevel = 45
            self.lastSeen = Date().addingTimeInterval(-60)
            
        } else {
            self.temperature = TemperatureReading(
                value: 21.0,
                unit: "°C",
                timestamp: Date()
            )
            self.ledState = .off
            self.isConnected = device.isOnline
            self.lastSeen = Date()
        }
    }
    
    private func setupAvailableFeatures() {
        let deviceName = device.name.lowercased()
        
        if deviceName.contains("termo") || deviceName.contains("clima") {
            availableFeatures = [
                .temperature, .humidity, .heater, .cooler, .power, .battery
            ]
        } else if deviceName.contains("luz") || deviceName.contains("light") {
            availableFeatures = [
                .light, .brightness, .power, .connectivity
            ]
        } else if deviceName.contains("ventilador") || deviceName.contains("fan") {
            availableFeatures = [
                .fan, .speed, .cooler, .power
            ]
        } else if deviceName.contains("sensor") {
            availableFeatures = [
                .temperature, .humidity, .battery, .connectivity, .lastSeen
            ]
        } else {
            availableFeatures = [
                .light, .temperature, .connectivity, .power
            ]
        }
        
        for feature in availableFeatures {
            features[feature] = FeatureState(
                isAvailable: true,
                value: getMockValueForFeature(feature),
                lastUpdated: Date()
            )
        }
    }
    
    private func getMockValueForFeature(_ feature: DeviceFeature) -> Any {
        switch feature {
        case .temperature:
            return temperature?.value ?? 0.0
        case .humidity:
            return humidity ?? 0.0
        case .light:
            return ledState == .on
        case .brightness:
            return brightness
        case .heater:
            return heaterState == .on
        case .cooler:
            return coolerState == .on
        case .fan:
            return fanSpeed > 0
        case .speed:
            return fanSpeed
        case .power:
            return powerConsumption ?? 0.0
        case .battery:
            return batteryLevel ?? 0
        case .connectivity:
            return isConnected
        case .lastSeen:
            return lastSeen ?? Date()
        }
    }
    
    private func updateMockFeatures() {
        if let currentTemp = temperature?.value {
            let variation = Double.random(in: -0.5...0.5)
            temperature = TemperatureReading(
                value: max(15.0, min(30.0, currentTemp + variation)),
                unit: "°C",
                timestamp: Date()
            )
        }
        
        if let currentHumidity = humidity {
            let variation = Double.random(in: -2...2)
            humidity = max(30.0, min(80.0, currentHumidity + variation))
        }
        
        if let currentPower = powerConsumption {
            let variation = Double.random(in: -0.05...0.05)
            powerConsumption = max(0.0, currentPower + variation)
        }
        
        if Bool.random() && device.name.lowercased().contains("luz") {
            ledState = ledState == .on ? .off : .on
        }
        
        for feature in availableFeatures {
            features[feature]?.value = getMockValueForFeature(feature)
            features[feature]?.lastUpdated = Date()
        }
    }

    func toggleLed() {
        let useCase = self.toggleLedUseCase
        let deviceID = device.deviceID
        let targetState: LedState = (ledState == .on) ? .off : .on

        Task {
            isLoading = true
            defer { isLoading = false }

            do {
                try await useCase.execute(deviceID: deviceID, to: targetState)
                ledState = targetState
                
                if availableFeatures.contains(.light) {
                    features[.light]?.value = targetState == .on
                    features[.light]?.lastUpdated = Date()
                }
                
            } catch {
                errorMessage = "No se pudo cambiar el LED"
                ledState = targetState == .on ? .off : .on
            }
        }
    }
    
    func setBrightness(_ level: Int) {
        brightness = max(0, min(100, level))
        
        if availableFeatures.contains(.brightness) {
            features[.brightness]?.value = brightness
            features[.brightness]?.lastUpdated = Date()
        }
    }
    
    func setFanSpeed(_ speed: Int) {
        fanSpeed = max(0, min(3, speed))
        coolerState = speed > 0 ? .on : .off
        
        if availableFeatures.contains(.speed) {
            features[.speed]?.value = fanSpeed
            features[.speed]?.lastUpdated = Date()
        }
        
        if availableFeatures.contains(.cooler) {
            features[.cooler]?.value = coolerState == .on
            features[.cooler]?.lastUpdated = Date()
        }
    }
    
    func toggleHeater() {
        heaterState = heaterState == .on ? .off : .on
        
        if availableFeatures.contains(.heater) {
            features[.heater]?.value = heaterState == .on
            features[.heater]?.lastUpdated = Date()
        }
    }
    
    func toggleCooler() {
        coolerState = coolerState == .on ? .off : .on
        fanSpeed = coolerState == .on ? 2 : 0
        
        if availableFeatures.contains(.cooler) {
            features[.cooler]?.value = coolerState == .on
            features[.cooler]?.lastUpdated = Date()
        }
        
        if availableFeatures.contains(.speed) {
            features[.speed]?.value = fanSpeed
            features[.speed]?.lastUpdated = Date()
        }
    }
}

// MARK: - Mock Use Cases (fuera de @MainActor)
class MockToggleLedUseCase {
    func execute(deviceID: MatterDeviceID, to state: LedState) async throws {
        try await Task.sleep(nanoseconds: 500_000_000)
        print("Mock: LED cambiado a \(state)")
    }
}

class MockReadTemperatureUseCase {
    func execute(deviceID: String) async throws -> Double {
        try await Task.sleep(nanoseconds: 300_000_000)
        return Double.random(in: 18...25)
    }
}

// MARK: - Mock Repository (@unchecked Sendable)
final class MockMatterDeviceRepository: MatterDeviceRepository, @unchecked Sendable {
    func commissionDevice(fromQRCode qrString: String) async throws -> MatterDevice {
        throw NSError(domain: "Mock", code: -1, userInfo: nil)
    }
    
    func getKnownDevices() async throws -> [MatterDevice] {
        return []
    }
    
    func toggleLed(for device: MatterDeviceID, to state: LedState) async throws {
        try await Task.sleep(nanoseconds: 500_000_000)
    }
    
    func readTemperature(for device: MatterDeviceID) async throws -> TemperatureReading {
        try await Task.sleep(nanoseconds: 300_000_000)
        return TemperatureReading(value: 22.5, unit: "°C", timestamp: Date())
    }
    
    func readHeaterState(for device: MatterDeviceID) async throws -> HeaterState {
        return .off
    }
    
    func readCoolerState(for device: MatterDeviceID) async throws -> CoolerState {
        return .off
    }
    
    func readAttribute(for deviceID: String, endpointID: UInt16, clusterID: UInt32, attributeID: UInt32) async throws -> any Sendable {
        return NSNumber(value: 2250)
    }
}

// MARK: - Factory para Preview
enum DeviceDetailViewModelFactory {
    @MainActor
    static func createPreview() -> DeviceDetailViewModel {
        let mockDevice = MatterDevice(
            deviceID: MatterDeviceID(rawValue: 0x1234),
            name: "Living Room Thermostat",
            isOnline: true
        )
        
        // Crear mock use cases
        let mockRepository = MockMatterDeviceRepository()
        let toggleUseCase = ToggleLedUseCase(repository: mockRepository)
        let tempUseCase = ReadTemperatureUseCase(repository: mockRepository)
        
        return DeviceDetailViewModel(
            device: mockDevice,
            toggleLedUseCase: toggleUseCase,
            readTemperatureUseCase: tempUseCase
        )
    }
    
   
}
