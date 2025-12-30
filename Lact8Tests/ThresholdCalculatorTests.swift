import XCTest
@testable import Lact8

final class ThresholdCalculatorTests: XCTestCase {

    var calculator: ThresholdCalculator!

    override func setUp() {
        super.setUp()
        calculator = ThresholdCalculator()
    }

    override func tearDown() {
        calculator = nil
        super.tearDown()
    }

    // MARK: - Helper Methods

    private func createStep(number: Int, intensity: Double, heartRate: Int, lactate: Double) -> TestStep {
        var step = TestStep(stepNumber: number)
        step.intensity = String(intensity)
        step.heartRate = String(heartRate)
        step.lactate = String(lactate)
        return step
    }

    // MARK: - Minimum Steps Tests

    func testCalculate_withFewerThanThreeSteps_returnsNilThresholds() {
        let steps = [
            createStep(number: 1, intensity: 100, heartRate: 120, lactate: 1.0),
            createStep(number: 2, intensity: 150, heartRate: 140, lactate: 1.5)
        ]

        let result = calculator.calculate(from: steps)

        XCTAssertNil(result.lt1, "LT1 should be nil with fewer than 3 steps")
        XCTAssertNil(result.lt2, "LT2 should be nil with fewer than 3 steps")
    }

    func testCalculate_withExactlyThreeSteps_canCalculate() {
        let steps = [
            createStep(number: 1, intensity: 100, heartRate: 120, lactate: 1.0),
            createStep(number: 2, intensity: 150, heartRate: 140, lactate: 1.5),
            createStep(number: 3, intensity: 200, heartRate: 160, lactate: 3.0)
        ]

        let result = calculator.calculate(from: steps)

        XCTAssertNotNil(result.lt1, "LT1 should be calculated with 3 valid steps")
    }

    // MARK: - LT1 Detection Tests

    func testCalculate_withClearLactateRise_detectsLT1() {
        // Step 2 to 3 has a rise of 1.5 mmol/L (> 0.3 threshold)
        let steps = [
            createStep(number: 1, intensity: 100, heartRate: 120, lactate: 1.0),
            createStep(number: 2, intensity: 150, heartRate: 140, lactate: 1.2),
            createStep(number: 3, intensity: 200, heartRate: 160, lactate: 2.7),
            createStep(number: 4, intensity: 250, heartRate: 175, lactate: 5.0)
        ]

        let result = calculator.calculate(from: steps)

        XCTAssertNotNil(result.lt1)
        // LT1 should be the point BEFORE the rise (step 2)
        XCTAssertEqual(result.lt1?.intensity, 150, "LT1 intensity should be at step 2")
        XCTAssertEqual(result.lt1?.heartRate, 140, "LT1 heart rate should be at step 2")
        XCTAssertEqual(result.lt1?.lactate, 1.2, "LT1 lactate should be at step 2")
    }

    func testCalculate_withNoClearRise_useFallbackThreshold() {
        // Gradual lactate rise, never exceeds 0.3 in single step
        // but crosses 2.0 mmol/L
        let steps = [
            createStep(number: 1, intensity: 100, heartRate: 120, lactate: 1.0),
            createStep(number: 2, intensity: 150, heartRate: 140, lactate: 1.2),
            createStep(number: 3, intensity: 200, heartRate: 155, lactate: 1.5),
            createStep(number: 4, intensity: 250, heartRate: 165, lactate: 1.8),
            createStep(number: 5, intensity: 300, heartRate: 175, lactate: 2.2)
        ]

        let result = calculator.calculate(from: steps)

        XCTAssertNotNil(result.lt1, "LT1 should be found using 2.0 fallback")
        // Should interpolate to 2.0 mmol/L level
        XCTAssertEqual(result.lt1?.lactate, 2.0, accuracy: 0.01)
    }

