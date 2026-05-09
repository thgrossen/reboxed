/*******************************************************************************
 * The MIT License (MIT)
 *
 * Copyright (c) 2026, Thomas Grossen
 ******************************************************************************/

import Foundation
import CoreImage
import CoreImage.CIFilterBuiltins
#if canImport(UIKit)
import UIKit
#else
import AppKit
#endif

enum PDFLabelService
{
    static func generate( entries: [ ( uid: String, title: String, number: Int? ) ], layout: LabelLayout ) -> Data?
    {
        #if canImport(UIKit)
        return generateiOS( entries: entries, layout: layout )
        #else
        return generatemacOS( entries: entries, layout: layout )
        #endif
    }

    // MARK: iOS

    #if canImport(UIKit)
    private static func generateiOS( entries: [ ( uid: String, title: String, number: Int? ) ], layout: LabelLayout ) -> Data?
    {
        let pageRect = CGRect( x: 0, y: 0, width: LabelLayout.a4Width, height: LabelLayout.a4Height )
        let renderer = UIGraphicsPDFRenderer( bounds: pageRect )
        return renderer.pdfData { ctx in
            ctx.beginPage()
            for ( index, entry ) in entries.prefix( layout.rawValue ).enumerated()
            {
                let col = index % layout.columns
                let row = index / layout.columns
                let x = LabelLayout.margin + CGFloat( col ) * ( layout.labelWidth + LabelLayout.gap )
                let y = LabelLayout.margin + CGFloat( row ) * ( layout.labelHeight + LabelLayout.gap )
                let rect = CGRect( x: x, y: y, width: layout.labelWidth, height: layout.labelHeight )
                drawLabel( entry: entry, in: rect, context: ctx.cgContext, layout: layout )
            }
        }
    }

    private static func drawLabel(
        entry: ( uid: String, title: String, number: Int? ),
        in rect: CGRect,
        context: CGContext,
        layout: LabelLayout
    )
    {
        context.saveGState()

        // Border
        context.setStrokeColor( UIColor.separator.cgColor )
        context.setLineWidth( 0.5 )
        context.stroke( rect.insetBy( dx: 2, dy: 2 ) )

        let padding: CGFloat = 6
        let qrSize = min( rect.width * 0.38, rect.height - padding * 2 )
        let qrRect = CGRect(
            x: rect.minX + padding,
            y: rect.minY + ( rect.height - qrSize ) / 2,
            width: qrSize,
            height: qrSize
        )

        if let cgQR = makeQRCGImage( from: entry.uid, size: qrSize )
        {
            context.draw( cgQR, in: qrRect )
        }

        let textX     = qrRect.maxX + padding
        let textWidth = rect.maxX - textX - padding

        if let number = entry.number
        {
            // Box label: large number + small title + tiny UID
            let numberFontSize: CGFloat = qrSize * 0.58
            let titleFontSize: CGFloat  = layout.rawValue <= 4 ? 9 : ( layout.rawValue <= 8 ? 7 : 6 )
            let uidFontSize: CGFloat    = layout.rawValue <= 4 ? 7 : ( layout.rawValue <= 8 ? 6 : 5 )

            let numberAttrs: [ NSAttributedString.Key: Any ] = [
                .font: UIFont.systemFont( ofSize: numberFontSize, weight: .bold )
            ]
            let titleAttrs: [ NSAttributedString.Key: Any ] = [
                .font: UIFont.systemFont( ofSize: titleFontSize, weight: .regular )
            ]
            let uidAttrs: [ NSAttributedString.Key: Any ] = [
                .font: UIFont.monospacedSystemFont( ofSize: uidFontSize, weight: .regular ),
                .foregroundColor: UIColor.secondaryLabel
            ]

            let numberStr = NSAttributedString( string: "\( number )", attributes: numberAttrs )
            let titleStr  = NSAttributedString( string: entry.title, attributes: titleAttrs )
            let uidStr    = NSAttributedString( string: entry.uid,   attributes: uidAttrs )

            let numberBounds = numberStr.boundingRect(
                with: CGSize( width: textWidth, height: rect.height ),
                options: [ .usesLineFragmentOrigin ], context: nil
            )
            let titleBounds = titleStr.boundingRect(
                with: CGSize( width: textWidth, height: rect.height ),
                options: [ .usesLineFragmentOrigin ], context: nil
            )

            let totalHeight = numberBounds.height + 4 + titleBounds.height + 3 + uidFontSize
            let startY = rect.minY + ( rect.height - totalHeight ) / 2

            numberStr.draw( in: CGRect( x: textX, y: startY,
                                        width: textWidth, height: numberBounds.height + 2 ) )
            titleStr.draw( in: CGRect( x: textX, y: startY + numberBounds.height + 4,
                                       width: textWidth, height: titleBounds.height + 2 ) )
            uidStr.draw( at: CGPoint( x: textX, y: startY + numberBounds.height + 4 + titleBounds.height + 3 ) )
        }
        else
        {
            // Standard label: title + UID
            let titleFontSize: CGFloat = layout.rawValue <= 4 ? 11 : ( layout.rawValue <= 8 ? 9 : 7 )
            let uidFontSize: CGFloat   = layout.rawValue <= 4 ? 8  : ( layout.rawValue <= 8 ? 7 : 6 )

            let titleAttrs: [ NSAttributedString.Key: Any ] = [
                .font: UIFont.systemFont( ofSize: titleFontSize, weight: .semibold )
            ]
            let uidAttrs: [ NSAttributedString.Key: Any ] = [
                .font: UIFont.monospacedSystemFont( ofSize: uidFontSize, weight: .regular ),
                .foregroundColor: UIColor.secondaryLabel
            ]

            let titleStr = NSAttributedString( string: entry.title, attributes: titleAttrs )
            let uidStr   = NSAttributedString( string: entry.uid,   attributes: uidAttrs )

            let titleBounds = titleStr.boundingRect(
                with: CGSize( width: textWidth, height: rect.height ),
                options: [ .usesLineFragmentOrigin ], context: nil
            )
            let totalHeight = titleBounds.height + 4 + uidFontSize
            let startY = rect.minY + ( rect.height - totalHeight ) / 2

            titleStr.draw( in: CGRect( x: textX, y: startY, width: textWidth, height: titleBounds.height + 2 ) )
            uidStr.draw( at: CGPoint( x: textX, y: startY + titleBounds.height + 4 ) )
        }

        context.restoreGState()
    }
    #endif

