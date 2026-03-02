import SwiftUI

struct HistoryView: View {
    @EnvironmentObject var viewModel: SymptomViewModel
    @State private var showClearConfirm = false

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                if viewModel.historyEntries.isEmpty {
                    Spacer()
                    VStack(spacing: 12) {
                        Image(systemName: "clock.badge.xmark")
                            .font(.system(size: 54))
                            .foregroundColor(.secondary)
                        Text("No history yet")
                            .font(.title3.bold())
                        Text("Complete a check-in to start tracking.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                } else {
                    List {
                        ForEach(viewModel.historyEntries) { entry in
                            HistoryRowView(entry: entry)
                                .listRowInsets(
                                    EdgeInsets(top: 10, leading: 16, bottom: 10, trailing: 16)
                                )
                        }
                    }
                    .listStyle(InsetGroupedListStyle())
                }

                // FR-18: Clear All History button pinned to bottom
                Button(role: .destructive) {
                    showClearConfirm = true
                } label: {
                    Text("Clear All History")
                        .font(.headline)
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.systemBackground))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color.red, lineWidth: 1.5)
                        )
                        .cornerRadius(14)
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
                .background(Color(.systemGroupedBackground))
                .confirmationDialog(
                    "Delete all symptom history?",
                    isPresented: $showClearConfirm,
                    titleVisibility: .visible
                ) {
                    Button("Delete All", role: .destructive) {
                        viewModel.clearAllHistory()
                    }
                }
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .navigationTitle("History")
            .onAppear {
                viewModel.loadHistory()
            }
        }
    }
}

struct HistoryRowView: View {
    let entry: SymptomEntry

    var urgencyColor: Color {
        switch entry.urgencyLevel {
        case "Self-Care":
            return .green
        case "Doctor Visit":
            return .orange
        case "Emergency":
            return .red
        default:
            return .blue
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            HStack {
                Text(entry.topCondition ?? "Unknown")
                    .font(.headline)
                Spacer()
                Text(entry.urgencyLevel ?? "")
                    .font(.caption.bold())
                    .foregroundColor(urgencyColor)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(urgencyColor.opacity(0.12))
                    .cornerRadius(8)
            }

            Text(Self.format(date: entry.date ?? Date()))
                .font(.caption)
                .foregroundColor(.secondary)

            if let symptoms = entry.selectedSymptoms, !symptoms.isEmpty {
                Text(symptoms)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
        }
        .padding(.vertical, 2)
    }

    private static func format(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

