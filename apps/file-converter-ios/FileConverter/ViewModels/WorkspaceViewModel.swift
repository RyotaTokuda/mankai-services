import SwiftUI
import UniformTypeIdentifiers

@Observable
final class WorkspaceViewModel {
    // Tool selection
    var selectedToolId: ToolId = .imageConvert
    var selectedCategory: ToolCategory = .image

    // Input files
    var inputFiles: [InputFile] = []
    var isShowingFilePicker = false

    // Conversion settings
    var outputImageFormat: ImageFormat = .jpeg
    var compressionQuality: Double = 0.85
    var resizeWidth: Int = 1920
    var resizeHeight: Int = 1080
    var rotationAngle: RotationAngle = .cw90
    var outputVideoFormat: VideoFormat = .mp4
    var pdfPassword: String = ""

    // Job state
    var status: JobStatus = .idle
    var results: [ConversionResult] = []

    // MARK: - Computed

    var selectedTool: ToolDefinition {
        ToolDefinition.tool(for: selectedToolId)
    }

    var acceptedContentTypes: [UTType] {
        selectedTool.acceptedTypes
    }

    var canStartConversion: Bool {
        !inputFiles.isEmpty && !status.isProcessing
    }

    var hasResults: Bool {
        !results.isEmpty
    }

    // MARK: - File Management

    func addFiles(urls: [URL]) {
        for url in urls {
            guard url.startAccessingSecurityScopedResource() else { continue }
            let file = InputFile(url: url)
            inputFiles.append(file)
        }
    }

    func removeFile(_ file: InputFile) {
        file.url.stopAccessingSecurityScopedResource()
        inputFiles.removeAll { $0.id == file.id }
    }

    func clearFiles() {
        for file in inputFiles {
            file.url.stopAccessingSecurityScopedResource()
        }
        inputFiles.removeAll()
    }

    func clearResults() {
        // Clean up temp files
        for result in results {
            try? FileManager.default.removeItem(at: result.outputURL)
        }
        results.removeAll()
        status = .idle
    }

    // MARK: - Validation

    func validate(planService: PlanService) -> ConversionError? {
        let maxFiles = planService.maxFilesPerJob()
        if inputFiles.count > maxFiles {
            return .tooManyFiles(limit: maxFiles)
        }

        let maxSizeMB = planService.maxFileSizeMB()
        for file in inputFiles {
            if file.fileSizeMB > Double(maxSizeMB) {
                return .fileTooLarge(limitMB: maxSizeMB)
            }
        }

        if selectedToolId == .metadataStrip && !planService.canRemoveMetadata() {
            return .plusRequired(feature: "メタデータ削除")
        }

        if selectedToolId == .pdfPassword && !planService.canSetPdfPassword() {
            return .plusRequired(feature: "PDFパスワード設定")
        }

        return nil
    }

    // MARK: - Conversion

    func startConversion(planService: PlanService) async {
        if let error = validate(planService: planService) {
            status = .failed(message: error.localizedDescription)
            return
        }

        status = .processing(progress: 0)
        results.removeAll()

        do {
            let total = inputFiles.count
            for (index, file) in inputFiles.enumerated() {
                let result = try await convertSingleFile(file)
                results.append(result)
                status = .processing(progress: Double(index + 1) / Double(total))
            }
            status = .completed
        } catch {
            status = .failed(message: error.localizedDescription)
        }
    }

    private func convertSingleFile(_ file: InputFile) async throws -> ConversionResult {
        let outputURL: URL

        switch selectedToolId {
        case .imageConvert:
            outputURL = try ImageConverter.convert(input: file.url, to: outputImageFormat, quality: compressionQuality)

        case .imageCompress:
            outputURL = try ImageConverter.compress(input: file.url, quality: compressionQuality)

        case .imageResize:
            outputURL = try ImageConverter.resize(input: file.url, width: resizeWidth, height: resizeHeight)

        case .imageRotate:
            outputURL = try ImageConverter.rotate(input: file.url, angle: rotationAngle)

        case .imageToPdf:
            outputURL = try PdfConverter.imagesToPdf(inputs: inputFiles.map(\.url))
            return makeResult(original: file, output: outputURL)

        case .metadataStrip:
            outputURL = try MetadataService.stripMetadata(input: file.url)

        case .pdfToImage:
            let imageURLs = try PdfConverter.pdfToImages(input: file.url, format: outputImageFormat)
            // Return first; others will be added separately
            for (i, url) in imageURLs.enumerated() {
                if i > 0 {
                    results.append(makeResult(original: file, output: url))
                }
            }
            guard let first = imageURLs.first else {
                throw ConversionError.processingFailed
            }
            outputURL = first

        case .pdfMerge:
            outputURL = try PdfConverter.merge(inputs: inputFiles.map(\.url))
            return makeResult(original: file, output: outputURL)

        case .pdfReorder:
            // Default: reverse order as a starting point
            let pageCount = inputFiles.count
            let order = Array((0..<pageCount).reversed())
            outputURL = try PdfConverter.reorder(input: file.url, newOrder: order)

        case .pdfPassword:
            outputURL = try PdfConverter.setPassword(input: file.url, password: pdfPassword)

        case .videoConvert:
            if outputVideoFormat == .gif {
                outputURL = try await VideoConverter.convertToGIF(input: file.url) { progress in
                    Task { @MainActor in
                        self.status = .processing(progress: progress)
                    }
                }
            } else {
                outputURL = try await VideoConverter.convertToMP4(input: file.url) { progress in
                    Task { @MainActor in
                        self.status = .processing(progress: progress)
                    }
                }
            }
        }

        return makeResult(original: file, output: outputURL)
    }

    private func makeResult(original: InputFile, output: URL) -> ConversionResult {
        let size = (try? FileManager.default.attributesOfItem(atPath: output.path)[.size] as? Int64) ?? 0
        return ConversionResult(
            originalFileName: original.fileName,
            outputURL: output,
            outputFileName: output.lastPathComponent,
            outputFileSize: size,
            toolId: selectedToolId
        )
    }

    // MARK: - Tool Change

    func selectTool(_ toolId: ToolId) {
        selectedToolId = toolId
        selectedCategory = ToolDefinition.tool(for: toolId).category
        clearFiles()
        clearResults()
    }
}
