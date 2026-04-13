import Foundation
import UniformTypeIdentifiers

// MARK: - Image Format

enum ImageFormat: String, CaseIterable, Identifiable, Codable {
    case jpeg
    case png
    case webp
    case heic

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .jpeg: "JPG"
        case .png: "PNG"
        case .webp: "WebP"
        case .heic: "HEIC"
        }
    }

    var fileExtension: String {
        switch self {
        case .jpeg: "jpg"
        case .png: "png"
        case .webp: "webp"
        case .heic: "heic"
        }
    }

    var utType: UTType {
        switch self {
        case .jpeg: .jpeg
        case .png: .png
        case .webp: .webP
        case .heic: .heic
        }
    }

    var mimeType: String {
        switch self {
        case .jpeg: "image/jpeg"
        case .png: "image/png"
        case .webp: "image/webp"
        case .heic: "image/heic"
        }
    }

    static func from(utType: UTType) -> ImageFormat? {
        allCases.first { $0.utType.conforms(to: utType) || utType.conforms(to: $0.utType) }
    }
}

// MARK: - Video Format

enum VideoFormat: String, CaseIterable, Identifiable, Codable {
    case mp4
    case mov
    case gif

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .mp4: "MP4"
        case .mov: "MOV"
        case .gif: "GIF"
        }
    }

    var fileExtension: String { rawValue }

    var utType: UTType {
        switch self {
        case .mp4: .mpeg4Movie
        case .mov: .quickTimeMovie
        case .gif: .gif
        }
    }
}

// MARK: - Rotation

enum RotationAngle: String, CaseIterable, Identifiable, Codable {
    case cw90
    case cw180
    case cw270
    case flipH
    case flipV

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .cw90: "90° 右回転"
        case .cw180: "180° 回転"
        case .cw270: "90° 左回転"
        case .flipH: "左右反転"
        case .flipV: "上下反転"
        }
    }
}
