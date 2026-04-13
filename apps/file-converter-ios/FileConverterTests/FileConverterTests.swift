import XCTest

final class FileConverterTests: XCTestCase {
    func testPlanLimitsFree() {
        XCTAssertEqual(PlanLimits.maxFilesPerJob(isPlus: false), 5)
        XCTAssertEqual(PlanLimits.maxFileSizeMB(isPlus: false), 25)
        XCTAssertFalse(PlanLimits.canBatchProcess(isPlus: false))
        XCTAssertFalse(PlanLimits.canRemoveMetadata(isPlus: false))
        XCTAssertFalse(PlanLimits.canSetPdfPassword(isPlus: false))
        XCTAssertTrue(PlanLimits.showAds(isPlus: false))
    }

    func testPlanLimitsPlus() {
        XCTAssertEqual(PlanLimits.maxFilesPerJob(isPlus: true), 100)
        XCTAssertEqual(PlanLimits.maxFileSizeMB(isPlus: true), 500)
        XCTAssertTrue(PlanLimits.canBatchProcess(isPlus: true))
        XCTAssertTrue(PlanLimits.canRemoveMetadata(isPlus: true))
        XCTAssertTrue(PlanLimits.canSetPdfPassword(isPlus: true))
        XCTAssertFalse(PlanLimits.showAds(isPlus: true))
    }

    func testToolDefinitions() {
        XCTAssertEqual(ToolDefinition.allTools.count, 11)
        XCTAssertEqual(ToolDefinition.tools(for: .image).count, 6)
        XCTAssertEqual(ToolDefinition.tools(for: .pdf).count, 4)
        XCTAssertEqual(ToolDefinition.tools(for: .video).count, 1)
    }

    func testFreeToolsAvailability() {
        let freeTools: [ToolId] = [
            .imageConvert, .imageCompress, .imageResize,
            .imageRotate, .imageToPdf, .pdfToImage,
            .pdfMerge, .videoConvert
        ]
        for toolId in freeTools {
            let tool = ToolDefinition.tool(for: toolId)
            XCTAssertTrue(tool.isFree, "\(toolId.rawValue) should be free")
            XCTAssertTrue(tool.isAvailable(isPlus: false), "\(toolId.rawValue) should be available on Free")
        }
    }

    func testPlusOnlyToolsLocked() {
        let plusTools: [ToolId] = [.metadataStrip, .pdfReorder, .pdfPassword]
        for toolId in plusTools {
            let tool = ToolDefinition.tool(for: toolId)
            XCTAssertFalse(tool.isFree, "\(toolId.rawValue) should not be free")
            XCTAssertFalse(tool.isAvailable(isPlus: false), "\(toolId.rawValue) should be locked on Free")
            XCTAssertTrue(tool.isAvailable(isPlus: true), "\(toolId.rawValue) should be available on Plus")
        }
    }
}
