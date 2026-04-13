import SwiftUI

struct ToolSelectorView: View {
    @Binding var selectedCategory: ToolCategory
    @Binding var selectedToolId: ToolId
    let onSelect: (ToolId) -> Void

    var body: some View {
        VStack(spacing: 8) {
            // Category tabs
            Picker("カテゴリ", selection: $selectedCategory) {
                ForEach(ToolCategory.allCases) { category in
                    Label(category.displayName, systemImage: category.icon)
                        .tag(category)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)

            // Tool list for selected category
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(ToolDefinition.tools(for: selectedCategory), id: \.id) { tool in
                        ToolChip(
                            tool: tool,
                            isSelected: selectedToolId == tool.id
                        ) {
                            onSelect(tool.id)
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.vertical, 8)
        .background(Color.appBackground)
        .onChange(of: selectedCategory) { _, newCategory in
            // Auto-select first tool in new category
            if let first = ToolDefinition.tools(for: newCategory).first {
                onSelect(first.id)
            }
        }
    }
}

// MARK: - ToolChip

private struct ToolChip: View {
    let tool: ToolDefinition
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: tool.icon)
                    .font(.caption)
                Text(tool.name)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isSelected ? Color.accentColor : Color.secondaryBackground)
            .foregroundStyle(isSelected ? .white : .primary)
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}
