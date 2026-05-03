import SwiftUI

struct TemplateListView: View {
    @Environment(TemplateStore.self) private var store
    @Environment(SessionStore.self) private var sessionStore
    @Environment(PlanService.self) private var planService
    @State private var viewModel = TemplateListViewModel()
    @State private var editingTemplate: Template?
    @State private var showingNewTemplate = false
    @State private var runningSession: PhoneSessionViewModel?

    var body: some View {
        NavigationStack {
            List {
                // カテゴリフィルタ
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        FilterChip(
                            title: "すべて",
                            isSelected: viewModel.selectedCategory == nil
                        ) {
                            viewModel.selectedCategory = nil
                        }
                        ForEach(TemplateCategory.allCases) { category in
                            FilterChip(
                                title: category.displayName,
                                isSelected: viewModel.selectedCategory == category
                            ) {
                                viewModel.selectedCategory = category
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)

                // シーン一覧
                ForEach(viewModel.filteredTemplates(from: store)) { template in
                    TemplateRow(template: template) {
                        let vm = PhoneSessionViewModel(template: template)
                        vm.start(sessionStore: sessionStore, templateStore: store, isPro: planService.isPro)
                        runningSession = vm
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        editingTemplate = template
                    }
                }
                .onDelete { offsets in
                    let filtered = viewModel.filteredTemplates(from: store)
                    let idsToDelete = offsets.map { filtered[$0].id }
                    for id in idsToDelete {
                        if let t = store.template(for: id) {
                            store.delete(t)
                        }
                    }
                }
            }
            .navigationTitle(S.Scene.navTitle)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        if viewModel.handleAddTap(store: store, planService: planService) {
                            showingNewTemplate = true
                        }
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(item: $editingTemplate) { template in
                TemplateEditView(template: template, isNew: false)
            }
            .sheet(isPresented: $showingNewTemplate) {
                TemplateEditView(
                    template: Template(
                        title: "",
                        durationMinutes: 30,
                        category: .meeting
                    ),
                    isNew: true
                )
            }
            .sheet(isPresented: $viewModel.showingPaywall) {
                PaywallView()
            }
            .fullScreenCover(item: $runningSession) { session in
                PhoneRunningSessionView(session: session)
                    .environment(sessionStore)
                    .environment(store)
            }
        }
    }
}

// MARK: - TemplateRow

private struct TemplateRow: View {
    let template: Template
    let onStart: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color(hex: template.colorHex))
                .frame(width: 10, height: 10)

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text(template.title)
                        .font(.body)
                        .fontWeight(.medium)
                    if template.isPinned {
                        Image(systemName: "pin.fill")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
                Text("\(S.Scene.minutes(template.durationMinutes)) · \(template.category.displayName)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button {
                onStart()
            } label: {
                Image(systemName: "play.circle.fill")
                    .font(.title2)
                    .foregroundStyle(Color(hex: template.colorHex))
            }
            .buttonStyle(.plain)

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - FilterChip

private struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .fontWeight(isSelected ? .semibold : .regular)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color.accentColor.opacity(0.15) : Color(.tertiarySystemFill))
                .foregroundStyle(isSelected ? Color.accentColor : .primary)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}