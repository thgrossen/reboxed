#if os(iOS)
import SwiftUI
import VisionKit
import SwiftData

struct MultiScanView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var scannedUIDs: Set<String> = []
    @State private var resolvedEntities: [ResolvedEntity] = []

    struct ResolvedEntity: Identifiable {
        let id: String
        let uid: String
        let title: String
        let type: EntityType
        var items: [Item] = []

        enum EntityType { case house, room, box, item }
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            MultiDataScannerView { uid in
                guard !scannedUIDs.contains(uid) else { return }
                scannedUIDs.insert(uid)
                resolveUID(uid)
            }
            .ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    Text("\(resolvedEntities.count) scanned")
                        .font(.headline)
                        .foregroundStyle(.white)
                    Spacer()
                    Button("Clear") {
                        scannedUIDs = []
                        resolvedEntities = []
                    }
                    .foregroundStyle(.white)
                }
                .padding()
                .background(.ultraThinMaterial)

                List(resolvedEntities) { entity in
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Image(systemName: entity.type == .box ? "shippingbox.fill" : "cube.box")
                            Text(entity.title)
                            Spacer()
                            Text(entity.uid)
                                .font(.system(.caption, design: .monospaced))
                                .foregroundStyle(.secondary)
                        }
                        if entity.type == .box && !entity.items.isEmpty {
                            ForEach(entity.items) { item in
                                Text("  · \(item.title)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
                .frame(maxHeight: 280)
                .background(.ultraThinMaterial)
            }
        }
    }

    private func resolveUID(_ uid: String) {
        let vm = ScannerViewModel()
        vm.resolve(uid: uid, context: modelContext)
        switch vm.navigationTarget {
        case .house(let h):
            resolvedEntities.append(ResolvedEntity(id: uid, uid: h.uid, title: h.title, type: .house))
        case .room(let r):
            resolvedEntities.append(ResolvedEntity(id: uid, uid: r.uid, title: r.title, type: .room))
        case .box(let b):
            var entity = ResolvedEntity(id: uid, uid: b.uid, title: b.title, type: .box)
            entity.items = (b.items ?? []).sorted { $0.title < $1.title }
            resolvedEntities.append(entity)
        case .item(let i):
            resolvedEntities.append(ResolvedEntity(id: uid, uid: i.uid, title: i.title, type: .item))
        case nil:
            break
        }
    }
}

struct MultiDataScannerView: UIViewControllerRepresentable {
    var onScan: (String) -> Void

    func makeUIViewController(context: Context) -> DataScannerViewController {
        let scanner = DataScannerViewController(
            recognizedDataTypes: [.barcode(symbologies: [.qr])],
            qualityLevel: .balanced,
            recognizesMultipleItems: true,
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
    func makeCoordinator() -> Coordinator { Coordinator(onScan: onScan) }

    class Coordinator: NSObject, DataScannerViewControllerDelegate {
        let onScan: (String) -> Void
        init(onScan: @escaping (String) -> Void) { self.onScan = onScan }

        func dataScanner(_ dataScanner: DataScannerViewController,
                         didAdd addedItems: [RecognizedItem],
                         allItems: [RecognizedItem]) {
            for item in addedItems {
                if case let .barcode(barcode) = item,
                   let payload = barcode.payloadStringValue {
                    DispatchQueue.main.async { self.onScan(payload) }
                }
            }
        }
    }
}
#endif