    func testCalculate_withFlatLactateCurve_returnsNilLT1() {
        // All lactate values below 2.0, no rise > 0.3
        let steps = [
            createStep(number: 1, intensity: 100, heartRate: 120, lactate: 1.0),
            createStep(number: 2, intensity: 150, heartRate: 140, lactate: 1.1),
            createStep(number: 3, intensity: 200, heartRate: 160, lactate: 1.2)
        ]

        let result = calculator.calculate(from: steps)

        XCTAssertNil(result.lt1, "LT1 should be nil with flat lactate curve")
    }

    // MARK: - LT2 Detection Tests

    func testCalculate_withValidData_detectsLT2() {
        let steps = [
            createStep(number: 1, intensity: 100, heartRate: 120, lactate: 1.0),
            createStep(number: 2, intensity: 150, heartRate: 140, lactate: 1.5),
            createStep(number: 3, intensity: 200, heartRate: 155, lactate: 2.5),
            createStep(number: 4, intensity: 250, heartRate: 170, lactate: 4.5),
            createStep(number: 5, intensity: 300, heartRate: 185, lactate: 8.0)
        ]

        let result = calculator.calculate(from: steps)

        XCTAssertNotNil(result.lt1)
        XCTAssertNotNil(result.lt2, "LT2 should be detected with proper lactate curve")
        XCTAssertGreaterThan(result.lt2!.intensity, result.lt1!.intensity,
                             "LT2 should be at higher intensity than LT1")
    }

    func testCalculate_withNoLT1_returnsNilLT2() {
        // Flat curve means no LT1, therefore no LT2
        let steps = [
            createStep(number: 1, intensity: 100, heartRate: 120, lactate: 1.0),
            createStep(number: 2, intensity: 150, heartRate: 140, lactate: 1.1),
            createStep(number: 3, intensity: 200, heartRate: 160, lactate: 1.2)
        ]

        let result = calculator.calculate(from: steps)

        XCTAssertNil(result.lt2, "LT2 should be nil when LT1 cannot be determined")
    }

    // MARK: - Sorting Tests

    func testCalculate_withUnsortedSteps_sortsAutomatically() {
        // Steps provided out of order
        let steps = [
            createStep(number: 3, intensity: 200, heartRate: 160, lactate: 2.5),
            createStep(number: 1, intensity: 100, heartRate: 120, lactate: 1.0),
            createStep(number: 4, intensity: 250, heartRate: 175, lactate: 5.0),
            createStep(number: 2, intensity: 150, heartRate: 140, lactate: 1.5)
        ]

        let result = calculator.calculate(from: steps)

        XCTAssertNotNil(result.lt1, "Should calculate LT1 even with unsorted input")
    }

    // MARK: - Edge Cases

    func testCalculate_withEmptySteps_returnsNilThresholds() {
        let result = calculator.calculate(from: [])

        XCTAssertNil(result.lt1)
        XCTAssertNil(result.lt2)
    }

    func testCalculate_withTypicalCyclingTest_producesRealisticResults() {
        // Realistic cycling test data
        let steps = [
            createStep(number: 1, intensity: 150, heartRate: 115, lactate: 0.8),
            createStep(number: 2, intensity: 180, heartRate: 125, lactate: 1.0),
            createStep(number: 3, intensity: 210, heartRate: 138, lactate: 1.4),
            createStep(number: 4, intensity: 240, heartRate: 152, lactate: 2.2),
            createStep(number: 5, intensity: 270, heartRate: 165, lactate: 3.8),
            createStep(number: 6, intensity: 300, heartRate: 178, lactate: 6.5)
        ]

        let result = calculator.calculate(from: steps)

        XCTAssertNotNil(result.lt1)
        XCTAssertNotNil(result.lt2)

        // LT1 should be around 210W (before lactate starts rising significantly)
        XCTAssertGreaterThanOrEqual(result.lt1!.intensity, 180)
        XCTAssertLessThanOrEqual(result.lt1!.intensity, 240)

        // LT2 should be higher than LT1
        XCTAssertGreaterThan(result.lt2!.intensity, result.lt1!.intensity)
    }
}
