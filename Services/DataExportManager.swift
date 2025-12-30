import Foundation
import CoreData

class DataExportManager {
    
    enum ExportFormat {
        case json
        case csv
        case markdown
    }
    
    func exportTests(_ tests: [TestEntity], format: ExportFormat) -> Data? {
        switch format {
        case .json:
            return exportAsJSON(tests)
        case .csv:
            return exportAsCSV(tests)
        case .markdown:
            return exportAsMarkdown(tests)
        }
    }
    
    private func exportAsJSON(_ tests: [TestEntity]) -> Data? {
        let lactateTests = tests.compactMap { entity -> LactateTest? in
            guard let data = entity.testData else { return nil }
            return try? JSONDecoder().decode(LactateTest.self, from: data)
        }
        
        return try? JSONEncoder().encode(lactateTests)
    }
    
    private func exportAsCSV(_ tests: [TestEntity]) -> Data? {
        var csv = "Date,Type,LT1 Intensity,LT1 HR,LT2 Intensity,LT2 HR\n"
        
        for test in tests {
            let date = test.testDate?.formatted(date: .numeric, time: .omitted) ?? ""
            let type = test.testType ?? ""
            let lt1Intensity = test.lt1Intensity > 0 ? "\(Int(test.lt1Intensity))" : ""
            let lt1HR = test.lt1HeartRate > 0 ? "\(test.lt1HeartRate)" : ""
            let lt2Intensity = test.lt2Intensity > 0 ? "\(Int(test.lt2Intensity))" : ""
            let lt2HR = test.lt2HeartRate > 0 ? "\(test.lt2HeartRate)" : ""
            
            csv += "\(date),\(type),\(lt1Intensity),\(lt1HR),\(lt2Intensity),\(lt2HR)\n"
        }
        
        return csv.data(using: .utf8)
    }
    
    private func exportAsMarkdown(_ tests: [TestEntity]) -> Data? {
        var markdown = "# Lactate Threshold Test Results\n\n"
        
        for test in tests {
            markdown += "## Test: \(test.testDate?.formatted(date: .abbreviated, time: .omitted) ?? "Unknown")\n"
            markdown += "**Type:** \(test.testType ?? "Unknown")\n\n"
            
            if test.lt1Intensity > 0 {
                markdown += "### LT1 (Aerobic Threshold)\n"
                markdown += "- Intensity: \(Int(test.lt1Intensity)) W\n"
                markdown += "- Heart Rate: \(test.lt1HeartRate) bpm\n\n"
            }
            
            if test.lt2Intensity > 0 {
                markdown += "### LT2 (Anaerobic Threshold)\n"
                markdown += "- Intensity: \(Int(test.lt2Intensity)) W\n"
                markdown += "- Heart Rate: \(test.lt2HeartRate) bpm\n\n"
            }
            
            markdown += "---\n\n"
        }
        
        return markdown.data(using: .utf8)
    }
    
    func exportTest(_ test: LactateTest, format: ExportFormat) -> String {
        switch format {
        case .json:
            if let data = try? JSONEncoder().encode(test),
               let string = String(data: data, encoding: .utf8) {
                return string
            }
            return ""
            
        case .csv:
            var csv = "Step,Intensity,Heart Rate,Lactate\n"
            for step in test.validSteps {
                csv += "\(step.stepNumber),\(step.intensityValue ?? 0),\(step.heartRateValue ?? 0),\(step.lactateValue ?? 0)\n"
            }
            return csv
            
        case .markdown:
            var markdown = "# Lactate Threshold Test\n\n"
            markdown += "**Date:** \(test.testDate.formatted())\n"
            markdown += "**Type:** \(test.testType.rawValue)\n\n"
            
            markdown += "## Results\n\n"
            
            if let lt1 = test.lt1Intensity {
                markdown += "### LT1 (Aerobic Threshold)\n"
                markdown += "- Intensity: \(Int(lt1)) W\n"
                if let hr = test.lt1HeartRate {
                    markdown += "- Heart Rate: \(hr) bpm\n"
                }
                if let lactate = test.lt1Lactate {
                    markdown += "- Lactate: \(lactate) mmol/L\n"
                }
                markdown += "\n"
            }
            
            if let lt2 = test.lt2Intensity {
                markdown += "### LT2 (Anaerobic Threshold)\n"
                markdown += "- Intensity: \(Int(lt2)) W\n"
                if let hr = test.lt2HeartRate {
                    markdown += "- Heart Rate: \(hr) bpm\n"
                }
                if let lactate = test.lt2Lactate {
                    markdown += "- Lactate: \(lactate) mmol/L\n"
                }
                markdown += "\n"
            }
            
            markdown += "## Raw Data\n\n"
            markdown += "| Step | Intensity | HR | Lactate |\n"
            markdown += "|------|-----------|----|---------|\n"
            
            for step in test.validSteps {
                markdown += "| \(step.stepNumber) | \(step.intensityValue ?? 0) | \(step.heartRateValue ?? 0) | \(step.lactateValue ?? 0) |\n"
            }
            
            if !test.notes.isEmpty {
                markdown += "\n## Notes\n\n\(test.notes)\n"
            }
            
            return markdown
        }
    }
}