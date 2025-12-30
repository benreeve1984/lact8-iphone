import Foundation

struct ThresholdResult {
    let lt1: ThresholdPoint?
    let lt2: ThresholdPoint?
}

struct ThresholdPoint {
    let intensity: Double
    let heartRate: Int
    let lactate: Double
}

/// Threshold calculation based on methodologies described in
/// "The Science of Maximal Athletic Development" by Alan Couzens
/// https://alancouzens.substack.com/
class ThresholdCalculator {
    func calculate(from steps: [TestStep]) -> ThresholdResult {
        guard steps.count >= ThresholdConstants.minimumStepsRequired else {
            return ThresholdResult(lt1: nil, lt2: nil)
        }
        
        let sortedSteps = steps.sorted { ($0.intensityValue ?? 0) < ($1.intensityValue ?? 0) }
        
        // Calculate LT1 (first lactate rise exceeding threshold)
        let lt1: ThresholdPoint? = calculateLT1(from: sortedSteps)

        // Calculate LT2 using modified D-max method
        var lt2: ThresholdPoint?
        if let lt1Point = lt1 {
            lt2 = calculateLT2UsingDmax(from: sortedSteps, lt1: lt1Point)
        }
        
        return ThresholdResult(lt1: lt1, lt2: lt2)
    }
    
    private func calculateLT1(from sortedSteps: [TestStep]) -> ThresholdPoint? {
        // Find the first rise in lactate exceeding the threshold
        for i in 1..<sortedSteps.count {
            let prevLactate = sortedSteps[i-1].lactateValue ?? 0
            let currLactate = sortedSteps[i].lactateValue ?? 0
            let lactateDiff = currLactate - prevLactate

            // First rise exceeding threshold indicates LT1
            if lactateDiff > ThresholdConstants.lactateRiseThreshold {
                // LT1 is the point BEFORE the rise (as per Couzens methodology)
                if let intensity = sortedSteps[i-1].intensityValue,
                   let heartRate = sortedSteps[i-1].heartRateValue,
                   let lactate = sortedSteps[i-1].lactateValue {
                    return ThresholdPoint(
                        intensity: intensity,
                        heartRate: heartRate,
                        lactate: lactate
                    )
                }
            }
        }
        
        // Fallback: if no clear rise, use fixed lactate level threshold
        let fallbackLevel = ThresholdConstants.fallbackLactateLevel
        for i in 1..<sortedSteps.count {
            let prevLactate = sortedSteps[i-1].lactateValue ?? 0
            let currLactate = sortedSteps[i].lactateValue ?? 0

            if prevLactate < fallbackLevel && currLactate >= fallbackLevel {
                return interpolateThreshold(
                    prev: sortedSteps[i-1],
                    curr: sortedSteps[i],
                    targetLactate: fallbackLevel
                )
            }
        }
        
        return nil
    }
    
    private func calculateLT2UsingDmax(from sortedSteps: [TestStep], lt1: ThresholdPoint) -> ThresholdPoint? {
        // Modified D-max: Find point with maximum perpendicular distance from line connecting LT1 to max
        guard let lastStep = sortedSteps.last,
              let maxLactate = lastStep.lactateValue,
              let maxIntensity = lastStep.intensityValue else {
            return nil
        }
        
        var maxDistance: Double = 0
        var lt2Point: ThresholdPoint? = nil
        
        // Only consider points after LT1
        let stepsAfterLT1 = sortedSteps.filter { 
            ($0.intensityValue ?? 0) > lt1.intensity 
        }
        
        for step in stepsAfterLT1 {
            guard let intensity = step.intensityValue,
                  let lactate = step.lactateValue,
                  let heartRate = step.heartRateValue else { continue }
            
            // Calculate perpendicular distance from point to line (LT1 to max)
            let distance = perpendicularDistance(
                pointX: intensity,
                pointY: lactate,
                lineX1: lt1.intensity,
                lineY1: lt1.lactate,
                lineX2: maxIntensity,
                lineY2: maxLactate
            )
            
            if distance > maxDistance {
                maxDistance = distance
                lt2Point = ThresholdPoint(
                    intensity: intensity,
                    heartRate: heartRate,
                    lactate: lactate
                )
            }
        }
        
        return lt2Point
    }
    
    private func perpendicularDistance(pointX: Double, pointY: Double,
                                      lineX1: Double, lineY1: Double,
                                      lineX2: Double, lineY2: Double) -> Double {
        // Calculate perpendicular distance from point to line
        let A = lineY2 - lineY1
        let B = lineX1 - lineX2
        let C = lineX2 * lineY1 - lineX1 * lineY2
        
        let denominator = sqrt(A * A + B * B)
        guard denominator > 0 else { return 0 }
        
        return abs(A * pointX + B * pointY + C) / denominator
    }
    
    private func interpolateThreshold(prev: TestStep, curr: TestStep, targetLactate: Double) -> ThresholdPoint? {
        guard let prevIntensity = prev.intensityValue,
              let currIntensity = curr.intensityValue,
              let prevHR = prev.heartRateValue,
              let currHR = curr.heartRateValue,
              let prevLactate = prev.lactateValue,
              let currLactate = curr.lactateValue else {
            return nil
        }
        
        let lactateDiff = currLactate - prevLactate
        guard lactateDiff != 0 else {
            return ThresholdPoint(
                intensity: prevIntensity,
                heartRate: prevHR,
                lactate: prevLactate
            )
        }
        
        let ratio = (targetLactate - prevLactate) / lactateDiff
        let intensity = prevIntensity + (currIntensity - prevIntensity) * ratio
        let heartRate = Int(Double(prevHR) + Double(currHR - prevHR) * ratio)
        
        return ThresholdPoint(
            intensity: intensity,
            heartRate: heartRate,
            lactate: targetLactate
        )
    }
}