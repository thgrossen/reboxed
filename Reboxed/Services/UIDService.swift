import Foundation

enum EntityPrefix: String {
    case place = "P"
    case room = "R"
    case box = "B"
    case item = "I"
}

enum UIDService {
    private static let chars = Array("ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789")

    static func generate(for prefix: EntityPrefix) -> String {
        let suffix = withUnsafeBytes(of: UUID().uuid) { raw in
            String(Array(raw.prefix(8)).map { chars[Int($0) % chars.count] })
        }
        return "\(prefix.rawValue)-\(suffix)"
    }

    static func entityPrefix(from uid: String) -> EntityPrefix? {
        guard uid.count == 10,
              uid[uid.index(uid.startIndex, offsetBy: 1)] == "-" else { return nil }
        return EntityPrefix(rawValue: String(uid.prefix(1)))
    }
}
