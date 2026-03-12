//
//  CalendarGridCard.swift
//  HabitFlow
//
//  Created by Kirill Atrakhimovich on 12.03.26.
//

import SwiftUI

struct CalendarGridCard: View {
    let days: [DateOnly]
    let selectedDate: DateOnly
    let isInDisplayedMonth: (DateOnly) -> Bool
    let hasCompletion: (DateOnly) -> Bool
    let primary: Color
    let accent: Color
    let success: Color
    let onSelectDate: (DateOnly) -> Void
    
    var body: some View {
        Card {
            VStack(spacing: 10) {
                WeekdayHeader()
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 7), spacing: 10) {
                    ForEach(days, id: \.self) { day in
                        DayCell(
                            day: day,
                            isInDisplayedMonth: isInDisplayedMonth(day),
                            isSelected: day == selectedDate,
                            hasDot: hasCompletion(day),
                            primary: primary,
                            accent: accent,
                            success: success,
                            onTap: { onSelectDate(day) }
                        )
                    }
                }
            }
        }
    }
}
