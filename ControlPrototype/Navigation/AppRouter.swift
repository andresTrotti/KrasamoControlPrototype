//
//  AppRouter.swift
//  ControlPrototype
//
//  Created by Andres Trotti on 1/23/26.
//


import SwiftUI

struct AppRouter: View {
    @ObservedObject var container: AppContainer

    @State private var selectedDevice: MatterDevice?
    @State private var showingQRScanner = false

    var body: some View {
        DeviceListView(
            viewModel: container.makeDeviceListViewModel(),
            onSelectDevice: { device in
                selectedDevice = device
            },
            onAddDevice: {
                showingQRScanner = true
            }
        )
        .sheet(item: $selectedDevice) { device in
            DeviceDetailView(
                viewModel: container.makeDeviceDetailViewModel(device: device)
            )
        }
        .sheet(isPresented: $showingQRScanner) {
            QRScannerView(
                viewModel: container.makeQRScannerViewModel()
            )
        }
    }
}
