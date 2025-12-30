import Foundation

enum Lact8Error: LocalizedError {

    // MARK: - Persistence Errors

    case persistenceLoadFailed(underlying: Error)
    case persistenceSaveFailed(underlying: Error)
    case testNotFound(id: UUID)
    case dataCorrupted(reason: String)

    // MARK: - Calculation Errors

    case insufficientData(reason: String)
    case calculationFailed(reason: String)
    case lt1NotFound
    case lt2NotFound

    // MARK: - Export Errors

    case exportFailed(format: String, reason: String)
    case encodingFailed

    var errorDescription: String? {
        switch self {
        case .persistenceLoadFailed(let error):
            return "Failed to load data: \(error.localizedDescription)"
        case .persistenceSaveFailed(let error):
            return "Failed to save data: \(error.localizedDescription)"
        case .testNotFound(let id):
            return "Test not found: \(id)"
        case .dataCorrupted(let reason):
            return "Data corrupted: \(reason)"
        case .insufficientData(let reason):
            return "Not enough data: \(reason)"
        case .calculationFailed(let reason):
            return "Calculation failed: \(reason)"
        case .lt1NotFound:
            return "Could not determine LT1 (aerobic threshold)"
        case .lt2NotFound:
            return "Could not determine LT2 (anaerobic threshold)"
        case .exportFailed(let format, let reason):
            return "Export to \(format) failed: \(reason)"
        case .encodingFailed:
            return "Failed to encode data"
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .persistenceLoadFailed:
            return "Try restarting the app. If the problem persists, you may need to reinstall."
        case .persistenceSaveFailed:
            return "Check available storage space and try again."
        case .testNotFound:
            return "The test may have been deleted. Refresh and try again."
        case .dataCorrupted:
            return "This test data appears to be corrupted and cannot be recovered."
        case .insufficientData:
            return "Ensure you have at least 3 complete test steps with intensity, heart rate, and lactate values."
        case .calculationFailed:
            return "Check that your test data is complete and values are reasonable."
        case .lt1NotFound:
            return "Ensure lactate values show a clear rise during the test. Try testing at a wider range of intensities."
        case .lt2NotFound:
            return "Ensure the test reaches high enough intensity to show lactate accumulation."
        case .exportFailed:
            return "Try exporting in a different format."
        case .encodingFailed:
            return "Try again. If the problem persists, contact support."
        }
    }
}

// MARK: - Result Extension for Error Handling

extension Result where Failure == Lact8Error {
    var errorMessage: String? {
        if case .failure(let error) = self {
            return error.localizedDescription
        }
        return nil
    }
}
