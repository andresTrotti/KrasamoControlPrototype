//
//  DeviceListView.swift
//  ControlPrototype
//
//  Created by Andres Trotti on 1/23/26.
//


import SwiftUI

struct DeviceListView: View {
    @StateObject var viewModel: DeviceListViewModel
    let onSelectDevice: (MatterDevice) -> Void
    let onAddDevice: () -> Void
    
    @State private var searchText = ""
    
    var filteredDevices: [MatterDevice] {
        if searchText.isEmpty {
            return viewModel.devices
        } else {
            return viewModel.devices.filter { device in
                device.name.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                if viewModel.devices.isEmpty && !viewModel.isLoading {
                    emptyStateView
                } else {
                    deviceListView
                }
            }
            .navigationTitle("Dispositivos")
            .searchable(text: $searchText, prompt: "Buscar dispositivos")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        onAddDevice()
                    } label: {
                        Image(systemName: "qrcode.viewfinder")
                            .font(.title3)
                    }
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        viewModel.load()
                    } label: {
                        Image(systemName: "arrow.clockwise")
                            .font(.title3)
                    }
                    .disabled(viewModel.isLoading)
                }
            }
            .onAppear {
                // Solo cargar si no hay datos ya
                if viewModel.devices.isEmpty {
                    viewModel.load()
                }
            }
            .overlay {
                if viewModel.isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(10)
                }
            }
        }
    }
    
    private var deviceListView: some View {
        List {
            Section {
                ForEach(filteredDevices) { device in
                    DeviceRow(
                        device: device,
                        onSelect: { onSelectDevice(device) }
                    )
                }
            } header: {
                Text("\(filteredDevices.count) dispositivos")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .refreshable {
            await refreshDevices()
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "square.grid.2x2")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("No hay dispositivos")
                .font(.title2)
                .fontWeight(.medium)
            
            Text("Añade tu primer dispositivo escaneando un código QR")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Button {
                onAddDevice()
            } label: {
                Label("Escanear QR", systemImage: "qrcode.viewfinder")
                    .font(.headline)
                    .padding(.horizontal, 30)
                    .padding(.vertical, 12)
            }
            .buttonStyle(.borderedProminent)
            .padding(.top, 10)
        }
        .padding()
    }
    
    private func refreshDevices() async {
        await withCheckedContinuation { continuation in
            viewModel.load()
            // Simular un pequeño delay para el refresh
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                continuation.resume()
            }
        }
    }
}

struct DeviceRow: View {
    let device: MatterDevice
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 15) {
                // Icono según tipo de dispositivo
                Image(systemName: deviceIcon(for: device.name))
                    .font(.title3)
                    .foregroundColor(device.isOnline ? .blue : .gray)
                    .frame(width: 30)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(device.name)
                        .font(.body)
                        .foregroundColor(.primary)
                    
                    Text(device.isOnline ? "Conectado" : "Desconectado")
                        .font(.caption)
                        .foregroundColor(device.isOnline ? .green : .red)
                }
                
                Spacer()
                
                // Indicador de estado
                Circle()
                    .fill(device.isOnline ? .green : .gray)
                    .frame(width: 10, height: 10)
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding(.vertical, 8)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func deviceIcon(for deviceName: String) -> String {
        let name = deviceName.lowercased()
        
        if name.contains("termo") || name.contains("clima") {
            return "thermometer"
        } else if name.contains("luz") || name.contains("light") || name.contains("led") {
            return "lightbulb"
        } else if name.contains("ventilador") || name.contains("fan") {
            return "wind"
        } else if name.contains("sensor") {
            return "sensor"
        } else if name.contains("cámara") || name.contains("camara") {
            return "video"
        } else if name.contains("enchufe") || name.contains("plug") {
            return "powerplug"
        } else {
            return "bolt.shield"
        }
    }
}

// Preview con datos mock
struct DeviceListView_Previews: PreviewProvider {
    static var previews: some View {
        DeviceListView(
            viewModel: DeviceListViewModel(
                getKnownDevicesUseCase: MockGetKnownDevicesUseCase()
            ),
            onSelectDevice: { _ in },
            onAddDevice: {}
        )
    }
}

// Mock para previews
struct MockGetKnownDevicesUseCase: GetKnownDevicesUseCase {
    func execute() async throws -> [MatterDevice] {
        // Simular delay de red
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        return [
            MatterDevice(
                deviceID: MatterDeviceID(rawValue: 0xF001),
                name: "Termostato Sala",
                isOnline: true
            ),
            MatterDevice(
                deviceID: MatterDeviceID(rawValue: 0xF002),
                name: "Luz Cocina",
                isOnline: true
            ),
            MatterDevice(
                deviceID: MatterDeviceID(rawValue: 0xF003),
                name: "Ventilador Dormitorio",
                isOnline: false
            )
        ]
    }
}





