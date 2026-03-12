//
//  WeeklyChartCard.swift
//  HabitFlow
//
//  Created by Kirill Atrakhimovich on 12.03.26.
//

import SwiftUI

struct WeeklyChartCard: View {
    let values: [Double]
    let weeklyAverage: Int
    let lineColor: Color
    let gridColor: Color
    
    var body: some View {
        Card {
            VStack(alignment: .leading, spacing: 12) {
                Text("Прогресс за неделю")
                    .font(.system(.headline, design: .rounded).weight(.bold))
                    .foregroundStyle(.white)
                
                WeeklyLineChart(
                    values: values,
                    lineColor: lineColor,
                    gridColor: gridColor
                )
                .frame(height: 140)
                
                HStack {
                    Text("Последние 7 дней")
                        .font(.system(.footnote, design: .rounded))
                        .foregroundStyle(.white.opacity(0.60))
                    Spacer()
                    Text("\(weeklyAverage)% в среднем")
                        .font(.system(.footnote, design: .rounded).weight(.semibold))
                        .foregroundStyle(.white.opacity(0.75))
                }
            }
        }
    }
}
