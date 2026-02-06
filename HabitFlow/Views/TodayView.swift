import SwiftUI

struct TodayView: View {
    @StateObject private var vm = HabitViewModel()

    private let primary = Color("8A2BE2")
    private let accent  = Color("00FFFF")

    @State private var showAddSheet = false
    @State private var newHabitTitle: String = ""
    @State private var selectedHabit: Habit?

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 14) {
                        headerCard
                        progressCard

                        if vm.habits.isEmpty {
                            emptyState
                        } else {
                            habitsList
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showAddSheet = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                            .padding(10)
                            .background(primary.opacity(0.35))
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .stroke(accent.opacity(0.35), lineWidth: 1)
                            )
                    }
                    .accessibilityLabel("Добавить привычку")
                }
            }
            .tint(accent)
            .onAppear { vm.loadHabits() }
            .sheet(isPresented: $showAddSheet) {
                AddHabitView { title, icon, colorHex, goal, reminder in
                    vm.addHabit(
                        title: title,
                        iconName: icon,
                        colorHex: colorHex,
                        goalTimesPerWeek: goal,
                        reminderTime: reminder
                    )
                }
                    .presentationDetents([.medium])
            }
        }
    }

    // MARK: - UI

    private var headerCard: some View {
        Card {
            VStack(alignment: .leading, spacing: 6) {
                Text("Сегодня")
                    .font(.system(.title2, design: .rounded).weight(.bold))
                    .foregroundStyle(.white)

                Text(formattedToday())
                    .font(.system(.subheadline, design: .rounded).weight(.semibold))
                    .foregroundStyle(.white.opacity(0.7))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var progressCard: some View {
        Card {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("Прогресс дня")
                        .font(.system(.headline, design: .rounded).weight(.bold))
                        .foregroundStyle(.white)

                    Spacer()

                    Text("\(vm.completedCount)/\(vm.totalCount)")
                        .font(.system(.subheadline, design: .rounded).weight(.semibold))
                        .foregroundStyle(.white.opacity(0.7))
                }

                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(Color.white.opacity(0.10))
                        .frame(height: 12)

                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(LinearGradient(colors: [accent, primary], startPoint: .leading, endPoint: .trailing))
                        .frame(width: max(0, CGFloat(vm.progress) * (UIScreen.main.bounds.width - 32 - 32)), height: 12)
                        .animation(.easeInOut(duration: 0.2), value: vm.progress)
                }

                Text(vm.habits.isEmpty ? "Добавьте первую привычку" : "Отмечайте привычки — и полоса заполнится.")
                    .font(.system(.footnote, design: .rounded))
                    .foregroundStyle(.white.opacity(0.6))
            }
        }
    }

    private var habitsList: some View {
        VStack(spacing: 10) {
            ForEach(vm.habits) { habit in
                NavigationLink {
                    HabitDetailView(
                        habit: habit,
                        onEdit: { updatedHabit in
                            vm.updateHabit(updatedHabit)
                        },
                        onArchive: { id in
                            vm.archiveHabit(id)
                        },
                        onDelete: { id in
                            vm.deleteHabit(id)
                        }
                    )
                } label: {
                    HabitRow(
                        habit: habit,
                        isCompleted: vm.isCompletedToday(habit),
                        primary: primary,
                        accent: accent
                    ) {
                        vm.toggleHabit(habit)
                    }
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var emptyState: some View {
        Card {
            VStack(spacing: 12) {
                Image(systemName: "sparkles")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundStyle(accent)

                Text("Пока нет привычек")
                    .font(.system(.headline, design: .rounded).weight(.bold))
                    .foregroundStyle(.white)

                Text("Нажмите «+», чтобы добавить первую привычку и начать трекать прогресс.")
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundStyle(.white.opacity(0.7))
                    .multilineTextAlignment(.center)

                Button {
                    showAddSheet = true
                } label: {
                    Text("Добавить привычку")
                        .font(.system(.headline, design: .rounded).weight(.bold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(LinearGradient(colors: [accent, primary], startPoint: .leading, endPoint: .trailing))
                        .foregroundStyle(.black)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                .padding(.top, 4)
            }
        }
    }

    // MARK: - Add Habit Sheet

    private var addHabitSheet: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                VStack(alignment: .leading, spacing: 14) {
                    Text("Новая привычка")
                        .font(.system(.title2, design: .rounded).weight(.bold))
                        .foregroundStyle(.white)

                    TextField("Название (например, «10 минут чтения»)", text: $newHabitTitle)
                        .textInputAutocapitalization(.sentences)
                        .disableAutocorrection(true)
                        .padding(12)
                        .background(Color.white.opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(accent.opacity(0.25), lineWidth: 1)
                        )
                        .foregroundStyle(.white)

                    Button {
                        vm.addHabit(title: newHabitTitle, iconName: "checkmark.circle.fill", colorHex: "00FFFF", goalTimesPerWeek: 7)
                        newHabitTitle = ""
                        showAddSheet = false
                    } label: {
                        Text("Добавить")
                            .font(.system(.headline, design: .rounded).weight(.bold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(LinearGradient(colors: [accent, primary], startPoint: .leading, endPoint: .trailing))
                            .foregroundStyle(.black)
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }
                    .disabled(newHabitTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .opacity(newHabitTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.5 : 1)

                    Spacer()
                }
                .padding(16)
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Закрыть") { showAddSheet = false }
                        .foregroundStyle(.white.opacity(0.9))
                }
            }
        }
        .tint(accent)
    }

    // MARK: - Helpers

    private func formattedToday() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateStyle = .full
        return formatter.string(from: Date())
    }
}

// MARK: - Components

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

private struct HabitRow: View {
    let habit: Habit
    let isCompleted: Bool
    let primary: Color
    let accent: Color
    let onToggle: () -> Void

    // MARK: - Derived values (help compiler)
    private var iconBackground: Color { Color(habit.colorHex).opacity(isCompleted ? 0.25 : 0.14) }
    private var iconBorder: Color { accent.opacity(isCompleted ? 0.55 : 0.15) }
    private var checkFill: Color { isCompleted ? accent.opacity(0.95) : Color.white.opacity(0.10) }
    private var checkForeground: Color { isCompleted ? .black : .white.opacity(0.65) }
    private var cardBackground: Color { Color.white.opacity(isCompleted ? 0.10 : 0.06) }
    private var cardBorder: Color { isCompleted ? accent.opacity(0.45) : Color.white.opacity(0.06) }
    private var cardShadow: Color { Color.black.opacity(isCompleted ? 0.45 : 0.30) }

    var body: some View {
        Button(action: onToggle) {
            rowContent
                .padding(14)
                .background(cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .overlay(cardOverlay)
                .shadow(color: cardShadow, radius: 12, x: 0, y: 8)
                .animation(.easeInOut(duration: 0.2), value: isCompleted)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Subviews

    private var rowContent: some View {
        HStack(spacing: 12) {
            iconTile

            texts

            Spacer()

            checkmark
        }
    }

    private var iconTile: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(iconBackground)
                .frame(width: 48, height: 48)
                .overlay(iconOverlay)

            Image(systemName: habit.iconName)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .opacity(isCompleted ? 1.0 : 0.9)
        }
    }

    private var iconOverlay: some View {
        RoundedRectangle(cornerRadius: 14, style: .continuous)
            .stroke(iconBorder, lineWidth: 1)
    }

    private var texts: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(habit.title)
                .font(.system(.headline, design: .rounded).weight(.bold))
                .foregroundStyle(.white)

            Text("Цель: \(habit.goalTimesPerWeek) раз(а) в неделю")
                .font(.system(.footnote, design: .rounded))
                .foregroundStyle(.white.opacity(0.65))
        }
    }

    private var checkmark: some View {
        ZStack {
            Circle()
                .fill(checkFill)
                .frame(width: 28, height: 28)

            Image(systemName: isCompleted ? "checkmark" : "circle")
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundStyle(checkForeground)
        }
    }

    private var cardOverlay: some View {
        RoundedRectangle(cornerRadius: 18, style: .continuous)
            .stroke(cardBorder, lineWidth: 1)
    }
}
