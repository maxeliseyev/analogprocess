import SwiftUI

struct StageRowView: View {
    @Binding var stage: StagingStage
    let swiftDataService: SwiftDataService
    let onDelete: () -> Void
    let onDuplicate: () -> Void
    
    @State private var swipeOffsetX: CGFloat = 0
    private let swipeThreshold: CGFloat = 80
    @State private var isEditingStage = false
    
    var body: some View {
        ZStack {
            // Фоновая индикация свайпов
            if swipeOffsetX < 0 {
                HStack {
                    Spacer()
                    Label(LocalizedStringKey("delete"), systemImage: "trash.fill")
                        .font(.subheadline)
                        .foregroundColor(.white)
                        .padding(.trailing, 16)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .trailing)
                .background(Color.red)
                .cornerRadius(12)
                .opacity(min(1, Double(-swipeOffsetX / 120)))
            } else if swipeOffsetX > 0 {
                HStack {
                    Label(LocalizedStringKey("edit"), systemImage: "pencil")
                        .font(.subheadline)
                        .foregroundColor(.white)
                        .padding(.leading, 16)
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                .background(Color.blue)
                .cornerRadius(12)
                .opacity(min(1, Double(swipeOffsetX / 120)))
            }
            
            HStack(spacing: 8) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(LocalizedStringKey(stage.name))
                        .headlineTextStyle()
                }
                
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                if stage.duration > 0 {
                    Text(formatDuration(stage.duration))
                        .font(.title3)
                        .fontWeight(.medium)
                        .foregroundColor(.blue)
                } else {
                    Text(LocalizedStringKey("tapToSetTime"))
                        .captionTextStyle()
                        .foregroundColor(.secondary)
                }
            }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
            .offset(x: swipeOffsetX)
            .contentShape(Rectangle())
            .onTapGesture {
                isEditingStage = true
            }
            .gesture(
                DragGesture(minimumDistance: 10)
                    .onChanged { value in
                        swipeOffsetX = value.translation.width
                    }
                    .onEnded { value in
                        let translation = value.translation.width
                        if translation <= -swipeThreshold {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                onDelete()
                            }
                        } else if translation >= swipeThreshold {
                            isEditingStage = true
                        }
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            swipeOffsetX = 0
                        }
                    }
            )
            .contextMenu {
                Button {
                    isEditingStage = true
                } label: {
                    Label(LocalizedStringKey("edit"), systemImage: "pencil")
                }
                Button {
                    onDuplicate()
                } label: {
                    Label(LocalizedStringKey("duplicate"), systemImage: "plus.square.on.square")
                }
                Button(role: .destructive) {
                    onDelete()
                } label: {
                    Label(LocalizedStringKey("delete"), systemImage: "trash")
                }
            }
        }
        .sheet(isPresented: $isEditingStage) {
            StageEditorSheet(swiftDataService: swiftDataService, stage: $stage) {
                isEditingStage = false
            }
        }
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