    // MARK: macOS

    #if os(macOS)
    private static func generatemacOS( entries: [ ( uid: String, title: String, number: Int? ) ], layout: LabelLayout ) -> Data?
    {
        let data = NSMutableData()
        var mediaBox = CGRect( origin: .zero, size: CGSize( width: LabelLayout.a4Width, height: LabelLayout.a4Height ) )
        guard let ctx = CGContext( consumer: CGDataConsumer( data: data as CFMutableData )!,
                                   mediaBox: &mediaBox, nil ) else { return nil }
        ctx.beginPDFPage( nil )
        for ( index, entry ) in entries.prefix( layout.rawValue ).enumerated()
        {
            let col = index % layout.columns
            let row = index / layout.columns
            let x = LabelLayout.margin + CGFloat( col ) * ( layout.labelWidth + LabelLayout.gap )
            let y = LabelLayout.margin + CGFloat( row ) * ( layout.labelHeight + LabelLayout.gap )
            let rect = CGRect( x: x, y: y, width: layout.labelWidth, height: layout.labelHeight )
            drawLabelMac( entry: entry, in: rect, context: ctx, layout: layout )
        }
        ctx.endPDFPage()
        ctx.closePDF()
        return data as Data
    }

    private static func drawLabelMac(
        entry: ( uid: String, title: String, number: Int? ),
        in rect: CGRect,
        context ctx: CGContext,
        layout: LabelLayout
    )
    {
        ctx.saveGState()
        ctx.setStrokeColor( CGColor( gray: 0.6, alpha: 1 ) )
        ctx.setLineWidth( 0.5 )
        ctx.stroke( rect.insetBy( dx: 2, dy: 2 ) )

        let padding: CGFloat = 6
        let qrSize = min( rect.width * 0.38, rect.height - padding * 2 )
        let qrRect = CGRect(
            x: rect.minX + padding,
            y: rect.minY + ( rect.height - qrSize ) / 2,
            width: qrSize,
            height: qrSize
        )

        if let cgQR = makeQRCGImage( from: entry.uid, size: qrSize )
        {
            ctx.draw( cgQR, in: qrRect )
        }

        let textX     = qrRect.maxX + padding
        let textWidth = rect.maxX - textX - padding

        NSGraphicsContext.saveGraphicsState()
        let nsCtx = NSGraphicsContext( cgContext: ctx, flipped: false )
        NSGraphicsContext.current = nsCtx

        if let number = entry.number
        {
            let numberFontSize: CGFloat = qrSize * 0.58
            let titleFontSize: CGFloat  = layout.rawValue <= 4 ? 9 : ( layout.rawValue <= 8 ? 7 : 6 )
            let uidFontSize: CGFloat    = layout.rawValue <= 4 ? 7 : ( layout.rawValue <= 8 ? 6 : 5 )

            let numberStr = NSAttributedString( string: "\( number )", attributes: [
                .font: NSFont.systemFont( ofSize: numberFontSize, weight: .bold )
            ] )
            let titleStr = NSAttributedString( string: entry.title, attributes: [
                .font: NSFont.systemFont( ofSize: titleFontSize, weight: .regular )
            ] )
            let uidStr = NSAttributedString( string: entry.uid, attributes: [
                .font: NSFont.monospacedSystemFont( ofSize: uidFontSize, weight: .regular ),
                .foregroundColor: NSColor.secondaryLabelColor
            ] )

            let numberBounds = numberStr.boundingRect( with: CGSize( width: textWidth, height: rect.height ) )
            let titleBounds  = titleStr.boundingRect(  with: CGSize( width: textWidth, height: rect.height ) )

            let totalHeight = numberBounds.height + 4 + titleBounds.height + 3 + uidFontSize
            let startY = rect.minY + ( rect.height - totalHeight ) / 2

            numberStr.draw( in: CGRect( x: textX, y: startY,
                                        width: textWidth, height: numberBounds.height + 2 ) )
            titleStr.draw( in: CGRect( x: textX, y: startY + numberBounds.height + 4,
                                       width: textWidth, height: titleBounds.height + 2 ) )
            uidStr.draw( at: CGPoint( x: textX, y: startY + numberBounds.height + 4 + titleBounds.height + 3 ) )
        }
        else
        {
            let titleFontSize: CGFloat = layout.rawValue <= 4 ? 11 : ( layout.rawValue <= 8 ? 9 : 7 )
            let uidFontSize: CGFloat   = layout.rawValue <= 4 ? 8  : ( layout.rawValue <= 8 ? 7 : 6 )

            let titleStr = NSAttributedString( string: entry.title, attributes: [
                .font: NSFont.systemFont( ofSize: titleFontSize, weight: .semibold )
            ] )
            let uidStr = NSAttributedString( string: entry.uid, attributes: [
                .font: NSFont.monospacedSystemFont( ofSize: uidFontSize, weight: .regular ),
                .foregroundColor: NSColor.secondaryLabelColor
            ] )

            let titleBounds = titleStr.boundingRect( with: CGSize( width: textWidth, height: rect.height ) )
            let totalHeight = titleBounds.height + 4 + uidFontSize
            let startY = rect.minY + ( rect.height - totalHeight ) / 2

            titleStr.draw( in: CGRect( x: textX, y: startY, width: textWidth, height: titleBounds.height + 2 ) )
            uidStr.draw( at: CGPoint( x: textX, y: startY + titleBounds.height + 4 ) )
        }

        NSGraphicsContext.restoreGraphicsState()
        ctx.restoreGState()
    }
    #endif

    // MARK: Shared

    private static func makeQRCGImage( from string: String, size: CGFloat ) -> CGImage?
    {
        let filter = CIFilter.qrCodeGenerator()
        filter.message = Data( string.utf8 )
        filter.correctionLevel = "M"
        guard let output = filter.outputImage else { return nil }
        let scale = size / output.extent.width
        let scaled = output.transformed( by: CGAffineTransform( scaleX: scale, y: scale ) )
        return CIContext().createCGImage( scaled, from: scaled.extent )
    }
}
