//
//  HomeDashboardView.swift
//  ControlPrototype
//
//  Created by Andres Trotti on 2/4/26.
//

import SwiftUI

struct HomeDashboardView: View {
    
    @StateObject var deviceListViewModel: DeviceListViewModel
    
    @State private var showingDeviceList = false
    
    var body: some View {
        NavigationStack {
            DashboardView()
                .navigationTitle("Smart Home")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            showingDeviceList = true
                        } label: {
                            Image(systemName: "square.grid.2x2")
                        }
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            // Acción para añadir dispositivo
                            print("Añadir dispositivo desde dashboard")
                        } label: {
                            Image(systemName: "plus")
                        }
                    }
                }
                .sheet(isPresented: $showingDeviceList) {
                    // Modal con lista de dispositivos
                    NavigationStack {
                        DeviceListView(
                            viewModel: deviceListViewModel,
                            onSelectDevice: { device in
                                showingDeviceList = false
                                // Navegar al detalle del dispositivo
                                print("Abrir detalles de \(device.name)")
                            },
                            onAddDevice: {
                                showingDeviceList = false
                                // Lógica para escanear QR
                                print("Escanear QR para añadir dispositivo")
                            }
                        )
                    }
                }
        }
    }
}

// Vista mejorada del Living Room con acceso a dispositivos
struct EnhancedLivingRoomView: View {
    @State private var showingDeviceList = false
    let onViewDevices: () -> Void
    
    var body: some View {
        VStack {
            // Contenido original del LivingRoomView...
            ScrollView {
                // ... tu contenido existente ...
                
                // Sección de dispositivos relacionados
                VStack(alignment: .leading, spacing: 15) {
                    HStack {
                        Text("Connected Devices")
                            .font(.headline)
                        
                        Spacer()
                        
                        Button("View All") {
                            onViewDevices()
                        }
                        .font(.subheadline)
                        .foregroundColor(.blue)
                    }
                    .padding(.horizontal, 20)
                    
                    // Mini grid de dispositivos
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 10) {
                        DeviceMiniCard(name: "Smart Thermostat", isOnline: true, icon: "thermometer")
                        DeviceMiniCard(name: "Living Room Light", isOnline: true, icon: "lightbulb")
                        DeviceMiniCard(name: "Air Purifier", isOnline: false, icon: "wind")
                        DeviceMiniCard(name: "Smart Plug", isOnline: true, icon: "powerplug")
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.top, 20)
            }
        }
    }
}

struct DeviceMiniCard: View {
    let name: String
    let isOnline: Bool
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(isOnline ? .blue : .gray)
            
            Text(name)
                .font(.caption)
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
            
            Circle()
                .fill(isOnline ? .green : .gray)
                .frame(width: 8, height: 8)
        }
        .frame(height: 80)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        )
    }
}
