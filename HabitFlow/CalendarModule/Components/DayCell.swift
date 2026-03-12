//
//  DayCell.swift
//  HabitFlow
//
//  Created by Kirill Atrakhimovich on 12.03.26.
//

import SwiftUI

struct DayCell: View {
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
