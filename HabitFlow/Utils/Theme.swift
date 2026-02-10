import SwiftUI

// MARK: - Color + Hex

extension Color {
    /// Инициализатор из hex-строки вида "8A2BE2" или "#8A2BE2".
    init?(hex: String) {
        let cleaned = hex
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "#", with: "")
            .uppercased()

        guard cleaned.count == 6,
              let value = UInt64(cleaned, radix: 16) else {
            return nil
        }

        let r = Double((value & 0xFF0000) >> 16) / 255.0
        let g = Double((value & 0x00FF00) >> 8) / 255.0
        let b = Double(value & 0x0000FF) / 255.0

        self.init(red: r, green: g, blue: b)
    }

    // MARK: - App Palette

    /// Основной фиолетовый цвет приложения.
    static let primaryPurple = Color(hex: "8A2BE2") ?? Color.purple

    /// Акцентный циановый цвет.
    static let accentCyan = Color(hex: "00FFFF") ?? Color.cyan
}

// MARK: - View Modifiers

private struct CardBackgroundModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(16)
            .background(Color.white.opacity(0.07))
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.35), radius: 14, x: 0, y: 10)
    }
}

private struct GradientButtonModifier: ViewModifier {
    let primary: Color
    let accent: Color

    func body(content: Content) -> some View {
        content
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity)
            .background(
                LinearGradient(
                    colors: [accent, primary],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .foregroundStyle(Color.black)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .shadow(color: accent.opacity(0.35), radius: 16, x: 0, y: 8)
    }
}

// MARK: - View + Theme helpers

extension View {
    /// Карточка в стиле HabitFlow (тот же стиль, что и в Today/Settings/Calendar).
    func habitCardStyle() -> some View {
        modifier(CardBackgroundModifier())
    }

    /// Градиентная кнопка в стиле HabitFlow.
    func habitGradientButton(
        primary: Color = .primaryPurple,
        accent: Color = .accentCyan
    ) -> some View {
        modifier(GradientButtonModifier(primary: primary, accent: accent))
    }
}

