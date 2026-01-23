// Caso de Uso para la Temperatura
protocol GetTemperatureUseCase {
    func execute(for deviceID: MatterDeviceID) async throws -> TemperatureReading
}

final class GetTemperatureUseCaseImpl: GetTemperatureUseCase {
    private let repository: MatterDeviceRepository
    init(repository: MatterDeviceRepository) { self.repository = repository }

    func execute(for deviceID: MatterDeviceID) async throws -> TemperatureReading {
        return try await repository.readTemperature(for: deviceID)
    }
}