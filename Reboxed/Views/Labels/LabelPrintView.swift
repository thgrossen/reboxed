/*******************************************************************************
 * The MIT License (MIT)
 *
 * Copyright (c) 2026, Thomas Grossen
 ******************************************************************************/

import SwiftUI
import PDFKit

struct LabelPrintView: View
{
    let entries: [ ( uid: String, title: String, number: Int? ) ]

    @AppStorage( "labelsPerPage" )  private var labelsPerPage: Int    = 4
    @AppStorage( "labelPaperSize" ) private var paperSizeRaw: String  = PaperSize.a4.rawValue

    @State private var quantities: [ Int ] = []
    @State private var pdfData: Data?
    @Environment( \.dismiss ) private var dismiss

    private var paperSize: PaperSize
    {
        PaperSize( rawValue: paperSizeRaw ) ?? .a4
    }

    private var config: LabelLayoutConfig
    {
        LabelLayoutConfig( labelsPerPage: max( 1, labelsPerPage ), paperSize: paperSize )
    }

    private var expandedEntries: [ ( uid: String, title: String, number: Int? ) ]
    {
        zip( entries, quantities ).flatMap { entry, qty in
            Array( repeating: entry, count: max( 1, qty ) )
        }
    }

    var body: some View
    {
        NavigationStack
        {
            VStack( spacing: 0 )
            {
                // Controls
                VStack( spacing: 6 )
                {
                    Stepper( "Labels per page: \( labelsPerPage )", value: $labelsPerPage, in: 1...50 )
                        .padding( .horizontal )
                    Text( config.orientationLabel )
                        .font( .caption )
                        .foregroundStyle( .secondary )
                }
                .padding( .vertical, 10 )

                Divider()

                // Per-entry quantities
                List
                {
                    ForEach( entries.indices, id: \.self ) { index in
                        HStack
                        {
                            VStack( alignment: .leading, spacing: 2 )
                            {
                                if let number = entries[ index ].number
                                {
                                    Text( "\( number )  \( entries[ index ].title )" )
                                }
                                else
                                {
                                    Text( entries[ index ].title )
                                }
                            }
                            Spacer()
                            if index < quantities.count
                            {
                                Stepper( "\( quantities[ index ] )", value: $quantities[ index ], in: 1...99 )
                                    .labelsHidden()
                                    .fixedSize()
                            }
                        }
                    }
                }
                .frame( maxHeight: CGFloat( entries.count ) * 56 + 16 )

                Divider()

                // PDF preview
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
            .onChange( of: labelsPerPage ) { generatePDF() }
            .onChange( of: paperSizeRaw )  { generatePDF() }
            .onChange( of: quantities )    { generatePDF() }
            .onAppear
            {
                quantities = Array( repeating: 1, count: entries.count )
                generatePDF()
            }
        }
    }

    private func generatePDF()
    {
        guard quantities.count == entries.count else { return }
        pdfData = PDFLabelService.generate( entries: expandedEntries, config: config )
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
