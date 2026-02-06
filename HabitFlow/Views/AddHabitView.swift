import SwiftUI

struct AddHabitView: View {
    @Environment(\.dismiss) private var dismiss
    
    // Theme
    private let primary = Color.purple
    private let accent  = Color.cyan
    
    // Form state
    @State private var title: String = ""
    @State private var selectedIcon: String = "sparkles"
    @State private var selectedColorHex: String = "8A2BE2"
    @State private var goalTimesPerWeek: Int = 7
    @State private var reminderEnabled: Bool = false
    @State private var reminderTime: Date = {
        var comps = DateComponents()
        comps.hour = 9
        comps.minute = 0
        return Calendar.current.date(from: comps) ?? Date()
    }()
    
    // UI state
    @State private var showIconPicker = false
    @State private var showColorPicker = false
    
    // Callback
    let onSave: (String, String, String, Int, DateComponents?) -> Void
    
    // Icon options (SF Symbols)
    private let iconOptions: [String] = [
        "sparkles", "checkmark.circle.fill", "flame.fill", "drop.fill",
        "figure.run", "figure.strengthtraining.traditional", "book.fill",
        "moon.fill", "sun.max.fill", "heart.fill", "star.fill",
        "leaf.fill", "pencil", "paintbrush.fill", "music.note",
        "gamecontroller.fill", "cup.and.saucer.fill", "bed.double.fill",
        "bicycle", "airplane", "car.fill", "tram.fill"
    ]
    
