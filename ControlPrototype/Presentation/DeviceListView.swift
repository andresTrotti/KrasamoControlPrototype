import SwiftUI

struct DeviceListView: View {
    @StateObject var viewModel: DeviceListViewModel
    let onSelectDevice: (MatterDevice) -> Void
    let onAddDevice: () -> Void

    var body: some View {
        NavigationStack {
            List(viewModel.devices) { device in
                Button {
                    onSelectDevice(device)
                } label: {
                    HStack {
                        Text(device.name)
                        Spacer()
                        Circle()
                            .fill(device.isOnline ? .green : .gray)
                            .frame(width: 10, height: 10)
                    }
                }
            }
            .navigationTitle("Dispositivos")
            .toolbar {
                Button {
                    onAddDevice()
                } label: {
                    Image(systemName: "qrcode.viewfinder")
                }
            }
            .onAppear {
                viewModel.load()
            }
        }
    }
}
