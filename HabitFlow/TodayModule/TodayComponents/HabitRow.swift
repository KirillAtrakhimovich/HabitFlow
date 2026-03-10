import SwiftUI

struct HabitRow: View {
    @ObservedObject var habit: HabitCD
    let isCompleted: Bool
    let primary: Color
    let accent: Color
    let onToggle: () -> Void

    // MARK: - Computed Properties для стилей
    private var iconBackground: Color {
        isCompleted ? accent.opacity(0.25) : accent.opacity(0.14)
    }
    
    private var iconBorder: Color {
        isCompleted ? accent.opacity(0.55) : accent.opacity(0.15)
    }
    
    private var checkFill: Color {
        isCompleted ? accent.opacity(0.95) : Color.white.opacity(0.10)
    }
    
    private var checkForeground: Color {
        isCompleted ? .black : .white.opacity(0.65)
    }
    
    private var cardBackground: Color {
        isCompleted ? primary.opacity(0.30) : primary.opacity(0.15)
    }
    
    private var cardBorder: Color {
        isCompleted ? accent.opacity(0.45) : Color.white.opacity(0.06)
    }
    
    private var cardShadow: Color {
        Color.black.opacity(isCompleted ? 0.45 : 0.30)
    }

    var body: some View {
        Button(action: onToggle) {
            rowContent
                .padding(14)
                .background(cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .overlay(cardOverlay)
                .shadow(color: cardShadow, radius: 12, x: 0, y: 8)
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.2), value: isCompleted)
    }

    // MARK: - Subviews
    private var rowContent: some View {
        HStack(spacing: 12) {
            iconTile
            
            VStack(alignment: .leading, spacing: 3) {
                Text(habit.title ?? "Без названия")
                    .font(.system(.headline, design: .rounded).weight(.bold))
                    .foregroundStyle(.white)
                
                // Временный текст, пока нет данных в Core Data
                Text("Нажмите, чтобы отметить")
                    .font(.system(.footnote, design: .rounded))
                    .foregroundStyle(.white.opacity(0.5))
            }
            
            Spacer()
            checkmark
        }
    }

    private var iconTile: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(iconBackground)
                .frame(width: 48, height: 48)
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(iconBorder, lineWidth: 1)
                )

            Image(systemName: habit.iconName ?? "star.fill")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(.white)
                .opacity(isCompleted ? 1.0 : 0.9)
        }
    }

    private var checkmark: some View {
        ZStack {
            Circle()
                .fill(checkFill)
                .frame(width: 28, height: 28)

            Image(systemName: isCompleted ? "checkmark" : "circle")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(checkForeground)
        }
    }

    private var cardOverlay: some View {
        RoundedRectangle(cornerRadius: 18, style: .continuous)
            .stroke(cardBorder, lineWidth: 1)
    }
}
