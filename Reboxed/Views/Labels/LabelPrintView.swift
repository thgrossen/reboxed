/*******************************************************************************
 * The MIT License (MIT)
 *
 * Copyright (c) 2026, Thomas Grossen
 ******************************************************************************/

import SwiftUI
import PDFKit

struct LabelPrintView: View
{
    let entries: [ ( uid: String, title: String ) ]
    @State private var layout: LabelLayout = .four
    @State private var pdfData: Data?
    @Environment( \.dismiss ) private var dismiss

    var body: some View
    {
        NavigationStack
        {
            VStack( spacing: 0 )
            {
                LabelLayoutPicker( selection: $layout )
                    .padding( .vertical, 8 )
                Divider()
                if let data = pdfData, let doc = PDFDocument( data: data )
                {
                    PDFKitView( document: doc )
                }
                else
                {
                    ProgressView()
                        .frame( maxWidth: .infinity, maxHeight: .infinity )
                }
            }
            .navigationTitle( "Print Labels" )
            #if os(iOS)
            .navigationBarTitleDisplayMode( .inline )
            #endif
            .toolbar
            {
                ToolbarItem( placement: .cancellationAction )
                {
                    Button( "Close" ) { dismiss() }
                }
                if let data = pdfData
                {
                    ToolbarItem( placement: .primaryAction )
                    {
                        ShareLink(
                            item: data,
                            preview: SharePreview( "Labels.pdf", image: Image( systemName: "doc.richtext" ) )
                        )
                    }
                }
            }
            .onChange( of: layout ) { generatePDF() }
            .onAppear { generatePDF() }
        }
    }

    private func generatePDF()
    {
        pdfData = PDFLabelService.generate( entries: entries, layout: layout )
    }
}

// MARK: - PDFKit wrapper

struct PDFKitView: View
{
    let document: PDFDocument

    var body: some View
    {
        #if os(iOS)
        PDFKitRepresentable( document: document )
        #else
        PDFKitRepresentable( document: document )
        #endif
    }
}

#if os(iOS)
import UIKit
struct PDFKitRepresentable: UIViewRepresentable
{
    let document: PDFDocument
    func makeUIView( context: Context ) -> PDFView
    {
        let view = PDFView()
        view.document = document
        view.autoScales = true
        view.displayMode = .singlePage
        return view
    }
    func updateUIView( _ uiView: PDFView, context: Context )
    {
        uiView.document = document
    }
}
#else
import AppKit
struct PDFKitRepresentable: NSViewRepresentable
{
    let document: PDFDocument
    func makeNSView( context: Context ) -> PDFView
    {
        let view = PDFView()
        view.document = document
        view.autoScales = true
        return view
    }
    func updateNSView( _ nsView: PDFView, context: Context )
    {
        nsView.document = document
    }
}
#endif
