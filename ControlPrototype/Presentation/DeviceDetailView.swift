//
//  DeviceDetailView.swift
//  ControlPrototype
//
//  Created by Andres Trotti on 2/4/26.
//


// DeviceDetailView.swift
import SwiftUI

struct DeviceDetailView: View {
    @StateObject var viewModel: DeviceDetailViewModel
    
    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                headerView
                
                // Grid de características
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(viewModel.availableFeatures) { feature in
                        if let state = viewModel.features[feature] {
                            FeatureCardView(
                                feature: feature,
                                state: state,
                                onToggle: { handleFeatureAction(feature) }
                            )
                        }
                    }
                }
                .padding(.horizontal)
                
                // Controles adicionales
                if viewModel.availableFeatures.contains(.brightness) {
                    brightnessControl
                }
                
                if viewModel.availableFeatures.contains(.speed) {
                    fanSpeedControl
                }
                
                // Botones de acción
                actionButtons
            }
            .padding(.vertical)
        }
        .navigationTitle(viewModel.device.name)
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(uiColor: .systemGroupedBackground))
        .onAppear { viewModel.onAppear() }
        .overlay { loadingOverlay }
    }
    
    private var headerView: some View {
        VStack(spacing: 8) {
            Image(systemName: getDeviceIcon())
                .font(.system(size: 60))
                .foregroundColor(viewModel.isConnected ? .blue : .gray)
                .padding()
                .background(
                    Circle()
                        .fill(viewModel.isConnected ? .blue.opacity(0.1) : .gray.opacity(0.1))
                )
            
            Text(viewModel.isConnected ? "Connected" : "Disconnected")
                .font(.subheadline)
                .foregroundColor(viewModel.isConnected ? .green : .red)
            
            if let lastSeen = viewModel.lastSeen, !viewModel.isConnected {
                Text("Last time: \(lastSeen, style: .relative)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    private var brightnessControl: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Brillo")
                .font(.headline)
            
            HStack {
                Image(systemName: "sun.min")
                Slider(value: Binding(
                    get: { Double(viewModel.brightness) },
                    set: { viewModel.setBrightness(Int($0)) }
                ), in: 0...100)
                Image(systemName: "sun.max")
            }
            
            Text("\(viewModel.brightness)%")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .cornerRadius(12)
        .padding(.horizontal)
    }
    
    private var fanSpeedControl: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Velocidad del Ventilador")
                .font(.headline)
            
            Picker("Velocidad", selection: Binding(
                get: { viewModel.fanSpeed },
                set: { viewModel.setFanSpeed($0) }
            )) {
                Text("Apagado").tag(0)
                Text("Bajo").tag(1)
                Text("Medio").tag(2)
                Text("Alto").tag(3)
            }
            .pickerStyle(.segmented)
        }
        .padding()
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .cornerRadius(12)
        .padding(.horizontal)
    }
    
    private var actionButtons: some View {
        HStack(spacing: 16) {
            Button("Refresh") {
                Task {
                    await viewModel.refreshAll()
                }
            }
            .buttonStyle(.bordered)
            
            if viewModel.availableFeatures.contains(.light) {
                Button(viewModel.ledState == .on ? "Turn off" : "Turn on") {
                    viewModel.toggleLed()
                }
                .buttonStyle(.borderedProminent)
            }
            
        }
        .padding()
    }
    
    @ViewBuilder
    private var loadingOverlay: some View {
        if viewModel.isLoading {
            ProgressView()
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(10)
        }
    }
    
    private func getDeviceIcon() -> String {
        let name = viewModel.device.name.lowercased()
        if name.contains("termorsta") || name.contains("clima") {
            return "thermometer"
        } else if name.contains("luz") || name.contains("light") {
            return "lightbulb"
        } else if name.contains("ventilador") || name.contains("fan") {
            return "wind"
        } else if name.contains("sensor") {
            return "sensor"
        } else {
            return "bolt.shield.fill"
        }
    }
    
    private func handleFeatureAction(_ feature: DeviceFeature) {
        switch feature {
        case .light:
            viewModel.toggleLed()
        case .heater:
            viewModel.toggleHeater()
        case .cooler:
            viewModel.toggleCooler()
        default:
            break
        }
    }
}

struct FeatureCardView: View {
    let feature: DeviceFeature
    let state: FeatureState
    let onToggle: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: feature.icon)
                    .foregroundColor(.blue)
                
                Spacer()
                
                if isToggleable(feature) {
                    Button(action: onToggle) {
                        Image(systemName: "power.circle")
                    }
                }
            }
            
            Text(feature.rawValue)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(displayValue)
                .font(.title3)
                .fontWeight(.semibold)
            
            if let date = state.lastUpdated {
                Text(date, style: .time)
                    .font(.caption2)
                    .foregroundColor(.secondary.opacity(0.7))
            }
        }
        .padding()
        .frame(maxWidth: .infinity, minHeight: 120, alignment: .topLeading)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
    
    private var displayValue: String {
        if let boolValue = state.value as? Bool {
            return boolValue ? "On" : "Off"
        } else if let intValue = state.value as? Int {
            return "\(intValue)\(feature.unit)"
        } else if let doubleValue = state.value as? Double {
            return String(format: "%.1f%@", doubleValue, feature.unit)
        } else if let dateValue = state.value as? Date {
            return dateValue.formatted(date: .omitted, time: .shortened)
        }
        return "\(state.value)"
    }
    
    private func isToggleable(_ feature: DeviceFeature) -> Bool {
        return [.light, .heater, .cooler, .fan].contains(feature)
    }
}

// MARK: - Preview
struct DeviceDetailView_Previews: PreviewProvider {
    @MainActor
    static var previews: some View {
        NavigationStack {
            DeviceDetailView(
                viewModel: {
                    let mockDevice = MatterDevice(
                        deviceID: MatterDeviceID(rawValue: 0x1234),
                        name: "Living Room Thermostat",
                        isOnline: true
                    )
                    let mockRepository = MockMatterDeviceRepository()
                    return DeviceDetailViewModel(
                        device: mockDevice,
                        toggleLedUseCase: ToggleLedUseCase(repository: mockRepository),
                        readTemperatureUseCase: ReadTemperatureUseCase(repository: mockRepository)
                    )
                }()
            )
        }
        .previewDisplayName("Thermostat")
    }
}
