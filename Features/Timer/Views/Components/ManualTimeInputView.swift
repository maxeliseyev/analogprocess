import SwiftUI

struct ManualTimeInputView: View {
    @Binding var minutes: Int
    @Binding var seconds: Int
    let onApply: () -> Void
    let onCancel: () -> Void
    let title: LocalizedStringKey
    
    @State private var tempMinutes: Int
    @State private var tempSeconds: Int
    
    init(minutes: Binding<Int>, seconds: Binding<Int>, onApply: @escaping () -> Void, onCancel: @escaping () -> Void, title: LocalizedStringKey = "setTimeManually") {
        self._minutes = minutes
        self._seconds = seconds
        self.onApply = onApply
        self.onCancel = onCancel
        self.title = title
        self._tempMinutes = State(initialValue: minutes.wrappedValue)
        self._tempSeconds = State(initialValue: seconds.wrappedValue)
    }
    
    var body: some View {
        VStack(spacing: 30) {
            Text(title)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            
            HStack(spacing: 0) {
                // Minutes Picker
                Picker("Minutes", selection: $tempMinutes) {
                    ForEach(0...59, id: \.self) { minute in
                        Text("\(minute)")
                            .font(.title)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .tag(minute)
                    }
                }
                #if os(iOS)
                .pickerStyle(WheelPickerStyle())
                #endif
                .frame(width: 100)
                .clipped()
                
                Text(":")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                
                // Seconds Picker
                Picker("Seconds", selection: $tempSeconds) {
                    ForEach(0...59, id: \.self) { second in
                        Text(String(format: "%02d", second))
                            .font(.title)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .tag(second)
                    }
                }
                #if os(iOS)
                .pickerStyle(WheelPickerStyle())
                #endif
                .frame(width: 100)
                .clipped()
            }
            .frame(height: 200)
            
            HStack(spacing: 20) {
                Button(action: onCancel) {
                    Text(LocalizedStringKey("cancel"))
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: 100, height: 44)
                        .background(Color.gray)
                        .cornerRadius(22)
                }
                
                Button(action: {
                    minutes = tempMinutes
                    seconds = tempSeconds
                    onApply()
                }) {
                    Text(LocalizedStringKey("apply"))
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: 100, height: 44)
                        .background(Color.green)
                        .cornerRadius(22)
                }
            }
        }
        .padding()
        .background(Color.black.opacity(0.8))
        .cornerRadius(16)
    }
}

struct ManualTimeInputView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Основной превью
            ZStack {
                Color.black.ignoresSafeArea()
                
                ManualTimeInputView(
                    minutes: .constant(5),
                    seconds: .constant(30),
                    onApply: {},
                    onCancel: {},
                    title: "setTimeManually"
                )
            }
            .previewDisplayName("Manual Time Input - Default")
            
            // Превью с нулевым временем
            ZStack {
                Color.black.ignoresSafeArea()
                
                ManualTimeInputView(
                    minutes: .constant(0),
                    seconds: .constant(0),
                    onApply: {},
                    onCancel: {},
                    title: "setTimeManually"
                )
            }
            .previewDisplayName("Manual Time Input - Zero Time")
            
            // Превью с длинным временем
            ZStack {
                Color.black.ignoresSafeArea()
                
                ManualTimeInputView(
                    minutes: .constant(25),
                    seconds: .constant(45),
                    onApply: {},
                    onCancel: {},
                    title: "setTimeManually"
                )
            }
            .previewDisplayName("Manual Time Input - Long Time")
        }
        .preferredColorScheme(.dark)
    }
} 