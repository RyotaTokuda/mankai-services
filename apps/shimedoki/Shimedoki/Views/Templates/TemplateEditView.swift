import SwiftUI

struct TemplateEditView: View {
    @Environment(TemplateStore.self) private var store
    @Environment(PlanService.self) private var planService
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: TemplateEditViewModel
    @State private var showingPaywall = false

    let originalTemplate: Template

    init(template: Template, isNew: Bool) {
        self.originalTemplate = template
        _viewModel = State(initialValue: TemplateEditViewModel(template: template, isNew: isNew))
    }

    var body: some View {
        NavigationStack {
            Form {
                // 基本情報
                Section("基本") {
                    TextField("タイトル", text: $viewModel.title)

                    Picker("カテゴリ", selection: $viewModel.category) {
                        ForEach(TemplateCategory.allCases) { cat in
                            Label(cat.displayName, systemImage: cat.symbolName)
                                .tag(cat)
                        }
                    }

                    Picker("時間", selection: $viewModel.durationMinutes) {
                        ForEach(TemplateEditViewModel.durationPresets, id: \.self) { min in
                            Text("\(min)分").tag(min)
                        }
                    }
                }

                // 通知設定
                Section("通知タイミング") {
                    if planService.canCustomizeAlertOffsets() {
                        Text(S.Scene.customPlus)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        // Plus 用: 自由入力（将来拡張）
                        ForEach(TemplateEditViewModel.alertPresets, id: \.self) { preset in
                            alertPresetRow(preset)
                        }
                    } else {
                        ForEach(TemplateEditViewModel.alertPresets, id: \.self) { preset in
                            alertPresetRow(preset)
                        }
                    }
                }

                // 触覚スタイル
                Section("触覚の強さ") {
                    Picker("スタイル", selection: $viewModel.hapticStyle) {
                        ForEach(HapticStyle.allCases) { style in
                            Text(style.displayName).tag(style)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                // カラー
                Section("カラー") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 12) {
                        ForEach(TemplateEditViewModel.presetColors, id: \.self) { hex in
                            Circle()
                                .fill(Color(hex: hex))
                                .frame(width: 36, height: 36)
                                .overlay {
                                    if viewModel.colorHex == hex {
                                        Image(systemName: "checkmark")
                                            .font(.caption)
                                            .fontWeight(.bold)
                                            .foregroundStyle(.white)
                                    }
                                }
                                .onTapGesture {
                                    viewModel.colorHex = hex
                                }
                        }
                    }
                    .padding(.vertical, 4)
                }

                // オプション
                Section {
                    Toggle("ピン留め", isOn: $viewModel.isPinned)
                }

                // 削除（編集時のみ）
                if !viewModel.isNew {
                    Section {
                        Button(S.Scene.deleteScene, role: .destructive) {
                            store.delete(originalTemplate)
                            dismiss()
                        }
                    }
                }
            }
            .navigationTitle(viewModel.isNew ? S.Scene.newScene : S.Scene.editNavTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(S.Scene.cancel) { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(S.Scene.save) {
                        save()
                    }
                    .fontWeight(.semibold)
                    .disabled(!viewModel.isValid)
                }
            }
            .sheet(isPresented: $showingPaywall) {
                PaywallView()
            }
        }
    }

    private func alertPresetRow(_ preset: [Int]) -> some View {
        let description = preset.map { offset in
            offset >= 60 ? "残り\(offset / 60)分" : "残り\(offset)秒"
        }.joined(separator: " + ")

        return Button {
            viewModel.alertOffsets = preset
        } label: {
            HStack {
                Text(description)
                    .foregroundStyle(.primary)
                Spacer()
                if viewModel.alertOffsets == preset {
                    Image(systemName: "checkmark")
                        .foregroundStyle(Color.accentColor)
                }
            }
        }
    }

    private func save() {
        let template = viewModel.toTemplate(original: originalTemplate)
        if viewModel.isNew {
            store.add(template)
            AnalyticsService.log(.templateCreated, parameters: [
                "category": template.category.rawValue,
                "duration": "\(template.durationMinutes)"
            ])
        } else {
            store.update(template)
        }
        dismiss()
    }
}
