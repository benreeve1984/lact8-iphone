import SwiftUI
import Charts

struct TestDetailView: View {
    let test: LactateTest
    @Environment(\.dismiss) private var dismiss
    @State private var shareText = ""
    @State private var showingShareSheet = false
    @State private var showingCopyAlert = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    headerInfo
                    thresholdSummary
                    lactateChart
                    heartRateChart
                    rawDataSection
                    
                    if !test.notes.isEmpty {
                        notesSection
                    }
                }
                .padding()
            }
            .navigationTitle("Test Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 16) {
                        Button(action: copyMarkdownToClipboard) {
                            Image(systemName: "doc.on.doc")
                        }
                        Button(action: shareResults) {
                            Image(systemName: "square.and.arrow.up")
                        }
                    }
                }
            }
            .sheet(isPresented: $showingShareSheet) {
                ShareSheet(items: [shareText])
            }
            .alert("Copied!", isPresented: $showingCopyAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Test results copied to clipboard as markdown")
            }
        }
    }
    
    private var headerInfo: some View {
        HStack {
            Label(test.testType.rawValue, systemImage: iconForTestType)
                .font(.headline)
            
            Spacer()
            
            Text(test.testDate, style: .date)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private var iconForTestType: String {
        switch test.testType {
        case .cycling:
            return "bicycle"
        case .running:
            return "figure.run"
        case .other:
            return "chart.xyaxis.line"
        }
    }
    
    private var thresholdSummary: some View {
        VStack(spacing: 16) {
            Text("Threshold Summary")
                .font(.headline)
            
            HStack(spacing: 20) {
                ThresholdCard(
                    title: "LT1",
                    intensity: test.lt1Intensity,
                    heartRate: test.lt1HeartRate,
                    lactate: test.lt1Lactate,
                    color: .green
                )
                
                ThresholdCard(
                    title: "LT2",
                    intensity: test.lt2Intensity,
                    heartRate: test.lt2HeartRate,
                    lactate: test.lt2Lactate,
                    color: .orange
                )
            }
        }
    }
    
    private var lactateChart: some View {
        LactateCurveChart(
            steps: test.validSteps,
            lt1Intensity: test.lt1Intensity,
            lt1Lactate: test.lt1Lactate,
            lt2Intensity: test.lt2Intensity,
            lt2Lactate: test.lt2Lactate
        )
    }

    private var heartRateChart: some View {
        HeartRateResponseChart(
            steps: test.validSteps,
            lt1Intensity: test.lt1Intensity,
            lt1HeartRate: test.lt1HeartRate,
            lt2Intensity: test.lt2Intensity,
            lt2HeartRate: test.lt2HeartRate
        )
    }

    private var rawDataSection: some View {
        RawDataTable(steps: test.validSteps)
    }
    
    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Notes")
                .font(.headline)
            
            Text(test.notes)
                .font(.body)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.systemGray6))
                .cornerRadius(12)
        }
    }
    
    private func shareResults() {
        var text = "Lactate Threshold Test Results\n"
        text += "Date: \(test.testDate.formatted(date: .abbreviated, time: .omitted))\n"
        text += "Type: \(test.testType.rawValue)\n\n"
        
        if let lt1 = test.lt1Intensity {
            text += "LT1: \(Int(lt1)) W"
            if let hr = test.lt1HeartRate {
                text += " @ \(hr) bpm"
            }
            text += "\n"
        }
        
        if let lt2 = test.lt2Intensity {
            text += "LT2: \(Int(lt2)) W"
            if let hr = test.lt2HeartRate {
                text += " @ \(hr) bpm"
            }
            text += "\n"
        }
        
        shareText = text
        showingShareSheet = true
    }
    
    private func copyMarkdownToClipboard() {
        let markdown = generateMarkdownReport()
        UIPasteboard.general.string = markdown
        showingCopyAlert = true
    }
    
    private func generateMarkdownReport() -> String {
        var md = "# Lactate Test Results\n\n"
        
        md += "**Date:** \(test.testDate.formatted(date: .abbreviated, time: .omitted))\n"
        md += "**Type:** \(test.testType.rawValue)\n\n"
        
        md += "## Threshold Summary\n\n"
        
        md += "**LT1:**\n"
        if let lt1Intensity = test.lt1Intensity,
           let lt1HR = test.lt1HeartRate,
           let lt1Lactate = test.lt1Lactate {
            md += "- **Intensity:** \(Int(lt1Intensity)) W\n"
            md += "- **Heart Rate:** \(lt1HR) bpm\n"
            md += "- **Lactate:** \(String(format: "%.1f", lt1Lactate)) mmol/L\n"
        } else {
            md += "- Not Identified\n"
        }
        
        md += "\n**LT2:**\n"
        if let lt2Intensity = test.lt2Intensity,
           let lt2HR = test.lt2HeartRate,
           let lt2Lactate = test.lt2Lactate {
            md += "- **Intensity:** \(Int(lt2Intensity)) W\n"
            md += "- **Heart Rate:** \(lt2HR) bpm\n"
            md += "- **Lactate:** \(String(format: "%.1f", lt2Lactate)) mmol/L\n"
        } else {
            md += "- Not Identified\n"
        }
        
        md += "\n## Test Steps\n\n"
        md += "| Step # | Intensity (W) | Heart Rate (bpm) | Lactate (mmol/L) |\n"
        md += "|--------|---------------|------------------|------------------|\n"
        
        for step in test.validSteps {
            let intensity = step.intensityValue.map { String(Int($0)) } ?? "-"
            let heartRate = step.heartRateValue.map { String($0) } ?? "-"
            let lactate = step.lactateValue.map { String(format: "%.1f", $0) } ?? "-"
            md += "| \(step.stepNumber) | \(intensity) | \(heartRate) | \(lactate) |\n"
        }
        
        if !test.notes.isEmpty {
            md += "\n## Notes\n\n"
            md += test.notes
        }
        
        return md
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}