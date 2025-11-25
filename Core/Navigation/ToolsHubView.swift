import SwiftUI

struct ToolsHubView: View {
    let swiftDataService: SwiftDataService
    
    // State for Timer navigation
    @State private var showTimerView = false
    @State private var timerMinutes = 0
    @State private var timerSeconds = 0
    @State private var timerLabel = String(localized: "manualTimer")
    @State private var selectedAgitationMode: AgitationMode?

    var body: some View {
        List {
            Section(header: Text(LocalizedStringKey("tools"))) {
                NavigationLink(destination: DevelopmentSetupView(viewModel: DevelopmentSetupViewModel(dataService: swiftDataService))) {
                    Label(LocalizedStringKey("developmentSetup"), systemImage: "slider.horizontal.3")
                }
                
                NavigationLink(destination: CalculatorView(swiftDataService: swiftDataService, onStartTimer: { _, _, _ in })) {
                    Label(LocalizedStringKey("calculator"), systemImage: "plus.forwardslash.minus")
                }
                
                NavigationLink(destination: timerDestinationView) {
                    Label(LocalizedStringKey("timer"), systemImage: "timer")
                }
            }
        }
        .navigationTitle(LocalizedStringKey("tools"))
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var timerDestinationView: some View {
        TimerTabView(onStartTimer: { minutes, seconds, agitationMode in
            self.timerMinutes = minutes
            self.timerSeconds = seconds
            self.timerLabel = String(localized: "manualTimer")
            self.selectedAgitationMode = agitationMode
            self.showTimerView = true
        })
        .navigationDestination(isPresented: $showTimerView) {
            TimerView(
                timerLabel: timerLabel,
                totalMinutes: timerMinutes,
                totalSeconds: timerSeconds,
                selectedAgitationMode: selectedAgitationMode
            )
        }
    }
}