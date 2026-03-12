//
//  OverwallStatsCard.swift
//  HabitFlow
//
//  Created by Kirill Atrakhimovich on 12.03.26.
//

import SwiftUI

struct OverallStatsCard: View {
    let monthCompletionPercent: Int
    let progress: Double
    let primary: Color
    let accent: Color
    let success: Color
    
    var body: some View {
        Card {
            VStack(alignment: .leading, spacing: 10) {
                Text("Итого за месяц")
                    .font(.system(.headline, design: .rounded).weight(.bold))
                    .foregroundStyle(.white)
                
                HStack {
                    Text("Средний процент выполнения")
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundStyle(.white.opacity(0.70))
                    Spacer()
                    Text("\(monthCompletionPercent)%")
                        .font(.system(.subheadline, design: .rounded).weight(.bold))
                        .foregroundStyle(monthCompletionPercent > 0 ? accent : .white.opacity(0.55))
                }
                
                ProgressBar(
                    progress: progress,
                    primary: primary,
                    accent: accent,
                    success: success
                )
                .frame(height: 12)
            }
        }
    }
}
