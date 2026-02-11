import SwiftUI

struct DashboardView: View {
    @State private var temperature: Double = 22.0
    @State private var humidity: Double = 65.0
    @State private var isTemperatureExpanded = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 25) {
                              // Header
                              VStack(alignment: .leading, spacing: 8) {
                                  HStack {
                                      Text("# Living room")
                                          .font(.system(size: 28, weight: .bold))
                                          .foregroundColor(.primary)
                                      
                                      Spacer()
                                      
                                     
                                      Text("More")
                                          .font(.system(size: 14, weight: .medium))
                                          .foregroundColor(.white)
                                          .padding(.horizontal, 12)
                                          .padding(.vertical, 6)
                                          .background(
                                              Capsule()
                                                  .fill(Color.blue)
                                          )
                                  }
                                  
                                  Text("Keep in mind that you can help the planet.")
                                      .font(.system(size: 16))
                                      .foregroundColor(.secondary)
                                      .multilineTextAlignment(.leading)
                              }
                              .padding(.horizontal, 20)
                              .padding(.top, 10)
                    
                    // Temperature Control Card
                    VStack(spacing: 20) {
                        // Current temperature display
                        HStack(alignment: .top) {
                            Text("\(Int(temperature))°")
                                .font(.system(size: 72, weight: .bold))
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            // Target temperature button
                            Button(action: {
                                withAnimation(.spring()) {
                                    isTemperatureExpanded.toggle()
                                }
                            }) {
                                VStack(alignment: .trailing, spacing: 4) {
                                    Text("19°")
                                        .font(.system(size: 24, weight: .semibold))
                                        .foregroundColor(.blue)
                                    
                                    Text("Target")
                                        .font(.system(size: 12))
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        .padding(.horizontal, 25)
                        .padding(.top, 20)
                        
                        // Temperature slider
                        VStack(spacing: 15) {
                            // Slider with labels
                            HStack {
                                Text("15°")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Slider(value: $temperature, in: 15...30, step: 0.5)
                                    .accentColor(.blue)
                                
                                Text("30°")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Text("Temperature")
                                .font(.headline)
                                .foregroundColor(.primary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.leading, 5)
                        }
                        .padding(.horizontal, 25)
                        .padding(.bottom, 25)
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .fill(Color(.systemGray6))
                    )
                    .padding(.horizontal, 20)
                    
                    // Stats Grid
                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: 15),
                        GridItem(.flexible(), spacing: 15)
                    ], spacing: 15) {
                        // Humidity Card
                        StatCard(
                            value: "\(Int(humidity))%",
                            title: "Humidity",
                            icon: "humidity.fill",
                            color: .cyan,
                            isActive: true
                        )
                        
                        // Air Quality Card
                        StatCard(
                            value: "Test",
                            title: "Demo",
                            icon: "wind",
                            color: .green,
                            isActive: true
                        )
                        
                        // Energy Usage Card
                        StatCard(
                            value: "42 kWh",
                            title: "Lights",
                            icon: "bolt.fill",
                            color: .orange,
                            isActive: false
                        )
                        
                        // CO2 Emissions Card
                        StatCard(
                            value: "1.2",
                            title: "Demo",
                            icon: "leaf.fill",
                            color: .green,
                            isActive: true
                        )
                    }
                    .padding(.horizontal, 20)
                    
                    // Expanded temperature view (when expanded)
                    if isTemperatureExpanded {
                        VStack(spacing: 15) {
                            Text("Schedule Temperature")
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            HStack(spacing: 10) {
                                ForEach(["Morning", "Day", "Evening", "Night"], id: \.self) { time in
                                    VStack(spacing: 8) {
                                        Text(time.prefix(3))
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        
                                        Text("21°")
                                            .font(.system(size: 20, weight: .semibold))
                                            .foregroundColor(.primary)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color(.systemGray6))
                                    )
                                }
                            }
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color(.systemGray6))
                        )
                        .padding(.horizontal, 20)
                        .transition(.move(edge: .top).combined(with: .opacity))
                    }
                    
                    // Quick Actions
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Quick Actions")
                            .font(.headline)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                QuickActionButton(
                                    title: "Eco Mode",
                                    icon: "leaf.fill",
                                    isActive: true
                                )
                                
                                QuickActionButton(
                                    title: "Away",
                                    icon: "person.fill.xmark"
                                )
                                
                                QuickActionButton(
                                    title: "Schedule",
                                    icon: "calendar"
                                )
                                
                                QuickActionButton(
                                    title: "Auto",
                                    icon: "sparkles"
                                )
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    
                    Spacer(minLength: 30)
                }
                .padding(.vertical, 10)
            }
            .navigationBarHidden(true)
            .background(Color(.systemBackground))
        }
    }
}

struct StatCard: View {
    let value: String
    let title: String
    let icon: String
    let color: Color
    let isActive: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(color)
                
                Spacer()
                
                if isActive {
                    Circle()
                        .fill(color)
                        .frame(width: 8, height: 8)
                }
            }
            
            Text(value)
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.primary)
            
            Text(title)
                .font(.system(size: 14))
                .foregroundColor(.secondary)
        }
        .padding(20)
        .frame(maxWidth: .infinity, minHeight: 140, alignment: .topLeading)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemGray6))
        )
    }
}

struct QuickActionButton: View {
    let title: String
    let icon: String
    var isActive: Bool = false
    
    var body: some View {
        Button(action: {}) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 22))
                    .foregroundColor(isActive ? .blue : .primary)
                
                Text(title)
                    .font(.system(size: 12))
                    .foregroundColor(isActive ? .blue : .primary)
            }
            .frame(width: 80, height: 80)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(isActive ? Color.blue.opacity(0.1) : Color(.systemGray6))
            )
        }
    }
}

// Preview
struct LivingRoomView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            DashboardView()
                .preferredColorScheme(.light)
                .previewDisplayName("Light Mode")
            
            DashboardView()
                .preferredColorScheme(.dark)
                .previewDisplayName("Dark Mode")
        }
    }
}

// Versión alternativa más fiel al diseño original
struct CompactLivingRoomView: View {
    @State private var temperature: Double = 22.0
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header
            HStack {
                Text("# Living room")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Spacer()
                
                Text("kit")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.blue)
                    .cornerRadius(12)
            }
            
            Text("Lower the temperature\nto decrease your emissions.")
                .foregroundColor(.gray)
                .multilineTextAlignment(.leading)
            
            // Temperature Section
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 5) {
                    Text("\(Int(temperature))°")
                        .font(.system(size: 80, weight: .bold))
                    
                    HStack(spacing: 30) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("19°")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.blue)
                            
                            Text("Temperature")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("65%")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                            
                            Text("Humidity")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.top, 10)
                }
                
                Spacer()
                
                // Air Quality Indicator
                VStack {
                    Text("A")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(.green)
                    
                    Text("Air Quality")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(
                    Circle()
                        .fill(Color.green.opacity(0.1))
                )
            }
            
            // Temperature Slider
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("15°")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Slider(value: $temperature, in: 15...30)
                        .accentColor(.blue)
                    
                    Text("30°")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.top, 10)
            
            Spacer()
        }
        .padding(20)
        .background(Color(.systemBackground))
    }
}
