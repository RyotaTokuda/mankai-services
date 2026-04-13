import Foundation

// MARK: - Input File

struct InputFile: Identifiable {
    let id = UUID()
    let url: URL
    let fileName: String
    let fileSize: Int64

    var fileSizeMB: Double {
        Double(fileSize) / 1_048_576
    }

    var fileExtension: String {
        url.pathExtension.lowercased()
    }

    init(url: URL) {
        self.url = url
        self.fileName = url.lastPathComponent
        self.fileSize = (try? FileManager.default.attributesOfItem(atPath: url.path)[.size] as? Int64) ?? 0
    }
}

// MARK: - Conversion Result

struct ConversionResult: Identifiable {
    let id = UUID()
    let originalFileName: String
    let outputURL: URL
    let outputFileName: String
    let outputFileSize: Int64
    let toolId: ToolId

    var outputFileSizeMB: Double {
        Double(outputFileSize) / 1_048_576
    }
}

// MARK: - Job Status

enum JobStatus: Equatable {
    case idle
    case processing(progress: Double)
    case completed
    case failed(message: String)

    var isProcessing: Bool {
        if case .processing = self { return true }
        return false
    }
}
