import XCTest

final class FileConverterTests: XCTestCase {
    func testPlanLimitsFree() {
        XCTAssertEqual(PlanLimits.maxFilesPerJob(isPlus: false), 5)
        XCTAssertEqual(PlanLimits.maxFileSizeMB(isPlus: false), 25)
        XCTAssertFalse(PlanLimits.canBatchProcess(isPlus: false))
        XCTAssertTrue(PlanLimits.showAds(isPlus: false))
    }

    func testPlanLimitsPlus() {
        XCTAssertEqual(PlanLimits.maxFilesPerJob(isPlus: true), 100)
        XCTAssertEqual(PlanLimits.maxFileSizeMB(isPlus: true), 500)
        XCTAssertTrue(PlanLimits.canBatchProcess(isPlus: true))
        XCTAssertFalse(PlanLimits.showAds(isPlus: true))
    }

    func testToolDefinitions() {
        XCTAssertEqual(ToolDefinition.allTools.count, 11)
        XCTAssertEqual(ToolDefinition.tools(for: .image).count, 6)
        XCTAssertEqual(ToolDefinition.tools(for: .pdf).count, 4)
        XCTAssertEqual(ToolDefinition.tools(for: .video).count, 1)
    }

    func testFreeToolsAvailability() {
        // Free: 画像変換、画像圧縮、動画変換の3つのみ
        let freeTools: [ToolId] = [.imageConvert, .imageCompress, .videoConvert]
        for toolId in freeTools {
            let tool = ToolDefinition.tool(for: toolId)
            XCTAssertTrue(tool.isFree, "\(toolId.rawValue) should be free")
            XCTAssertTrue(tool.isAvailable(isPlus: false), "\(toolId.rawValue) should be available on Free")
        }
    }

    func testPlusOnlyToolsLocked() {
        // Plus: リサイズ、回転、画像→PDF、メタデータ削除、PDF全ツール
        let plusTools: [ToolId] = [
            .imageResize, .imageRotate, .imageToPdf, .metadataStrip,
            .pdfToImage, .pdfMerge, .pdfReorder, .pdfPassword
        ]
        for toolId in plusTools {
            let tool = ToolDefinition.tool(for: toolId)
            XCTAssertFalse(tool.isFree, "\(toolId.rawValue) should not be free")
            XCTAssertFalse(tool.isAvailable(isPlus: false), "\(toolId.rawValue) should be locked on Free")
            XCTAssertTrue(tool.isAvailable(isPlus: true), "\(toolId.rawValue) should be available on Plus")
        }
    }

    func testImageFormatFreeRestriction() {
        // JPG, PNG は Free
        XCTAssertTrue(ImageFormat.jpeg.isFree)
        XCTAssertTrue(ImageFormat.png.isFree)
        // WebP, HEIC は Plus
        XCTAssertFalse(ImageFormat.webp.isFree)
        XCTAssertFalse(ImageFormat.heic.isFree)
        // Free では JPG/PNG のみ
        XCTAssertEqual(ImageFormat.available(isPlus: false).count, 2)
        // Plus では全形式
        XCTAssertEqual(ImageFormat.available(isPlus: true).count, 4)
    }

    func testVideoOutputFormatFreeRestriction() {
        // MP4 は Free
        XCTAssertTrue(VideoOutputFormat.mp4.isFree)
        // GIF は Plus
        XCTAssertFalse(VideoOutputFormat.gif.isFree)
        // Free では MP4 のみ
        XCTAssertEqual(VideoOutputFormat.available(isPlus: false).count, 1)
        // Plus では全形式
        XCTAssertEqual(VideoOutputFormat.available(isPlus: true).count, 2)
    }
}
