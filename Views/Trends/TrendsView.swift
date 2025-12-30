import SwiftUI
import Charts
import CoreData

struct TrendsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \TestEntity.testDate, ascending: true)],
        animation: .default)
    private var tests: FetchedResults<TestEntity>
    
    @State private var selectedTestType: LactateTest.TestType = .cycling
    @State private var selectedMetric: Metric = .intensity
    @State private var selectedZoneSystem: ZoneSystem = .threeZone
    @State private var hasInitialized = false
    
    enum Metric: String, CaseIterable {
        case intensity = "Power/Speed"
        case heartRate = "Heart Rate"
        
        var unit: String {
            switch self {
            case .intensity: return "W"
            case .heartRate: return "bpm"
            }
        }
    }
    
    private var filteredTests: [TestEntity] {
        tests.filter { $0.testType == selectedTestType.rawValue }
    }
    
    private func initializeTestType() {
        guard !hasInitialized && !tests.isEmpty else { return }
        
        // Find the first test type that has data
        for testType in LactateTest.TestType.allCases {
            if tests.contains(where: { $0.testType == testType.rawValue }) {
                selectedTestType = testType
                break
            }
        }
        hasInitialized = true
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    if tests.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "chart.xyaxis.line")
                                .font(.system(size: 50))
                                .foregroundColor(.secondary)
                            Text("No Tests Yet")
                                .font(.title2)
                                .fontWeight(.semibold)
                            Text("Complete your first lactate test to see it here")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .frame(height: 400)
                        .frame(maxWidth: .infinity)
                    } else {
                        filterSection
                        if filteredTests.isEmpty {
                            VStack(spacing: 12) {
                                Image(systemName: "info.circle")
                                    .font(.system(size: 40))
                                    .foregroundColor(.secondary)
                                Text("No \(selectedTestType.rawValue) Tests")
                                    .font(.title3)
                                    .fontWeight(.medium)
                                Text("Try selecting a different test type above")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            .frame(height: 200)
                            .frame(maxWidth: .infinity)
                        } else {
                            trendChart
                            statisticsSection
                            progressSection
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Threshold Trends")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                initializeTestType()
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    private var filterSection: some View {
        VStack(spacing: 12) {
            Picker("Test Type", selection: $selectedTestType) {
                ForEach(LactateTest.TestType.allCases, id: \.self) { type in
                    Text(type.rawValue).tag(type)
                }
            }
            .pickerStyle(.segmented)
            
            Picker("Metric", selection: $selectedMetric) {
                ForEach(Metric.allCases, id: \.self) { metric in
                    Text(metric.rawValue).tag(metric)
                }
            }
            .pickerStyle(.segmented)
            
            Picker("Zone System", selection: $selectedZoneSystem) {
                ForEach(ZoneSystem.allCases, id: \.self) { system in
                    Text(system.rawValue).tag(system)
                }
            }
            .pickerStyle(.menu)
        }
    }
    
    private var trendChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Threshold Progression")
                .font(.headline)
            
            Chart {
                ForEach(filteredTests) { test in
                    if let date = test.testDate {
                        switch selectedMetric {
                        case .intensity:
                            if test.lt1Intensity > 0 {
                                LineMark(
                                    x: .value("Date", date),
                                    y: .value("LT1", test.lt1Intensity)
                                )
                                .foregroundStyle(.green)
                                .symbol(.circle)
                                
                                PointMark(
                                    x: .value("Date", date),
                                    y: .value("LT1", test.lt1Intensity)
                                )
                                .foregroundStyle(.green)
                            }
                            
                            if test.lt2Intensity > 0 {
                                LineMark(
                                    x: .value("Date", date),
                                    y: .value("LT2", test.lt2Intensity)
                                )
                                .foregroundStyle(.orange)
                                .symbol(.square)
                                
                                PointMark(
                                    x: .value("Date", date),
                                    y: .value("LT2", test.lt2Intensity)
                                )
                                .foregroundStyle(.orange)
                            }
                            
                        case .heartRate:
                            if test.lt1HeartRate > 0 {
                                LineMark(
                                    x: .value("Date", date),
                                    y: .value("LT1", test.lt1HeartRate)
                                )
                                .foregroundStyle(.green)
                                .symbol(.circle)
                                
                                PointMark(
                                    x: .value("Date", date),
                                    y: .value("LT1", test.lt1HeartRate)
                                )
                                .foregroundStyle(.green)
                            }
                            
                            if test.lt2HeartRate > 0 {
                                LineMark(
                                    x: .value("Date", date),
                                    y: .value("LT2", test.lt2HeartRate)
                                )
                                .foregroundStyle(.orange)
                                .symbol(.square)
                                
                                PointMark(
                                    x: .value("Date", date),
                                    y: .value("LT2", test.lt2HeartRate)
                                )
                                .foregroundStyle(.orange)
                            }
                        }
                    }
                }
            }
            .frame(height: 300)
            .chartXAxisLabel("Date")
            .chartYAxisLabel(selectedMetric.unit)
            .chartLegend(position: .top)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private var statisticsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Statistics")
                .font(.headline)
            
            HStack(spacing: 16) {
                StatCard(
                    title: "Latest LT1",
                    value: latestLT1Value,
                    unit: selectedMetric.unit,
                    color: .green
                )
                
                StatCard(
                    title: "Latest LT2",
                    value: latestLT2Value,
                    unit: selectedMetric.unit,
                    color: .orange
                )
            }
            
            HStack(spacing: 16) {
                StatCard(
                    title: "LT1 Change",
                    value: lt1Change,
                    unit: "%",
                    color: lt1Change >= 0 ? .green : .red
                )
                
                StatCard(
                    title: "LT2 Change",
                    value: lt2Change,
                    unit: "%",
                    color: lt2Change >= 0 ? .green : .red
                )
            }
        }
    }
    
    private var progressSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Training Zones (\(selectedZoneSystem.rawValue))")
                .font(.headline)
            
            if let latest = filteredTests.last {
                VStack(spacing: 8) {
                    ForEach(currentZones(for: latest), id: \.name) { zone in
                        TrainingZoneRow(
                            name: zone.name,
                            range: "\(Int(zone.lowerBound)) - \(Int(zone.upperBound))",
                            unit: selectedMetric.unit,
                            color: colorFromString(zone.color),
                            description: zone.description
                        )
                    }
                    
                    if selectedZoneSystem == .couzens || selectedZoneSystem == .touretski {
                        Text("Zone calculations based on methodologies from \"The Science of Maximal Athletic Development\" by Alan Couzens")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .italic()
                            .padding(.top, 8)
                            .onTapGesture {
                                if let url = URL(string: "https://alancouzens.substack.com/") {
                                    UIApplication.shared.open(url)
                                }
                            }
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
            }
        }
    }
    
    private func currentZones(for test: TestEntity) -> [TrainingZone] {
        switch selectedMetric {
        case .intensity:
            return TrainingZoneCalculator.calculateZones(
                lt1: test.lt1Intensity,
                lt2: test.lt2Intensity,
                system: selectedZoneSystem
            )
        case .heartRate:
            let maxHR = Int(Double(test.lt2HeartRate) * 1.1)
            return TrainingZoneCalculator.getHeartRateZones(
                lt1HR: Int(test.lt1HeartRate),
                lt2HR: Int(test.lt2HeartRate),
                maxHR: maxHR,
                system: selectedZoneSystem
            )
        }
    }
    
    private func colorFromString(_ colorName: String) -> Color {
        switch colorName {
        case "lightgray": return Color.gray.opacity(0.3)
        case "lightgreen": return Color.green.opacity(0.5)
        case "green": return .green
        case "yellow": return .yellow
        case "orange": return .orange
        case "red": return .red
        case "darkred": return Color.red.opacity(0.8)
        case "purple": return .purple
        case "lightblue": return Color.blue.opacity(0.3)
        default: return .blue
        }
    }
    
    private var latestLT1Value: Double {
        switch selectedMetric {
        case .intensity:
            return filteredTests.last?.lt1Intensity ?? 0
        case .heartRate:
            return Double(filteredTests.last?.lt1HeartRate ?? 0)
        }
    }
    
    private var latestLT2Value: Double {
        switch selectedMetric {
        case .intensity:
            return filteredTests.last?.lt2Intensity ?? 0
        case .heartRate:
            return Double(filteredTests.last?.lt2HeartRate ?? 0)
        }
    }
    
    private var lt1Change: Double {
        guard filteredTests.count >= 2 else { return 0 }
        let first = filteredTests.first!
        let last = filteredTests.last!
        
        let firstValue: Double
        let lastValue: Double
        
        switch selectedMetric {
        case .intensity:
            firstValue = first.lt1Intensity
            lastValue = last.lt1Intensity
        case .heartRate:
            firstValue = Double(first.lt1HeartRate)
            lastValue = Double(last.lt1HeartRate)
        }
        
        guard firstValue > 0 else { return 0 }
        return ((lastValue - firstValue) / firstValue) * 100
    }
    
    private var lt2Change: Double {
        guard filteredTests.count >= 2 else { return 0 }
        let first = filteredTests.first!
        let last = filteredTests.last!
        
        let firstValue: Double
        let lastValue: Double
        
        switch selectedMetric {
        case .intensity:
            firstValue = first.lt2Intensity
            lastValue = last.lt2Intensity
        case .heartRate:
            firstValue = Double(first.lt2HeartRate)
            lastValue = Double(last.lt2HeartRate)
        }
        
        guard firstValue > 0 else { return 0 }
        return ((lastValue - firstValue) / firstValue) * 100
    }
}