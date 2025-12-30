import SwiftUI

struct RawDataTable: View {
    let steps: [TestStep]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Raw Data")
                .font(.headline)

            VStack(spacing: 8) {
                HStack {
                    Text("Step")
                        .frame(width: 50, alignment: .leading)
                    Text("Intensity")
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text("HR")
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text("Lactate")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .font(.caption)
                .foregroundColor(.secondary)

                Divider()

                ForEach(steps.filter { $0.isValid }) { step in
                    HStack {
                        Text("\(step.stepNumber)")
                            .frame(width: 50, alignment: .leading)
                        Text("\(step.intensityValue ?? 0, specifier: "%.0f")")
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text("\(step.heartRateValue ?? 0)")
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text("\(step.lactateValue ?? 0, specifier: "%.1f")")
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .font(.system(.body, design: .monospaced))
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
    }
}
