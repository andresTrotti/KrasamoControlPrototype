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
            DeviceListView(
                viewModel: container.makeDeviceListViewModel(),
                onSelectDevice: { device in
                    // Handle device selection - could use navigation or sheet
                    print("Selected: \(device.name)")
                },
                onAddDevice: {
                    // Handle add device
                    print("Add device")
                }
            )
            .tabItem {
                Image(systemName: "square.grid.2x2.fill")
                Text("Devices")
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


