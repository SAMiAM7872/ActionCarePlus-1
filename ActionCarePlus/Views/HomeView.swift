import SwiftUI

struct HomeView: View {
    @EnvironmentObject var viewModel: SymptomViewModel
    @State private var navigateToCheck = false

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // FR-14: Header
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Welcome back!")
                                .font(.largeTitle.bold())
                            Text("How are you feeling today?")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal)
                        .padding(.top, 20)

                        // FR-14: Recent Symptom Entry card
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Recent Symptom Entry")
                                .font(.headline)

                            Divider()

                            if let latest = viewModel.historyEntries.first {
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Text(latest.topCondition ?? "Unknown")
                                            .font(.subheadline.bold())

                                        Spacer()

                                        Text(latest.urgencyLevel ?? "")
                                            .font(.caption.bold())
                                            .foregroundColor(urgencyColor(for: latest.urgencyLevel))
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 3)
                                            .background(urgencyColor(for: latest.urgencyLevel).opacity(0.12))
                                            .cornerRadius(6)
                                    }

                                    if let date = latest.date {
                                        Text(Self.format(date: date))
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }

                                    if let symptoms = latest.selectedSymptoms {
                                        Text(symptoms)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                            .lineLimit(2)
                                    }
                                }
                            } else {
                                VStack(spacing: 6) {
                                    Image(systemName: "tray")
                                        .foregroundColor(.secondary)
                                        .font(.title2)
                                    Text("No entries yet")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                            }
                        }
                        .padding(16)
                        .background(Color(.systemBackground))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color.blue.opacity(0.35), lineWidth: 1.5)
                        )
                        .cornerRadius(14)
                        .shadow(color: Color.blue.opacity(0.08), radius: 6)
                        .padding(.horizontal)

                        // FR-17: Disclaimer
                        HStack(spacing: 10) {
                            Image(systemName: "info.circle.fill")
                                .foregroundColor(.orange)
                            Text("Not a substitute for professional medical advice.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(12)
                        .background(Color.orange.opacity(0.08))
                        .cornerRadius(10)
                        .padding(.horizontal)

                        Spacer(minLength: 120)
                    }
                }

                // Start New Assessment button
                VStack {
                    NavigationLink(
                        destination: SymptomInputView().environmentObject(viewModel),
                        isActive: $navigateToCheck
                    ) {
                        EmptyView()
                    }

                    Button {
                        viewModel.resetInput()
                        navigateToCheck = true
                    } label: {
                        Text("Start New Assessment")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(14)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 24)
                    .padding(.top, 12)
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarHidden(true)
            .onAppear {
                viewModel.loadHistory()
            }
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
    }

    private static func format(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    private func urgencyColor(for level: String?) -> Color {
        switch level {
        case "Emergency": return .red
        case "Doctor Visit": return .orange
        default: return .green
        }
    }
}

