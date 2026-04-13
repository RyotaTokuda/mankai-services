import SwiftUI
import UniformTypeIdentifiers

struct WorkspaceView: View {
    @Environment(PlanService.self) private var planService
    @State private var viewModel = WorkspaceViewModel()
    @State private var showPaywall = false

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
                        // Settings area
                        toolSettingsSection

                        // Drop zone / file list
                        FileDropView(
                            files: viewModel.inputFiles,
                            acceptedTypes: viewModel.acceptedContentTypes,
                            onAdd: { viewModel.addFiles(urls: $0) },
                            onRemove: { viewModel.removeFile($0) },
                            onShowPicker: { viewModel.isShowingFilePicker = true }
                        )

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
                    viewModel.addFiles(urls: urls)
                }
            }
            .sheet(isPresented: $showPaywall) {
                PaywallView()
            }
        }
    }

    // MARK: - Tool Settings

    @ViewBuilder
    private var toolSettingsSection: some View {
        switch viewModel.selectedToolId {
        case .imageConvert:
            HStack {
                Text("出力形式")
                    .font(.subheadline)
                Spacer()
                Picker("形式", selection: $viewModel.outputImageFormat) {
                    ForEach(ImageFormat.allCases) { format in
                        Text(format.displayName).tag(format)
                    }
                }
                .pickerStyle(.segmented)
                .frame(maxWidth: 280)
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

        case .pdfPassword:
            HStack {
                Text("パスワード")
                    .font(.subheadline)
                SecureField("パスワードを入力", text: $viewModel.pdfPassword)
                    .textFieldStyle(.roundedBorder)
            }
            .padding(.horizontal)

        case .videoConvert:
            HStack {
                Text("出力形式")
                    .font(.subheadline)
                Spacer()
                Picker("形式", selection: $viewModel.outputVideoFormat) {
                    Text("MP4").tag(VideoFormat.mp4)
                    Text("GIF").tag(VideoFormat.gif)
                }
                .pickerStyle(.segmented)
                .frame(maxWidth: 200)
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

    // MARK: - Actions

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
