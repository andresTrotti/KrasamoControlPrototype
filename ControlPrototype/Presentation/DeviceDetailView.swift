import SwiftUI

struct DeviceDetailView: View {
    @StateObject var viewModel: DeviceDetailViewModel
    
    // Configuración de la cuadrícula para escalabilidad (2 columnas)
    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // --- CABECERA DE ESTADO ---
                headerView
                
                // --- CUADRÍCULA DE FEATURES (Aquí irán las 15+) ---
                LazyVGrid(columns: columns, spacing: 16) {
                    
                    // Feature 1: Control de LED
                    FeatureCard(
                        title: "LED",
                        value: viewModel.ledState == .on ? "Encendido" : "Apagado",
                        icon: "lightbulb.fill",
                        color: viewModel.ledState == .on ? .yellow : .gray,
                        isActive: viewModel.ledState == .on,
                        action: { viewModel.toggleLed() }
                    )
                    
                    // Feature 2: Sensor de Temperatura (x917)
                    FeatureCard(
                        title: "Temperatura",
                        value: viewModel.temperature?.displayValue ?? "--°C",
                        icon: "thermometer.medium",
                        color: .orange,
                        action: { Task { await viewModel.refreshAll() } }
                    )
                    
                    // Feature 3: Heater Status
                    FeatureCard(
                        title: "Heater",
                        value: viewModel.heaterState == .on ? "Calentando" : "Inactivo",
                        icon: "flame.fill",
                        color: viewModel.heaterState == .on ? .red : .gray
                    )
                    
                    // Feature 4: Cooler Status
                    FeatureCard(
                        title: "Cooler",
                        value: viewModel.coolerState == .on ? "Enfriando" : "Inactivo",
                        icon: "snowflake",
                        color: viewModel.coolerState == .on ? .blue : .gray
                    )
                    
                    // ESPACIO PARA LAS PRÓXIMAS 11+ FEATURES...
                    // Simplemente añade más FeatureCards aquí.
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .navigationTitle(viewModel.device.name)
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(uiColor: .systemGroupedBackground))
        .onAppear { viewModel.onAppear() }
        .overlay {
            if viewModel.isLoading {
                ProgressView()
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(10)
            }
        }
    }

    private var headerView: some View {
        VStack(spacing: 8) {
            Image(systemName: "bolt.shield.fill")
                .font(.system(size: 60))
                .foregroundColor(.blue)
                .padding()
                .background(Circle().fill(.blue.opacity(0.1)))
            
            Text(viewModel.device.isOnline ? "Conectado vía Matter" : "Sin conexión")
                .font(.subheadline)
                .foregroundColor(viewModel.device.isOnline ? .green : .red)
        }
        .frame(maxWidth: .infinity)
    }
}