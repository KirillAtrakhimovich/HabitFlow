import SwiftUI

struct HabitDetailView: View {
    let habit: Habit
    @Environment(\.dismiss) private var dismiss
    @Environment(\.horizontalSizeClass) private var hSizeClass
    
    // Theme
    private let primary = Color.primaryPurple
    private let accent  = Color.accentCyan
    private let success = Color.green
    
    // State
    @State private var showEditSheet = false
    @State private var showArchiveAlert = false
    
    // Demo completion history (replace with real DailyRecord queries later)
    @State private var completionHistory: [DateOnly] = []
    @State private var successRate: Double = 0.0
    
    // Callbacks
    var onEdit: ((Habit) -> Void)?
    var onArchive: ((UUID) -> Void)?
    var onDelete: ((UUID) -> Void)?
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: hSizeClass == .regular ? 20 : 16) {
                        headerCard
                        statsCard
                        historyCard
                        
                        Spacer(minLength: 20)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 12)
                }
            }
            .navigationTitle("Детали")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button {
                            showEditSheet = true
                        } label: {
                            Label("Редактировать", systemImage: "pencil")
                        }
                        
                        Divider()
                        
                        Button(role: .destructive) {
                            showArchiveAlert = true
                        } label: {
                            Label("Архивировать", systemImage: "archivebox")
                        }
                        
                        Button(role: .destructive) {
                            onDelete?(habit.id)
                            dismiss()
                        } label: {
                            Label("Удалить", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .foregroundStyle(.white)
                    }
                }
            }
            .tint(accent)
            .onAppear {
                loadHistory()
            }
            .sheet(isPresented: $showEditSheet) {
                EditHabitView(habit: habit) { updatedHabit in
                    onEdit?(updatedHabit)
                    dismiss()
                }
            }
            .alert("Архивировать привычку?", isPresented: $showArchiveAlert) {
                Button("Отмена", role: .cancel) { }
                Button("Архивировать") {
                    onArchive?(habit.id)
                    dismiss()
                }
            } message: {
                Text("Привычка будет перемещена в архив. Вы сможете восстановить её позже.")
            }
        }
        .dynamicTypeSize(.small ... .accessibility3)
    }
    
    // MARK: - Cards
    
    private var headerCard: some View {
        Card {
            VStack(spacing: 16) {
                // Icon & Title
                HStack(spacing: 14) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(colorForHex(habit.colorHex).opacity(0.25))
                            .frame(width: 70, height: 70)
                            .overlay(
                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                    .stroke(accent.opacity(0.35), lineWidth: 1.5)
                            )
                        
                        Image(systemName: habit.iconName)
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                    }
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text(habit.title)
                            .font(.system(.title2, design: .rounded).weight(.bold))
                            .foregroundStyle(.white)
                        
                        Text("Цель: \(habit.goalTimesPerWeek) раз(а) в неделю")
                            .font(.system(.subheadline, design: .rounded))
                            .foregroundStyle(.white.opacity(0.7))
                    }
                    
                    Spacer()
                }
                
                Divider()
                    .background(Color.white.opacity(0.15))
                
                // Reminder info
                if let reminder = habit.reminderTime, let hour = reminder.hour, let minute = reminder.minute {
                    HStack(spacing: 10) {
                        Image(systemName: "bell.fill")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundStyle(accent)
                        
                        Text("Напоминание: \(String(format: "%02d:%02d", hour, minute))")
                            .font(.system(.subheadline, design: .rounded).weight(.semibold))
                            .foregroundStyle(.white.opacity(0.85))
                        
                        Spacer()
                    }
                } else {
                    HStack(spacing: 10) {
                        Image(systemName: "bell.slash")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundStyle(.white.opacity(0.5))
                        
                        Text("Напоминания отключены")
                            .font(.system(.subheadline, design: .rounded))
                            .foregroundStyle(.white.opacity(0.6))
                        
                        Spacer()
                    }
                }
            }
        }
    }
    
    private var statsCard: some View {
        Card {
            VStack(alignment: .leading, spacing: 14) {
                Text("Статистика")
                    .font(.system(.headline, design: .rounded).weight(.bold))
                    .foregroundStyle(.white)
                
                // Success rate
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Процент успеха")
                            .font(.system(.subheadline, design: .rounded).weight(.semibold))
                            .foregroundStyle(.white.opacity(0.85))
                        
                        Spacer()
                        
                        Text("\(Int(successRate * 100))%")
                            .font(.system(.title3, design: .rounded).weight(.bold))
                            .foregroundStyle(successRate >= 0.7 ? success : accent)
                    }
                    
                    ProgressBar(progress: successRate, primary: primary, accent: accent, success: success)
                        .frame(height: 12)
                }
                
                Divider()
                    .background(Color.white.opacity(0.15))
                
                // Stats grid
                HStack(spacing: 20) {
                    StatItem(
                        title: "Выполнено",
                        value: "\(completionHistory.count)",
                        icon: "checkmark.circle.fill",
                        color: success
                    )
                    
                    Divider()
                        .frame(height: 40)
                        .background(Color.white.opacity(0.15))
                    
                    StatItem(
                        title: "Цель/неделю",
                        value: "\(habit.goalTimesPerWeek)",
                        icon: "target",
                        color: accent
                    )
                    
                    Divider()
                        .frame(height: 40)
                        .background(Color.white.opacity(0.15))
                    
                    StatItem(
                        title: "Создана",
                        value: daysSinceCreated,
                        icon: "calendar",
                        color: primary
                    )
                }
            }
        }
    }
    
    private var historyCard: some View {
        Card {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("История выполнения")
                        .font(.system(.headline, design: .rounded).weight(.bold))
                        .foregroundStyle(.white)
                    
                    Spacer()
                    
                    if !completionHistory.isEmpty {
                        Text("\(completionHistory.count) записей")
                            .font(.system(.caption, design: .rounded))
                            .foregroundStyle(.white.opacity(0.6))
                    }
                }
                
                if completionHistory.isEmpty {
                    emptyHistoryView
                } else {
                    historyList
                }
            }
        }
    }
    
    private var emptyHistoryView: some View {
        VStack(spacing: 10) {
            Image(systemName: "calendar.badge.clock")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundStyle(.white.opacity(0.4))
            
            Text("Пока нет записей")
                .font(.system(.subheadline, design: .rounded).weight(.semibold))
                .foregroundStyle(.white.opacity(0.7))
            
            Text("Отмечайте выполнение на главном экране")
                .font(.system(.caption, design: .rounded))
                .foregroundStyle(.white.opacity(0.5))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
    }
    
    private var historyList: some View {
        VStack(spacing: 0) {
            ForEach(Array(completionHistory.enumerated()), id: \.element) { index, date in
                HistoryRow(date: date, isLast: index == completionHistory.count - 1)
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var daysSinceCreated: String {
        let days = Calendar.current.dateComponents([.day], from: habit.createdAt, to: Date()).day ?? 0
        if days == 0 { return "Сегодня" }
        if days == 1 { return "1 день" }
        if days < 7 { return "\(days) дня" }
        if days < 30 { return "\(days / 7) нед." }
        return "\(days / 30) мес."
    }
    
    // MARK: - Methods
    
    private func loadHistory() {
        // Demo data generation (replace with real DailyRecord queries)
        let calendar = Calendar.current
        let today = DateOnly(date: Date())
        var history: [DateOnly] = []
        
        // Generate some random completion dates for demo
        for i in 0..<30 {
            guard let date = calendar.date(byAdding: .day, value: -i, to: Date()) else { continue }
            let dateOnly = DateOnly(date: date)
            
            // Simulate ~60% completion rate
            let shouldInclude = (dateOnly.day * 7 + dateOnly.month * 3) % 10 < 6
            if shouldInclude && dateOnly <= today {
                history.append(dateOnly)
            }
        }
        
        completionHistory = history.sorted(by: >) // newest first
        
        // Calculate success rate (based on goal)
        let weeksSinceStart = max(1, daysSinceCreated.split(separator: " ").first.flatMap { Int($0) } ?? 1)
        let expectedCompletions = habit.goalTimesPerWeek * weeksSinceStart
        successRate = expectedCompletions > 0 ? min(1.0, Double(history.count) / Double(expectedCompletions)) : 0.0
    }
    
    private func colorForHex(_ hex: String) -> Color {
        if let color = Color(hex: hex) {
            return color
        }
        return Color.primaryPurple
    }
}

// MARK: - Components

private struct StatItem: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundStyle(color)
            
            Text(value)
                .font(.system(.headline, design: .rounded).weight(.bold))
                .foregroundStyle(.white)
            
            Text(title)
                .font(.system(.caption2, design: .rounded))
                .foregroundStyle(.white.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
    }
}

private struct HistoryRow: View {
    let date: DateOnly
    let isLast: Bool
    
    private let success = Color.green
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(success.opacity(0.2))
                    .frame(width: 36, height: 36)
                
                Image(systemName: "checkmark")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(success)
            }
            
            VStack(alignment: .leading, spacing: 3) {
                Text(formattedDate(date))
                    .font(.system(.subheadline, design: .rounded).weight(.semibold))
                    .foregroundStyle(.white)
                
                Text(relativeDate(date))
                    .font(.system(.caption, design: .rounded))
                    .foregroundStyle(.white.opacity(0.6))
            }
            
            Spacer()
        }
        .padding(.vertical, 10)
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundStyle(Color.white.opacity(0.08))
                .offset(y: isLast ? 0 : 20),
            alignment: .bottom
        )
    }
    
    private func formattedDate(_ d: DateOnly) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateStyle = .long
        return formatter.string(from: d.toDate())
    }
    
    private func relativeDate(_ d: DateOnly) -> String {
        let calendar = Calendar.current
        let today = DateOnly(date: Date())
        let daysDiff = calendar.dateComponents([.day], from: d.toDate(), to: today.toDate()).day ?? 0
        
        if daysDiff == 0 { return "Сегодня" }
        if daysDiff == 1 { return "Вчера" }
        if daysDiff < 7 { return "\(daysDiff) дня назад" }
        if daysDiff < 30 { return "\(daysDiff / 7) недели назад" }
        return "\(daysDiff / 30) месяца назад"
    }
}

