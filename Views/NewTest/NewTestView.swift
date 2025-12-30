import SwiftUI

struct NewTestView: View {
    @StateObject private var viewModel = NewTestViewModel()
    @FocusState private var focusedField: Field?
    @State private var showingResults = false
    
    enum Field: Hashable {
        case intensity(Int)
        case heartRate(Int)
        case lactate(Int)
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                testTypeSection
                headerSection
                
                ScrollView {
                    VStack(spacing: 16) {
                        stepsSection
                        actionButtons
                    }
                    .padding()
                    .frame(maxWidth: 600)
                    .frame(maxWidth: .infinity)
                }
                .scrollDismissesKeyboard(.interactively)
            }
            .navigationTitle("New Test")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showingResults) {
                TestResultsView(test: viewModel.currentTest)
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    private var headerSection: some View {
        HStack {
            Text("Step")
                .frame(width: 50)
            Text("Intensity")
                .frame(maxWidth: .infinity)
            Text("HR")
                .frame(maxWidth: .infinity)
            Text("Lactate")
                .frame(maxWidth: .infinity)
        }
        .font(.caption)
        .foregroundColor(.secondary)
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
    }
    
    private var testTypeSection: some View {
        Picker("Test Type", selection: $viewModel.currentTest.testType) {
            ForEach(LactateTest.TestType.allCases, id: \.self) { type in
                Text(type.rawValue).tag(type)
            }
        }
        .pickerStyle(.segmented)
        .padding(.horizontal)
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
    }
    
    private var stepsSection: some View {
        VStack(spacing: 12) {
            ForEach(viewModel.currentTest.steps.indices, id: \.self) { index in
                StepRow(
                    step: $viewModel.currentTest.steps[index],
                    focusedField: _focusedField,
                    index: index,
                    onDelete: {
                        viewModel.deleteStep(at: index)
                    }
                )
            }
        }
    }
    
    private var actionButtons: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                Button(action: viewModel.addStep) {
                    Label("Add Step", systemImage: "plus.circle")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                
                Button(action: viewModel.clearAllValues) {
                    Label("Clear All", systemImage: "xmark.circle")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .tint(.red)
            }
            
            Button(action: {
                viewModel.calculateThresholds()
                showingResults = true
            }) {
                Text("Calculate Thresholds")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .disabled(!viewModel.currentTest.canCalculateThresholds)
        }
        .padding(.top)
    }
}

struct StepRow: View {
    @Binding var step: TestStep
    @FocusState var focusedField: NewTestView.Field?
    let index: Int
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 8) {
            Text("\(step.stepNumber)")
                .font(.system(.body, design: .monospaced))
                .frame(width: 30)
                .foregroundColor(.secondary)
            
            TextField("Pow/Spd", text: $step.intensity)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.decimalPad)
                .focused($focusedField, equals: .intensity(index))
                .font(.system(size: 14))
            
            TextField("bpm", text: $step.heartRate)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.numberPad)
                .focused($focusedField, equals: .heartRate(index))
                .font(.system(size: 14))
            
            TextField("mmol/L", text: $step.lactate)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.decimalPad)
                .focused($focusedField, equals: .lactate(index))
                .font(.system(size: 14))
            
            Button(action: onDelete) {
                Image(systemName: "minus.circle.fill")
                    .foregroundColor(.red)
            }
            .buttonStyle(.plain)
        }
    }
}