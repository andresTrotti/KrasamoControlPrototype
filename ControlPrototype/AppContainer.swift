final class AppContainer {
    let matterRepository: MatterDeviceRepository

    init() {
        let controller = MTRDeviceController(/* config */)
        self.matterRepository = MatterDeviceRepositoryImpl(controller: controller)
    }

    func makeDeviceDetailViewModel(device: MatterDevice) -> DeviceDetailViewModel {
        let toggleLed = ToggleLedUseCase(repository: matterRepository)
        let readTemp = ReadTemperatureUseCase(repository: matterRepository)
        return DeviceDetailViewModel(
            device: device,
            toggleLedUseCase: toggleLed,
            readTemperatureUseCase: readTemp
        )
    }
}
