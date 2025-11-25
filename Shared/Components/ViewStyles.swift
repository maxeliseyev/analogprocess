//
//  ViewStyles.swift
//  Film Lab
//
//  Created by Maxim Eliseyev on 12.07.2025.
//

import SwiftUI

// MARK: - Button Styles
extension View {
    /// Основной стиль кнопки с синим фоном и белым текстом
    /// Использование: Button("Текст") { }.primaryButtonStyle()
    func primaryButtonStyle() -> some View {
        self
            .foregroundColor(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .frame(minWidth: 80)
            .background(.blue)
            .cornerRadius(10)
    }
    
    /// Вторичный стиль кнопки с зеленым фоном и белым текстом
    /// Использование: Button("Текст") { }.secondaryButtonStyle()
    func secondaryButtonStyle() -> some View {
        self
            .foregroundColor(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .frame(minWidth: 80)
            .background(.green)
            .cornerRadius(10)
    }
    
    /// Стиль для иконок в кнопках
    /// Использование: Image(systemName: "timer").iconButtonStyle()
    func iconButtonStyle() -> some View {
        self
            .font(.system(size: 16))
            .foregroundColor(.white)
    }
    
    /// Заполненная прямоугольная кнопка с иконкой (основная)
    /// Использование: Image(systemName: "timer").primaryIconButtonStyle()
    func primaryIconButtonStyle() -> some View {
        self
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(.white)
            .frame(width: 60, height: 40)
            .background(Color.blue)
            .cornerRadius(10)
    }
    
    /// Заполненная прямоугольная кнопка с иконкой (вторичная)
    /// Использование: Image(systemName: "square.and.arrow.down").secondaryIconButtonStyle()
    func secondaryIconButtonStyle() -> some View {
        self
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(.white)
            .frame(width: 60, height: 40)
            .background(Color.green)
            .cornerRadius(10)
    }

    /// Стиль для кнопок выбора в таймере (активная)
    /// Использование: HStack { }.timerSelectorButtonStyle()
    func timerSelectorButtonStyle() -> some View {
        self
            .padding()
            .frame(maxWidth: .infinity, minHeight: 64)
            .background(Color(.systemGray6))
            .cornerRadius(10)
    }

    /// Стиль для кнопок выбора в таймере (неактивная)
    /// Использование: HStack { }.timerSelectorButtonDisabledStyle()
    func timerSelectorButtonDisabledStyle() -> some View {
        self
            .padding()
            .frame(maxWidth: .infinity, minHeight: 64)
            .background(Color(.systemGray5))
            .cornerRadius(10)
    }

    /// Стиль для основной кнопки действия в таймере (активная)
    /// Использование: HStack { }.timerActionButtonStyle()
    func timerActionButtonStyle() -> some View {
        self
            .padding()
            .frame(maxWidth: .infinity, minHeight: 64)
            .background(Color.accentColor)
            .cornerRadius(10)
    }

    /// Стиль для основной кнопки действия в таймере (неактивная)
    /// Использование: HStack { }.timerActionButtonDisabledStyle()
    func timerActionButtonDisabledStyle() -> some View {
        self
            .padding()
            .frame(maxWidth: .infinity, minHeight: 64)
            .background(Color(.systemGray5))
            .cornerRadius(10)
    }
}

// MARK: - Conditional View Modifier
extension View {
    /// Условный модификатор
    /// Использование: view.if(condition) { $0.modifier() }
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

// MARK: - Card Styles
extension View {
    /// Основной стиль карточки с серым фоном
    /// Использование: VStack { }.cardStyle()
    func cardStyle() -> some View {
        self
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
    }
    
    /// Стиль карточки для параметров с более темным фоном
    /// Использование: HStack { }.parameterCardStyle(isDisabled: Bool)
    func parameterCardStyle(isDisabled: Bool) -> some View {
        self
            .padding()
            .background(isDisabled ? Color(uiColor: .systemGray6) : Color(uiColor: .secondarySystemBackground))
            .cornerRadius(8)
    }
    
    /// Стиль карточки для picker'ов
    /// Использование: HStack { }.pickerCardStyle()
    func pickerCardStyle() -> some View {
        self
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.gray.opacity(0.1))
    }
}

// MARK: - Text Styles
extension View {
    /// Стиль заголовка с адаптивным цветом текста
    /// Использование: Text("Заголовок").headlineTextStyle()
    func headlineTextStyle() -> some View {
        self
            .font(.headline)
            .foregroundColor(.primary)
    }
    
    /// Стиль основного текста с адаптивным цветом
    /// Использование: Text("Текст").bodyTextStyle()
    func bodyTextStyle() -> some View {
        self
            .font(.body)
            .foregroundColor(.primary)
    }
    
    /// Стиль подписи с серым текстом
    /// Использование: Text("Подпись").captionTextStyle()
    func captionTextStyle() -> some View {
        self
            .font(.caption)
            .foregroundColor(.secondary)
    }
    
    /// Стиль моноширинного текста для основного контента
    /// Использование: Text("123").monospacedBodyStyle()
    func monospacedBodyStyle() -> some View {
        self
            .font(.system(.body, design: .monospaced))
            .fontWeight(.medium)
            .foregroundColor(.primary)
    }
    
    /// Стиль моноширинного заголовка
    /// Использование: Text("123").monospacedTitleStyle()
    func monospacedTitleStyle() -> some View {
        self
            .font(.system(.title3, design: .monospaced))
            .fontWeight(.bold)
            .foregroundColor(.primary)
    }
    
    /// Стиль заголовка для picker'ов
    /// Использование: Text("Заголовок").pickerTitleStyle()
    func pickerTitleStyle() -> some View {
        self
            .font(.headline)
            .foregroundColor(.primary)
    }
    
    /// Стиль подписи для picker'ов
    /// Использование: Text("Подпись").pickerSubtitleStyle()
    func pickerSubtitleStyle() -> some View {
        self
            .font(.caption)
            .foregroundColor(.secondary)
    }
}

// MARK: - Layout Styles
extension View {
    /// Стандартные горизонтальные отступы
    /// Использование: VStack { }.standardPadding()
    func standardPadding() -> some View {
        self
            .padding(.horizontal)
    }
    
    /// Вертикальные отступы с настраиваемым размером
    /// Использование: VStack { }.verticalSpacing(16)
    func verticalSpacing(_ spacing: CGFloat = 12) -> some View {
        self
            .padding(.vertical, spacing)
    }
    
    /// Горизонтальные отступы с настраиваемым размером
    /// Использование: HStack { }.horizontalSpacing(20)
    func horizontalSpacing(_ spacing: CGFloat = 16) -> some View {
        self
            .padding(.horizontal, spacing)
    }
}

// MARK: - Interactive Styles
extension View {
    /// Стиль галочки для выбранных элементов
    /// Использование: Image(systemName: "checkmark").checkmarkStyle()
    func checkmarkStyle() -> some View {
        self
            .foregroundColor(.blue)
            .font(.system(size: 16, weight: .medium))
    }
    
    /// Стиль стрелки для навигации
    /// Использование: Image(systemName: "chevron.down").chevronStyle()
    func chevronStyle() -> some View {
        self
            .foregroundColor(.secondary)
            .font(.caption)
    }
    
    /// Стиль информационной иконки
    /// Использование: Image(systemName: "info.circle").infoIconStyle()
    func infoIconStyle() -> some View {
        self
            .font(.largeTitle)
            .foregroundColor(.blue)
    }
    
    /// Стиль предупреждающей иконки
    /// Использование: Image(systemName: "exclamationmark.triangle").warningIconStyle()
    func warningIconStyle() -> some View {
        self
            .font(.largeTitle)
            .foregroundColor(.orange)
    }
    
    /// Стиль отключенного текста
    /// Использование: Text("Текст").disabledTextStyle()
    func disabledTextStyle() -> some View {
        self
            .font(.body)
            .foregroundColor(.secondary)
    }
    
    /// Стиль основного текста
    /// Использование: Text("Текст").primaryTextStyle()
    func primaryTextStyle() -> some View {
        self
            .font(.body)
            .foregroundColor(.primary)
    }
}

// MARK: - Background Styles
extension View {
    /// Основной фон приложения
    /// Использование: VStack { }.primaryBackground()
    func primaryBackground() -> some View {
        self
            .background(Color.gray.opacity(0.05))
    }
    
    /// Вторичный фон
    /// Использование: VStack { }.secondaryBackground()
    func secondaryBackground() -> some View {
        self
            .background(Color.gray.opacity(0.1))
    }
}

// MARK: - Selection Styles
extension View {
    /// Стиль для выбранных элементов
    /// Использование: HStack { }.selectionStyle()
    func selectionStyle() -> some View {
        self
            .background(Color.blue.opacity(0.15))
            .cornerRadius(8)
    }
    
    /// Стиль границы для выбранных элементов
    /// Использование: HStack { }.selectionBorderStyle()
    func selectionBorderStyle() -> some View {
        self
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.blue, lineWidth: 2)
            )
    }
}

// MARK: - Timer Styles
extension Shape {
    /// Стиль активного таймера
    /// Использование: Circle().timerActiveStyle()
    func timerActiveStyle() -> some View {
        self
            .fill(Color.blue)
    }
    
    /// Стиль неактивного таймера
    /// Использование: Circle().timerInactiveStyle()
    func timerInactiveStyle() -> some View {
        self
            .fill(Color.gray.opacity(0.3))
    }
    
    /// Стиль для агитации
    /// Использование: Circle().agitationStyle()
    func agitationStyle() -> some View {
        self
            .fill(Color.orange)
    }
}