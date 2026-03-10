//
//  AddHabitSheet.swift
//  HabitFlow
//
//  Created by Kirill Atrakhimovich on 10.03.26.
//

import SwiftUI

struct AddHabitSheet: View {
    @Binding var newHabitTitle: String
    @Environment(\.dismiss) private var dismiss
    
    let accent: Color
    let primary: Color
    let onAdd: () -> Void
    let onCancel: () -> Void
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack(alignment: .leading, spacing: 14) {
                    Text("Новая привычка")
                        .font(.system(.title2, design: .rounded).weight(.bold))
                        .foregroundStyle(.white)
                    
                    TextField("Название (например, «10 минут чтения»)", text: $newHabitTitle)
                        .textInputAutocapitalization(.sentences)
                        .disableAutocorrection(true)
                        .padding(12)
                        .background(Color.white.opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(accent.opacity(0.25), lineWidth: 1)
                        )
                        .foregroundStyle(.white)
                    
                    addButton
                    
                    Spacer()
                }
                .padding(16)
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Закрыть") {
                        onCancel()
                        dismiss()
                    }
                    .foregroundStyle(.white.opacity(0.9))
                }
            }
        }
        .tint(accent)
    }
    
    private var addButton: some View {
        Button(action: {
            onAdd()
            dismiss()
        }) {
            Text("Добавить")
                .font(.system(.headline, design: .rounded).weight(.bold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(LinearGradient(
                    colors: [accent, primary],
                    startPoint: .leading,
                    endPoint: .trailing
                ))
                .foregroundStyle(.black)
                .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .disabled(newHabitTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        .opacity(newHabitTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.5 : 1)
    }
}
