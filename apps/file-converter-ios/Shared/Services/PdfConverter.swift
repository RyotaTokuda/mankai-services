import Foundation
import PDFKit
import CoreImage

struct PdfConverter {

    // MARK: - Image to PDF

    static func imagesToPdf(inputs: [URL]) throws -> URL {
        let pdfDocument = PDFDocument()

        for (index, url) in inputs.enumerated() {
            guard let image = platformImage(from: url),
                  let page = PDFPage(image: image)
            else {
                throw ConversionError.failedToLoadImage
            }
            pdfDocument.insert(page, at: index)
        }

        let outputURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("combined_\(UUID().uuidString.prefix(8)).pdf")

        guard pdfDocument.write(to: outputURL) else {
            throw ConversionError.failedToWriteOutput
        }
        return outputURL
    }

    // MARK: - PDF to Images

    static func pdfToImages(input: URL, format: ImageFormat = .png) throws -> [URL] {
        guard let document = PDFDocument(url: input) else {
            throw ConversionError.failedToLoadImage
        }

        var results: [URL] = []
        let baseName = (input.lastPathComponent as NSString).deletingPathExtension

        for i in 0..<document.pageCount {
            guard let page = document.page(at: i) else { continue }

            let pageRect = page.bounds(for: .mediaBox)
            let scale: CGFloat = 2.0 // Retina
            let size = CGSize(width: pageRect.width * scale, height: pageRect.height * scale)

            #if canImport(UIKit)
            let renderer = UIGraphicsImageRenderer(size: size)
            let uiImage = renderer.image { ctx in
                ctx.cgContext.setFillColor(UIColor.white.cgColor)
                ctx.cgContext.fill(CGRect(origin: .zero, size: size))
                ctx.cgContext.scaleBy(x: scale, y: scale)
                page.draw(with: .mediaBox, to: ctx.cgContext)
            }
            guard let cgImage = uiImage.cgImage else { continue }
            #elseif canImport(AppKit)
            let image = NSImage(size: size)
            image.lockFocus()
            if let ctx = NSGraphicsContext.current?.cgContext {
                ctx.setFillColor(NSColor.white.cgColor)
                ctx.fill(CGRect(origin: .zero, size: size))
                ctx.scaleBy(x: scale, y: scale)
                page.draw(with: .mediaBox, to: ctx)
            }
            image.unlockFocus()
            guard let tiffData = image.tiffRepresentation,
                  let bitmap = NSBitmapImageRep(data: tiffData),
                  let cgImage = bitmap.cgImage
            else { continue }
            #endif

            let outputURL = FileManager.default.temporaryDirectory
                .appendingPathComponent("\(baseName)_page\(i + 1).\(format.fileExtension)")

            try ImageConverter.writeImage(cgImage, to: outputURL, format: format, quality: 0.9)
            results.append(outputURL)
        }

        return results
    }

    // MARK: - Merge

    static func merge(inputs: [URL]) throws -> URL {
        let merged = PDFDocument()
        var pageIndex = 0

        for url in inputs {
            guard let doc = PDFDocument(url: url) else {
                throw ConversionError.failedToLoadImage
            }
            for i in 0..<doc.pageCount {
                guard let page = doc.page(at: i) else { continue }
                merged.insert(page, at: pageIndex)
                pageIndex += 1
            }
        }

        let outputURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("merged_\(UUID().uuidString.prefix(8)).pdf")

        guard merged.write(to: outputURL) else {
            throw ConversionError.failedToWriteOutput
        }
        return outputURL
    }

    // MARK: - Reorder

    static func reorder(input: URL, newOrder: [Int]) throws -> URL {
        guard let document = PDFDocument(url: input) else {
            throw ConversionError.failedToLoadImage
        }

        let reordered = PDFDocument()
        for (index, pageNum) in newOrder.enumerated() {
            guard pageNum < document.pageCount,
                  let page = document.page(at: pageNum)
            else { continue }
            reordered.insert(page, at: index)
        }

        let outputURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("reordered_\(UUID().uuidString.prefix(8)).pdf")

        guard reordered.write(to: outputURL) else {
            throw ConversionError.failedToWriteOutput
        }
        return outputURL
    }

    // MARK: - Password

    static func setPassword(input: URL, password: String) throws -> URL {
        guard let document = PDFDocument(url: input) else {
            throw ConversionError.failedToLoadImage
        }

        let outputURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("protected_\(UUID().uuidString.prefix(8)).pdf")

        guard document.write(
            to: outputURL,
            withOptions: [
                .userPasswordOption: password,
                .ownerPasswordOption: password
            ]
        ) else {
            throw ConversionError.failedToWriteOutput
        }
        return outputURL
    }

    // MARK: - Helpers

    private static func platformImage(from url: URL) -> PlatformImage? {
        #if canImport(UIKit)
        return UIImage(contentsOfFile: url.path)
        #elseif canImport(AppKit)
        return NSImage(contentsOf: url)
        #endif
    }
}

#if canImport(UIKit)
import UIKit
typealias PlatformImage = UIImage
#elseif canImport(AppKit)
import AppKit
typealias PlatformImage = NSImage
#endif

