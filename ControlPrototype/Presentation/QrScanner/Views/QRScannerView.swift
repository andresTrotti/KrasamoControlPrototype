//
//  QRScannerView.swift
//  ControlPrototype
//
//  Created by Andres Trotti on 1/23/26.
//


import SwiftUI
import VisionKit

struct QRScannerView: View {
    @StateObject var viewModel: QRScannerViewModel

    var body: some View {
        ZStack {
            QRScannerRepresentable(
                onQRCodeScanned: { qr in
                    viewModel.handleScannedCode(qr)
                }
            )

            if viewModel.isProcessing {
                Color.black.opacity(0.4)
                ProgressView("Comisionando dispositivo…")
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(12)
            }

            if let error = viewModel.errorMessage {
                VStack {
                    Spacer()
                    Text(error)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.red.opacity(0.8))
                        .cornerRadius(8)
                        .padding()
                }
            }
        }
        .ignoresSafeArea()
    }
}
