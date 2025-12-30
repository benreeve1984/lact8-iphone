import XCTest
@testable import Lact8

final class TrainingZoneCalculatorTests: XCTestCase {

    // MARK: - Test Data

    let lt1: Double = 200  // watts
    let lt2: Double = 280  // watts
    let lt1HR: Int = 145   // bpm
    let lt2HR: Int = 172   // bpm
    let maxHR: Int = 190   // bpm

    // MARK: - Three Zone System Tests

    func testThreeZoneSystem_returnsThreeZones() {
        let zones = TrainingZoneCalculator.calculateZones(lt1: lt1, lt2: lt2, system: .threeZone)

        XCTAssertEqual(zones.count, 3, "Three zone system should return 3 zones")
    }

    func testThreeZoneSystem_hasCorrectBoundaries() {
        let zones = TrainingZoneCalculator.calculateZones(lt1: lt1, lt2: lt2, system: .threeZone)

        // Zone 1: 0 to LT1
        XCTAssertEqual(zones[0].lowerBound, 0)
        XCTAssertEqual(zones[0].upperBound, lt1)

        // Zone 2: LT1 to LT2
        XCTAssertEqual(zones[1].lowerBound, lt1)
        XCTAssertEqual(zones[1].upperBound, lt2)

        // Zone 3: LT2 to max (LT2 * 1.15)
        XCTAssertEqual(zones[2].lowerBound, lt2)
        XCTAssertEqual(zones[2].upperBound, lt2 * ThresholdConstants.maxIntensityFromLT2Multiplier)
    }

    func testThreeZoneSystem_hasCorrectNames() {
        let zones = TrainingZoneCalculator.calculateZones(lt1: lt1, lt2: lt2, system: .threeZone)

        XCTAssertTrue(zones[0].name.contains("Easy"))
        XCTAssertTrue(zones[1].name.contains("Moderate"))
        XCTAssertTrue(zones[2].name.contains("Hard"))
    }

    // MARK: - Touretski System Tests

    func testTouretskiSystem_returnsSevenZones() {
        let zones = TrainingZoneCalculator.calculateZones(lt1: lt1, lt2: lt2, system: .touretski)

        XCTAssertEqual(zones.count, 7, "Touretski system should return 7 zones")
    }

    func testTouretskiSystem_hasExpectedZoneNames() {
        let zones = TrainingZoneCalculator.calculateZones(lt1: lt1, lt2: lt2, system: .touretski)

        let expectedNames = ["A1", "A2", "AT", "MVO2", "LT", "LP", "SP"]

        for expectedName in expectedNames {
            XCTAssertTrue(zones.contains { $0.name.contains(expectedName) },
                          "Should contain zone named \(expectedName)")
        }
    }

    func testTouretskiSystem_recoveryZoneUsesCorrectMultiplier() {
        let zones = TrainingZoneCalculator.calculateZones(lt1: lt1, lt2: lt2, system: .touretski)

        let recoveryZone = zones[0]
        let expectedUpper = lt1 * ZoneConstants.Touretski.recoveryUpperMultiplier

        XCTAssertEqual(recoveryZone.upperBound, expectedUpper, accuracy: 0.1)
    }

    // MARK: - Couzens System Tests

    func testCouzensSystem_returnsEightZones() {
        let zones = TrainingZoneCalculator.calculateZones(lt1: lt1, lt2: lt2, system: .couzens)

        XCTAssertEqual(zones.count, 8, "Couzens system should return 8 zones")
    }

    func testCouzensSystem_hasZonesZeroToSeven() {
        let zones = TrainingZoneCalculator.calculateZones(lt1: lt1, lt2: lt2, system: .couzens)

        for i in 0...7 {
            XCTAssertTrue(zones.contains { $0.name.contains("Zone \(i)") },
                          "Should contain Zone \(i)")
        }
    }

    func testCouzensSystem_zoneOffsetCalculation() {
        let zones = TrainingZoneCalculator.calculateZones(lt1: lt1, lt2: lt2, system: .couzens)

        // Zone offset should be (LT2 - LT1) / 4
        let expectedOffset = (lt2 - lt1) / ZoneConstants.Couzens.zoneOffsetDivisor

        // Zone 0 upper should be LT1 - offset
        XCTAssertEqual(zones[0].upperBound, max(0, lt1 - expectedOffset), accuracy: 0.1)

        // Zone 1 should span from (LT1 - offset) to LT1
        XCTAssertEqual(zones[1].upperBound, lt1, accuracy: 0.1)
    }

