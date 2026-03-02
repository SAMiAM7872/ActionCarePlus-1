import SwiftUI

struct TrendChartView: View {
    @EnvironmentObject var viewModel: SymptomViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                if viewModel.symptomFrequency.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "chart.bar.xaxis")
                            .font(.system(size: 60))
                            .foregroundColor(.secondary)
                        Text("No Data Yet")
                            .font(.title3.bold())
                        Text("Complete check-ins to see your symptom trends.")
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 80)
                } else {
                    Text("Most Frequent Symptoms")
                        .font(.headline)
                        .padding(.horizontal)

                    let maxCount = viewModel.symptomFrequency.first?.count ?? 1

                    VStack(spacing: 14) {
                        ForEach(viewModel.symptomFrequency, id: \.symptom) { item in
                            HStack(spacing: 12) {
                                Text(item.symptom)
                                    .font(.subheadline)
                                    .frame(width: 130, alignment: .trailing)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.7)

                                GeometryReader { geo in
                                    ZStack(alignment: .leading) {
                                        RoundedRectangle(cornerRadius: 6)
                                            .fill(Color(.systemGray5))
                                            .frame(height: 28)

                                        RoundedRectangle(cornerRadius: 6)
                                            .fill(
                                                LinearGradient(
                                                    colors: [.blue, .cyan],
                                                    startPoint: .leading,
                                                    endPoint: .trailing
                                                )
                                            )
                                            .frame(
                                                width: max(
                                                    30,
                                                    geo.size.width * CGFloat(item.count) / CGFloat(maxCount)
                                                ),
                                                height: 28
                                            )
                                    }
                                }
                                .frame(height: 28)

                                Text("\(item.count)x")
                                    .font(.subheadline.bold())
                                    .foregroundColor(.blue)
                                    .frame(width: 36)
                            }
                        }
                    }
                    .padding(.horizontal)
                }

                Spacer(minLength: 30)
            }
            .padding(.top)
        }
        .navigationTitle("Symptom Trends")
        .onAppear {
            viewModel.loadHistory()
        }
    }
}

