//
//  CardStyle.swift
//  HabitFlow
//
//  Created by Kirill Atrakhimovich on 10.03.26.
//

import SwiftUI

struct Card<Content: View>: View {
    @ViewBuilder let content: Content
    
    var body: some View {
        content
            .padding(16)
            .background(Color.purple.opacity(0.3))
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.35), radius: 14, x: 0, y: 10)
    }
}
