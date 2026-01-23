@MainActor
final class DeviceDetailViewModel: ObservableObject {
    @Published var device: MatterDevice
    @Published var ledState: LedState = .off
    @Published var temperature: TemperatureReading?
    @Published var heaterState: HeaterState = .off
    @Published var coolerState: CoolerState = .off
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let toggleLedUseCase: ToggleLedUseCase
    private let readTemperatureUseCase: ReadTemperatureUseCase
    private let readHeaterStateUseCase: ReadHeaterStateUseCase
    private let readCoolerStateUseCase: ReadCoolerStateUseCase

    init(
        device: MatterDevice,
        toggleLedUseCase: ToggleLedUseCase,
        readTemperatureUseCase: ReadTemperatureUseCase,
        readHeaterStateUseCase: ReadHeaterStateUseCase,
        readCoolerStateUseCase: ReadCoolerStateUseCase
    ) {
        self.device = device
        self.toggleLedUseCase = toggleLedUseCase
        self.readTemperatureUseCase = readTemperatureUseCase
        self.readHeaterStateUseCase = readHeaterStateUseCase
        self.readCoolerStateUseCase = readCoolerStateUseCase
    }

    func onAppear() {
        Task { await refreshAll() }
    }

    func refreshAll() async {
        isLoading = true
        defer { isLoading = false }

        do {
            temperature = try await readTemperatureUseCase.execute(deviceID: device.deviceID)
            heaterState = try await readHeaterStateUseCase.execute(deviceID: device.deviceID)
            coolerState = try await readCoolerStateUseCase.execute(deviceID: device.deviceID)
        } catch {
            errorMessage = "Error al actualizar estados"
        }
    }

    func toggleLed() {
        Task {
            isLoading = true
            defer { isLoading = false }

            let newState: LedState = (ledState == .on) ? .off : .on
            do {
                try await toggleLedUseCase.execute(deviceID: device.deviceID, to: newState)
                ledState = newState
            } catch {
                errorMessage = "No se pudo cambiar el LED"
            }
        }
    }
}
