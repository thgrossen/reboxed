import Foundation
import CoreImage
import CoreImage.CIFilterBuiltins
#if canImport(UIKit)
import UIKit
#else
import AppKit
#endif

enum PDFLabelService {
    static func generate(entries: [(uid: String, title: String)], layout: LabelLayout) -> Data? {
        #if canImport(UIKit)
        return generateiOS(entries: entries, layout: layout)
        #else
        return generatemacOS(entries: entries, layout: layout)
        #endif
    }

    // MARK: iOS

    #if canImport(UIKit)
    private static func generateiOS(entries: [(uid: String, title: String)], layout: LabelLayout) -> Data? {
        let pageRect = CGRect(x: 0, y: 0, width: LabelLayout.a4Width, height: LabelLayout.a4Height)
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect)
        return renderer.pdfData { ctx in
            ctx.beginPage()
            for (index, entry) in entries.prefix(layout.rawValue).enumerated() {
                let col = index % layout.columns
                let row = index / layout.columns
                let x = LabelLayout.margin + CGFloat(col) * (layout.labelWidth + LabelLayout.gap)
                let y = LabelLayout.margin + CGFloat(row) * (layout.labelHeight + LabelLayout.gap)
                let rect = CGRect(x: x, y: y, width: layout.labelWidth, height: layout.labelHeight)
                drawLabel(entry: entry, in: rect, context: ctx.cgContext, layout: layout)
            }
        }
    }

    private static func drawLabel(
        entry: (uid: String, title: String),
        in rect: CGRect,
        context: CGContext,
        layout: LabelLayout
    ) {
        context.saveGState()

        // Border
        context.setStrokeColor(UIColor.separator.cgColor)
        context.setLineWidth(0.5)
        context.stroke(rect.insetBy(dx: 2, dy: 2))

        let padding: CGFloat = 6
        let qrSize = min(rect.width * 0.38, rect.height - padding * 2)
        let qrRect = CGRect(
            x: rect.minX + padding,
            y: rect.minY + (rect.height - qrSize) / 2,
            width: qrSize,
            height: qrSize
        )

        // QR code
        if let cgQR = makeQRCGImage(from: entry.uid, size: qrSize) {
            context.draw(cgQR, in: qrRect)
        }

        // Text area
        let textX = qrRect.maxX + padding
        let textWidth = rect.maxX - textX - padding
        let titleFontSize: CGFloat = layout.rawValue <= 4 ? 11 : (layout.rawValue <= 8 ? 9 : 7)
        let uidFontSize: CGFloat = layout.rawValue <= 4 ? 8 : (layout.rawValue <= 8 ? 7 : 6)

        let titleAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: titleFontSize, weight: .semibold)
        ]
        let uidAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.monospacedSystemFont(ofSize: uidFontSize, weight: .regular),
            .foregroundColor: UIColor.secondaryLabel
        ]

        let titleStr = NSAttributedString(string: entry.title, attributes: titleAttrs)
        let uidStr = NSAttributedString(string: entry.uid, attributes: uidAttrs)

        let titleBounds = titleStr.boundingRect(
            with: CGSize(width: textWidth, height: rect.height),
            options: [.usesLineFragmentOrigin],
            context: nil
        )
        let totalTextHeight = titleBounds.height + 4 + uidFontSize
        let textStartY = rect.minY + (rect.height - totalTextHeight) / 2

        titleStr.draw(in: CGRect(x: textX, y: textStartY, width: textWidth, height: titleBounds.height + 2))
        uidStr.draw(at: CGPoint(x: textX, y: textStartY + titleBounds.height + 4))

        context.restoreGState()
    }
    #endif

    // MARK: macOS

    #if os(macOS)
    private static func generatemacOS(entries: [(uid: String, title: String)], layout: LabelLayout) -> Data? {
        let pageSize = CGSize(width: LabelLayout.a4Width, height: LabelLayout.a4Height)
        guard let ctx = CGContext(consumer: CGDataConsumer(data: NSMutableData() as CFMutableData)!,
                                  mediaBox: nil, nil) else { return nil }

        var mediaBox = CGRect(origin: .zero, size: pageSize)
        ctx.beginPDFPage(nil)
        for (index, entry) in entries.prefix(layout.rawValue).enumerated() {
            let col = index % layout.columns
            let row = index / layout.columns
            let x = LabelLayout.margin + CGFloat(col) * (layout.labelWidth + LabelLayout.gap)
            let y = LabelLayout.margin + CGFloat(row) * (layout.labelHeight + LabelLayout.gap)
            let rect = CGRect(x: x, y: y, width: layout.labelWidth, height: layout.labelHeight)
            drawLabelMac(entry: entry, in: rect, context: ctx, layout: layout)
        }
        ctx.endPDFPage()
        ctx.closePDF()

        // Capture via NSGraphicsContext
        let data = NSMutableData()
        if let pdfCtx = CGContext(consumer: CGDataConsumer(data: data as CFMutableData)!, mediaBox: &mediaBox, nil) {
            pdfCtx.beginPDFPage(nil)
            for (index, entry) in entries.prefix(layout.rawValue).enumerated() {
                let col = index % layout.columns
                let row = index / layout.columns
                let x = LabelLayout.margin + CGFloat(col) * (layout.labelWidth + LabelLayout.gap)
                let y = LabelLayout.margin + CGFloat(row) * (layout.labelHeight + LabelLayout.gap)
                let rect = CGRect(x: x, y: y, width: layout.labelWidth, height: layout.labelHeight)
                drawLabelMac(entry: entry, in: rect, context: pdfCtx, layout: layout)
            }
            pdfCtx.endPDFPage()
            pdfCtx.closePDF()
        }
        return data as Data
    }

    private static func drawLabelMac(
        entry: (uid: String, title: String),
        in rect: CGRect,
        context ctx: CGContext,
        layout: LabelLayout
    ) {
        ctx.saveGState()
        ctx.setStrokeColor(CGColor(gray: 0.6, alpha: 1))
        ctx.setLineWidth(0.5)
        ctx.stroke(rect.insetBy(dx: 2, dy: 2))

        let padding: CGFloat = 6
        let qrSize = min(rect.width * 0.38, rect.height - padding * 2)
        let qrRect = CGRect(x: rect.minX + padding, y: rect.minY + (rect.height - qrSize) / 2,
                            width: qrSize, height: qrSize)

        if let cgQR = makeQRCGImage(from: entry.uid, size: qrSize) {
            ctx.draw(cgQR, in: qrRect)
        }

        let textX = qrRect.maxX + padding
        let titleFontSize: CGFloat = layout.rawValue <= 4 ? 11 : (layout.rawValue <= 8 ? 9 : 7)
        let uidFontSize: CGFloat = layout.rawValue <= 4 ? 8 : (layout.rawValue <= 8 ? 7 : 6)
        let textWidth = rect.maxX - textX - padding

        let titleFont = NSFont.systemFont(ofSize: titleFontSize, weight: .semibold)
        let uidFont = NSFont.monospacedSystemFont(ofSize: uidFontSize, weight: .regular)

        let titleStr = NSAttributedString(string: entry.title, attributes: [.font: titleFont])
        let uidStr = NSAttributedString(string: entry.uid, attributes: [
            .font: uidFont,
            .foregroundColor: NSColor.secondaryLabelColor
        ])

        let titleBounds = titleStr.boundingRect(with: CGSize(width: textWidth, height: rect.height))
        let textStartY = rect.minY + (rect.height - titleBounds.height - 4 - uidFontSize) / 2

        NSGraphicsContext.saveGraphicsState()
        if let nsCtx = NSGraphicsContext(cgContext: ctx, flipped: false) {
            NSGraphicsContext.current = nsCtx
            titleStr.draw(in: CGRect(x: textX, y: textStartY, width: textWidth, height: titleBounds.height + 2))
            uidStr.draw(at: CGPoint(x: textX, y: textStartY + titleBounds.height + 4))
        }
        NSGraphicsContext.restoreGraphicsState()
        ctx.restoreGState()
    }
    #endif

    // MARK: Shared

    private static func makeQRCGImage(from string: String, size: CGFloat) -> CGImage? {
        let filter = CIFilter.qrCodeGenerator()
        filter.message = Data(string.utf8)
        filter.correctionLevel = "M"
        guard let output = filter.outputImage else { return nil }
        let scale = size / output.extent.width
        let scaled = output.transformed(by: CGAffineTransform(scaleX: scale, y: scale))
        return CIContext().createCGImage(scaled, from: scaled.extent)
    }
}
