import SwiftUI

struct HouseRowView: View {
    let house: House

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(house.title.isEmpty ? "Unnamed Place" : house.title)
                .font(.body)
            Text([house.city, house.country].filter { !$0.isEmpty }.joined(separator: ", "))
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 2)
    }
}
