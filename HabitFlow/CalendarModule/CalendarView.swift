import SwiftUI

struct CalendarView: View {
    @Environment(\.horizontalSizeClass) private var hSizeClass
    @StateObject private var viewModel: CalendarViewModel
    
    // Theme
    let primary = Color(red: 0.75, green: 0.70, blue: 0.90)
    let accent = Color(red: 0.55, green: 0.75, blue: 0.80)
    let purple = Color.purple
    let cyan = Color.cyan
    let success = Color("34C759")
    
    init(viewModel: CalendarViewModel) {
          _viewModel = StateObject(wrappedValue: viewModel)
      }

    var body: some View {
        NavigationStack {
            ZStack {
                backgroundGradient
                
                ScrollView {
                    VStack(spacing: hSizeClass == .regular ? 18 : 14) {
                        MonthHeaderCard(
                            monthTitle: viewModel.monthTitle,
                            onPrevious: viewModel.previousMonth,
                            onNext: viewModel.nextMonth,
                            primary: primary
                        )
                        
                        CalendarGridCard(
                            days: viewModel.monthGridDays,
                            selectedDate: viewModel.selectedDate,
                            isInDisplayedMonth: viewModel.isInDisplayedMonth,
                            hasCompletion: viewModel.hasCompletion,
                            primary: primary,
                            accent: accent,
                            success: success,
                            onSelectDate: viewModel.selectDate
                        )
                        
                        DayDetailsCard(
                            dateFormatted: viewModel.selectedDateFormatted,
                            completionPercent: viewModel.selectedDayCompletionPercent,
                            progress: viewModel.selectedDayCompletion,
                            primary: purple,
                            accent: cyan,
                            success: success
                        )
                        
                        WeeklyChartCard(
                            values: viewModel.weeklyValues,
                            weeklyAverage: viewModel.weeklyAveragePercent,
                            lineColor: success,
                            gridColor: .white.opacity(0.10)
                        )
                        
                        OverallStatsCard(
                            monthCompletionPercent: viewModel.monthCompletionPercentInt,
                            progress: viewModel.monthCompletionPercent,
                            primary: purple,
                            accent: cyan,
                            success: success
                        )
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 12)
                }
            }
            .navigationTitle("Календарь")
            .navigationBarTitleDisplayMode(.inline)
        }
        .tint(accent)
        .dynamicTypeSize(.small ... .accessibility3)
    }
    
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
}
