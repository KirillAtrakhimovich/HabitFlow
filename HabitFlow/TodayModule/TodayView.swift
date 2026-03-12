import SwiftUI

struct TodayView: View {
    @Environment(\.horizontalSizeClass) private var hSizeClass
    @StateObject private var viewModel = TodayViewModel()
    
    let primary = Color(red: 0.75, green: 0.70, blue: 0.90)
    let accent = Color(red: 0.55, green: 0.75, blue: 0.80)
    let purple = Color.purple
    let cyan = Color.cyan

    var body: some View {
        NavigationStack {
            ZStack {
                backgroundGradient
                
                ScrollView {
                    VStack(spacing: hSizeClass == .regular ? 18 : 14) {
                        HeaderCard()
                        
                        ProgressCard(
                            completedCount: viewModel.completedCount,
                            totalCount: viewModel.totalCount,
                            progress: viewModel.progress
                        )
                        
                        if viewModel.hasHabits {
                            habitsList
                        } else {
                            EmptyStateView(
                                accent: accent,
                                onAddTap: { viewModel.showAddSheet = true }
                            )
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 12)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { toolbarContent }
            .tint(accent)
            .sheet(isPresented: $viewModel.showAddSheet) {
                AddHabitSheet(
                    newHabitTitle: $viewModel.newHabitTitle,
                    accent: accent,
                    primary: primary,
                    onAdd: viewModel.addHabit,
                    onCancel: { viewModel.showAddSheet = false }
                )
            }
        }
        .dynamicTypeSize(.small ... .accessibility3)
        .onAppear {
            viewModel.refresh()
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
            ForEach(viewModel.habits) { habit in
                NavigationLink {
                    // Destination view
                } label: {
                    HabitRow(
                        habit: habit,
                        primary: primary,
                        accent: accent,
                        onToggle: {
                            viewModel.toggleHabit(habit)
                        }
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }
    
    // MARK: - Toolbar
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                viewModel.showAddSheet = true
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
}
