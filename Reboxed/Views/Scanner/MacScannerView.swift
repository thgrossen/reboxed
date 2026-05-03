#if os(macOS)
import SwiftUI
import Vision
import AppKit

struct MacScannerView: View {
    var onScan: (String) -> Void
    @State private var isPickingFile = false
    @State private var lastResult = ""

    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "qrcode.viewfinder")
                .font(.system(size: 64))
                .foregroundStyle(.secondary)
            Text("Scan a QR Code")
                .font(.title2)
            Text("Import an image containing a QR code, or paste one with ⌘V.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
            Button("Import Image…") { isPickingFile = true }
                .buttonStyle(.borderedProminent)
        }
        .padding(40)
        .fileImporter(
            isPresented: $isPickingFile,
            allowedContentTypes: [.image]
        ) { result in
            if let url = try? result.get(),
               let cgImage = loadCGImage(from: url) {
                detectQR(in: cgImage)
            }
        }
        .onPasteCommand(of: [.image]) { providers in
            providers.first?.loadObject(ofClass: NSImage.self) { object, _ in
                if let nsImage = object as? NSImage,
                   let cgImage = nsImage.cgImage(forProposedRect: nil, context: nil, hints: nil) {
                    DispatchQueue.main.async { detectQR(in: cgImage) }
                }
            }
        }
    }

    private func loadCGImage(from url: URL) -> CGImage? {
        guard let source = CGImageSourceCreateWithURL(url as CFURL, nil),
              let image = CGImageSourceCreateImageAtIndex(source, 0, nil) else { return nil }
        return image
    }

    private func detectQR(in image: CGImage) {
        let request = VNDetectBarcodesRequest { req, _ in
            guard let obs = req.results?.first as? VNBarcodeObservation,
                  obs.symbology == .qr,
                  let payload = obs.payloadStringValue else { return }
            DispatchQueue.main.async { onScan(payload) }
        }
        let handler = VNImageRequestHandler(cgImage: image)
        try? handler.perform([request])
    }
}
#endif
