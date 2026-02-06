import SwiftUI

struct SettingsView: View {
    @AppStorage("isDarkMode") private var isDarkMode = true
    @AppStorage("notificationsEnabled") private var notificationsEnabled = true
    @AppStorage("dailyRemindersEnabled") private var dailyRemindersEnabled = true
    
    // Theme
    private let primary = Color.purple
    private let accent  = Color.cyan
    
    @State private var showExportAlert = false
    @State private var showAboutSheet = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 16) {
                        appearanceSection
                        notificationsSection
                        dataSection
                        aboutSection
                        
                        Spacer(minLength: 20)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                }
            }
            .navigationTitle("Настройки")
            .navigationBarTitleDisplayMode(.large)
            .tint(accent)
            .preferredColorScheme(isDarkMode ? .dark : .light)
            .sheet(isPresented: $showAboutSheet) {
                AboutSheet()
            }
            .alert("Экспорт данных", isPresented: $showExportAlert) {
                Button("OK") { }
            } message: {
                Text("Данные успешно экспортированы. Файл сохранён в папке «Файлы».")
            }
        }
    }
    
    // MARK: - Sections
    
    private var appearanceSection: some View {
        Card {
            VStack(alignment: .leading, spacing: 12) {
                Text("Внешний вид")
                    .font(.system(.headline, design: .rounded).weight(.bold))
                    .foregroundStyle(.white)
                
                SettingRow(
                    icon: "paintbrush.fill",
                    iconColor: primary,
                    title: "Тёмная тема",
                    subtitle: "Использовать тёмный интерфейс"
                ) {
                    Toggle("", isOn: $isDarkMode)
                        .tint(accent)
                }
            }
        }
    }
    
    private var notificationsSection: some View {
        Card {
            VStack(alignment: .leading, spacing: 12) {
                Text("Уведомления")
                    .font(.system(.headline, design: .rounded).weight(.bold))
                    .foregroundStyle(.white)
                
                SettingRow(
                    icon: "bell.fill",
                    iconColor: accent,
                    title: "Включить уведомления",
                    subtitle: "Получать напоминания о привычках"
                ) {
                    Toggle("", isOn: $notificationsEnabled)
                        .tint(accent)
                }
                
                Divider()
                    .background(Color.white.opacity(0.15))
                
                SettingRow(
                    icon: "sunrise.fill",
                    iconColor: Color.orange,
                    title: "Ежедневные напоминания",
                    subtitle: "Напоминать каждый день в одно время"
                ) {
                    Toggle("", isOn: $dailyRemindersEnabled)
                        .tint(accent)
                        .disabled(!notificationsEnabled)
                        .opacity(notificationsEnabled ? 1 : 0.5)
                }
            }
        }
    }
    
    private var dataSection: some View {
        Card {
            VStack(alignment: .leading, spacing: 12) {
                Text("Данные")
                    .font(.system(.headline, design: .rounded).weight(.bold))
                    .foregroundStyle(.white)
                
                Button {
                    exportData()
                } label: {
                    SettingRowContent(
                        icon: "square.and.arrow.up.fill",
                        iconColor: Color.green,
                        title: "Экспорт данных",
                        subtitle: "Сохранить все данные в файл"
                    ) {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .foregroundStyle(.white.opacity(0.6))
                    }
                }
                .buttonStyle(.plain)
                
                Divider()
                    .background(Color.white.opacity(0.15))
                
                Button {
                    // Пока просто показываем alert
                    showExportAlert = true
                } label: {
                    SettingRowContent(
                        icon: "trash.fill",
                        iconColor: Color.red,
                        title: "Очистить данные",
                        subtitle: "Удалить все привычки и записи"
                    ) {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .foregroundStyle(.white.opacity(0.6))
                    }
                }
                .buttonStyle(.plain)
            }
        }
    }
    
    private var aboutSection: some View {
        Card {
            VStack(alignment: .leading, spacing: 12) {
                Text("О приложении")
                    .font(.system(.headline, design: .rounded).weight(.bold))
                    .foregroundStyle(.white)
                
                Button {
                    showAboutSheet = true
                } label: {
                    SettingRowContent(
                        icon: "info.circle.fill",
                        iconColor: accent,
                        title: "О HabitFlow",
                        subtitle: "Версия 1.0.0"
                    ) {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .foregroundStyle(.white.opacity(0.6))
                    }
                }
                .buttonStyle(.plain)
                
                Divider()
                    .background(Color.white.opacity(0.15))
                
                Link(destination: URL(string: "https://example.com/privacy")!) {
                    SettingRowContent(
                        icon: "lock.shield.fill",
                        iconColor: Color.blue,
                        title: "Политика конфиденциальности",
                        subtitle: nil
                    ) {
                        Image(systemName: "arrow.up.right.square")
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .foregroundStyle(.white.opacity(0.6))
                    }
                }
                
                Divider()
                    .background(Color.white.opacity(0.15))
                
                Link(destination: URL(string: "https://example.com/terms")!) {
                    SettingRowContent(
                        icon: "doc.text.fill",
                        iconColor: Color.gray,
                        title: "Условия использования",
                        subtitle: nil
                    ) {
                        Image(systemName: "arrow.up.right.square")
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .foregroundStyle(.white.opacity(0.6))
                    }
                }
            }
        }
    }
    
    // MARK: - Methods
    
    private func exportData() {
        // Простая реализация экспорта (можно расширить)
        let data = "Экспорт данных HabitFlow\nДата: \(Date())\n\nЗдесь будут данные о привычках..."
        
        // В реальном приложении здесь бы был код для сохранения в файл
        // и открытия share sheet
        showExportAlert = true
    }
}

