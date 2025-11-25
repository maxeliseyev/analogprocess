import SwiftUI
import SwiftData

struct JournalView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel: JournalViewModel
    
    let onEditRecord: (SwiftDataJournalRecord) -> Void
    let onCreateNew: () -> Void
    
    @State private var selectedRecord: SwiftDataJournalRecord?
    @State private var searchText = ""
    @Query(sort: \SwiftDataJournalRecord.date, order: .reverse) private var records: [SwiftDataJournalRecord]
    
    private var filteredRecords: [SwiftDataJournalRecord] {
        if searchText.isEmpty {
            return records
        } else {
            return records.filter { record in
                let searchQuery = searchText.lowercased()
                let name = record.name?.lowercased() ?? ""
                let filmName = record.filmName?.lowercased() ?? ""
                let developerName = record.developerName?.lowercased() ?? ""
                let process = record.process?.lowercased() ?? ""
                let comment = record.comment?.lowercased() ?? ""
                
                return name.contains(searchQuery) ||
                filmName.contains(searchQuery) ||
                developerName.contains(searchQuery) ||
                process.contains(searchQuery) ||
                comment.contains(searchQuery)
            }
        }
    }

    init(
        swiftDataService: SwiftDataService,
        onEditRecord: @escaping (SwiftDataJournalRecord) -> Void,
        onCreateNew: @escaping () -> Void,
    ) {
        self._viewModel = StateObject(wrappedValue: JournalViewModel(swiftDataService: swiftDataService))
        self.onEditRecord = onEditRecord
        self.onCreateNew = onCreateNew
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if records.isEmpty && searchText.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "book")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)
                    
                    Text(LocalizedStringKey("noRecords"))
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(LocalizedStringKey("noRecordsDescription"))
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if records.isEmpty && !searchText.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)

                    Text(LocalizedStringKey("noResultsFound"))
                        .font(.headline)
                        .foregroundColor(.primary)

                    Text(LocalizedStringKey("trySearchingDifferentKeywords"))
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(filteredRecords, id: \.id) { record in
                            RecordRowView(
                                record: record,
                                onTap: {
                                    selectedRecord = record
                                }
                            )
                            .swipeActions(edge: .leading, allowsFullSwipe: false) {
                                Button {
                                    onEditRecord(record)
                                } label: {
                                    Label(LocalizedStringKey("edit"), systemImage: "pencil")
                                }
                                .tint(.blue)
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button(role: .destructive) {
                                    deleteRecord(record)
                                } label: {
                                    Label(LocalizedStringKey("delete"), systemImage: "trash")
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
        .navigationTitle(LocalizedStringKey("journal"))
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $selectedRecord) { record in
            RecordDetailView(
                record: record,
                swiftDataService: viewModel.swiftDataService,
                onEdit: {
                    selectedRecord = nil
                    onEditRecord(record)
                },
                onDelete: {
                    selectedRecord = nil
                    deleteRecord(record)
                }
            )
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: onCreateNew) {
                    Image(systemName: "plus")
                }
            }
        }
    }
    
    private func deleteRecord(_ record: SwiftDataJournalRecord) {
        modelContext.delete(record)
    }
}
