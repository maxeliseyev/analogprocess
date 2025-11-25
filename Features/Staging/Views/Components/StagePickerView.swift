import SwiftUI

struct StagePickerView: View {
    let availableStages: [StagingStage]
    let onSelectStage: (StagingStage) -> Void
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: StagingViewModel
    
    var body: some View {
        NavigationView {
            List(availableStages) { stage in
                Button(action: {
                    onSelectStage(stage)
                }) {
                    HStack(spacing: 12) {
                        Image(systemName: stage.iconName)
                            .font(.title2)
                            .foregroundColor(Color(stage.color))
                            .frame(width: 32, height: 32)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text(LocalizedStringKey(stage.name))
                                    .headlineTextStyle()
                                
                                // Показываем количество уже добавленных стадий этого типа
                                let count = viewModel.selectedStages.filter { $0.name.hasPrefix(stage.name) }.count
                                if count > 0 {
                                    Text("(\(count))")
                                        .captionTextStyle()
                                }
                            }
                            
                            Text(LocalizedStringKey(stage.description))
                                .captionTextStyle()
                                .lineLimit(2)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle(LocalizedStringKey("chooseStage"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(LocalizedStringKey("cancel")) {
                        dismiss()
                    }
                }
            }
        }
    }
}
