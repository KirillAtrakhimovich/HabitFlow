//
//  MonthHeaderCard.swift
//  HabitFlow
//
//  Created by Kirill Atrakhimovich on 12.03.26.
//

import SwiftUI

struct MonthHeaderCard: View {
    let monthTitle: String
    let onPrevious: () -> Void
    let onNext: () -> Void
    let primary: Color
    
    var body: some View {
        Card {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(monthTitle)
                        .font(.system(.title2, design: .rounded).weight(.bold))
                        .foregroundStyle(.white)
                    
                    Text("Выберите день для деталей")
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundStyle(.white.opacity(0.65))
                }
                
                Spacer()
                
                HStack(spacing: 10) {
                    Button(action: onPrevious) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(.white)
                            .padding(10)
                            .background(primary.opacity(0.28))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    
                    Button(action: onNext) {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(.white)
                            .padding(10)
                            .background(primary.opacity(0.28))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
            }
        }
    }
}
