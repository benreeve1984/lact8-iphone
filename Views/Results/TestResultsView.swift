import SwiftUI
import Charts

struct TestResultsView: View {
    let test: LactateTest
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    @State private var showingSaveConfirmation = false
    @State private var savedTest: LactateTest?
    @State private var showingTestDetails = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    thresholdSummary
                    lactateChart
                    heartRateChart
                    rawDataSection
                }
                .padding()
            }
            .navigationTitle("Test Results")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveTest()
                    }
                    .fontWeight(.semibold)
                }
            }
            .alert("Test Saved", isPresented: $showingSaveConfirmation) {
                Button("View Test") {
                    showingTestDetails = true
                }
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text("Your test has been saved successfully.")
            }
            .sheet(isPresented: $showingTestDetails) {
                if let savedTest = savedTest {
                    TestDetailView(test: savedTest)
                }
            }
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
            
            Text("Threshold calculations based on methodologies from \"The Science of Maximal Athletic Development\" by Alan Couzens")
                .font(.caption2)
                .foregroundColor(.secondary)
                .italic()
                .multilineTextAlignment(.center)
                .onTapGesture {
                    if let url = URL(string: "https://alancouzens.substack.com/") {
                        UIApplication.shared.open(url)
                    }
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
    
    private func saveTest() {
        let viewModel = NewTestViewModel()
        viewModel.currentTest = test
        if let entity = viewModel.saveTest(context: viewContext),
           let data = entity.testData,
           let decodedTest = try? JSONDecoder().decode(LactateTest.self, from: data) {
            savedTest = decodedTest
        }
        showingSaveConfirmation = true
    }
}