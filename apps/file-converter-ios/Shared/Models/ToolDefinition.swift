import Foundation
import UniformTypeIdentifiers

// MARK: - Tool ID

enum ToolId: String, CaseIterable, Identifiable, Codable {
    case imageConvert = "image-convert"
    case imageCompress = "image-compress"
    case imageResize = "image-resize"
    case imageRotate = "image-rotate"
    case imageToPdf = "image-to-pdf"
    case metadataStrip = "metadata-strip"
    case pdfToImage = "pdf-to-image"
    case pdfMerge = "pdf-merge"
    case pdfReorder = "pdf-reorder"
    case pdfPassword = "pdf-password"
    case videoConvert = "video-convert"

    var id: String { rawValue }
}

// MARK: - Tool Category

enum ToolCategory: String, CaseIterable, Identifiable {
    case image
    case pdf
    case video

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .image: "画像"
        case .pdf: "PDF"
        case .video: "動画"
        }
    }

    var icon: String {
        switch self {
        case .image: "photo"
        case .pdf: "doc.richtext"
        case .video: "film"
        }
    }
}

// MARK: - Tool Definition

struct ToolDefinition: Identifiable {
    let id: ToolId
    let name: String
    let description: String
    let category: ToolCategory
    let icon: String
    let acceptedTypes: [UTType]

    var acceptsImages: Bool { category == .image }
    var acceptsPdfs: Bool { category == .pdf }
    var acceptsVideos: Bool { category == .video }
}

// MARK: - All Tools

extension ToolDefinition {
    static let allTools: [ToolDefinition] = [
        ToolDefinition(
            id: .imageConvert,
            name: "画像変換",
            description: "JPG・PNG・WebP・HEIC を相互変換",
            category: .image,
            icon: "arrow.triangle.2.circlepath",
            acceptedTypes: [.jpeg, .png, .webP, .heic]
        ),
        ToolDefinition(
            id: .imageCompress,
            name: "画像圧縮",
            description: "画質を調整してファイルサイズを削減",
            category: .image,
            icon: "arrow.down.right.and.arrow.up.left",
            acceptedTypes: [.jpeg, .png, .webP]
        ),
        ToolDefinition(
            id: .imageResize,
            name: "画像リサイズ",
            description: "指定サイズに変更",
            category: .image,
            icon: "arrow.up.left.and.arrow.down.right",
            acceptedTypes: [.jpeg, .png, .webP]
        ),
        ToolDefinition(
            id: .imageRotate,
            name: "画像回転",
            description: "90° / 180° / 270° / 左右反転",
            category: .image,
            icon: "rotate.right",
            acceptedTypes: [.jpeg, .png, .webP]
        ),
        ToolDefinition(
            id: .imageToPdf,
            name: "画像→PDF",
            description: "複数画像から PDF を作成",
            category: .image,
            icon: "doc.badge.plus",
            acceptedTypes: [.jpeg, .png, .webP]
        ),
        ToolDefinition(
            id: .metadataStrip,
            name: "メタデータ削除",
            description: "GPS・カメラ情報・撮影日時を除去",
            category: .image,
            icon: "eye.slash",
            acceptedTypes: [.jpeg, .png, .webP]
        ),
        ToolDefinition(
            id: .pdfToImage,
            name: "PDF→画像",
            description: "PDF の各ページを画像に変換",
            category: .pdf,
            icon: "photo.badge.arrow.down",
            acceptedTypes: [.pdf]
        ),
        ToolDefinition(
            id: .pdfMerge,
            name: "PDF結合",
            description: "複数の PDF を1つにまとめる",
            category: .pdf,
            icon: "doc.on.doc",
            acceptedTypes: [.pdf]
        ),
        ToolDefinition(
            id: .pdfReorder,
            name: "PDF整理",
            description: "ページの並び替え",
            category: .pdf,
            icon: "arrow.up.arrow.down",
            acceptedTypes: [.pdf]
        ),
        ToolDefinition(
            id: .pdfPassword,
            name: "PDFパスワード",
            description: "PDF にパスワードを設定",
            category: .pdf,
            icon: "lock.doc",
            acceptedTypes: [.pdf]
        ),
        ToolDefinition(
            id: .videoConvert,
            name: "動画変換",
            description: "MP4・MOV → MP4・GIF",
            category: .video,
            icon: "film.stack",
            acceptedTypes: [.mpeg4Movie, .quickTimeMovie]
        ),
    ]

    static func tool(for id: ToolId) -> ToolDefinition {
        allTools.first { $0.id == id }!
    }

    static func tools(for category: ToolCategory) -> [ToolDefinition] {
        allTools.filter { $0.category == category }
    }
}
