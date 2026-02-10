import SwiftUI

struct CalendarView: View {
    @Environment(\.horizontalSizeClass) private var hSizeClass
    // Theme
    private let primary = Color.primaryPurple
    private let accent  = Color.accentCyan
    private let success = Color("34C759")

    // Calendar state
    @State private var monthOffset: Int = 0
    @State private var selectedDate: DateOnly = DateOnly(date: Date())

    // Demo data (replace with real DailyRecord aggregation later)
    @State private var completionByDay: [DateOnly: Double] = [:]   // 0...1
    @State private var hasAnyCompletion: Set<DateOnly> = []        // green dot days

    private var calendar: Calendar {
        var c = Calendar.current
        c.firstWeekday = 2 // Monday (ru_RU style)
        return c
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: hSizeClass == .regular ? 18 : 14) {
                        monthHeaderCard
                        calendarGridCard
                        detailsCard
                        weeklyChartCard
                        overallPercentCard
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 12)
                }
            }
            .navigationTitle("Календарь")
            .navigationBarTitleDisplayMode(.inline)
        }
        .tint(accent)
        .onAppear {
            seedDemoDataIfNeeded()
        }
        .dynamicTypeSize(.small ... .accessibility3)
    }

    // MARK: - Cards

    private var monthHeaderCard: some View {
        Card {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(monthTitle(for: displayedMonthDate))
                        .font(.system(.title2, design: .rounded).weight(.bold))
                        .foregroundStyle(.white)

                    Text("Выберите день для деталей")
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundStyle(.white.opacity(0.65))
                }

                Spacer()

                HStack(spacing: 10) {
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) { monthOffset -= 1 }
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                            .padding(10)
                            .background(primary.opacity(0.28))
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }

                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) { monthOffset += 1 }
                    } label: {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                            .padding(10)
                            .background(primary.opacity(0.28))
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }
                }
            }
        }
    }

    private var calendarGridCard: some View {
        Card {
            VStack(spacing: 10) {
                weekdayHeader

                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 7), spacing: 10) {
                    ForEach(monthGridDays, id: \.self) { day in
                        DayCell(
                            day: day,
                            isInDisplayedMonth: isInDisplayedMonth(day),
                            isSelected: day == selectedDate,
                            hasDot: hasAnyCompletion.contains(day),
                            primary: primary,
                            accent: accent,
                            success: success
                        ) {
                            withAnimation(.easeInOut(duration: 0.15)) {
                                selectedDate = day
                            }
                        }
                    }
                }
            }
        }
    }

    private var detailsCard: some View {
        Card {
            VStack(alignment: .leading, spacing: 10) {
                Text("Детали")
                    .font(.system(.headline, design: .rounded).weight(.bold))
                    .foregroundStyle(.white)

                Text(formattedFullDate(selectedDate))
                    .font(.system(.subheadline, design: .rounded).weight(.semibold))
                    .foregroundStyle(.white.opacity(0.75))

                let percent = Int((completionByDay[selectedDate] ?? 0) * 100)

                HStack {
                    Text("Выполнение привычек")
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundStyle(.white.opacity(0.70))

                    Spacer()

                    Text("\(percent)%")
                        .font(.system(.subheadline, design: .rounded).weight(.bold))
                        .foregroundStyle(percent > 0 ? success : .white.opacity(0.55))
                }

                ProgressBar(
                    progress: completionByDay[selectedDate] ?? 0,
                    primary: primary,
                    accent: accent,
                    success: success
                )
                .frame(height: 12)
            }
        }
    }

    private var weeklyChartCard: some View {
        Card {
            VStack(alignment: .leading, spacing: 12) {
                Text("Прогресс за неделю")
                    .font(.system(.headline, design: .rounded).weight(.bold))
                    .foregroundStyle(.white)

                WeeklyLineChart(
                    values: weeklyValues(endingAt: selectedDate),
                    lineColor: success,
                    gridColor: .white.opacity(0.10)
                )
                .frame(height: 140)

                HStack {
                    Text("Последние 7 дней")
                        .font(.system(.footnote, design: .rounded))
                        .foregroundStyle(.white.opacity(0.60))
                    Spacer()
                    Text("\(Int(weeklyAverage(endingAt: selectedDate) * 100))% в среднем")
                        .font(.system(.footnote, design: .rounded).weight(.semibold))
                        .foregroundStyle(.white.opacity(0.75))
                }
            }
        }
    }

    private var overallPercentCard: some View {
        Card {
            VStack(alignment: .leading, spacing: 10) {
                Text("Итого за месяц")
                    .font(.system(.headline, design: .rounded).weight(.bold))
                    .foregroundStyle(.white)

                let monthPercent = monthCompletionPercent()
                HStack {
                    Text("Средний процент выполнения")
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundStyle(.white.opacity(0.70))
                    Spacer()
                    Text("\(Int(monthPercent * 100))%")
                        .font(.system(.subheadline, design: .rounded).weight(.bold))
                        .foregroundStyle(monthPercent > 0 ? accent : .white.opacity(0.55))
                }

                ProgressBar(progress: monthPercent, primary: primary, accent: accent, success: success)
                    .frame(height: 12)
            }
        }
    }

    private var weekdayHeader: some View {
        let symbols = shortWeekdaySymbols(calendar: calendar) // Mon..Sun
        return HStack(spacing: 0) {
            ForEach(symbols, id: \.self) { s in
                Text(s)
                    .font(.system(.caption, design: .rounded).weight(.bold))
                    .foregroundStyle(.white.opacity(0.55))
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, 4)
    }

    // MARK: - Date calculations

    private var displayedMonthDate: Date {
        let base = Date()
        return calendar.date(byAdding: .month, value: monthOffset, to: base) ?? base
    }

    private var monthGridDays: [DateOnly] {
        // Build a 6x7 grid starting from the first visible day (week starts on Monday).
        let monthStart = startOfMonth(displayedMonthDate)
        let firstWeekdayIndex = weekdayIndexMondayFirst(monthStart) // 0..6
        let gridStart = calendar.date(byAdding: .day, value: -firstWeekdayIndex, to: monthStart) ?? monthStart

        return (0..<42).compactMap { i in
            guard let d = calendar.date(byAdding: .day, value: i, to: gridStart) else { return nil }
            return DateOnly(date: d, calendar: calendar)
        }
    }

    private func isInDisplayedMonth(_ day: DateOnly) -> Bool {
        let month = calendar.component(.month, from: displayedMonthDate)
        let year  = calendar.component(.year, from: displayedMonthDate)
        return day.month == month && day.year == year
    }

    private func startOfMonth(_ date: Date) -> Date {
        let comps = calendar.dateComponents([.year, .month], from: date)
        return calendar.date(from: comps) ?? date
    }

    /// Monday-first index: Mon=0 ... Sun=6
    private func weekdayIndexMondayFirst(_ date: Date) -> Int {
        let weekday = calendar.component(.weekday, from: date) // Sun=1 ... Sat=7
        // Convert to Mon=0..Sun=6
        return (weekday + 5) % 7
    }

    // MARK: - Weekly stats

    private func weeklyValues(endingAt end: DateOnly) -> [Double] {
        // oldest -> newest (7 points)
        let endDate = end.toDate(calendar: calendar)
        return (0..<7).map { i in
            let dayDate = calendar.date(byAdding: .day, value: i - 6, to: endDate) ?? endDate
            let key = DateOnly(date: dayDate, calendar: calendar)
            return clamp01(completionByDay[key] ?? 0)
        }
    }

    private func weeklyAverage(endingAt end: DateOnly) -> Double {
        let v = weeklyValues(endingAt: end)
        guard !v.isEmpty else { return 0 }
        return v.reduce(0, +) / Double(v.count)
    }

    private func monthCompletionPercent() -> Double {
        let days = monthGridDays.filter(isInDisplayedMonth)
        let values = days.compactMap { completionByDay[$0] }.map(clamp01)
        guard !values.isEmpty else { return 0 }
        return values.reduce(0, +) / Double(values.count)
    }

    private func clamp01(_ x: Double) -> Double { min(1, max(0, x)) }

    // MARK: - Formatting

    private func monthTitle(for date: Date) -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ru_RU")
        f.setLocalizedDateFormatFromTemplate("LLLL yyyy")
        return f.string(from: date).capitalized
    }

    private func formattedFullDate(_ d: DateOnly) -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ru_RU")
        f.dateStyle = .full
        return f.string(from: d.toDate(calendar: calendar))
    }

    private func shortWeekdaySymbols(calendar: Calendar) -> [String] {
        // Calendar.shortStandaloneWeekdaySymbols is Sun..Sat by default.
        let symbols = calendar.shortStandaloneWeekdaySymbols
        // Reorder to Mon..Sun
        return Array(symbols[1...6]) + [symbols[0]]
    }

    // MARK: - Demo data

    private func seedDemoDataIfNeeded() {
        guard completionByDay.isEmpty else { return }

        // Generate pseudo-random completion for the last ~60 days
        let base = Date()
        for i in 0..<60 {
            guard let d = calendar.date(byAdding: .day, value: -i, to: base) else { continue }
            let key = DateOnly(date: d, calendar: calendar)

            // deterministic-ish "random"
            let r = Double((key.day * 37 + key.month * 13) % 101) / 100.0
            let value = max(0, min(1, (r - 0.15) / 0.85)) // skew a bit

            completionByDay[key] = value
            if value >= 0.33 { hasAnyCompletion.insert(key) }
        }
    }
}

