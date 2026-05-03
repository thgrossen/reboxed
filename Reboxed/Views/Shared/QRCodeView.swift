import SwiftUI
import CoreImage.CIFilterBuiltins

struct QRCodeView: View {
    let uid: String
    var size: CGFloat = 150

    var body: some View {
        if let image = makeQRImage() {
            image
                .interpolation(.none)
                .resizable()
                .scaledToFit()
                .frame(width: size, height: size)
        } else {
            Image(systemName: "qrcode")
                .resizable()
                .scaledToFit()
                .frame(width: size, height: size)
                .foregroundStyle(.secondary)
        }
    }

    private func makeQRImage() -> Image? {
        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()
        filter.message = Data(uid.utf8)
        filter.correctionLevel = "M"
        guard let output = filter.outputImage else { return nil }
        let scale = size / output.extent.width
        let scaled = output.transformed(by: CGAffineTransform(scaleX: scale, y: scale))
        guard let cgImage = context.createCGImage(scaled, from: scaled.extent) else { return nil }
        #if canImport(UIKit)
        return Image(uiImage: UIImage(cgImage: cgImage))
        #else
        return Image(nsImage: NSImage(cgImage: cgImage, size: NSSize(width: size, height: size)))
        #endif
    }
}
