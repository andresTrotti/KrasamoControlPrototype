//
//  FeatureCard.swift
//  ControlPrototype
//
//  Created by Andres Trotti on 1/23/26.
//


import SwiftUI

struct FeatureCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    var isActive: Bool = false
    var action: (() -> Void)? = nil

    var body: some View {
        Button(action: {
            // Ejecuta la acción (ej. toggleLed) si existe
            action?()
        }) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    // Icono representativo del cluster de Matter
                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundColor(isActive ? .white : color)
                    Spacer()
                    if action != nil {
                        Image(systemName: "chevron.right.circle")
                            .font(.caption)
                            .foregroundColor(isActive ? .white.opacity(0.6) : .secondary)
                    }
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(isActive ? .white.opacity(0.8) : .secondary)
                    
                    Text(value)
                        .font(.headline)
                        .foregroundColor(isActive ? .white : .primary)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            // Cambia el fondo según el estado activo (ej. LED encendido)
            .background(isActive ? color : Color(uiColor: .secondarySystemGroupedBackground))
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(PlainButtonStyle()) // Evita el efecto de resaltado gris por defecto
    }
}