import Foundation

struct LactateTest: Identifiable, Codable {
    let id: UUID
    let testDate: Date
    var testType: TestType = .cycling
    var steps: [TestStep] = []
    var lt1Intensity: Double?
    var lt1HeartRate: Int?
    var lt1Lactate: Double?
    var lt2Intensity: Double?
    var lt2HeartRate: Int?
    var lt2Lactate: Double?
    var notes: String = ""
    var customSportName: String = ""
    
    init(id: UUID = UUID(), testDate: Date, testType: TestType = .cycling) {
        self.id = id
        self.testDate = testDate
        self.testType = testType
    }
    
    enum TestType: String, CaseIterable, Codable {
        case cycling = "Cycling"
        case running = "Running"
        case other = "Other"
        
        var displayName: String {
            return self.rawValue
        }
    }
    
    var validSteps: [TestStep] {
        steps.filter { $0.isValid }
    }
    
    var canCalculateThresholds: Bool {
        validSteps.count >= 3
    }
}