// MARK: - Components

private struct DayCell: View {
    let day: DateOnly
    let isInDisplayedMonth: Bool
    let isSelected: Bool
    let hasDot: Bool
    let primary: Color
    let accent: Color
    let success: Color
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 6) {
                Text("\(day.day)")
                    .font(.system(.subheadline, design: .rounded).weight(.semibold))
                    .foregroundStyle(textColor)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 6)

                Circle()
                    .fill(hasDot ? success : .clear)
                    .frame(width: 6, height: 6)
                    .padding(.bottom, 6)
            }
            .frame(height: 44)
            .background(background)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(border)
        }
        .buttonStyle(.plain)
        .disabled(!isInDisplayedMonth && !isSelected ? false : false) // keep tappable for adjacent days
    }

    private var background: Color {
        if isSelected { return accent.opacity(0.25) }
        return Color.white.opacity(isInDisplayedMonth ? 0.06 : 0.03)
    }

    private var border: some View {
        RoundedRectangle(cornerRadius: 12, style: .continuous)
            .stroke(isSelected ? accent.opacity(0.6) : Color.white.opacity(0.05), lineWidth: 1)
    }

    private var textColor: Color {
        if isSelected { return .white }
        return isInDisplayedMonth ? .white.opacity(0.9) : .white.opacity(0.35)
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

private struct WeeklyLineChart: View {
    let values: [Double]         // 0...1
    let lineColor: Color
    let gridColor: Color

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Grid (2 horizontal lines)
                Path { p in
                    let w = geo.size.width
                    let h = geo.size.height
                    p.move(to: CGPoint(x: 0, y: h * 0.33))
                    p.addLine(to: CGPoint(x: w, y: h * 0.33))
                    p.move(to: CGPoint(x: 0, y: h * 0.66))
                    p.addLine(to: CGPoint(x: w, y: h * 0.66))
                }
                .stroke(gridColor, style: StrokeStyle(lineWidth: 1, lineCap: .round, dash: [4, 4]))

                // Line
                Path { p in
                    let pts = points(in: geo.size)
                    guard let first = pts.first else { return }
                    p.move(to: first)
                    for pt in pts.dropFirst() { p.addLine(to: pt) }
                }
                .stroke(lineColor, style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))

                // Dots
                ForEach(Array(points(in: geo.size).enumerated()), id: \.offset) { _, pt in
                    Circle()
                        .fill(lineColor)
                        .frame(width: 7, height: 7)
                        .position(pt)
                }
            }
        }
    }

    private func points(in size: CGSize) -> [CGPoint] {
        let v = values.map { min(1, max(0, $0)) }
        guard v.count >= 2 else { return [] }

        let w = size.width
        let h = size.height

        let stepX = w / CGFloat(v.count - 1)
        let topPadding: CGFloat = 8
        let bottomPadding: CGFloat = 10
        let usableH = max(1, h - topPadding - bottomPadding)

        return v.enumerated().map { idx, val in
            let x = CGFloat(idx) * stepX
            let y = topPadding + (1 - CGFloat(val)) * usableH
            return CGPoint(x: x, y: y)
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
