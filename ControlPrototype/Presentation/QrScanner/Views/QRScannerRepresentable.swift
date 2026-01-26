//
//  QRScannerRepresentable.swift
//  ControlPrototype
//
//  Created by Andres Trotti on 1/23/26.
//


import SwiftUI
import VisionKit


struct QRScannerRepresentable: UIViewControllerRepresentable {
    // 1. Recibimos el estado de procesamiento para saber si debemos escanear o no
    @Binding var isProcessing: Bool
    let onQRCodeScanned: (String) -> Void

    func makeUIViewController(context: Context) -> DataScannerViewController {
        let controller = DataScannerViewController(
            recognizedDataTypes: [.barcode(symbologies: [.qr])],
            qualityLevel: .balanced,
            recognizesMultipleItems: false,
            isHighFrameRateTrackingEnabled: false,
            isPinchToZoomEnabled: true,
            isGuidanceEnabled: true
        )
        controller.delegate = context.coordinator
        return controller
    }

    // 2. Aquí está la corrección mágica
    func updateUIViewController(_ uiViewController: DataScannerViewController, context: Context) {
        // Si estamos procesando, DETENEMOS el scanner
        if isProcessing {
            if uiViewController.isScanning {
                uiViewController.stopScanning()
            }
        }
        // Si NO estamos procesando y el scanner está apagado, lo ENCENDEMOS
        else {
            if !uiViewController.isScanning {
                try? uiViewController.startScanning()
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    final class Coordinator: NSObject, DataScannerViewControllerDelegate {
        let parent: QRScannerRepresentable

        init(parent: QRScannerRepresentable) {
            self.parent = parent
        }

        func dataScanner(_ dataScanner: DataScannerViewController,
                         didAdd addedItems: [RecognizedItem],
                         allItems: [RecognizedItem]) {
            guard let item = addedItems.first else { return }

            if case let .barcode(barcode) = item,
               let payload = barcode.payloadStringValue {
                
                // 3. Importante: Detenemos inmediatamente para evitar lecturas dobles
                // y evitar el crash de AVCaptureSession
                dataScanner.stopScanning()
                
                // Llamamos al callback
                parent.onQRCodeScanned(payload)
            }
        }
    }
}