    // MARK: - Heart Rate Zone Tests

    func testHeartRateZones_threeZone_returnsThreeZones() {
        let zones = TrainingZoneCalculator.getHeartRateZones(
            lt1HR: lt1HR, lt2HR: lt2HR, maxHR: maxHR, system: .threeZone
        )

        XCTAssertEqual(zones.count, 3)
    }

    func testHeartRateZones_threeZone_hasCorrectBoundaries() {
        let zones = TrainingZoneCalculator.getHeartRateZones(
            lt1HR: lt1HR, lt2HR: lt2HR, maxHR: maxHR, system: .threeZone
        )

        XCTAssertEqual(zones[0].upperBound, Double(lt1HR))
        XCTAssertEqual(zones[1].lowerBound, Double(lt1HR))
        XCTAssertEqual(zones[1].upperBound, Double(lt2HR))
        XCTAssertEqual(zones[2].lowerBound, Double(lt2HR))
        XCTAssertEqual(zones[2].upperBound, Double(maxHR))
    }

    func testHeartRateZones_touretski_usesStandardOffsets() {
        let zones = TrainingZoneCalculator.getHeartRateZones(
            lt1HR: lt1HR, lt2HR: lt2HR, maxHR: maxHR, system: .touretski
        )

        let stdOffset = Double(ZoneConstants.HeartRate.standardOffset)
        let lgOffset = Double(ZoneConstants.HeartRate.largeOffset)

        // A1 zone: lt1 - 20 to lt1 - 10
        XCTAssertEqual(zones[0].lowerBound, Double(lt1HR) - lgOffset, accuracy: 0.1)
        XCTAssertEqual(zones[0].upperBound, Double(lt1HR) - stdOffset, accuracy: 0.1)

        // A2 zone: lt1 - 10 to lt1
        XCTAssertEqual(zones[1].lowerBound, Double(lt1HR) - stdOffset, accuracy: 0.1)
        XCTAssertEqual(zones[1].upperBound, Double(lt1HR), accuracy: 0.1)
    }

    func testHeartRateZones_couzens_usesStandardOffsets() {
        let zones = TrainingZoneCalculator.getHeartRateZones(
            lt1HR: lt1HR, lt2HR: lt2HR, maxHR: maxHR, system: .couzens
        )

        let stdOffset = Double(ZoneConstants.HeartRate.standardOffset)

        // Zone 0: 0 to lt1 - 10
        XCTAssertEqual(zones[0].upperBound, Double(lt1HR) - stdOffset, accuracy: 0.1)

        // Zone 1: lt1 - 10 to lt1
        XCTAssertEqual(zones[1].upperBound, Double(lt1HR), accuracy: 0.1)
    }

    // MARK: - Edge Cases

    func testCalculateZones_withZeroLT1_handlesGracefully() {
        let zones = TrainingZoneCalculator.calculateZones(lt1: 0, lt2: 280, system: .threeZone)

        // Should still produce zones without crashing
        XCTAssertEqual(zones.count, 3)
    }

    func testCalculateZones_withEqualLT1AndLT2_handlesGracefully() {
        let zones = TrainingZoneCalculator.calculateZones(lt1: 200, lt2: 200, system: .couzens)

        // Should produce zones without crashing (zone offset will be 0)
        XCTAssertEqual(zones.count, 8)
    }

    // MARK: - Color Tests

    func testZones_haveValidColors() {
        let zones = TrainingZoneCalculator.calculateZones(lt1: lt1, lt2: lt2, system: .touretski)

        let validColors = ["lightgray", "lightgreen", "green", "yellow", "orange", "red", "darkred", "purple", "lightblue"]

        for zone in zones {
            XCTAssertTrue(validColors.contains(zone.color),
                          "Zone '\(zone.name)' has invalid color '\(zone.color)'")
        }
    }

    // MARK: - Zone Continuity Tests

    func testThreeZoneSystem_zonesAreContinuous() {
        let zones = TrainingZoneCalculator.calculateZones(lt1: lt1, lt2: lt2, system: .threeZone)

        // Each zone's upper bound should equal the next zone's lower bound
        for i in 0..<(zones.count - 1) {
            XCTAssertEqual(zones[i].upperBound, zones[i + 1].lowerBound, accuracy: 0.1,
                           "Zone \(i) upper should equal Zone \(i+1) lower")
        }
    }
}
