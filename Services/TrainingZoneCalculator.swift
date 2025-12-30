import Foundation

public struct TrainingZone {
    let name: String
    let lowerBound: Double
    let upperBound: Double
    let color: String
    let description: String
}

public enum ZoneSystem: String, CaseIterable {
    case threeZone = "3-Zone (Simple)"
    case touretski = "7-Zone (Touretski)"
    case couzens = "8-Zone (Couzens)"
}

/// Training zone calculations based on methodologies described in
/// "The Science of Maximal Athletic Development" by Alan Couzens
/// https://alancouzens.substack.com/
/// 
/// Includes Gennadi Touretski's 7-zone system (used with Olympic champion Alex Popov)
/// and Alan Couzens' 8-zone system with individualized thresholds
class TrainingZoneCalculator {
    
    static func calculateZones(lt1: Double, lt2: Double, system: ZoneSystem) -> [TrainingZone] {
        switch system {
        case .threeZone:
            return calculateThreeZoneSystem(lt1: lt1, lt2: lt2)
        case .touretski:
            return calculateTouretskiSystem(lt1: lt1, lt2: lt2)
        case .couzens:
            return calculateCouzensSystem(lt1: lt1, lt2: lt2)
        }
    }
    
    private static func calculateThreeZoneSystem(lt1: Double, lt2: Double) -> [TrainingZone] {
        let maxEstimate = lt2 * ThresholdConstants.maxIntensityFromLT2Multiplier

        return [
            TrainingZone(
                name: "Zone 1 - Easy",
                lowerBound: 0,
                upperBound: lt1,
                color: "green",
                description: "Below first threshold - Easy aerobic work"
            ),
            TrainingZone(
                name: "Zone 2 - Moderate",
                lowerBound: lt1,
                upperBound: lt2,
                color: "yellow",
                description: "Between thresholds - Steady/threshold work"
            ),
            TrainingZone(
                name: "Zone 3 - Hard",
                lowerBound: lt2,
                upperBound: maxEstimate,
                color: "red",
                description: "Above second threshold - VO2max/anaerobic work"
            )
        ]
    }
    
    private static func calculateTouretskiSystem(lt1: Double, lt2: Double) -> [TrainingZone] {
        let maxEstimate = lt2 * ThresholdConstants.maxIntensityFromLT2Multiplier
        let recoveryUpper = lt1 * ZoneConstants.Touretski.recoveryUpperMultiplier
        let thresholdMid = lt1 + (lt2 - lt1) * ZoneConstants.Touretski.thresholdMidpointFactor
        let lactateToleranceUpper = lt2 * ZoneConstants.Touretski.lactateToleranceMultiplier
        let speedLower = lt1 * ZoneConstants.Touretski.speedLowerMultiplier

        return [
            TrainingZone(
                name: "A1 - Recovery",
                lowerBound: 0,
                upperBound: recoveryUpper,
                color: "lightblue",
                description: "Recovery pace (1-2mmol/L)"
            ),
            TrainingZone(
                name: "A2 - Aerobic Base",
                lowerBound: recoveryUpper,
                upperBound: lt1,
                color: "green",
                description: "Aerobic base building (2-3mmol/L)"
            ),
            TrainingZone(
                name: "AT - Aerobic Threshold",
                lowerBound: lt1,
                upperBound: thresholdMid,
                color: "yellow",
                description: "Aerobic threshold pace (3-5mmol/L)"
            ),
            TrainingZone(
                name: "MVO2 - Max Aerobic",
                lowerBound: thresholdMid,
                upperBound: lt2,
                color: "orange",
                description: "Maximum aerobic power (5-10mmol/L)"
            ),
            TrainingZone(
                name: "LT - Lactate Tolerance",
                lowerBound: lt2,
                upperBound: lactateToleranceUpper,
                color: "red",
                description: "Lactate tolerance (8-15mmol/L)"
            ),
            TrainingZone(
                name: "LP - Lactate Production",
                lowerBound: lactateToleranceUpper,
                upperBound: maxEstimate,
                color: "darkred",
                description: "Lactate production (8-12mmol/L)"
            ),
            TrainingZone(
                name: "SP - Speed",
                lowerBound: speedLower,
                upperBound: maxEstimate,
                color: "purple",
                description: "Speed/alactic work (3-6mmol/L)"
            )
        ]
    }
    
    private static func calculateCouzensSystem(lt1: Double, lt2: Double) -> [TrainingZone] {
        // For power/speed zones, we use fixed offsets similar to HR zones
        // These approximate the 10bpm offsets in power/speed terms
        let zoneOffset = (lt2 - lt1) / ZoneConstants.Couzens.zoneOffsetDivisor
        let maxEstimate = lt2 + zoneOffset

        return [
            TrainingZone(
                name: "Zone 0 - Active Recovery",
                lowerBound: 0,
                upperBound: max(0, lt1 - zoneOffset),
                color: "lightgray",
                description: "Active recovery - movement for recovery"
            ),
            TrainingZone(
                name: "Zone 1 - Easy Aerobic",
                lowerBound: max(0, lt1 - zoneOffset),
                upperBound: lt1,
                color: "lightgreen",
                description: "Easy aerobic - base building"
            ),
            TrainingZone(
                name: "Zone 2 - Steady Endurance",
                lowerBound: lt1,
                upperBound: lt1 + zoneOffset,
                color: "green",
                description: "Steady endurance - first tier fast oxidative fibers"
            ),
            TrainingZone(
                name: "Zone 3 - Moderate Aerobic",
                lowerBound: lt1 + zoneOffset,
                upperBound: lt2 - zoneOffset,
                color: "yellow",
                description: "Moderate aerobic - avoid unless race pace"
            ),
            TrainingZone(
                name: "Zone 4 - Threshold",
                lowerBound: lt2 - zoneOffset,
                upperBound: lt2,
                color: "orange",
                description: "Threshold training - aerobic power"
            ),
            TrainingZone(
                name: "Zone 5 - Max VO2",
                lowerBound: lt2,
                upperBound: maxEstimate,
                color: "red",
                description: "VO2max training - maximal aerobic power"
            ),
            TrainingZone(
                name: "Zone 6 - Lactate Tolerance",
                lowerBound: maxEstimate - (zoneOffset * ZoneConstants.Couzens.zone6LowerOffsetMultiplier),
                upperBound: maxEstimate,
                color: "darkred",
                description: "Lactate tolerance/production"
            ),
            TrainingZone(
                name: "Zone 7 - Speed",
                lowerBound: lt1 + zoneOffset,
                upperBound: lt2,
                color: "purple",
                description: "Speed/alactic work"
            )
        ]
    }
    
