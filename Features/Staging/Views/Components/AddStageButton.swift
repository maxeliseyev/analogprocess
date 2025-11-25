import SwiftUI

struct AddStageButton: View {
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                Rectangle()
                    .fill(Color.clear)
                    .frame(width: 24, height: 12)
                
                HStack {
                    Spacer()
                    Image(systemName: "plus")
                        .font(.title3)
                        .foregroundColor(.blue)
                    Spacer()
                }
                
                Rectangle()
                    .fill(Color.clear)
                    .frame(width: 24, height: 12)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.blue, style: StrokeStyle(lineWidth: 1, dash: [4]))
            )
        }
    }
}
