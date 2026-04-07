//
//  AddHabitSheet.swift
//  HabitFlow
//
//  Created by Kirill Atrakhimovich on 10.03.26.
//

import SwiftUI

struct AddHabitSheet: View {
    @Binding var newHabitTitle: String
    @Binding var selectedIcon: String
    @Binding var selectedColorName: String
    @Environment(\.dismiss) private var dismiss
    
    let accent: Color
    let primary: Color
    let onSave: () -> Void
    let onCancel: () -> Void
    
    // Новые параметры для режима редактирования
    var isEditing: Bool = false
    var editingHabit: Habit? = nil
    
    // UI state for pickers
    @State private var showIconPicker = false
    @State private var showColorPicker = false
    
    // Icon options (SF Symbols)
    private let iconOptions: [String] = [
        "sparkles", "checkmark.circle.fill", "flame.fill", "drop.fill",
        "figure.run", "figure.strengthtraining.traditional", "book.fill",
        "moon.fill", "sun.max.fill", "heart.fill", "star.fill",
        "leaf.fill", "pencil", "paintbrush.fill", "music.note",
        "gamecontroller.fill", "cup.and.saucer.fill", "bed.double.fill",
        "bicycle", "airplane", "car.fill", "tram.fill"
    ]
    
    // Color palette
    private let colorOptions: [(name: String, color: Color)] = [
        ("Фиолетовый", .purple),
        ("Голубой", .cyan),
        ("Зелёный", .green),
        ("Оранжевый", .orange),
        ("Красный", .red),
        ("Синий", .blue),
        ("Розовый", .pink),
        ("Пурпурный", .purple),
        ("Жёлтый", .yellow),
        ("Светло-синий", Color(red: 0.35, green: 0.70, blue: 0.90))
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack(alignment: .leading, spacing: 14) {
                    Text(isEditing ? "Редактировать привычку" : "Новая привычка")
                        .font(.system(.title2, design: .rounded).weight(.bold))
                        .foregroundStyle(.white)
                    
                    // Название привычки
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
                    
                    // Иконка
                    iconSelectionButton
                    
                    // Цвет
                    colorSelectionButton
                    
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
        .sheet(isPresented: $showIconPicker) {
            iconPickerSheet
        }
        .sheet(isPresented: $showColorPicker) {
            colorPickerSheet
        }
    }
    
    // MARK: - UI Components
    
    private var iconSelectionButton: some View {
        Button {
            showIconPicker = true
        } label: {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(colorForName(selectedColorName).opacity(0.25))
                        .frame(width: 44, height: 44)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(accent.opacity(0.35), lineWidth: 1)
                        )
                    
                    Image(systemName: selectedIcon)
                        .font(.system(size: 20, weight: .medium, design: .rounded))
                        .foregroundStyle(.white)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Иконка")
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundStyle(.white.opacity(0.7))
                    
                    Text(selectedIcon.replacingOccurrences(of: ".fill", with: "").replacingOccurrences(of: ".", with: " "))
                        .font(.system(.caption, design: .rounded))
                        .foregroundStyle(.white.opacity(0.5))
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(.white.opacity(0.6))
            }
            .padding(12)
            .background(Color.white.opacity(0.06))
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .buttonStyle(.plain)
    }
    
    private var colorSelectionButton: some View {
        Button {
            showColorPicker = true
        } label: {
            HStack(spacing: 12) {
                Circle()
                    .fill(colorForName(selectedColorName))
                    .frame(width: 32, height: 32)
                    .overlay(
                        Circle()
                            .stroke(accent.opacity(0.35), lineWidth: 2)
                    )
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Цвет")
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundStyle(.white.opacity(0.7))
                    
                    Text(selectedColorName)
                        .font(.system(.caption, design: .rounded))
                        .foregroundStyle(.white.opacity(0.5))
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(.white.opacity(0.6))
            }
            .padding(12)
            .background(Color.white.opacity(0.06))
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .buttonStyle(.plain)
    }
    
    private var addButton: some View {
        Button(action: {
            onSave()
            dismiss()
        }) {
            Text(isEditing ? "Сохранить" : "Добавить")
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
    
    // MARK: - Pickers
    
    private var iconPickerSheet: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                ScrollView {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 4), spacing: 16) {
                        ForEach(iconOptions, id: \.self) { icon in
                            ZStack {
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(selectedIcon == icon ? colorForName(selectedColorName).opacity(0.35) : Color.white.opacity(0.08))
                                    .frame(width: 70, height: 70)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(selectedIcon == icon ? accent.opacity(0.6) : Color.white.opacity(0.1), lineWidth: selectedIcon == icon ? 2 : 1)
                                    )
                                
                                Image(systemName: icon)
                                    .font(.system(size: 24, weight: .medium, design: .rounded))
                                    .foregroundStyle(.white)
                            }
                            .onTapGesture {
                                selectedIcon = icon
                                showIconPicker = false
                            }
                        }
                    }
                    .padding(16)
                }
            }
            .navigationTitle("Выберите иконку")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Готово") {
                        showIconPicker = false
                    }
                    .foregroundStyle(.white.opacity(0.9))
                }
            }
            .tint(accent)
        }
        .presentationDetents([.large])
    }
    
    private var colorPickerSheet: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(colorOptions.indices, id: \.self) { index in
                            let option = colorOptions[index]
                            colorPickerRow(option: option)
                        }
                    }
                    .padding(16)
                }
            }
            .navigationTitle("Выберите цвет")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Готово") {
                        showColorPicker = false
                    }
                    .foregroundStyle(.white.opacity(0.9))
                }
            }
            .tint(accent)
        }
        .presentationDetents([.medium])
    }

    // Выносим каждый ряд в отдельную функцию
    private func colorPickerRow(option: (name: String, color: Color)) -> some View {
        HStack(spacing: 14) {
            Circle()
                .fill(option.color)
                .frame(width: 40, height: 40)
                .overlay(
                    Circle()
                        .stroke(selectedColorName == option.name ? accent : Color.clear, lineWidth: 3)
                )
            
            Text(option.name)
                .font(.system(.body, design: .rounded).weight(.semibold))
                .foregroundStyle(.white)
            
            Spacer()
            
            if selectedColorName == option.name {
                Image(systemName: "checkmark")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(accent)
            }
        }
        .padding(14)
        .background(selectedColorName == option.name ? Color.white.opacity(0.10) : Color.white.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(selectedColorName == option.name ? accent.opacity(0.4) : Color.white.opacity(0.05), lineWidth: 1)
        )
        .onTapGesture {
            selectedColorName = option.name
            showColorPicker = false
        }
    }
    // MARK: - Helpers
    
    private func colorForName(_ name: String) -> Color {
        colorOptions.first(where: { $0.name == name })?.color ?? .purple
    }
}

// MARK: - Preview
#Preview {
    AddHabitSheet(
        newHabitTitle: .constant(""),
        selectedIcon: .constant("sparkles"),
        selectedColorName: .constant("Фиолетовый"),
        accent: Color(red: 0.55, green: 0.75, blue: 0.80),
        primary: Color(red: 0.75, green: 0.70, blue: 0.90),
        onSave: {},
        onCancel: {}
    )
}
