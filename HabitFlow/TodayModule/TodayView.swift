import SwiftUI

struct TodayView: View {
    @Environment(\.horizontalSizeClass) private var hSizeClass
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var repository = HabitRepository()
    
    @State private var newHabitTitle = ""
    @State private var selectedIcon = "sparkles"
    @State private var selectedColorName = "Фиолетовый"
    @State private var showAddSheet = false
    @State private var showEditSheet = false
    @State private var editingHabit: Habit?
    
    let primary = Color(red: 0.75, green: 0.70, blue: 0.90)
    let accent = Color(red: 0.55, green: 0.75, blue: 0.80)
    
    var body: some View {
        NavigationStack {
            ZStack {
                backgroundGradient
                
                VStack(spacing: hSizeClass == .regular ? 18 : 14) {
                    HeaderCard()
                    
                    ProgressCard(
                        completedCount: repository.completedCount,
                        totalCount: repository.totalCount,
                        progress: repository.progress
                    )
                    
                    ScrollView {
                        if !repository.habits.isEmpty {
                            habitsList
                        } else {
                            emptyStateView
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { toolbarContent }
            .tint(accent)
            .sheet(isPresented: $showAddSheet) {
                AddHabitSheet(
                    newHabitTitle: $newHabitTitle,
                    selectedIcon: $selectedIcon,
                    selectedColorName: $selectedColorName,
                    accent: accent,
                    primary: primary,
                    onSave: addHabit,
                    onCancel: {
                        showAddSheet = false
                        resetForm()
                    },
                    isEditing: false
                )
            }
            .sheet(isPresented: $showEditSheet) {
                AddHabitSheet(
                    newHabitTitle: $newHabitTitle,
                    selectedIcon: $selectedIcon,
                    selectedColorName: $selectedColorName,
                    accent: accent,
                    primary: primary,
                    onSave: {
                        if let habit = editingHabit {
                            updateHabit(habit)
                        }
                    },
                    onCancel: {
                        showEditSheet = false
                        resetForm()
                    },
                    isEditing: true,
                    editingHabit: editingHabit
                )
            }
        }
        .dynamicTypeSize(.small ... .accessibility3)
        .onAppear {
            print("👋 TodayView появился")
            repository.fetchHabits()
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
            switch newPhase {
            case .active:
                print("🔵 Приложение стало активным")
                repository.checkForNewDay()
            case .inactive:
                print("⚪️ Приложение неактивно")
            case .background:
                print("⚫️ Приложение в фоне")
            @unknown default:
                break
            }
        }
    }
    
    // MARK: - Background
    private var backgroundGradient: some View {
        LinearGradient(
            colors: [
                primary.opacity(0.22),
                accent.opacity(0.94)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
    
    // MARK: - Habits List
    private var habitsList: some View {
        VStack(spacing: 10) {
            ForEach(repository.habits) { habit in
                HabitRow(
                    habit: habit,
                    primary: primary,
                    accent: accent,
                    onComplete: {
                        repository.toggleHabit(habit)
                    },
                    onEdit: {
                        startEditing(habit)
                    },
                    onDelete: {
                        repository.deleteHabit(habit)
                    }
                )
            }
        }
    }
    
    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "list.bullet.clipboard")
                .font(.system(size: 60))
                .foregroundStyle(accent)
            
            Text("Нет привычек на сегодня")
                .font(.title3)
                .fontWeight(.medium)
                .foregroundStyle(.white)
            
            Text("Добавьте привычку, чтобы начать")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.7))
            
            Button {
                resetForm()
                showAddSheet = true
            } label: {
                Text("Добавить привычку")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(accent)
                    .clipShape(RoundedRectangle(cornerRadius: 25))
            }
        }
        .padding(40)
        .frame(maxWidth: .infinity)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 30))
    }
    
    // MARK: - Toolbar
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                resetForm()
                showAddSheet = true
            } label: {
                Image(systemName: "plus")
                    .font(.system(size: 16, weight: .heavy, design: .rounded))
                    .foregroundStyle(Color.cyan.opacity(0.6))
                    .padding(10)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .accessibilityLabel("Добавить привычку")
        }
    }
    
    // MARK: - Actions
    private func addHabit() {
        repository.addHabit(
            title: newHabitTitle,
            icon: selectedIcon,
            colorName: selectedColorName
        )
        resetForm()
        showAddSheet = false
    }
    
    private func updateHabit(_ habit: Habit) {
        repository.updateHabit(
            habit,
            title: newHabitTitle,
            icon: selectedIcon,
            colorName: selectedColorName
        )
        
        resetForm()
        showEditSheet = false
        editingHabit = nil
    }
    
    private func startEditing(_ habit: Habit) {
        // Сначала устанавливаем значения
        newHabitTitle = habit.title
        selectedIcon = habit.iconName
        selectedColorName = habit.colorName
        editingHabit = habit
        
        // Затем открываем sheet
        showEditSheet = true
    }
    
    private func resetForm() {
        newHabitTitle = ""
        selectedIcon = "sparkles"
        selectedColorName = "Фиолетовый"
        editingHabit = nil
    }
}
