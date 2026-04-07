//
//  ProgressCard.swift
//  HabitFlow
//
//  Created by Kirill Atrakhimovich on 10.03.26.
//

import SwiftUI

struct ProgressCard: View {
    let completedCount: Int
    let totalCount: Int
    let progress: Double
    
    private let purple = Color.purple
    private let cyan = Color.cyan
    
    var body: some View {
        Card {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("Прогресс дня")
                        .font(.system(.headline, design: .rounded).weight(.bold))
                        .foregroundStyle(.white)
                    
                    Spacer()
                    
                    Text("\(completedCount)/\(totalCount)")
                        .font(.system(.subheadline, design: .rounded).weight(.semibold))
                        .foregroundStyle(.white.opacity(0.7))
                }
                
                progressBar
                
                Text(totalCount == 0 ?
                     "Добавьте первую привычку" :
                     "Отмечайте привычки — и полоса заполнится.")
                    .font(.system(.footnote, design: .rounded))
                    .foregroundStyle(.white.opacity(0.6))
            }
        }
        .padding(.horizontal, 20)
    }
    
    private var progressBar: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white.opacity(0.10))
                    .frame(height: 12)
                
                RoundedRectangle(cornerRadius: 10)
                    .fill(LinearGradient(
                        colors: [purple, cyan],
                        startPoint: .leading,
                        endPoint: .trailing
                    ))
                    .frame(width: max(0, CGFloat(progress) * geometry.size.width), height: 12)
                    .animation(.easeInOut(duration: 0.2), value: progress)
            }
        }
        .frame(height: 12)
    }
}
