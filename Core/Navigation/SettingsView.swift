import SwiftUI

public struct SettingsView: View {
    @EnvironmentObject var githubService: GitHubDataService
    @EnvironmentObject var autoSyncService: AutoSyncService
    @EnvironmentObject var swiftDataService: SwiftDataService
    
    @Binding var colorScheme: ColorScheme?
    @State private var selectedTheme: Int = 0
    @State private var showingDataAlert = false
    @State private var alertMessage = ""
    @State private var isSyncing = false
    
    private var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
        return "v\(version)"
    }
    
    public init(colorScheme: Binding<ColorScheme?>) {
        self._colorScheme = colorScheme
    }
    
    public var body: some View {
        Form {
            Section(header: Text(LocalizedStringKey("settingsTheme"))) {
                Picker(selection: $selectedTheme, label: Text(LocalizedStringKey("settingsThemeMode"))) {
                    Text(LocalizedStringKey("settingsThemeSystem")).tag(0)
                    Text(LocalizedStringKey("settingsThemeLight")).tag(1)
                    Text(LocalizedStringKey("settingsThemeDark")).tag(2)
                }
                .pickerStyle(SegmentedPickerStyle())
                .onChange(of: selectedTheme) { oldValue, newValue in
                    switch newValue {
                    case 1: colorScheme = .light
                    case 2: colorScheme = .dark
                    default: colorScheme = nil
                    }
                }
            }
            
            Section(header: Text(LocalizedStringKey("settingsData"))) {
                // Переключатель автоматической синхронизации
                VStack(alignment: .leading, spacing: 8) {
                    Toggle(isOn: Binding(
                        get: { autoSyncService.isAutoSyncEnabled },
                        set: { autoSyncService.setAutoSyncEnabled($0) }
                    )) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(LocalizedStringKey("settingsAutoSyncEnabled"))
                                .font(.body)
                            Text(LocalizedStringKey("settingsAutoSyncDescription"))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(.vertical, 4)
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(LocalizedStringKey("settingsSyncData"))
                        Spacer()
                        if isSyncing || autoSyncService.isAutoSyncing {
                            ProgressView()
                                .scaleEffect(0.8)
                        }
                    }
                    
                    // Статус автоматической синхронизации
                    AutoSyncStatusView(autoSyncService: autoSyncService)
                    
                    if githubService.isDownloading {
                        ProgressView(value: min(max(githubService.downloadProgress, 0.0), 1.0))
                            .progressViewStyle(LinearProgressViewStyle())
                    }
                    
                    if let lastSync = githubService.lastSyncDate {
                        Text(LocalizedStringKey("settingsLastSync"))
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(lastSync, style: .relative)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    if let lastAutoSync = autoSyncService.lastAutoSyncDate {
                        Text(LocalizedStringKey("settingsLastAutoSync"))
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(lastAutoSync, style: .relative)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Button(action: syncData) {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                        Text(LocalizedStringKey("settingsSyncNow"))
                    }
                }
                .disabled(isSyncing || githubService.isDownloading || autoSyncService.isAutoSyncing)
                
                // Тестовая кнопка для автосинхронизации (только для разработки)
                #if DEBUG
                Button(action: {
                    Task { await autoSyncService.forceAutoSync() }
                }) {
                    HStack {
                        Image(systemName: "play.circle")
                        Text("Test Auto Sync")
                    }
                }
                .disabled(autoSyncService.isAutoSyncing)
                .foregroundColor(.orange)
                #endif
            }
            
            Section(header: Text(LocalizedStringKey("support"))) {
                Button(action: contactDeveloper) {
                    HStack {
                        Image(systemName: "envelope")
                        Text(LocalizedStringKey("contactDeveloper"))
                        Spacer()
                        Image(systemName: "arrow.up.right")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .foregroundColor(.primary)
            }
            
        }
        .navigationTitle(LocalizedStringKey("settings"))
        .navigationBarTitleDisplayMode(.inline)
        .overlay(
            VStack {
                Spacer()
                Text(appVersion)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .padding(.bottom, 20)
            }
        )
        .onAppear {
            if colorScheme == .light { selectedTheme = 1 }
            else if colorScheme == .dark { selectedTheme = 2 }
            else { selectedTheme = 0 }
        }
                        .alert(LocalizedStringKey("settingsSyncResult"), isPresented: $showingDataAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
    }
    
    private func syncData() {
        isSyncing = true
        
        Task {
            do {
                try await swiftDataService.syncDataFromGitHub()
                await MainActor.run {
                    alertMessage = NSLocalizedString("settingsSyncSuccess", comment: "")
                    showingDataAlert = true
                    isSyncing = false
                }
            } catch {
                await MainActor.run {
                    alertMessage = NSLocalizedString("settingsSyncError", comment: "") + ": \(error.localizedDescription)"
                    showingDataAlert = true
                    isSyncing = false
                }
            }
        }
    }
    
    private func contactDeveloper() {
        let email = AppConstants.Developer.email
        let subject = "Analog Process App Feedback"
        let body = "Hello,\n\nI would like to provide feedback about the Analog Process app.\n\n"
        
        if let url = URL(string: "mailto:\(email)?subject=\(subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&body=\(body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")") {
            UIApplication.shared.open(url)
        }
    }
} 
