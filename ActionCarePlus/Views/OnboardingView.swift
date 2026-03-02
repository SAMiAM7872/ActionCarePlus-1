import SwiftUI

struct OnboardingView: View {
    @Binding var hasSeenOnboarding: Bool
    @State private var currentPage = 0

    struct Page {
        let icon: String
        let color: Color
        let title: String
        let body: String
    }

    let pages: [Page] = [
        Page(
            icon: "waveform.path.ecg",
            color: .blue,
            title: "Welcome to ActionCare+",
            body: "Your personal symptom tracker. Get instant health guidance on your device, completely private."
        ),
        Page(
            icon: "checklist",
            color: .teal,
            title: "Track Your Symptoms",
            body: "Choose from 25 common symptoms or describe them in your own words. ActionCare+ uses machine learning to suggest likely conditions."
        ),
        // FR-17: Medical disclaimer on slide 3
        Page(
            icon: "exclamationmark.shield.fill",
            color: .orange,
            title: "Important Disclaimer",
            body: "ActionCare+ is NOT a substitute for professional medical advice. Results are not a diagnosis. Always consult a licensed healthcare provider."
        )
    ]

    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $currentPage) {
                ForEach(0..<pages.count, id: \.self) { index in
                    VStack(spacing: 28) {
                        Spacer()

                        Image(systemName: pages[index].icon)
                            .font(.system(size: 80))
                            .foregroundColor(pages[index].color)
                            .padding(24)
                            .background(pages[index].color.opacity(0.12))
                            .clipShape(Circle())

                        Text(pages[index].title)
                            .font(.title.bold())
                            .multilineTextAlignment(.center)

                        Text(pages[index].body)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)

                        Spacer()
                        Spacer()
                    }
                    .padding(.horizontal, 24)
                    .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))

            VStack(spacing: 14) {
                if currentPage < pages.count - 1 {
                    Button {
                        currentPage += 1
                    } label: {
                        Text("Next")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(14)
                    }
                } else {
                    Button {
                        hasSeenOnboarding = true
                    } label: {
                        Text("Get Started")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(14)
                    }
                }

                Button("Skip") {
                    hasSeenOnboarding = true
                }
                .foregroundColor(.secondary)
                .font(.subheadline)
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 44)
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
    }
}

