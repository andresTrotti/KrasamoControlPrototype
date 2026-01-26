//
//  DeviceListViewModel.swift
//  ControlPrototype
//
//  Created by Andres Trotti on 1/23/26.
//


import Foundation


@MainActor
final class DeviceListViewModel: ObservableObject {
    @Published var devices: [MatterDevice] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let getKnownDevicesUseCase: GetKnownDevicesUseCase

    init(getKnownDevicesUseCase: GetKnownDevicesUseCase) {
        self.getKnownDevicesUseCase = getKnownDevicesUseCase
    }

    func load() {
        let useCase = self.getKnownDevicesUseCase // Captura local fuera de la Task
        
        Task {
            isLoading = true
            defer { isLoading = false }
            do {
                devices = try await useCase.execute() // Usamos la local
            } catch {
                errorMessage = "Error"
            }
        }
    }
}


