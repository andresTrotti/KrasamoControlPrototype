struct DeviceDetailView: View {
    @StateObject var viewModel: DeviceDetailViewModel

    var body: some View {
        VStack(spacing: 16) {
            Text(viewModel.device.name)
                .font(.title)

            if let temp = viewModel.temperature {
                Text("Temperatura: \(temp.value, specifier: "%.1f") \(temp.unit)")
            } else {
                Text("Leyendo temperatura…")
            }

            Text("Heater: \(label(for: viewModel.heaterState))")
            Text("Cooler: \(label(for: viewModel.coolerState))")

            Button {
                viewModel.toggleLed()
            } label: {
                Text(viewModel.ledState == .on ? "Apagar LED" : "Encender LED")
            }
            .buttonStyle(.borderedProminent)

            if viewModel.isLoading {
                ProgressView()
            }

            if let error = viewModel.errorMessage {
                Text(error)
                    .foregroundColor(.red)
            }

            Spacer()
        }
        .padding()
        .onAppear {
            viewModel.onAppear()
        }
    }

    private func label(for state: HeaterState) -> String {
        switch state {
        case .off: return "Apagado"
        case .heating: return "Calentando"
        }
    }

    private func label(for state: CoolerState) -> String {
        switch state {
        case .off: return "Apagado"
        case .cooling: return "Enfriando"
        }
    }
}
