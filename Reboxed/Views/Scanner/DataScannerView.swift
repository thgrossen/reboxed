#if os(iOS)
import SwiftUI
import VisionKit

struct DataScannerView: UIViewControllerRepresentable {
    var onScan: (String) -> Void
    @State private var lastScanned = ""

    func makeUIViewController(context: Context) -> DataScannerViewController {
        let scanner = DataScannerViewController(
            recognizedDataTypes: [.barcode(symbologies: [.qr])],
            qualityLevel: .balanced,
            recognizesMultipleItems: false,
            isHighFrameRateTrackingEnabled: false,
            isPinchToZoomEnabled: true,
            isGuidanceEnabled: true,
            isHighlightingEnabled: true
        )
        scanner.delegate = context.coordinator
        try? scanner.startScanning()
        return scanner
    }

    func updateUIViewController(_ uiViewController: DataScannerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onScan: onScan)
    }

    class Coordinator: NSObject, DataScannerViewControllerDelegate {
        let onScan: (String) -> Void
        private var lastUID = ""
        private var lastScanTime = Date.distantPast

        init(onScan: @escaping (String) -> Void) {
            self.onScan = onScan
        }

        func dataScanner(_ dataScanner: DataScannerViewController,
                         didAdd addedItems: [RecognizedItem],
                         allItems: [RecognizedItem]) {
            guard let first = addedItems.first,
                  case let .barcode(barcode) = first,
                  let payload = barcode.payloadStringValue else { return }
            // Debounce: ignore same code within 2s
            let now = Date()
            guard payload != lastUID || now.timeIntervalSince(lastScanTime) > 2 else { return }
            lastUID = payload
            lastScanTime = now
            DispatchQueue.main.async { self.onScan(payload) }
        }
    }
}
#endif
