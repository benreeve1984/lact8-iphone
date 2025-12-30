import SwiftUI

struct TrainingZoneRow: View {
    let name: String
    let range: String
    let unit: String
    let color: Color
    let description: String

    var body: some View {
        HStack {
            RoundedRectangle(cornerRadius: 4)
                .fill(color)
                .frame(width: 4)

            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(.subheadline)
                    .fontWeight(.medium)

                Text("\(range) \(unit)")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Text(description)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .italic()
            }

            Spacer()
        }
        .padding(.vertical, 8)
    }
}