    static func getHeartRateZones(lt1HR: Int, lt2HR: Int, maxHR: Int, system: ZoneSystem) -> [TrainingZone] {
        let lt1 = Double(lt1HR)
        let lt2 = Double(lt2HR)
        let max = Double(maxHR)
        
        switch system {
        case .threeZone:
            return [
                TrainingZone(
                    name: "Zone 1 - Easy",
                    lowerBound: 0,
                    upperBound: lt1,
                    color: "green",
                    description: "Below first threshold"
                ),
                TrainingZone(
                    name: "Zone 2 - Moderate",
                    lowerBound: lt1,
                    upperBound: lt2,
                    color: "yellow",
                    description: "Between thresholds"
                ),
                TrainingZone(
                    name: "Zone 3 - Hard",
                    lowerBound: lt2,
                    upperBound: max,
                    color: "red",
                    description: "Above second threshold"
                )
            ]
            
        case .touretski:
            let stdOffset = Double(ZoneConstants.HeartRate.standardOffset)
            let lgOffset = Double(ZoneConstants.HeartRate.largeOffset)
            let smOffset = Double(ZoneConstants.HeartRate.smallOffset)
            let spOffset = Double(ZoneConstants.HeartRate.speedUpperOffset)

            return [
                TrainingZone(
                    name: "A1",
                    lowerBound: lt1 - lgOffset,
                    upperBound: lt1 - stdOffset,
                    color: "lightblue",
                    description: "60-70% effort"
                ),
                TrainingZone(
                    name: "A2",
                    lowerBound: lt1 - stdOffset,
                    upperBound: lt1,
                    color: "green",
                    description: "70-75% effort"
                ),
                TrainingZone(
                    name: "AT",
                    lowerBound: lt1,
                    upperBound: lt2 - stdOffset,
                    color: "yellow",
                    description: "80-85% effort"
                ),
                TrainingZone(
                    name: "MVO2",
                    lowerBound: lt2 - stdOffset,
                    upperBound: lt2,
                    color: "orange",
                    description: "90-95% effort"
                ),
                TrainingZone(
                    name: "LT",
                    lowerBound: lt2,
                    upperBound: max - smOffset,
                    color: "red",
                    description: "95-100% effort"
                ),
                TrainingZone(
                    name: "LP",
                    lowerBound: max - smOffset,
                    upperBound: max,
                    color: "darkred",
                    description: "95-100% effort"
                ),
                TrainingZone(
                    name: "SP",
                    lowerBound: lt1,
                    upperBound: lt2 - spOffset,
                    color: "purple",
                    description: "80-85% effort"
                )
            ]
            
        case .couzens:
            let stdOffset = Double(ZoneConstants.HeartRate.standardOffset)
            let smOffset = Double(ZoneConstants.HeartRate.smallOffset)

            return [
                TrainingZone(
                    name: "Zone 0",
                    lowerBound: 0,
                    upperBound: lt1 - stdOffset,
                    color: "lightgray",
                    description: "Recovery"
                ),
                TrainingZone(
                    name: "Zone 1",
                    lowerBound: lt1 - stdOffset,
                    upperBound: lt1,
                    color: "lightgreen",
                    description: "Easy aerobic"
                ),
                TrainingZone(
                    name: "Zone 2",
                    lowerBound: lt1,
                    upperBound: lt1 + stdOffset,
                    color: "green",
                    description: "Steady endurance"
                ),
                TrainingZone(
                    name: "Zone 3",
                    lowerBound: lt1 + stdOffset,
                    upperBound: lt2 - stdOffset,
                    color: "yellow",
                    description: "Moderate aerobic"
                ),
                TrainingZone(
                    name: "Zone 4",
                    lowerBound: lt2 - stdOffset,
                    upperBound: lt2,
                    color: "orange",
                    description: "Threshold"
                ),
                TrainingZone(
                    name: "Zone 5",
                    lowerBound: lt2,
                    upperBound: max - smOffset,
                    color: "red",
                    description: "Max VO2"
                ),
                TrainingZone(
                    name: "Zone 6",
                    lowerBound: max - smOffset,
                    upperBound: max,
                    color: "darkred",
                    description: "Lactate tolerance"
                ),
                TrainingZone(
                    name: "Zone 7",
                    lowerBound: lt1,
                    upperBound: lt2,
                    color: "purple",
                    description: "Speed work"
                )
            ]
        }
    }
}