//
//  ControlPrototypeApp.swift
//  ControlPrototype
//
//  Created by Andres Trotti on 1/23/26.
//


import SwiftUI

@main
struct ControlPrototypeApp: App {
    @StateObject private var container = AppContainer.shared
    
    var body: some Scene {
        WindowGroup {
            AppRouter(container: container)
                .environmentObject(container)
        }
    }
}