private struct ProgressBar: View {
    let progress: Double
    let primary: Color
    let accent: Color
    let success: Color
    
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(Color.white.opacity(0.10))
                
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(LinearGradient(colors: [success, accent, primary], startPoint: .leading, endPoint: .trailing))
                    .frame(width: geo.size.width * CGFloat(min(1, max(0, progress))))
                    .animation(.easeInOut(duration: 0.2), value: progress)
            }
        }
    }
}

private struct Card<Content: View>: View {
    @ViewBuilder var content: Content
    
    var body: some View {
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

// MARK: - Edit Habit View (Simplified)

private struct EditHabitView: View {
    let habit: Habit
    let onSave: (Habit) -> Void
    @Environment(\.dismiss) private var dismiss
    
    @State private var title: String
    @State private var goalTimesPerWeek: Int
    
    init(habit: Habit, onSave: @escaping (Habit) -> Void) {
        self.habit = habit
        self.onSave = onSave
        _title = State(initialValue: habit.title)
        _goalTimesPerWeek = State(initialValue: habit.goalTimesPerWeek)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 16) {
                    TextField("Название", text: $title)
                        .textInputAutocapitalization(.sentences)
                        .padding(12)
                        .background(Color.white.opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .foregroundStyle(.white)
                    
                    Stepper("Цель: \(goalTimesPerWeek) раз(а) в неделю", value: $goalTimesPerWeek, in: 1...14)
                        .foregroundStyle(.white)
                    
                    Spacer()
                }
                .padding(.horizontal)
            }
            .navigationTitle("Редактировать")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Отмена") { dismiss() }
                        .foregroundStyle(.white)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Сохранить") {
                        var updated = habit
                        updated.title = title
                        updated.goalTimesPerWeek = goalTimesPerWeek
                        onSave(updated)
                    }
                    .foregroundStyle(.cyan)
                }
            }
        }
        .dynamicTypeSize(.small ... .accessibility3)
    }
}
