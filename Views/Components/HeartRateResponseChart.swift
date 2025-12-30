import SwiftUI
import Charts

struct HeartRateResponseChart: View {
    let steps: [TestStep]
    let lt1Intensity: Double?
    let lt1HeartRate: Int?
    let lt2Intensity: Double?
    let lt2HeartRate: Int?

    private var intensityRange: ClosedRange<Double> {
        let intensities = steps.compactMap { $0.intensityValue }
        let minIntensity = intensities.min() ?? 0
        let maxIntensity = intensities.max() ?? 100
        return minIntensity...maxIntensity
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Heart Rate Response")
                .font(.headline)

            Chart {
                ForEach(steps.filter { $0.isValid }) { step in
                    if let intensity = step.intensityValue,
                       let heartRate = step.heartRateValue {
                        LineMark(
                            x: .value("Intensity", intensity),
                            y: .value("Heart Rate", heartRate)
                        )
                        .foregroundStyle(.red)

                        PointMark(
                            x: .value("Intensity", intensity),
                            y: .value("Heart Rate", heartRate)
                        )
                        .foregroundStyle(.red)
                    }
                }

                if let lt1Intensity = lt1Intensity,
                   let lt1HeartRate = lt1HeartRate {
                    PointMark(
                        x: .value("Intensity", lt1Intensity),
                        y: .value("Heart Rate", lt1HeartRate)
                    )
                    .foregroundStyle(.green)
                    .symbolSize(150)
                }

                if let lt2Intensity = lt2Intensity,
                   let lt2HeartRate = lt2HeartRate {
                    PointMark(
                        x: .value("Intensity", lt2Intensity),
                        y: .value("Heart Rate", lt2HeartRate)
                    )
                    .foregroundStyle(.orange)
                    .symbolSize(150)
                }
            }
            .frame(height: 250)
            .chartXAxisLabel("Intensity")
            .chartYAxisLabel("Heart Rate (bpm)")
            .chartXScale(domain: intensityRange)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}
