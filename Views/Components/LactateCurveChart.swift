import SwiftUI
import Charts

struct LactateCurveChart: View {
    let steps: [TestStep]
    let lt1Intensity: Double?
    let lt1Lactate: Double?
    let lt2Intensity: Double?
    let lt2Lactate: Double?

    private var intensityRange: ClosedRange<Double> {
        let intensities = steps.compactMap { $0.intensityValue }
        let minIntensity = intensities.min() ?? 0
        let maxIntensity = intensities.max() ?? 100
        return minIntensity...maxIntensity
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Lactate Curve")
                .font(.headline)

            Chart {
                ForEach(steps.filter { $0.isValid }) { step in
                    if let intensity = step.intensityValue,
                       let lactate = step.lactateValue {
                        LineMark(
                            x: .value("Intensity", intensity),
                            y: .value("Lactate", lactate)
                        )
                        .foregroundStyle(.blue)

                        PointMark(
                            x: .value("Intensity", intensity),
                            y: .value("Lactate", lactate)
                        )
                        .foregroundStyle(.blue)
                    }
                }

                if let lt1Intensity = lt1Intensity,
                   let lt1Lactate = lt1Lactate {
                    PointMark(
                        x: .value("Intensity", lt1Intensity),
                        y: .value("Lactate", lt1Lactate)
                    )
                    .foregroundStyle(.green)
                    .symbolSize(150)
                    .annotation(position: .top) {
                        Text("LT1")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                }

                if let lt2Intensity = lt2Intensity,
                   let lt2Lactate = lt2Lactate {
                    PointMark(
                        x: .value("Intensity", lt2Intensity),
                        y: .value("Lactate", lt2Lactate)
                    )
                    .foregroundStyle(.orange)
                    .symbolSize(150)
                    .annotation(position: .top) {
                        Text("LT2")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                }
            }
            .frame(height: 250)
            .chartXAxisLabel("Intensity")
            .chartYAxisLabel("Lactate (mmol/L)")
            .chartXScale(domain: intensityRange)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}
