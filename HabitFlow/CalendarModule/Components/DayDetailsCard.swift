//
//  DayDetailsCard.swift
//  HabitFlow
//
//  Created by Kirill Atrakhimovich on 12.03.26.
//

import SwiftUI

struct DayDetailsCard: View {
    let dateFormatted: String
    let completionPercent: Int
    let progress: Double
    let primary: Color
    let accent: Color
    let success: Color
    
    var body: some View {
        Card {
            VStack(alignment: .leading, spacing: 10) {
                Text("Детали")
                    .font(.system(.headline, design: .rounded).weight(.bold))
                    .foregroundStyle(.white)
                
                Text(dateFormatted)
                    .font(.system(.subheadline, design: .rounded).weight(.semibold))
                    .foregroundStyle(.white.opacity(0.75))
                
                HStack {
                    Text("Выполнение привычек")
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundStyle(.white.opacity(0.70))
                    
                    Spacer()
                    
                    Text("\(completionPercent)%")
                        .font(.system(.subheadline, design: .rounded).weight(.bold))
                        .foregroundStyle(completionPercent > 0 ? success : .white.opacity(0.55))
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
