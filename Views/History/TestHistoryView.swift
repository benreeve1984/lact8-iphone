import SwiftUI
import CoreData

struct TestHistoryView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \TestEntity.testDate, ascending: false)],
        animation: .default)
    private var tests: FetchedResults<TestEntity>

    @State private var selectedTest: LactateTest?
    @State private var showingTestDetails = false
    @State private var testToDelete: IndexSet?
    @State private var showDeleteConfirmation = false
    
    var body: some View {
        NavigationView {
            List {
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
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 60)
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                } else {
                    ForEach(tests) { testEntity in
                        TestHistoryRow(testEntity: testEntity)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                HapticManager.selection()
                                if let data = testEntity.testData,
                                   let test = try? JSONDecoder().decode(LactateTest.self, from: data) {
                                    selectedTest = test
                                    showingTestDetails = true
                                }
                            }
                    }
                    .onDelete { offsets in
                        testToDelete = offsets
                        showDeleteConfirmation = true
                    }
                }
            }
            .navigationTitle("Test History")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showingTestDetails) {
                if let test = selectedTest {
                    TestDetailView(test: test)
                }
            }
            .alert("Delete Test?", isPresented: $showDeleteConfirmation) {
                Button("Cancel", role: .cancel) {
                    testToDelete = nil
                }
                Button("Delete", role: .destructive) {
                    if let offsets = testToDelete {
                        deleteTests(offsets: offsets)
                    }
                }
            } message: {
                Text("This test will be permanently deleted. This action cannot be undone.")
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }

    private func deleteTests(offsets: IndexSet) {
        HapticManager.warning()
        withAnimation {
            offsets.map { tests[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                print("Error deleting test: \(error)")
            }
        }
        testToDelete = nil
    }
}

struct TestHistoryRow: View {
    let testEntity: TestEntity
    
    private var test: LactateTest? {
        guard let data = testEntity.testData else { return nil }
        return try? JSONDecoder().decode(LactateTest.self, from: data)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Label(testEntity.testType ?? "Unknown", systemImage: iconForTestType)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Text(testEntity.testDate ?? Date(), style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            HStack(spacing: 20) {
                if testEntity.lt1Intensity > 0 {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("LT1")
                            .font(.caption2)
                            .foregroundColor(.green)
                        Text("\(Int(testEntity.lt1Intensity)) W")
                            .font(.caption)
                            .fontWeight(.medium)
                        Text("\(testEntity.lt1HeartRate) bpm")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                
                if testEntity.lt2Intensity > 0 {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("LT2")
                            .font(.caption2)
                            .foregroundColor(.orange)
                        Text("\(Int(testEntity.lt2Intensity)) W")
                            .font(.caption)
                            .fontWeight(.medium)
                        Text("\(testEntity.lt2HeartRate) bpm")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
            }
        }
        .padding(.vertical, 4)
    }
    
    private var iconForTestType: String {
        switch testEntity.testType {
        case "Cycling":
            return "bicycle"
        case "Running":
            return "figure.run"
        default:
            return "chart.xyaxis.line"
        }
    }
}