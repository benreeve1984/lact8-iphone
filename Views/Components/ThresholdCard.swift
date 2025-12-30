import SwiftUI

struct ThresholdCard: View {
    let title: String
    let intensity: Double?
    let heartRate: Int?
    let lactate: Double?
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(color)

            VStack(alignment: .leading, spacing: 4) {
                if let intensity = intensity {
                    Label("\(intensity, specifier: "%.0f") W", systemImage: "bolt.fill")
                        .font(.caption)
                }
                if let heartRate = heartRate {
                    Label("\(heartRate) bpm", systemImage: "heart.fill")
                        .font(.caption)
                }
                if let lactate = lactate {
                    Label("\(lactate, specifier: "%.1f") mmol/L", systemImage: "drop.fill")
                        .font(.caption)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(12)
    }
}
