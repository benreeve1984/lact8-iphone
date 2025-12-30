import Foundation

struct TestStep: Identifiable, Codable {
    let id: UUID
    var stepNumber: Int
    var intensity: String = ""
    var heartRate: String = ""
    var lactate: String = ""
    
    init(id: UUID = UUID(), stepNumber: Int, intensity: String = "", heartRate: String = "", lactate: String = "") {
        self.id = id
        self.stepNumber = stepNumber
        self.intensity = intensity
        self.heartRate = heartRate
        self.lactate = lactate
    }
    
    var intensityValue: Double? {
        Double(intensity)
    }
    
    var heartRateValue: Int? {
        Int(heartRate)
    }
    
    var lactateValue: Double? {
        Double(lactate)
    }
    
    var isValid: Bool {
        intensityValue != nil && heartRateValue != nil && lactateValue != nil
    }
}