    // Color palette (hex strings)
    private let colorOptions: [(hex: String, name: String)] = [
        ("8A2BE2", "Фиолетовый"),
        ("00FFFF", "Голубой"),
        ("34C759", "Зелёный"),
        ("FF9500", "Оранжевый"),
        ("FF3B30", "Красный"),
        ("007AFF", "Синий"),
        ("FF2D55", "Розовый"),
        ("AF52DE", "Пурпурный"),
        ("FFCC00", "Жёлтый"),
        ("5AC8FA", "Светло-синий")
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 16) {
                        titleSection
                        iconSection
                        colorSection
                        goalSection
                        reminderSection
                        
                        saveButton
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                }
            }
            .navigationTitle("Новая привычка")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                    .foregroundStyle(.white.opacity(0.9))
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
    }
    
    // MARK: - Sections
    
    private var titleSection: some View {
        Card {
            VStack(alignment: .leading, spacing: 10) {
                Text("Название")
                    .font(.system(.headline, design: .rounded).weight(.bold))
                    .foregroundStyle(.white)
                
                TextField("Например: Пить воду", text: $title)
                    .textInputAutocapitalization(.sentences)
                    .disableAutocorrection(true)
                    .padding(12)
                    .background(Color.white.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(accent.opacity(0.25), lineWidth: 1)
                    )
                    .foregroundStyle(.white)
            }
        }
    }
    
    private var iconSection: some View {
        Card {
            VStack(alignment: .leading, spacing: 10) {
                Text("Иконка")
                    .font(.system(.headline, design: .rounded).weight(.bold))
                    .foregroundStyle(.white)
                
                Button {
                    showIconPicker = true
                } label: {
                    HStack(spacing: 12) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(colorForHex(selectedColorHex).opacity(0.25))
                                .frame(width: 50, height: 50)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        .stroke(accent.opacity(0.35), lineWidth: 1)
                                )
                            
                            Image(systemName: selectedIcon)
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                        }
                        
                        Text("Выбрать иконку")
                            .font(.system(.body, design: .rounded).weight(.semibold))
                            .foregroundStyle(.white)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .foregroundStyle(.white.opacity(0.6))
                    }
                    .padding(12)
                    .background(Color.white.opacity(0.06))
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                .buttonStyle(.plain)
            }
        }
    }
    
    private var colorSection: some View {
        Card {
            VStack(alignment: .leading, spacing: 10) {
                Text("Цвет")
                    .font(.system(.headline, design: .rounded).weight(.bold))
                    .foregroundStyle(.white)
                
                Button {
                    showColorPicker = true
                } label: {
                    HStack(spacing: 12) {
                        Circle()
                            .fill(colorForHex(selectedColorHex))
                            .frame(width: 32, height: 32)
                            .overlay(
                                Circle()
                                    .stroke(accent.opacity(0.35), lineWidth: 2)
                            )
                        
                        Text(colorNameForHex(selectedColorHex))
                            .font(.system(.body, design: .rounded).weight(.semibold))
                            .foregroundStyle(.white)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .foregroundStyle(.white.opacity(0.6))
                    }
                    .padding(12)
                    .background(Color.white.opacity(0.06))
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                .buttonStyle(.plain)
            }
        }
    }
    
    private var goalSection: some View {
        Card {
            VStack(alignment: .leading, spacing: 10) {
                Text("Цель на неделю")
                    .font(.system(.headline, design: .rounded).weight(.bold))
                    .foregroundStyle(.white)
                
                HStack(spacing: 12) {
                    Stepper(value: $goalTimesPerWeek, in: 1...14) {
                        Text("\(goalTimesPerWeek) раз(а)")
                            .font(.system(.body, design: .rounded).weight(.semibold))
                            .foregroundStyle(.white)
                    }
                    .tint(accent)
                }
                .padding(12)
                .background(Color.white.opacity(0.06))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
        }
    }
    
    private var reminderSection: some View {
        Card {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Напоминание")
                        .font(.system(.headline, design: .rounded).weight(.bold))
                        .foregroundStyle(.white)
                    
                    Spacer()
                    
                    Toggle("", isOn: $reminderEnabled)
                        .tint(accent)
                }
                
                if reminderEnabled {
                    DatePicker(
                        "Время",
                        selection: $reminderTime,
                        displayedComponents: .hourAndMinute
                    )
                    .datePickerStyle(.compact)
                    .tint(accent)
                    .padding(12)
                    .background(Color.white.opacity(0.06))
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .transition(.opacity.combined(with: .scale))
                }
            }
            .animation(.easeInOut(duration: 0.2), value: reminderEnabled)
        }
    }
    
    private var saveButton: some View {
        Button {
            let reminderComps = reminderEnabled ? Calendar.current.dateComponents([.hour, .minute], from: reminderTime) : nil
            onSave(title.trimmingCharacters(in: .whitespacesAndNewlines), selectedIcon, selectedColorHex, goalTimesPerWeek, reminderComps)
            dismiss()
        } label: {
            Text("Сохранить")
                .font(.system(.headline, design: .rounded).weight(.bold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    LinearGradient(
                        colors: [accent, primary],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .foregroundStyle(.black)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .shadow(color: accent.opacity(0.35), radius: 16, x: 0, y: 8)
        }
        .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        .opacity(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.5 : 1)
        .padding(.top, 8)
    }
    
    // MARK: - Sheets
    
    private var iconPickerSheet: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                ScrollView {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 4), spacing: 16) {
                        ForEach(iconOptions, id: \.self) { icon in
                            Button {
                                selectedIcon = icon
                                showIconPicker = false
                            } label: {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .fill(selectedIcon == icon ? colorForHex(selectedColorHex).opacity(0.35) : Color.white.opacity(0.08))
                                        .frame(width: 70, height: 70)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                                .stroke(selectedIcon == icon ? accent.opacity(0.6) : Color.white.opacity(0.1), lineWidth: selectedIcon == icon ? 2 : 1)
                                        )
                                    
                                    Image(systemName: icon)
                                        .font(.system(size: 24, weight: .bold, design: .rounded))
                                        .foregroundStyle(.white)
                                }
                            }
                            .buttonStyle(.plain)
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
                    VStack(spacing: 16) {
                        ForEach(colorOptions, id: \.hex) { option in
                            Button {
                                selectedColorHex = option.hex
                                showColorPicker = false
                            } label: {
                                HStack(spacing: 14) {
                                    Circle()
                                        .fill(colorForHex(option.hex))
                                        .frame(width: 40, height: 40)
                                        .overlay(
                                            Circle()
                                                .stroke(selectedColorHex == option.hex ? accent : Color.clear, lineWidth: 3)
                                        )
                                    
                                    Text(option.name)
                                        .font(.system(.body, design: .rounded).weight(.semibold))
                                        .foregroundStyle(.white)
                                    
                                    Spacer()
                                    
                                    if selectedColorHex == option.hex {
                                        Image(systemName: "checkmark")
                                            .font(.system(size: 14, weight: .bold, design: .rounded))
                                            .foregroundStyle(accent)
                                    }
                                }
                                .padding(14)
                                .background(selectedColorHex == option.hex ? Color.white.opacity(0.10) : Color.white.opacity(0.06))
                                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .stroke(selectedColorHex == option.hex ? accent.opacity(0.4) : Color.white.opacity(0.05), lineWidth: 1)
                                )
                            }
                            .buttonStyle(.plain)
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
    
    // MARK: - Helpers
    
    private func colorForHex(_ hex: String) -> Color {
        // Простая функция для преобразования hex в Color
        // Если у тебя есть расширение Color(hex:), используй его
        // Иначе используй системные цвета по умолчанию
        switch hex {
        case "8A2BE2": return Color.purple
        case "00FFFF": return Color.cyan
        case "34C759": return Color.green
        case "FF9500": return Color.orange
        case "FF3B30": return Color.red
        case "007AFF": return Color.blue
        case "FF2D55": return Color.pink
        case "AF52DE": return Color.purple.opacity(0.8)
        case "FFCC00": return Color.yellow
        case "5AC8FA": return Color.blue.opacity(0.7)
        default: return Color.purple
        }
    }
    
    private func colorNameForHex(_ hex: String) -> String {
        colorOptions.first(where: { $0.hex == hex })?.name ?? "Фиолетовый"
    }
}

// MARK: - Card Component

private struct Card<Content: View>: View {
    @ViewBuilder var content: Content
    
    var body: some View {
        content
            .padding(16)
            .background(Color.white.opacity(0.07))
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.35), radius: 14, x: 0, y: 10)
    }
}