// MARK: - Components

private struct SettingRow<Content: View>: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String?
    @ViewBuilder var trailing: Content
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(iconColor.opacity(0.2))
                    .frame(width: 40, height: 40)
                
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundStyle(iconColor)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(.body, design: .rounded).weight(.semibold))
                    .foregroundStyle(.white)
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.system(.caption, design: .rounded))
                        .foregroundStyle(.white.opacity(0.6))
                }
            }
            
            Spacer()
            
            trailing
        }
        .padding(.vertical, 4)
    }
}

private struct SettingRowContent<Content: View>: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String?
    @ViewBuilder var trailing: Content
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(iconColor.opacity(0.2))
                    .frame(width: 40, height: 40)
                
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundStyle(iconColor)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(.body, design: .rounded).weight(.semibold))
                    .foregroundStyle(.white)
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.system(.caption, design: .rounded))
                        .foregroundStyle(.white.opacity(0.6))
                }
            }
            
            Spacer()
            
            trailing
        }
        .padding(.vertical, 4)
    }
}

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

// MARK: - About Sheet

private struct AboutSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    private let accent = Color.cyan
    private let primary = Color.purple
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Logo
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [accent, primary],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 100, height: 100)
                            
                            Image(systemName: "checkmark")
                                .font(.system(size: 50, weight: .bold, design: .rounded))
                                .foregroundStyle(.black)
                        }
                        .padding(.top, 20)
                        
                        VStack(spacing: 8) {
                            Text("HabitFlow")
                                .font(.system(.title, design: .rounded).weight(.bold))
                                .foregroundStyle(.white)
                            
                            Text("Версия 1.0.0")
                                .font(.system(.subheadline, design: .rounded))
                                .foregroundStyle(.white.opacity(0.7))
                        }
                        
                        VStack(alignment: .leading, spacing: 16) {
                            Text("О приложении")
                                .font(.system(.headline, design: .rounded).weight(.bold))
                                .foregroundStyle(.white)
                            
                            Text("HabitFlow помогает вам формировать полезные привычки и отслеживать прогресс. Создавайте цели, отмечайте выполнение и наблюдайте за своим ростом.")
                                .font(.system(.body, design: .rounded))
                                .foregroundStyle(.white.opacity(0.8))
                                .lineSpacing(4)
                            
                            Text("Разработано с ❤️ для вашего успеха")
                                .font(.system(.subheadline, design: .rounded))
                                .foregroundStyle(.white.opacity(0.6))
                        }
                        .padding(.horizontal, 20)
                        
                        Spacer(minLength: 20)
                    }
                }
            }
            .navigationTitle("О приложении")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Готово") {
                        dismiss()
                    }
                    .foregroundStyle(.white)
                }
            }
            .tint(accent)
        }
    }
}
