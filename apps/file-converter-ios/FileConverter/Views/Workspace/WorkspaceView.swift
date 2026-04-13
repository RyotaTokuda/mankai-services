import SwiftUI
import UniformTypeIdentifiers

struct WorkspaceView: View {
    @Environment(PlanService.self) private var planService
    @State private var viewModel = WorkspaceViewModel()
    @State private var showPaywall = false

    /// 選択中のツールが Plus 専用かつ Free ユーザーか
    private var isToolLocked: Bool {
        !viewModel.selectedTool.isAvailable(isPlus: planService.isPlus)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ToolSelectorView(
                    selectedCategory: $viewModel.selectedCategory,
                    selectedToolId: $viewModel.selectedToolId,
                    onSelect: { viewModel.selectTool($0) }
                )

                Divider()

                ScrollView {
                    VStack(spacing: 20) {
                        if isToolLocked {
                            // Plus 専用ツール — アップセルバナー
                            plusUpsellBanner
                        } else {
                            // Settings area
                            toolSettingsSection

                            // Drop zone / file list
                            FileDropView(
                                files: viewModel.inputFiles,
                                acceptedTypes: viewModel.acceptedContentTypes,
                                onAdd: { addFilesWithLimit(urls: $0) },
                                onRemove: { viewModel.removeFile($0) },
                                onShowPicker: { viewModel.isShowingFilePicker = true }
                            )

                            // ファイル数制限の注意表示
                            if !planService.isPlus && viewModel.inputFiles.count >= PlanLimits.freeMaxFilesPerJob {
                                fileLimitNotice
                            }

                            // Action button
                            if viewModel.canStartConversion {
                                Button {
                                    Task { await startOrShowPaywall() }
                                } label: {
                                    Label("変換開始", systemImage: "play.fill")
                                        .font(.headline)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.accentColor)
                                        .foregroundStyle(.white)
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                }
                                .padding(.horizontal)
                            }

                            // Progress
                            if case .processing(let progress) = viewModel.status {
                                VStack(spacing: 8) {
                                    ProgressView(value: progress)
                                        .progressViewStyle(.linear)
                                    Text("処理中… \(Int(progress * 100))%")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                .padding(.horizontal)
                            }

                            // Error
                            if case .failed(let message) = viewModel.status {
                                HStack {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .foregroundStyle(.orange)
                                    Text(message)
                                        .font(.subheadline)
                                }
                                .padding()
                                .background(.orange.opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .padding(.horizontal)
                            }

                            // Results
                            if viewModel.hasResults {
                                ResultView(
                                    results: viewModel.results,
                                    onClear: { viewModel.clearResults() }
                                )
                            }
                        }
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("ファイル変換")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .fileImporter(
                isPresented: $viewModel.isShowingFilePicker,
                allowedContentTypes: viewModel.acceptedContentTypes,
                allowsMultipleSelection: true
            ) { result in
                if let urls = try? result.get() {
                    addFilesWithLimit(urls: urls)
                }
            }
            .sheet(isPresented: $showPaywall) {
                PaywallView()
            }
        }
    }

    // MARK: - Plus Upsell Banner

    private var plusUpsellBanner: some View {
        VStack(spacing: 16) {
            Image(systemName: "lock.shield.fill")
                .font(.system(size: 40))
                .foregroundStyle(.orange)

            Text("\(viewModel.selectedTool.name)は Plus 機能です")
                .font(.headline)

            Text(viewModel.selectedTool.description)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Button {
                showPaywall = true
            } label: {
                Text("Plus にアップグレード")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.orange)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .padding(.horizontal, 40)
        }
        .padding(.vertical, 40)
        .padding(.horizontal)
    }

    // MARK: - File Limit Notice

    private var fileLimitNotice: some View {
        HStack(spacing: 8) {
            Image(systemName: "info.circle.fill")
                .foregroundStyle(.orange)
            Text("Free プランは\(PlanLimits.freeMaxFilesPerJob)ファイルまで")
                .font(.caption)
            Spacer()
            Button("Plus で拡張") {
                showPaywall = true
            }
            .font(.caption)
            .foregroundStyle(.orange)
        }
        .padding(10)
        .background(.orange.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .padding(.horizontal)
    }

    // MARK: - Tool Settings

    @ViewBuilder
    private var toolSettingsSection: some View {
        switch viewModel.selectedToolId {
        case .imageConvert:
            VStack(spacing: 8) {
                HStack {
                    Text("出力形式")
                        .font(.subheadline)
                    Spacer()
                    Picker("形式", selection: $viewModel.outputImageFormat) {
                        ForEach(ImageFormat.allCases) { format in
                            HStack {
                                Text(format.displayName)
                                if !format.isFree && !planService.isPlus {
                                    Text("Plus")
                                }
                            }
                            .tag(format)
                        }
                    }
                    .pickerStyle(.segmented)
                    .frame(maxWidth: 280)
                }
                if !viewModel.outputImageFormat.isFree && !planService.isPlus {
                    formatUpsellHint("\(viewModel.outputImageFormat.displayName) への変換は Plus 機能です")
                }
            }
            .padding(.horizontal)

        case .imageCompress:
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("画質")
                        .font(.subheadline)
                    Spacer()
                    Text("\(Int(viewModel.compressionQuality * 100))%")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Slider(value: $viewModel.compressionQuality, in: 0.1...1.0, step: 0.05)
            }
            .padding(.horizontal)

        case .imageResize:
            HStack(spacing: 12) {
                VStack(alignment: .leading) {
                    Text("幅").font(.caption)
                    TextField("幅", value: $viewModel.resizeWidth, format: .number)
                        .textFieldStyle(.roundedBorder)
                        #if os(iOS)
                        .keyboardType(.numberPad)
                        #endif
                }
                Text("×").foregroundStyle(.secondary)
                VStack(alignment: .leading) {
                    Text("高さ").font(.caption)
                    TextField("高さ", value: $viewModel.resizeHeight, format: .number)
                        .textFieldStyle(.roundedBorder)
                        #if os(iOS)
                        .keyboardType(.numberPad)
                        #endif
                }
            }
            .padding(.horizontal)

        case .imageRotate:
            HStack {
                Text("回転")
                    .font(.subheadline)
                Spacer()
                Picker("回転", selection: $viewModel.rotationAngle) {
                    ForEach(RotationAngle.allCases) { angle in
                        Text(angle.displayName).tag(angle)
                    }
                }
                .pickerStyle(.menu)
            }
            .padding(.horizontal)

        case .videoConvert:
            VStack(spacing: 8) {
                HStack {
                    Text("出力形式")
                        .font(.subheadline)
                    Spacer()
                    Picker("形式", selection: $viewModel.outputVideoFormat) {
                        ForEach(VideoOutputFormat.allCases) { format in
                            HStack {
                                Text(format.displayName)
                                if !format.isFree && !planService.isPlus {
                                    Text("Plus")
                                }
                            }
                            .tag(format)
                        }
                    }
                    .pickerStyle(.segmented)
                    .frame(maxWidth: 200)
                }
                if !viewModel.outputVideoFormat.isFree && !planService.isPlus {
                    formatUpsellHint("GIF への変換は Plus 機能です")
                }
            }
            .padding(.horizontal)

        case .pdfToImage:
            HStack {
                Text("出力形式")
                    .font(.subheadline)
                Spacer()
                Picker("形式", selection: $viewModel.outputImageFormat) {
                    Text("PNG").tag(ImageFormat.png)
                    Text("JPG").tag(ImageFormat.jpeg)
                }
                .pickerStyle(.segmented)
                .frame(maxWidth: 200)
            }
            .padding(.horizontal)

        default:
            EmptyView()
        }
    }

    // MARK: - Format Upsell Hint

    private func formatUpsellHint(_ text: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: "lock.fill")
                .font(.caption2)
                .foregroundStyle(.orange)
            Text(text)
                .font(.caption)
                .foregroundStyle(.secondary)
            Spacer()
            Button("Plus") {
                showPaywall = true
            }
            .font(.caption)
            .fontWeight(.semibold)
            .foregroundStyle(.orange)
        }
        .padding(8)
        .background(.orange.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 6))
    }

    // MARK: - Actions

    /// ファイル追加時に Free プランの上限を適用
    private func addFilesWithLimit(urls: [URL]) {
        let maxFiles = planService.isPlus
            ? PlanLimits.plusMaxFilesPerJob
            : PlanLimits.freeMaxFilesPerJob
        let remaining = maxFiles - viewModel.inputFiles.count
        guard remaining > 0 else {
            showPaywall = true
            return
        }

        let maxSizeMB = planService.isPlus
            ? PlanLimits.plusMaxFileSizeMB
            : PlanLimits.freeMaxFileSizeMB

        var accepted: [URL] = []
        for url in urls.prefix(remaining) {
            let file = InputFile(url: url)
            if file.fileSizeMB > Double(maxSizeMB) {
                viewModel.status = .failed(
                    message: "\(maxSizeMB)MBを超えるファイルは Plus で処理できます"
                )
                if !planService.isPlus { showPaywall = true }
                continue
            }
            accepted.append(url)
        }

        if accepted.count < urls.count && viewModel.inputFiles.count + accepted.count >= maxFiles {
            // 上限に達した旨を伝える（ペイウォールは上の fileLimitNotice で表示）
        }

        viewModel.addFiles(urls: accepted)
    }

    private func startOrShowPaywall() async {
        if let error = viewModel.validate(planService: planService) {
            if case .plusRequired = error {
                showPaywall = true
                return
            }
            if case .tooManyFiles = error, !planService.isPlus {
                showPaywall = true
                return
            }
            if case .fileTooLarge = error, !planService.isPlus {
                showPaywall = true
                return
            }
        }
        await viewModel.startConversion(planService: planService)
    }
}
