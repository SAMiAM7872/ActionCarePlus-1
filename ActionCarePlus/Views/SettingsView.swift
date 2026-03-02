import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var viewModel: SymptomViewModel
    @State private var showClearConfirm = false
    @State private var showDisclaimer = false
    @State private var showPrivacy = false
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = true

    var body: some View {
        NavigationView {
            List {
                Section("Data") {
                    // FR-18: Clear history
                    Button(role: .destructive) {
                        showClearConfirm = true
                    } label: {
                        Label("Clear All History", systemImage: "trash")
                    }
                    .confirmationDialog(
                        "Delete all symptom history?",
                        isPresented: $showClearConfirm,
                        titleVisibility: .visible
                    ) {
                        Button("Delete All", role: .destructive) {
                            viewModel.clearAllHistory()
                        }
                    }

                    // FR-13: Trend chart link
                    NavigationLink {
                        TrendChartView()
                            .environmentObject(viewModel)
                    } label: {
                        Label("View Symptom Trends", systemImage: "chart.bar.fill")
                    }
                }

                Section("Legal & Safety") {
                    // FR-17, FR-19
                    Button {
                        showDisclaimer = true
                    } label: {
                        Label("Medical Disclaimer", systemImage: "exclamationmark.triangle")
                    }

                    Button {
                        showPrivacy = true
                    } label: {
                        Label("Privacy Policy", systemImage: "lock.shield")
                    }
                }

                Section("App") {
                    Button {
                        hasSeenOnboarding = false
                    } label: {
                        Label("Replay Onboarding", systemImage: "arrow.counterclockwise")
                    }
                    .foregroundColor(.primary)

                    HStack {
                        Label("Version", systemImage: "info.circle")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }

                    HStack {
                        Label("Developer", systemImage: "person")
                        Spacer()
                        Text("Samuel Stewart")
                            .foregroundColor(.secondary)
                    }
                }

                Section("Privacy") {
                    VStack(alignment: .leading, spacing: 6) {
                        Label("All data stored locally on this device", systemImage: "iphone")
                            .font(.subheadline)
                        Text("ActionCare+ never sends your data to any server.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Settings")
            // FR-17
            .sheet(isPresented: $showDisclaimer) {
                LegalSheet(
                    title: "Medical Disclaimer",
                    icon: "exclamationmark.triangle.fill",
                    iconColor: .orange,
                    text: "ActionCare+ is for informational purposes only. Results are NOT a substitute for professional medical advice, diagnosis, or treatment. Always consult a licensed healthcare provider. In a medical emergency call 911."
                )
            }
            // FR-19
            .sheet(isPresented: $showPrivacy) {
                LegalSheet(
                    title: "Privacy Policy",
                    icon: "lock.shield.fill",
                    iconColor: .blue,
                    text: "All symptom data is stored exclusively on your device using Core Data. No data is transmitted to any server. ActionCare+ does not collect, share, or sell personal information. Delete all data anytime via Settings."
                )
            }
        }
    }
}

struct LegalSheet: View {
    let title: String
    let icon: String
    let iconColor: Color
    let text: String

    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Image(systemName: icon)
                        .font(.system(size: 50))
                        .foregroundColor(iconColor)
                        .frame(maxWidth: .infinity)
                        .padding(.top, 24)

                    Text(text)
                        .font(.body)
                        .padding(.horizontal)
                }
                .padding(.bottom, 40)
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

