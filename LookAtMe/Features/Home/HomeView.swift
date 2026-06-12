import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()

    private let templateColumns = [
        GridItem(.flexible(), spacing: LookSpacing.sm),
        GridItem(.flexible(), spacing: LookSpacing.sm)
    ]

    var body: some View {
        ZStack(alignment: .top) {
            LookScreenBackground()

            ScrollView(showsIndicators: false) {
                VStack(spacing: LookSpacing.sectionSpacing) {
                    brandHeader

                    NeonTextInput(
                        text: $viewModel.text,
                        limit: HomeViewModel.textLimit,
                        placeholder: "输入你想表达的话…",
                        example: "例如：周深我爱你！💗"
                    )

                    sceneShortcuts
                    templatesSection
                    stylesSection
                }
                .padding(.horizontal, LookSpacing.pageHorizontal)
                .padding(.top, LookSpacing.lg)
                .padding(.bottom, 108)
            }
        }
        .safeAreaInset(edge: .bottom) {
            startButton
                .padding(.horizontal, LookSpacing.pageHorizontal)
                .padding(.top, LookSpacing.sm)
                .padding(.bottom, LookSpacing.sm)
                .background(
                    LinearGradient(
                        colors: [
                            LookTheme.Colors.backgroundBlack.opacity(0),
                            LookTheme.Colors.backgroundBlack.opacity(0.92)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .ignoresSafeArea()
                )
        }
        .overlay(alignment: .top) {
            if let message = viewModel.toastMessage {
                ToastView(message: message)
                    .padding(.top, LookSpacing.lg)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.28, dampingFraction: 0.86), value: viewModel.toastMessage)
        .onChange(of: viewModel.toastMessage) { _, message in
            guard message != nil else {
                return
            }
            Task { @MainActor in
                try? await Task.sleep(for: .seconds(1.7))
                viewModel.toastMessage = nil
            }
        }
        .fullScreenCover(isPresented: $viewModel.isShowingDisplayPreview) {
            LEDDisplayPreviewView(draft: viewModel.currentDraft)
        }
        .sheet(isPresented: $viewModel.isShowingMore) {
            MoreFeaturesPlaceholderView()
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
    }

    private var brandHeader: some View {
        ZStack(alignment: .topTrailing) {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            LookTheme.Colors.backgroundBlack.opacity(0.98),
                            LookTheme.Colors.elevatedPurple.opacity(0.76),
                            LookTheme.Colors.cardPurple.opacity(0.92)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .stroke(LookTheme.neonBorderGradient, lineWidth: 1)
                )
                .shadow(color: LookTheme.Colors.primaryPink.opacity(0.24), radius: 24, y: 14)

            RadialGradient(
                colors: [
                    LookTheme.Colors.primaryPink.opacity(0.46),
                    LookTheme.Colors.neonPurple.opacity(0.18),
                    .clear
                ],
                center: .topLeading,
                startRadius: 8,
                endRadius: 240
            )
            .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))

            VStack(alignment: .leading, spacing: LookSpacing.md) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: LookSpacing.xs) {
                        Text("想恋爱")
                            .font(.system(size: 38, weight: .heavy, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [
                                        LookTheme.Colors.textPrimary,
                                        LookTheme.Colors.softPink,
                                        LookTheme.Colors.primaryPink
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .shadow(color: LookTheme.Colors.primaryPink.opacity(0.88), radius: 12)

                        Text("让全世界看到你的爱")
                            .font(LookTypography.body)
                            .foregroundColor(LookTheme.Colors.softPink)
                    }

                    Spacer()

                    Button {
                        viewModel.showProEntryPlaceholder()
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "crown.fill")
                            Text("Pro")
                        }
                        .font(.system(size: 12, weight: .heavy, design: .rounded))
                        .foregroundColor(LookTheme.Colors.warmYellow)
                        .padding(.horizontal, LookSpacing.sm)
                        .padding(.vertical, LookSpacing.xs)
                        .background(
                            Capsule()
                                .fill(LookTheme.Colors.backgroundBlack.opacity(0.72))
                                .overlay(
                                    Capsule()
                                        .stroke(LookTheme.Colors.warmYellow.opacity(0.48), lineWidth: 1)
                                )
                        )
                    }
                    .buttonStyle(.plain)
                }

                HStack(spacing: LookSpacing.xs) {
                    Image(systemName: "sparkles")
                    Text("让 iPhone 变成会发光的表白灯牌")
                }
                .font(LookTypography.caption)
                .foregroundColor(LookTheme.Colors.textSecondary)
                .padding(.horizontal, LookSpacing.sm)
                .padding(.vertical, LookSpacing.xs)
                .background(Capsule().fill(LookTheme.Colors.backgroundBlack.opacity(0.42)))
            }
            .padding(LookSpacing.lg)
        }
        .frame(minHeight: 156)
    }

    private var sceneShortcuts: some View {
        VStack(alignment: .leading, spacing: LookSpacing.sm) {
            SectionHeader("选择场景")

            HStack(spacing: LookSpacing.sm) {
                ForEach(BannerScene.allCases) { scene in
                    SceneShortcutButton(
                        title: scene.title,
                        systemImage: scene.symbolName,
                        tint: scene.accentColor,
                        isSelected: viewModel.selectedScene == scene
                    ) {
                        viewModel.selectScene(scene)
                    }
                }

                SceneShortcutButton(
                    title: "更多",
                    systemImage: "square.grid.2x2.fill",
                    tint: LookTheme.Colors.neonPurple,
                    isSelected: false
                ) {
                    viewModel.showMorePlaceholder()
                }
            }
        }
    }

    private var templatesSection: some View {
        VStack(alignment: .leading, spacing: LookSpacing.sm) {
            SectionHeader("热门模板 🔥") {
                Button("更多 >") {
                    viewModel.showMorePlaceholder()
                }
                .font(LookTypography.caption)
                .foregroundColor(LookTheme.Colors.hotPink)
            }

            LazyVGrid(columns: templateColumns, spacing: LookSpacing.sm) {
                ForEach(viewModel.templates) { template in
                    TemplateChip(title: template.title) {
                        viewModel.applyTemplate(template)
                    }
                }
            }
        }
    }

    private var stylesSection: some View {
        VStack(alignment: .leading, spacing: LookSpacing.sm) {
            SectionHeader("样式选择") {
                Button("更多 >") {
                    viewModel.showMorePlaceholder()
                }
                .font(LookTypography.caption)
                .foregroundColor(LookTheme.Colors.hotPink)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: LookSpacing.sm) {
                    ForEach(viewModel.styles) { style in
                        StyleCard(
                            style: style,
                            isSelected: viewModel.selectedStyle == style
                        ) {
                            viewModel.selectStyle(style)
                        }
                        .frame(width: 138)
                    }
                }
                .padding(.vertical, LookSpacing.xs)
            }
        }
    }

    private var startButton: some View {
        Button {
            viewModel.startDisplay()
        } label: {
            HStack(spacing: LookSpacing.sm) {
                Text("开始展示")
                    .font(LookTypography.button)

                Image(systemName: "play.fill")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(LookTheme.Colors.primaryPink)
                    .frame(width: 30, height: 30)
                    .background(Circle().fill(LookTheme.Colors.textPrimary))
            }
            .foregroundColor(LookTheme.Colors.textPrimary)
            .frame(maxWidth: .infinity, minHeight: 56)
            .background(LookTheme.primaryButtonGradient)
            .clipShape(Capsule())
            .overlay(Capsule().stroke(LookTheme.Colors.softPink.opacity(0.56), lineWidth: 1))
            .shadow(color: LookTheme.Colors.primaryPink.opacity(0.58), radius: 18, y: 8)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    HomeView()
}

