//
//  MainTabView.swift
//  ControlPrototype
//
//  Created by Andres Trotti on 2/4/26.
//


// Presentation/MainApp/MainTabView.swift
import SwiftUI
struct MainTabView: View {
    @EnvironmentObject var container: AppContainer
    @State private var showingQRScanner = false
    @State private var selectedDevice: MatterDevice?
    
    var body: some View {
        TabView {
            // Tab 1: Dashboard
            NavigationStack {
                DashboardView()
                    .navigationTitle("Home")
                    .navigationBarTitleDisplayMode(.inline)
            }
            .tabItem {
                Image(systemName: "house.fill")
                Text("Home")
            }
            
            // Tab 2: Devices
            NavigationStack {
                DeviceListView(
                    viewModel: container.makeDeviceListViewModel(),
                    onSelectDevice: { device in
                        selectedDevice = device
                    },
                    onAddDevice: {
                        showingQRScanner = true
                    }
                )
            }
            .tabItem {
                Image(systemName: "square.grid.2x2.fill")
                Text("Devices")
            }
            .sheet(isPresented: $showingQRScanner) {
                // Vista del escáner QR
                QRScannerView(
                    viewModel: container.makeQRScannerViewModel()
                )
            }
            .sheet(item: $selectedDevice) { device in
                // Vista de detalles del dispositivo
                DeviceDetailView(
                    viewModel: container.makeDeviceDetailViewModel(device: device)
                )
            }
            
            // Tab 3: Settings
            NavigationStack {
                SettingsView()
                    .navigationTitle("Settings")
            }
            .tabItem {
                Image(systemName: "gear")
                Text("Settings")
            }
        }
        .accentColor(.blue)
    }
}

struct SettingsView: View {
    var body: some View {
        List {
            Section("Account") {
                Label("Profile", systemImage: "person.circle")
                Label("Notifications", systemImage: "bell")
            }
            
            Section("Home") {
                Label("Rooms", systemImage: "door.left.hand.open")
                Label("Scenes", systemImage: "lightbulb")
            }
            
            Section("System") {
                Label("About", systemImage: "info.circle")
            }
        }
    }
}

// Preview para MainTabView
struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
            .environmentObject(AppContainer.shared)
    }
}



