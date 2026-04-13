import Foundation
import ImageIO
import UniformTypeIdentifiers

struct MetadataService {

    /// メタデータ（EXIF, GPS, TIFF等）を除去した画像を出力する
    static func stripMetadata(input: URL) throws -> URL {
        guard let source = CGImageSourceCreateWithURL(input as CFURL, nil),
              let cgImage = CGImageSourceCreateImageAtIndex(source, 0, nil),
              let utType = CGImageSourceGetType(source)
        else {
            throw ConversionError.failedToLoadImage
        }

        let baseName = (input.lastPathComponent as NSString).deletingPathExtension
        let ext = input.pathExtension.lowercased()
        let outputURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("\(baseName)_clean.\(ext)")

        guard let destination = CGImageDestinationCreateWithURL(
            outputURL as CFURL,
            utType,
            1,
            nil
        ) else {
            throw ConversionError.failedToCreateOutput
        }

        // 元の品質を維持しつつメタデータを除去
        let cleanProperties: [CFString: Any] = [
            kCGImagePropertyExifDictionary: kCFNull as Any,
            kCGImagePropertyGPSDictionary: kCFNull as Any,
            kCGImagePropertyTIFFDictionary: kCFNull as Any,
            kCGImagePropertyIPTCDictionary: kCFNull as Any,
            kCGImageDestinationLossyCompressionQuality: 0.95,
        ]

        CGImageDestinationAddImage(destination, cgImage, cleanProperties as CFDictionary)

        guard CGImageDestinationFinalize(destination) else {
            throw ConversionError.failedToWriteOutput
        }

        return outputURL
    }

    /// 画像のメタデータを読み取って返す（プレビュー用）
    static func readMetadata(from url: URL) -> [String: Any]? {
        guard let source = CGImageSourceCreateWithURL(url as CFURL, nil),
              let properties = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [String: Any]
        else {
            return nil
        }
        return properties
    }
}
