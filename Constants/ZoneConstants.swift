import Foundation

/// Constants for training zone calculations
/// Based on Touretski's 7-zone and Couzens' 8-zone systems
enum ZoneConstants {

    // MARK: - Touretski System Multipliers (Intensity)

    enum Touretski {
        /// Recovery zone upper bound as fraction of LT1 (85%)
        static let recoveryUpperMultiplier: Double = 0.85

        /// Aerobic threshold zone midpoint factor (50% between LT1 and LT2)
        static let thresholdMidpointFactor: Double = 0.5

        /// Lactate tolerance upper bound as fraction of LT2 (105%)
        static let lactateToleranceMultiplier: Double = 1.05

        /// Speed zone lower bound as fraction of LT1 (70%)
        static let speedLowerMultiplier: Double = 0.7
    }

    // MARK: - Couzens System Divisor

    enum Couzens {
        /// Divisor to calculate zone offset from LT1-LT2 range
        /// Results in approximately 10bpm equivalent in power terms
        static let zoneOffsetDivisor: Double = 4.0

        /// Multiplier for Zone 6 lower bound offset from max (50% of zone offset)
        static let zone6LowerOffsetMultiplier: Double = 0.5
    }

    // MARK: - Heart Rate Offsets (bpm)

    enum HeartRate {
        /// Standard zone offset (bpm) - used for most zone boundaries
        static let standardOffset: Int = 10

        /// Large zone offset (bpm) - used for recovery zones
        static let largeOffset: Int = 20

        /// Small zone offset (bpm) - used near max HR
        static let smallOffset: Int = 5

        /// Speed zone upper offset from LT2 (bpm)
        static let speedUpperOffset: Int = 15
    }
}
