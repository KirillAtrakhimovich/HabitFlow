import SwiftUI

struct HabitRow: View {
    let habit: Habit
    let primary: Color
    let accent: Color
    let onComplete: (() -> Void)?
    let onEdit: (() -> Void)?
    let onDelete: (() -> Void)?

    private var isCompleted: Bool {
        habit.isCompletedToday
    }
    
    // MARK: - Computed Properties для стилей
    private var habitColor: Color {
        habit.color
    }
    
    private var iconBackground: Color {
        if isCompleted {
            return habitColor.opacity(0.35)
        } else {
            return habitColor.opacity(0.14)
        }
    }
    
    private var iconBorder: Color {
        if isCompleted {
            return habitColor.opacity(0.7)
        } else {
            return habitColor.opacity(0.15)
        }
    }
    
    private var checkFill: Color {
        if isCompleted {
            return habitColor.opacity(0.95)
        } else {
            return Color.white.opacity(0.10)
        }
    }
    
    private var checkForeground: Color {
        isCompleted ? .black : .white.opacity(0.65)
    }
    
    private var cardBackground: Color {
        if isCompleted {
            return habitColor.opacity(0.25)
        } else {
            return habitColor.opacity(0.15)
        }
    }
    
    private var cardBorder: Color {
        if isCompleted {
            return habitColor.opacity(0.6)
        } else {
            return habitColor.opacity(0.3)
        }
    }
    
    private var cardShadow: Color {
        if isCompleted {
            return habitColor.opacity(0.5)
        } else {
            return habitColor.opacity(0.3)
        }
    }
    
    private var titleColor: Color {
        if isCompleted {
            return habitColor.opacity(0.9)
        } else {
            return .white
        }
    }
    
    private var subtitleColor: Color {
        if isCompleted {
            return habitColor.opacity(0.9)
        } else {
            return .white.opacity(0.7)
        }
    }

    var body: some View {
        cardContent
            .contentShape(Rectangle())
            .onTapGesture {
                // Выполняем привычку только если она не выполнена
                if !isCompleted {
                    onComplete?()
                }
            }
            .contextMenu {
                Button {
                    onEdit?()
                } label: {
                    Label("Редактировать", systemImage: "pencil")
                }
                
                Button(role: .destructive) {
                    onDelete?()
                } label: {
                    Label("Удалить", systemImage: "trash")
                }
            }
            .animation(.easeInOut(duration: 0.3), value: isCompleted)
    }
    
    // MARK: - Card Content
    private var cardContent: some View {
        HStack(spacing: 12) {
            iconTile
            
            VStack(alignment: .leading, spacing: 3) {
                Text(habit.title)
                    .font(.system(.headline, design: .rounded).weight(.bold))
                    .foregroundStyle(titleColor)
                    .strikethrough(isCompleted, color: habitColor.opacity(0.7))
                
                if habit.streakCount > 0 {
                    HStack(spacing: 4) {
                        if isCompleted {
                            Image(systemName: "star.fill")
                                .font(.system(size: 10))
                                .foregroundStyle(habitColor)
                        } else {
                            Text("🔥")
                        }
                        Text(streakText)
                            .font(.system(.footnote, design: .rounded))
                    }
                    .foregroundStyle(subtitleColor)
                } else if isCompleted {
                    Text("✨ Выполнено")
                        .font(.system(.footnote, design: .rounded))
                        .foregroundStyle(habitColor.opacity(0.8))
                } else {
                    Text("Нажмите, чтобы отметить")
                        .font(.system(.footnote, design: .rounded))
                        .foregroundStyle(subtitleColor)
                }
            }
            
            Spacer()
            
            if !isCompleted {
                Image(systemName: "chevron.down")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(.white.opacity(0.3))
                    .padding(.trailing, 4)
            }
            
            checkmark
        }
        .padding(14)
        .background(cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(cardOverlay)
        .shadow(color: cardShadow, radius: 12, x: 0, y: 8)
    }
    
    // MARK: - Subviews
    private var iconTile: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(iconBackground)
                .frame(width: 48, height: 48)
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(iconBorder, lineWidth: 1)
                )

            Image(systemName: habit.iconName)
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(isCompleted ? habitColor : .white)
                .opacity(isCompleted ? 1.0 : 0.9)
        }
    }

    private var checkmark: some View {
        ZStack {
            Circle()
                .fill(checkFill)
                .frame(width: 28, height: 28)
                .overlay(
                    Circle()
                        .stroke(isCompleted ? habitColor.opacity(0.8) : Color.clear, lineWidth: 1)
                )

            Image(systemName: isCompleted ? "star.fill" : "circle")
                .font(.system(size: isCompleted ? 12 : 14, weight: .bold))
                .foregroundStyle(checkForeground)
        }
    }

    private var cardOverlay: some View {
        RoundedRectangle(cornerRadius: 18, style: .continuous)
            .stroke(cardBorder, lineWidth: 1)
    }
    
    private var streakText: String {
        if isCompleted {
            return "\(habit.streakCount) \(dayWord) подряд"
        } else {
            return "\(habit.streakCount) дней подряд"
        }
    }
    
    private var dayWord: String {
        let count = habit.streakCount % 10
        let hundred = habit.streakCount % 100
        
        if hundred >= 11 && hundred <= 19 {
            return "дней"
        }
        
        switch count {
        case 1: return "день"
        case 2, 3, 4: return "дня"
        default: return "дней"
        }
    }
}

// MARK: - Preview
#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        
        VStack {
            HabitRow(
                habit: Habit(
                    id: UUID(),
                    title: "Пить воду",
                    iconName: "drop.fill",
                    colorName: "Голубой",
                    createdAt: Date(),
                    completedDates: []
                ),
                primary: Color(red: 0.75, green: 0.70, blue: 0.90),
                accent: Color(red: 0.55, green: 0.75, blue: 0.80),
                onComplete: {},
                onEdit: {},
                onDelete: {}
            )
            
            HabitRow(
                habit: Habit(
                    id: UUID(),
                    title: "Зарядка",
                    iconName: "figure.run",
                    colorName: "Зелёный",
                    createdAt: Date(),
                    completedDates: [Date()]
                ),
                primary: Color(red: 0.75, green: 0.70, blue: 0.90),
                accent: Color(red: 0.55, green: 0.75, blue: 0.80),
                onComplete: nil,
                onEdit: {},
                onDelete: {}
            )
        }
        .padding()
    }
}


