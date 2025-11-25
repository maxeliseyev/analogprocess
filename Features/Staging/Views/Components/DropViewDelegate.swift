import SwiftUI

struct DropViewDelegate: DropDelegate {
    @Binding var draggedStage: StagingStage?
    @Binding var stages: [StagingStage]
    let currentIndex: Int
    
    func performDrop(info: DropInfo) -> Bool {
        guard let draggedStage = draggedStage,
              let draggedIndex = stages.firstIndex(where: { $0.id == draggedStage.id }) else {
            return false
        }
        
        if draggedIndex != currentIndex {
            withAnimation(.easeInOut(duration: 0.3)) {
                let stage = stages.remove(at: draggedIndex)
                let newIndex = draggedIndex < currentIndex ? currentIndex - 1 : currentIndex
                stages.insert(stage, at: newIndex)
            }
        }
        
        self.draggedStage = nil
        return true
    }
    
    func dropEntered(info: DropInfo) {
        guard let draggedStage = draggedStage,
              let fromIndex = stages.firstIndex(where: { $0.id == draggedStage.id }) else {
            return
        }
        if fromIndex != currentIndex {
            withAnimation(.easeInOut(duration: 0.25)) {
                let stage = stages.remove(at: fromIndex)
                let newIndex = fromIndex < currentIndex ? currentIndex - 1 : currentIndex
                stages.insert(stage, at: newIndex)
            }

        }
    }
    
    func dropExited(info: DropInfo) {
        // Можно добавить визуальную обратную связь при перетаскивании
    }

    func dropUpdated(info: DropInfo) -> DropProposal? {
        DropProposal(operation: .move)
    }
}
