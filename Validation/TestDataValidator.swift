import Foundation

enum ValidationError: LocalizedError {
    case intensityOutOfRange(value: Double, range: ClosedRange<Double>)
    case heartRateOutOfRange(value: Int, range: ClosedRange<Int>)
    case lactateOutOfRange(value: Double, range: ClosedRange<Double>)
    case intensityNotIncreasing(stepNumber: Int)
    case insufficientSteps(count: Int, required: Int)
    case insufficientIntensityRange(range: Double, minimumRequired: Double)

    var errorDescription: String? {
        switch self {
        case .intensityOutOfRange(let value, let range):
            return "Intensity \(Int(value)) is outside valid range (\(Int(range.lowerBound))-\(Int(range.upperBound)))"
        case .heartRateOutOfRange(let value, let range):
            return "Heart rate \(value) is outside valid range (\(range.lowerBound)-\(range.upperBound) bpm)"
        case .lactateOutOfRange(let value, let range):
            return "Lactate \(String(format: "%.1f", value)) is outside valid range (\(String(format: "%.1f", range.lowerBound))-\(String(format: "%.1f", range.upperBound)) mmol/L)"
        case .intensityNotIncreasing(let stepNumber):
            return "Step \(stepNumber) intensity should be higher than previous step"
        case .insufficientSteps(let count, let required):
            return "Need at least \(required) valid steps (currently have \(count))"
        case .insufficientIntensityRange(let range, let minimumRequired):
            return "Intensity range (\(Int(range))) too narrow. Need at least \(Int(minimumRequired)) difference between lowest and highest."
        }
    }
}

struct ValidationResult {
    let isValid: Bool
    let errors: [ValidationError]
    let warnings: [String]

    static var valid: ValidationResult {
        ValidationResult(isValid: true, errors: [], warnings: [])
    }

    static func invalid(errors: [ValidationError], warnings: [String] = []) -> ValidationResult {
        ValidationResult(isValid: false, errors: errors, warnings: warnings)
    }
}

enum TestDataValidator {

    // MARK: - Validation Ranges

    enum Ranges {
        static let cyclingIntensity: ClosedRange<Double> = 50...2500   // Watts
        static let runningIntensity: ClosedRange<Double> = 5...50     // km/h or min/km
        static let heartRate: ClosedRange<Int> = 30...250             // bpm
        static let lactate: ClosedRange<Double> = 0.1...30.0          // mmol/L
        static let minimumIntensitySpan: Double = 50                  // Minimum difference between min/max intensity
    }

    // MARK: - Single Value Validation

    static func validateIntensity(_ value: Double, testType: LactateTest.TestType) -> ValidationError? {
        let range = testType == .running ? Ranges.runningIntensity : Ranges.cyclingIntensity
        guard range.contains(value) else {
            return .intensityOutOfRange(value: value, range: range)
        }
        return nil
    }

    static func validateHeartRate(_ value: Int) -> ValidationError? {
        guard Ranges.heartRate.contains(value) else {
            return .heartRateOutOfRange(value: value, range: Ranges.heartRate)
        }
        return nil
    }

    static func validateLactate(_ value: Double) -> ValidationError? {
        guard Ranges.lactate.contains(value) else {
            return .lactateOutOfRange(value: value, range: Ranges.lactate)
        }
        return nil
    }

    // MARK: - Step Validation

    static func validateStep(_ step: TestStep, testType: LactateTest.TestType) -> [ValidationError] {
        var errors: [ValidationError] = []

        if let intensity = step.intensityValue {
            if let error = validateIntensity(intensity, testType: testType) {
                errors.append(error)
            }
        }

        if let heartRate = step.heartRateValue {
            if let error = validateHeartRate(heartRate) {
                errors.append(error)
            }
        }

        if let lactate = step.lactateValue {
            if let error = validateLactate(lactate) {
                errors.append(error)
            }
        }

        return errors
    }

    // MARK: - Full Test Validation

    static func validateTest(_ test: LactateTest) -> ValidationResult {
        var errors: [ValidationError] = []
        var warnings: [String] = []

        let validSteps = test.validSteps

        // Check minimum step count
        if validSteps.count < ThresholdConstants.minimumStepsRequired {
            errors.append(.insufficientSteps(
                count: validSteps.count,
                required: ThresholdConstants.minimumStepsRequired
            ))
        }

        // Validate each step
        for step in validSteps {
            let stepErrors = validateStep(step, testType: test.testType)
            errors.append(contentsOf: stepErrors)
        }

        // Check intensity progression (should be increasing)
        let intensities = validSteps.compactMap { $0.intensityValue }
        for i in 1..<intensities.count {
            if intensities[i] <= intensities[i - 1] {
                errors.append(.intensityNotIncreasing(stepNumber: i + 1))
            }
        }

        // Check intensity range span
        if let minIntensity = intensities.min(),
           let maxIntensity = intensities.max() {
            let span = maxIntensity - minIntensity
            if span < Ranges.minimumIntensitySpan {
                errors.append(.insufficientIntensityRange(
                    range: span,
                    minimumRequired: Ranges.minimumIntensitySpan
                ))
            }
        }

        // Add warnings for unusual but valid data
        let lactateValues = validSteps.compactMap { $0.lactateValue }
        if let maxLactate = lactateValues.max(), maxLactate < 4.0 {
            warnings.append("Maximum lactate is low (\(String(format: "%.1f", maxLactate)) mmol/L). Ensure test was completed at high enough intensity.")
        }

        if errors.isEmpty {
            return .valid
        } else {
            return .invalid(errors: errors, warnings: warnings)
        }
    }

    // MARK: - Quick Validation Checks

    static func isValidIntensity(_ value: String, testType: LactateTest.TestType) -> Bool {
        guard let intensity = Double(value.replacingOccurrences(of: ",", with: ".")) else { return false }
        return validateIntensity(intensity, testType: testType) == nil
    }

    static func isValidHeartRate(_ value: String) -> Bool {
        guard let hr = Int(value) else { return false }
        return validateHeartRate(hr) == nil
    }

    static func isValidLactate(_ value: String) -> Bool {
        guard let lactate = Double(value.replacingOccurrences(of: ",", with: ".")) else { return false }
        return validateLactate(lactate) == nil
    }
}
