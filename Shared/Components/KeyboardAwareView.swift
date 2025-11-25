//
//  KeyboardAwareView.swift
//  Film Lab
//
//  Created by Maxim Eliseyev on 12.07.2025.
//

import SwiftUI
import Combine

struct KeyboardAwareView<Content: View>: View {
    @State private var keyboardHeight: CGFloat = 0
    @State private var isKeyboardVisible = false
    
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack {
                    content
                    
                    // Добавляем отступ снизу, когда клавиатура видна
                    if isKeyboardVisible {
                        Spacer()
                            .frame(height: keyboardHeight)
                    }
                }
                .frame(minHeight: geometry.size.height)
            }
            // Добавляем обработчик жестов для скрытия клавиатуры при прокрутке
            .simultaneousGesture(
                DragGesture()
                    .onChanged { _ in
                        // Скрываем клавиатуру при начале прокрутки
                        if isKeyboardVisible {
                            hideKeyboard()
                        }
                    }
            )
            // Добавляем обработчик нажатия вне текстовых полей
            .onTapGesture {
                if isKeyboardVisible {
                    hideKeyboard()
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { notification in
            if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                keyboardHeight = keyboardFrame.height
                isKeyboardVisible = true
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
            keyboardHeight = 0
            isKeyboardVisible = false
        }
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

// MARK: - View Extension
extension View {
    func keyboardAware() -> some View {
        KeyboardAwareView {
            self
        }
    }
} 