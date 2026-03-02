import SwiftUI

struct SymptomInputView: View {
    @EnvironmentObject var viewModel: SymptomViewModel
    @State private var navigateToResults = false

    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    if !viewModel.selectedSymptoms.isEmpty {
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.blue)
                            Text("\(viewModel.selectedSymptoms.count) symptom(s) selected")
                                .font(.subheadline.bold())
                                .foregroundColor(.blue)
                        }
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.blue.opacity(0.08))
                        .cornerRadius(10)
                        .padding(.horizontal)
                    }

                    // FR-1: 25-symptom checklist
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Select Your Symptoms")
                            .font(.headline)
                            .padding(.horizontal)

                        LazyVGrid(columns: columns, spacing: 10) {
                            ForEach(SymptomData.symptoms, id: \.self) { symptom in
                                SymptomChip(
                                    symptom: symptom,
                                    isSelected: viewModel.isSelected(symptom)
                                ) {
                                    viewModel.toggle(symptom: symptom)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }

                    // FR-4: Text input field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Or describe your symptoms")
                            .font(.headline)
                            .padding(.horizontal)

                        Text("e.g. \"I have a sore throat and feel tired\"")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)

                        TextEditor(text: $viewModel.textInput)
                            .frame(height: 85)
                            .padding(8)
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                            .padding(.horizontal)
                    }

                    if let error = viewModel.errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.subheadline)
                            .padding(.horizontal)
                    }

                    Button {
                        viewModel.runPrediction()
                        if viewModel.hasInput {
                            navigateToResults = true
                        }
                    } label: {
                        HStack {
                            if viewModel.isLoading {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Image(systemName: "brain")
                                Text("Analyze Symptoms")
                                    .font(.headline)
                            }
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(viewModel.hasInput ? Color.blue : Color.gray)
                        .cornerRadius(14)
                    }
                    .disabled(!viewModel.hasInput || viewModel.isLoading)
                    .padding(.horizontal)

                    NavigationLink(
                        destination: ResultsView().environmentObject(viewModel),
                        isActive: $navigateToResults
                    ) {
                        EmptyView()
                    }

                    Spacer(minLength: 30)
                }
                .padding(.top)
            }
            .navigationTitle("Check-In")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Clear") {
                        viewModel.resetInput()
                    }
                }
            }
        }
    }
}

struct SymptomChip: View {
    let symptom: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? .white : .secondary)
                Text(symptom)
                    .font(.subheadline)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 9)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(isSelected ? Color.blue : Color(.systemGray6))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(10)
        }
    }
}

