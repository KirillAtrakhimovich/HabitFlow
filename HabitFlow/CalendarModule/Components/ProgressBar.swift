//
//  ProgressBar.swift
//  HabitFlow
//
//  Created by Kirill Atrakhimovich on 12.03.26.
//

import SwiftUI

struct ProgressBar: View {
    let progress: Double
    let primary: Color
    let accent: Color
    let success: Color

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                // ФОН - теперь тоже используем geo.size.width
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(Color.white.opacity(0.10))
                    .frame(width: geo.size.width, height: 12)  // ← добавляем frame
                
                // ЗАПОЛНЕНИЕ
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(LinearGradient(colors: [primary, accent], startPoint: .leading, endPoint: .trailing))
                    .frame(width: geo.size.width * CGFloat(min(1, max(0, progress))), height: 12)
                    .animation(.easeInOut(duration: 0.2), value: progress)
            }
        }
        .frame(height: 12)  // ← фиксируем высоту
        .frame(maxWidth: .infinity)  // ← говорим, что хотим занять всю ширину
    }
}
