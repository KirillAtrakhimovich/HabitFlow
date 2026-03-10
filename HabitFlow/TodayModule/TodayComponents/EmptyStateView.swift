//
//  EmptyStateView.swift
//  HabitFlow
//
//  Created by Kirill Atrakhimovich on 10.03.26.
//

import SwiftUI

struct EmptyStateView: View {
    let accent: Color
    let onAddTap: () -> Void
    
    var body: some View {
        Card {
            VStack(spacing: 12) {
                Image(systemName: "sparkles")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundStyle(accent)
                
                Text("Пока нет привычек")
                    .font(.system(.headline, design: .rounded).weight(.bold))
                    .foregroundStyle(.white)
                
                Text("Нажмите «+», чтобы добавить первую привычку и начать трекать прогресс.")
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundStyle(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                
                addButton
            }
        }
    }
    
    private var addButton: some View {
        Button(action: onAddTap) {
            Text("Добавить привычку")
                .font(.system(.headline, design: .rounded).weight(.bold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(LinearGradient(
                    colors: [accent, Color(red: 0.75, green: 0.70, blue: 0.90)],
                    startPoint: .leading,
                    endPoint: .trailing
                ))
                .foregroundStyle(.black)
                .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .padding(.top, 4)
    }
}
