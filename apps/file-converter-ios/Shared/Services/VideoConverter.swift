import Foundation
import AVFoundation

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

struct VideoConverter {

    // MARK: - Convert to MP4

    static func convertToMP4(
        input: URL,
        progress: @escaping (Double) -> Void
    ) async throws -> URL {
        let asset = AVURLAsset(url: input)
        let baseName = (input.lastPathComponent as NSString).deletingPathExtension
        let outputURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("\(baseName)_converted.mp4")

        // Remove existing file
        try? FileManager.default.removeItem(at: outputURL)

        guard let exportSession = AVAssetExportSession(
            asset: asset,
            presetName: AVAssetExportPresetHighestQuality
        ) else {
            throw ConversionError.processingFailed
        }

        exportSession.outputURL = outputURL
        exportSession.outputFileType = .mp4

        // Progress monitoring
        let progressTask = Task {
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 200_000_000)
                progress(Double(exportSession.progress))
            }
        }

        await exportSession.export()
        progressTask.cancel()

        guard exportSession.status == .completed else {
            throw ConversionError.processingFailed
        }

        progress(1.0)
        return outputURL
    }

    // MARK: - Convert to GIF

    static func convertToGIF(
        input: URL,
        fps: Int = 10,
        maxDuration: Double = 15,
        progress: @escaping (Double) -> Void
    ) async throws -> URL {
        let asset = AVURLAsset(url: input)
        let duration = try await asset.load(.duration)
        let durationSeconds = min(CMTimeGetSeconds(duration), maxDuration)
        let totalFrames = Int(durationSeconds * Double(fps))

        let baseName = (input.lastPathComponent as NSString).deletingPathExtension
        let outputURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("\(baseName).gif")

        try? FileManager.default.removeItem(at: outputURL)

        guard let destination = CGImageDestinationCreateWithURL(
            outputURL as CFURL,
            "com.compuserve.gif" as CFString,
            totalFrames,
            nil
        ) else {
            throw ConversionError.failedToCreateOutput
        }

        let gifProperties: [CFString: Any] = [
            kCGImagePropertyGIFDictionary: [
                kCGImagePropertyGIFLoopCount: 0
            ]
        ]
        CGImageDestinationSetProperties(destination, gifProperties as CFDictionary)

        let frameDelay = 1.0 / Double(fps)
        let frameProperties: [CFString: Any] = [
            kCGImagePropertyGIFDictionary: [
                kCGImagePropertyGIFDelayTime: frameDelay
            ]
        ]

        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        generator.requestedTimeToleranceBefore = .zero
        generator.requestedTimeToleranceAfter = .zero

        // Scale down for GIF
        generator.maximumSize = CGSize(width: 480, height: 480)

        for i in 0..<totalFrames {
            let time = CMTime(seconds: Double(i) * frameDelay, preferredTimescale: 600)
            do {
                let (image, _) = try await generator.image(at: time)
                CGImageDestinationAddImage(destination, image, frameProperties as CFDictionary)
                progress(Double(i + 1) / Double(totalFrames))
            } catch {
                continue
            }
        }

        guard CGImageDestinationFinalize(destination) else {
            throw ConversionError.failedToWriteOutput
        }

        return outputURL
    }
}
