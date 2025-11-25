//
//  ProcessTypeView.swift
//  Film Lab
//
//  Created by Maxim Eliseyev on 11.07.2025.
//

import SwiftUI

struct ProcessTypeView: View {
    @Binding var isPushMode: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(LocalizedStringKey("processType"))
                .font(.headline)
            
            Picker(LocalizedStringKey("processType"), selection: $isPushMode) {
                Text(LocalizedStringKey("pull")).tag(false)
                Text(LocalizedStringKey("push")).tag(true)
            }
            .pickerStyle(SegmentedPickerStyle())
        }
    }
}

struct ProcessTypeView_Previews: PreviewProvider {
    static var previews: some View {
        ProcessTypeView(isPushMode: .constant(true))
            .padding()
    }
} 