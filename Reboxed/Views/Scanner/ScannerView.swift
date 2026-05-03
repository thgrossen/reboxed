/*******************************************************************************
 * The MIT License (MIT)
 *
 * Copyright (c) 2026, Thomas Grossen
 ******************************************************************************/

import SwiftUI
import SwiftData

struct ScannerView: View
{
    @Environment( \.modelContext ) private var modelContext
    @State private var viewModel = ScannerViewModel()
    @State private var mode: ScanMode = .single
    @State private var showUnknown = false

    enum ScanMode { case single, multi }

    var body: some View
    {
        NavigationStack
        {
            ZStack( alignment: .bottom )
            {
                #if os(iOS)
                if mode == .single
                {
                    DataScannerView( onScan: handleScan )
                        .ignoresSafeArea()
                }
                else
                {
                    MultiScanView()
                        .ignoresSafeArea()
                }
                #else
                MacScannerView( onScan: handleScan )
                #endif
            }
            .navigationTitle( "Scan" )
            .toolbar
            {
                #if os(iOS)
                ToolbarItem( placement: .primaryAction )
                {
                    Picker( "Mode", selection: $mode )
                    {
                        Image( systemName: "qrcode.viewfinder" ).tag( ScanMode.single )
                        Image( systemName: "list.bullet.rectangle" ).tag( ScanMode.multi )
                    }
                    .pickerStyle( .segmented )
                }
                #endif
            }
            .navigationDestination( item: $viewModel.navigationTarget ) { target in
                switch target
                {
                case .house( let h ): HouseDetailView( house: h )
                case .room( let r ): RoomDetailView( room: r )
                case .box( let b ): BoxDetailView( box: b )
                case .item( let i ): ItemDetailView( item: i )
                }
            }
            .alert( "Unknown QR Code", isPresented: $showUnknown )
            {
                Button( "OK", role: .cancel ) {}
            } message: {
                Text( "No item found for: \( viewModel.unknownUID ?? "" )" )
            }
            .onChange( of: viewModel.unknownUID )
            {
                showUnknown = viewModel.unknownUID != nil
            }
        }
    }

    private func handleScan( _ uid: String )
    {
        viewModel.resolve( uid: uid, context: modelContext )
    }
}
