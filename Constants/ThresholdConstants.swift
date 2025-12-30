import Foundation

/// Constants for lactate threshold calculations
/// Based on methodologies from "The Science of Maximal Athletic Development" by Alan Couzens
enum ThresholdConstants {

    // MARK: - LT1 Detection

    /// Minimum lactate rise (mmol/L) to indicate first lactate threshold (LT1)
    /// A rise greater than this value between consecutive steps suggests the aerobic threshold
    static let lactateRiseThreshold: Double = 0.3

    /// Fallback lactate level (mmol/L) used when no clear lactate rise is detected
    /// The 2.0 mmol/L level is a commonly used fixed threshold in sports science
    static let fallbackLactateLevel: Double = 2.0

    // MARK: - Calculation Requirements

    /// Minimum number of test steps required to calculate thresholds
    /// Fewer steps don't provide enough data points for reliable threshold detection
    static let minimumStepsRequired: Int = 3

    // MARK: - Zone Estimation

    /// Multiplier to estimate maximum intensity from LT2
    /// Used when actual max is not available (e.g., max ≈ LT2 × 1.15)
    static let maxIntensityFromLT2Multiplier: Double = 1.15
}
