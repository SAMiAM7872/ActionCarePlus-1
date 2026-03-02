import SwiftUI

struct ResultsView: View {
    @EnvironmentObject var viewModel: SymptomViewModel
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // FR-17: Medical disclaimer
                HStack(spacing: 10) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.orange)
                    Text("Not a substitute for professional medical advice. Results are not a diagnosis.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(12)
                .background(Color.orange.opacity(0.1))
                .cornerRadius(12)
                .padding(.horizontal)

                if viewModel.isLoading {
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.4)
                        Text("Analyzing...")
                            .foregroundColor(.secondary)
                    }
                    .padding(60)
                } else if viewModel.predictionResults.isEmpty {
                    Text("No results. Go back and select symptoms.")
                        .foregroundColor(.secondary)
                        .padding(40)
                } else {
                    ForEach(Array(viewModel.predictionResults.enumerated()), id: \.element.id) { index, result in
                        ResultCard(result: result, rank: index + 1)
                            .padding(.horizontal)
                    }
                }

                Button {
                    viewModel.resetInput()
                    dismiss()
                } label: {
                    Text("Start New Assessment")
                        .font(.headline)
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(14)
                }
                .padding(.horizontal)

                Spacer(minLength: 30)
            }
            .padding(.top)
        }
        .navigationTitle("Your Results")
        .navigationBarTitleDisplayMode(.large)
    }
}

struct ResultCard: View {
    let result: ConditionResult
    let rank: Int

    @State private var expanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button {
                withAnimation {
                    expanded.toggle()
                }
            } label: {
                HStack(spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(result.urgency.color.opacity(0.15))
                            .frame(width: 46, height: 46)
                        Image(systemName: result.urgency.icon)
                            .foregroundColor(result.urgency.color)
                            .font(.title3)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        if rank == 1 {
                            Text("Most Likely")
                                .font(.caption.bold())
                                .foregroundColor(result.urgency.color)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(result.urgency.color.opacity(0.12))
                                .cornerRadius(6)
                        }

                        Text(result.conditionName)
                            .font(.headline)
                    }

                    Spacer()

                    // FR-8: Confidence score
                    VStack(alignment: .trailing, spacing: 3) {
                        Text("\(Int(result.confidence * 100))%")
                            .font(.title3.bold())
                            .foregroundColor(result.urgency.color)
                        Text("confidence")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }

                    Image(systemName: expanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.secondary)
                        .font(.caption)
                }
                .padding(16)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color(.systemGray5))
                        .frame(height: 4)

                    Rectangle()
                        .fill(result.urgency.color)
                        .frame(width: geo.size.width * CGFloat(result.confidence), height: 4)
                }
            }
            .frame(height: 4)
            .padding(.horizontal, 16)

            // FR-9, FR-10: Urgency + actionable steps
            if expanded {
                VStack(alignment: .leading, spacing: 12) {
                    Divider()
                        .padding(.horizontal, 16)

                    HStack(spacing: 8) {
                        Image(systemName: result.urgency.icon)
                            .foregroundColor(result.urgency.color)
                        Text(result.urgency.rawValue)
                            .font(.subheadline.bold())
                            .foregroundColor(result.urgency.color)
                    }
                    .padding(.horizontal, 16)

                    Text("Recommended Actions")
                        .font(.subheadline.bold())
                        .padding(.horizontal, 16)

                    ForEach(result.recommendations, id: \.self) { step in
                        HStack(alignment: .top, spacing: 10) {
                            Image(systemName: "arrow.right.circle.fill")
                                .foregroundColor(result.urgency.color)
                                .font(.subheadline)
                            Text(step)
                                .font(.subheadline)
                        }
                        .padding(.horizontal, 16)
                    }
                }
                .padding(.bottom, 16)
            }
        }
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.07), radius: 8, x: 0, y: 2)
    }
}

