import SwiftUI

struct StylePickerView: View {
    @EnvironmentObject private var styleStore: StyleStore
    @EnvironmentObject private var displayConfigStore: DisplayConfigStore
    @State private var filter: StyleFilter = .all
    @State private var toastMessage: String?

    private let columns = [
        GridItem(.flexible(), spacing: LookSpacing.sm),
        GridItem(.flexible(), spacing: LookSpacing.sm)
    ]

    private var filteredStyles: [BannerStyle] {
        switch filter {
        case .all:
            styleStore.styles
        case .free:
            styleStore.styles.filter { !$0.isPro }
        case .pro:
            styleStore.styles.filter(\.isPro)
        }
    }

    var body: some View {
        ZStack {
            LookScreenBackground()

            VStack(alignment: .leading, spacing: 0) {
                fixedHeader

                ScrollView(showsIndicators: false) {
                    LazyVGrid(columns: columns, spacing: LookSpacing.sm) {
                        ForEach(filteredStyles) { style in
                            StyleCard(
                                style: style,
                                isSelected: displayConfigStore.selectedStyleID == style.id,
                                previewColor: Color(hex: displayConfigStore.textColorHex),
                                fontStyle: displayConfigStore.fontStyle
                            ) {
                                select(style)
                            }
                        }
                    }
                    .padding(.horizontal, LookSpacing.pageHorizontal)
                    .padding(.top, LookSpacing.lg)
                    .padding(.bottom, LookSpacing.tabContentBottomPadding)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .overlay(alignment: .top) {
            if let toastMessage {
                ToastView(message: toastMessage)
                    .padding(.top, LookSpacing.lg)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.28, dampingFraction: 0.86), value: toastMessage)
        .onChange(of: toastMessage) { _, message in
            guard message != nil else { return }
            Task { @MainActor in
                try? await Task.sleep(for: .seconds(1.7))
                toastMessage = nil
            }
        }
    }

    private var fixedHeader: some View {
        VStack(alignment: .leading, spacing: LookSpacing.lg) {
            NeonPageHeader(
                title: "样式选择",
                subtitle: "免费样式可直接使用，Pro 样式当前开放测试"
            )

            Picker("筛选", selection: $filter) {
                ForEach(StyleFilter.allCases) { item in
                    Text(item.title).tag(item)
                }
            }
            .pickerStyle(.segmented)
            .tint(LookTheme.Colors.primaryPink)
        }
        .padding(.horizontal, LookSpacing.pageHorizontal)
        .padding(.top, LookSpacing.lg)
        .padding(.bottom, LookSpacing.md)
    }

    private func select(_ style: BannerStyle) {
        displayConfigStore.selectStyle(style)
    }
}

private enum StyleFilter: String, CaseIterable, Identifiable {
    case all
    case free
    case pro

    var id: String { rawValue }

    var title: String {
        switch self {
        case .all:
            "全部"
        case .free:
            "免费"
        case .pro:
            "Pro"
        }
    }
}

#Preview {
    NavigationStack {
        StylePickerView()
            .environmentObject(StyleStore())
            .environmentObject(DisplayConfigStore())
    }
}
