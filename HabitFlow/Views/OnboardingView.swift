import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject private var appVM: AppViewModel
    @Environment(\.horizontalSizeClass) private var hSizeClass

    private let primary = Color.primaryPurple
    private let accent  = Color.accentCyan

    @State private var selection: Int = 0

    private let slides: [OnboardingSlide] = [
        .init(
            title: "Добро пожаловать в HabitFlow",
            subtitle: "Создавайте привычки и двигайтесь к цели маленькими шагами каждый день.",
            systemImage: "sparkles"
        ),
        .init(
            title: "План на неделю",
            subtitle: "Задайте цель: сколько раз в неделю выполнять привычку — и держите фокус.",
            systemImage: "calendar"
        ),
        .init(
            title: "Отмечайте прогресс",
            subtitle: "Отмечайте выполнение и наблюдайте, как растёт ваша серия и уверенность.",
            systemImage: "checkmark.seal"
        ),
        .init(
            title: "Напоминания",
            subtitle: "Включайте мягкие напоминания, чтобы не забывать о важном.",
            systemImage: "bell.badge"
        )
    ]

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    primary.opacity(0.22),
                    Color.black.opacity(0.94)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: hSizeClass == .regular ? 24 : 18) {
                header

                TabView(selection: $selection) {
                    ForEach(Array(slides.enumerated()), id: \.offset) { index, slide in
                        OnboardingSlideView(
                            slide: slide,
                            primary: primary,
                            accent: accent
                        )
                        .tag(index)
                        .padding(.horizontal)
                        .transition(.opacity.combined(with: .scale))
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                .indexViewStyle(.page(backgroundDisplayMode: .interactive))
                .animation(.easeInOut(duration: 0.25), value: selection)

                footer
            }
            .padding(.vertical, 18)
        }
        .tint(accent)
        .dynamicTypeSize(.small ... .accessibility3)
    }

    // MARK: - Header

    private var header: some View {
        HStack {
            Button("Пропустить") {
                finish()
            }
            .font(.system(.body, design: .rounded).weight(.semibold))
            .foregroundStyle(.white.opacity(0.9))
            .opacity(isLast ? 0 : 1)
            .disabled(isLast)

            Spacer()

            Text("\(selection + 1)/\(slides.count)")
                .font(.system(.subheadline, design: .rounded).weight(.semibold))
                .foregroundStyle(.white.opacity(0.55))
        }
        .padding(.horizontal)
    }

    // MARK: - Footer

    private var footer: some View {
        HStack(spacing: hSizeClass == .regular ? 16 : 12) {
            if isLast {
                Button {
                    finish()
                } label: {
                    Text("Начать")
                        .font(.system(.headline, design: .rounded).weight(.bold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            LinearGradient(
                                colors: [accent, primary],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .foregroundStyle(.black)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .shadow(color: accent.opacity(0.25), radius: 14, x: 0, y: 8)
                }
                .accessibilityLabel("Начать использование приложения")
            } else {
                Button {
                    next()
                } label: {
                    HStack(spacing: 10) {
                        Text("Далее")
                            .font(.system(.headline, design: .rounded).weight(.bold))
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(primary.opacity(0.35))
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(accent.opacity(0.35), lineWidth: 1)
                    )
                }

                Button {
                    finish()
                } label: {
                    Text("Пропустить")
                        .font(.system(.headline, design: .rounded).weight(.semibold))
                        .frame(width: 130)
                        .padding(.vertical, 14)
                        .background(Color.white.opacity(0.08))
                        .foregroundStyle(.white.opacity(0.9))
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
                .accessibilityLabel("Пропустить онбординг")
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 10)
    }

    // MARK: - Actions

    private var isLast: Bool { selection == slides.count - 1 }

    private func next() {
        withAnimation(.easeInOut(duration: 0.25)) {
            selection = min(selection + 1, slides.count - 1)
        }
    }

    private func finish() {
        withAnimation(.easeInOut(duration: 0.25)) {
            appVM.completeOnboarding()
        }
    }
}

// MARK: - Slide Models & UI

private struct OnboardingSlide: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let subtitle: String
    let systemImage: String
}

private struct OnboardingSlideView: View {
    let slide: OnboardingSlide
    let primary: Color
    let accent: Color

    @State private var appear: Bool = false

    var body: some View {
        VStack(spacing: 18) {
            Spacer(minLength: 6)

            ZStack {
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(primary.opacity(0.20))
                    .frame(width: 160, height: 160)
                    .overlay(
                        RoundedRectangle(cornerRadius: 28, style: .continuous)
                            .stroke(accent.opacity(0.22), lineWidth: 1)
                    )
                    .blur(radius: 0)
                    .shadow(color: primary.opacity(0.35), radius: 18, x: 0, y: 10)

                Image(systemName: slide.systemImage)
                    .font(.system(size: 54, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [accent, .white],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .scaleEffect(appear ? 1.0 : 0.92)
                    .opacity(appear ? 1.0 : 0.0)
                    .animation(.easeOut(duration: 0.35), value: appear)
            }
            .padding(.bottom, 6)

            Text(slide.title)
                .font(.system(.title2, design: .rounded).weight(.bold))
                .multilineTextAlignment(.center)
                .foregroundStyle(.white)
                .opacity(appear ? 1.0 : 0.0)
                .offset(y: appear ? 0 : 8)
                .animation(.easeOut(duration: 0.35).delay(0.05), value: appear)

            Text(slide.subtitle)
                .font(.system(.body, design: .rounded))
                .multilineTextAlignment(.center)
                .foregroundStyle(.white.opacity(0.75))
                .lineSpacing(3)
                .padding(.horizontal, 8)
                .opacity(appear ? 1.0 : 0.0)
                .offset(y: appear ? 0 : 8)
                .animation(.easeOut(duration: 0.35).delay(0.10), value: appear)

            Spacer(minLength: 10)
        }
        .onAppear { appear = true }
        .onDisappear { appear = false }
        .contentShape(Rectangle())
    }
}
