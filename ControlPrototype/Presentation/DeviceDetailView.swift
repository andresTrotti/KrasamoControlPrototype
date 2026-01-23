//
//  DeviceDetailView.swift
//  ControlPrototype
//
//  Created by Andres Trotti on 1/23/26.
//


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
                featuresGrid // Extraído para facilitar el type-check
            }
            .padding(.vertical)
        }
        .navigationTitle(viewModel.device.name)
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(uiColor: .systemGroupedBackground))
        .onAppear { viewModel.onAppear() }
        .overlay { loadingOverlay }
    }

    // --- Sub-vistas extraídas ---

    private var featuresGrid: some View {
        LazyVGrid(columns: columns, spacing: 16) {
            ledCard
            temperatureCard
            heaterCard
            coolerCard
            // Aquí podrás añadir las otras 11+ cards sin saturar el compilador
        }
        .padding(.horizontal)
    }

    private var ledCard: some View {
        FeatureCard(
            title: "LED",
            value: viewModel.ledState == .on ? "Encendido" : "Apagado",
            icon: "lightbulb.fill",
            color: .yellow,
            isActive: viewModel.ledState == .on,
            action: { viewModel.toggleLed() }
        )
    }

    private var temperatureCard: some View {
        FeatureCard(
            title: "Temperatura",
            value: viewModel.temperature?.value.description ?? "N/A°C",
            icon: "thermometer.medium",
            color: .orange,
            action: { Task { await viewModel.refreshAll() } }
        )
    }

    private var heaterCard: some View {
        FeatureCard(
            title: "Heater",
            value: viewModel.heaterState == .on ? "Calentando" : "Inactivo",
            icon: "flame.fill",
            color: viewModel.heaterState == .on ? .red : .gray
        )
    }

    private var coolerCard: some View {
        FeatureCard(
            title: "Cooler",
            value: viewModel.coolerState == .on ? "Enfriando" : "Inactivo",
            icon: "snowflake",
            color: viewModel.coolerState == .on ? .blue : .gray
        )
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
