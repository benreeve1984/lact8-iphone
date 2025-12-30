import SwiftUI
import CoreData

class NewTestViewModel: ObservableObject {
    @Published var currentTest: LactateTest
    
    init() {
        var test = LactateTest(testDate: Date())
        test.steps = (1...5).map { TestStep(stepNumber: $0) }
        self.currentTest = test
    }
    
    func addStep() {
        let newStep = TestStep(stepNumber: currentTest.steps.count + 1)
        currentTest.steps.append(newStep)
    }
    
    func deleteStep(at index: Int) {
        guard currentTest.steps.count > 3 else { return }
        currentTest.steps.remove(at: index)
        updateStepNumbers()
    }
    
    private func updateStepNumbers() {
        for i in 0..<currentTest.steps.count {
            currentTest.steps[i].stepNumber = i + 1
        }
    }
    
    func clearAllValues() {
        for i in 0..<currentTest.steps.count {
            currentTest.steps[i].intensity = ""
            currentTest.steps[i].heartRate = ""
            currentTest.steps[i].lactate = ""
        }
    }
    
    func calculateThresholds() {
        let calculator = ThresholdCalculator()
        let result = calculator.calculate(from: currentTest.validSteps)
        
        currentTest.lt1Intensity = result.lt1?.intensity
        currentTest.lt1HeartRate = result.lt1?.heartRate
        currentTest.lt1Lactate = result.lt1?.lactate
        
        currentTest.lt2Intensity = result.lt2?.intensity
        currentTest.lt2HeartRate = result.lt2?.heartRate
        currentTest.lt2Lactate = result.lt2?.lactate
    }
    
    @discardableResult
    func saveTest(context: NSManagedObjectContext) -> TestEntity? {
        let entity = TestEntity(context: context)
        entity.testId = currentTest.id
        entity.testDate = currentTest.testDate
        entity.testType = currentTest.testType.rawValue
        entity.lt1Intensity = currentTest.lt1Intensity ?? 0
        entity.lt1HeartRate = Int32(currentTest.lt1HeartRate ?? 0)
        entity.lt2Intensity = currentTest.lt2Intensity ?? 0
        entity.lt2HeartRate = Int32(currentTest.lt2HeartRate ?? 0)

        if let encoded = try? JSONEncoder().encode(currentTest) {
            entity.testData = encoded
        }

        do {
            try context.save()
            HapticManager.success()
            return entity
        } catch {
            HapticManager.error()
            print("Error saving test: \(error)")
            return nil
        }
    }
}