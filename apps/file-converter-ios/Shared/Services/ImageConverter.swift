import Foundation
import CoreImage
import ImageIO
import UniformTypeIdentifiers

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

struct ImageConverter {

    // MARK: - Convert Format

    static func convert(
        input: URL,
        to format: ImageFormat,
        quality: Double = 0.85
    ) throws -> URL {
        guard let source = CGImageSourceCreateWithURL(input as CFURL, nil),
              let cgImage = CGImageSourceCreateImageAtIndex(source, 0, nil)
        else {
            throw ConversionError.failedToLoadImage
        }

        let outputURL = Self.tempURL(originalName: input.lastPathComponent, extension: format.fileExtension)
        try writeImage(cgImage, to: outputURL, format: format, quality: quality)
        return outputURL
    }

    // MARK: - Compress

    static func compress(
        input: URL,
        quality: Double
    ) throws -> URL {
        guard let source = CGImageSourceCreateWithURL(input as CFURL, nil),
              let cgImage = CGImageSourceCreateImageAtIndex(source, 0, nil),
              let sourceType = CGImageSourceGetType(source)
        else {
            throw ConversionError.failedToLoadImage
        }

        let format = ImageFormat.from(utType: UTType(sourceType as String) ?? .jpeg) ?? .jpeg
        let outputURL = Self.tempURL(originalName: input.lastPathComponent, extension: format.fileExtension, suffix: "_compressed")
        try writeImage(cgImage, to: outputURL, format: format, quality: quality)
        return outputURL
    }

    // MARK: - Resize

    static func resize(
        input: URL,
        width: Int,
        height: Int
    ) throws -> URL {
        guard let source = CGImageSourceCreateWithURL(input as CFURL, nil),
              let cgImage = CGImageSourceCreateImageAtIndex(source, 0, nil),
              let sourceType = CGImageSourceGetType(source)
        else {
            throw ConversionError.failedToLoadImage
        }

        let context = CIContext()
        let ciImage = CIImage(cgImage: cgImage)

        let scaleX = CGFloat(width) / ciImage.extent.width
        let scaleY = CGFloat(height) / ciImage.extent.height
        let scaled = ciImage.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))

        guard let resized = context.createCGImage(scaled, from: scaled.extent) else {
            throw ConversionError.processingFailed
        }

        let format = ImageFormat.from(utType: UTType(sourceType as String) ?? .jpeg) ?? .jpeg
        let outputURL = Self.tempURL(originalName: input.lastPathComponent, extension: format.fileExtension, suffix: "_resized")
        try writeImage(resized, to: outputURL, format: format, quality: 0.9)
        return outputURL
    }

    // MARK: - Rotate

    static func rotate(
        input: URL,
        angle: RotationAngle
    ) throws -> URL {
        guard let source = CGImageSourceCreateWithURL(input as CFURL, nil),
              let cgImage = CGImageSourceCreateImageAtIndex(source, 0, nil),
              let sourceType = CGImageSourceGetType(source)
        else {
            throw ConversionError.failedToLoadImage
        }

        let context = CIContext()
        var ciImage = CIImage(cgImage: cgImage)

        switch angle {
        case .cw90:
            ciImage = ciImage.transformed(by: CGAffineTransform(rotationAngle: -.pi / 2))
        case .cw180:
            ciImage = ciImage.transformed(by: CGAffineTransform(rotationAngle: -.pi))
        case .cw270:
            ciImage = ciImage.transformed(by: CGAffineTransform(rotationAngle: .pi / 2))
        case .flipH:
            ciImage = ciImage.transformed(by: CGAffineTransform(scaleX: -1, y: 1))
        case .flipV:
            ciImage = ciImage.transformed(by: CGAffineTransform(scaleX: 1, y: -1))
        }

        // Normalize origin to (0,0)
        let translated = ciImage.transformed(by: CGAffineTransform(
            translationX: -ciImage.extent.origin.x,
            y: -ciImage.extent.origin.y
        ))

        guard let rotated = context.createCGImage(translated, from: translated.extent) else {
            throw ConversionError.processingFailed
        }

        let format = ImageFormat.from(utType: UTType(sourceType as String) ?? .jpeg) ?? .jpeg
        let outputURL = Self.tempURL(originalName: input.lastPathComponent, extension: format.fileExtension, suffix: "_rotated")
        try writeImage(rotated, to: outputURL, format: format, quality: 0.95)
        return outputURL
    }

    // MARK: - Helpers

    static func writeImage(
        _ image: CGImage,
        to url: URL,
        format: ImageFormat,
        quality: Double
    ) throws {
        guard let destination = CGImageDestinationCreateWithURL(
            url as CFURL,
            format.utType.identifier as CFString,
            1,
            nil
        ) else {
            throw ConversionError.failedToCreateOutput
        }

        let options: [CFString: Any] = [
            kCGImageDestinationLossyCompressionQuality: quality
        ]
        CGImageDestinationAddImage(destination, image, options as CFDictionary)

        guard CGImageDestinationFinalize(destination) else {
            throw ConversionError.failedToWriteOutput
        }
    }

    private static func tempURL(originalName: String, extension ext: String, suffix: String = "") -> URL {
        let baseName = (originalName as NSString).deletingPathExtension
        let fileName = "\(baseName)\(suffix).\(ext)"
        return FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
    }
}

// MARK: - Errors

enum ConversionError: LocalizedError {
    case failedToLoadImage
    case failedToCreateOutput
    case failedToWriteOutput
    case processingFailed
    case unsupportedFormat
    case fileTooLarge(limitMB: Int)
    case tooManyFiles(limit: Int)
    case plusRequired(feature: String)

    var errorDescription: String? {
        switch self {
        case .failedToLoadImage: "ファイルを読み込めませんでした"
        case .failedToCreateOutput: "出力ファイルを作成できませんでした"
        case .failedToWriteOutput: "ファイルの書き出しに失敗しました"
        case .processingFailed: "変換処理に失敗しました"
        case .unsupportedFormat: "サポートされていない形式です"
        case .fileTooLarge(let limit): "\(limit)MBを超えるファイルは Plus で処理できます"
        case .tooManyFiles(let limit): "\(limit + 1)ファイル以上の一括処理は Plus で利用できます"
        case .plusRequired(let feature): "\(feature)は Plus で利用できます"
        }
    }
}
