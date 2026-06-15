import SwiftUI

struct TemplateCenterView: View {
    let onUseTemplate: (BannerTemplate) -> Void

    @EnvironmentObject private var templateStore: TemplateStore
    @EnvironmentObject private var displayConfigStore: DisplayConfigStore
    @EnvironmentObject private var styleStore: StyleStore
    @EnvironmentObject private var favoriteStore: FavoriteStore
    @State private var selectedScene: BannerScene = .concert
    @State private var toastMessage: String?

    var body: some View {
        ZStack {
            LookScreenBackground()

            VStack(alignment: .leading, spacing: 0) {
                fixedHeader

                ScrollView(showsIndicators: false) {
                    VStack(spacing: LookSpacing.sm) {
                        ForEach(templateStore.templates(for: selectedScene)) { template in
                            templateRow(template)
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
                title: "模板中心",
                subtitle: "长按模板可快速使用或收藏"
            )

            sceneTabs
        }
        .padding(.horizontal, LookSpacing.pageHorizontal)
        .padding(.top, LookSpacing.lg)
        .padding(.bottom, LookSpacing.md)
    }

    private var sceneTabs: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: LookSpacing.sm) {
                ForEach(templateStore.allScenes) { scene in
                    Button {
                        selectedScene = scene
                    } label: {
                        HStack(spacing: LookSpacing.xs) {
                            Image(systemName: scene.symbolName)
                            Text(scene.title)
                        }
                        .font(LookTypography.caption.weight(.semibold))
                        .foregroundColor(selectedScene == scene ? LookTheme.Colors.textPrimary : LookTheme.Colors.textTertiary)
                        .padding(.horizontal, LookSpacing.md)
                        .padding(.vertical, LookSpacing.xs)
                        .background(
                            Capsule()
                                .fill(selectedScene == scene ? LookTheme.Colors.primaryPink.opacity(0.28) : LookTheme.Colors.cardPurple.opacity(0.92))
                        )
                        .overlay(
                            Capsule()
                                .stroke(selectedScene == scene ? LookTheme.Colors.primaryPink : LookTheme.Colors.primaryPink.opacity(0.22), lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.vertical, LookSpacing.xs)
        }
    }

    private func templateRow(_ template: BannerTemplate) -> some View {
        Button {
            onUseTemplate(template)
        } label: {
            NeonCard(padding: LookSpacing.md) {
                HStack(spacing: LookSpacing.md) {
                    ZStack {
                        RoundedRectangle(cornerRadius: LookRadius.chip, style: .continuous)
                            .fill(LookTheme.Colors.backgroundBlack.opacity(0.86))
                            .frame(width: 54, height: 54)
                            .overlay(
                                RoundedRectangle(cornerRadius: LookRadius.chip, style: .continuous)
                                    .stroke(template.scene.accentColor.opacity(0.58), lineWidth: 1)
                            )

                        Image(systemName: template.scene.symbolName)
                            .font(.system(size: 21, weight: .bold, design: .rounded))
                            .foregroundColor(template.scene.accentColor)
                    }

                    VStack(alignment: .leading, spacing: LookSpacing.xxs) {
                        Text(template.title)
                            .font(LookTypography.sectionTitle)
                            .foregroundColor(LookTheme.Colors.textPrimary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.78)
                        Text(template.scene.title)
                            .font(LookTypography.caption)
                            .foregroundColor(LookTheme.Colors.textTertiary)
                    }

                    Spacer()

                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(LookTheme.Colors.primaryPink)
                }
            }
        }
        .buttonStyle(.plain)
        .contextMenu {
            Button {
                onUseTemplate(template)
            } label: {
                Label("使用", systemImage: "arrow.turn.down.left")
            }

            Button {
                favoriteStore.addTemplate(template, displayConfigStore: displayConfigStore, styleStore: styleStore)
                toastMessage = "已收藏模板"
            } label: {
                Label("收藏", systemImage: "heart.fill")
            }
        }
    }
}

#Preview {
    NavigationStack {
        TemplateCenterView(onUseTemplate: { _ in })
            .environmentObject(TemplateStore())
            .environmentObject(DisplayConfigStore())
            .environmentObject(StyleStore())
            .environmentObject(FavoriteStore())
    }
}
