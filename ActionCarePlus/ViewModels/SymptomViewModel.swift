import SwiftUI
import CoreML
import CoreData
import Combine

class SymptomViewModel: ObservableObject {
    @Published var selectedSymptoms: Set<String> = []
    @Published var textInput: String = ""
    @Published var predictionResults: [ConditionResult] = []
    @Published var historyEntries: [SymptomEntry] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    private let context = PersistenceController.shared.context

    // FR-2: Multi-select toggle
    func toggle(symptom: String) {
        if selectedSymptoms.contains(symptom) {
            selectedSymptoms.remove(symptom)
        } else {
            selectedSymptoms.insert(symptom)
        }
    }

    func isSelected(_ symptom: String) -> Bool {
        selectedSymptoms.contains(symptom)
    }

    var hasInput: Bool {
        !selectedSymptoms.isEmpty ||
        !textInput.trimmingCharacters(in: .whitespaces).isEmpty
    }

    // FR-6: Trigger Core ML prediction
    func runPrediction() {
        guard hasInput else {
            errorMessage = "Please select at least one symptom."
            return
        }

        isLoading = true
        errorMessage = nil

        let allSelected = selectedSymptoms.union(parseTextSymptoms(textInput))
        let vector = buildFeatureVector(from: allSelected)

        DispatchQueue.global(qos: .userInitiated).async {
            let results = self.predictConditions(featureVector: vector)
            DispatchQueue.main.async {
                self.predictionResults = results
                self.isLoading = false
                if let top = results.first {
                    self.saveToHistory(symptoms: allSelected, topResult: top)
                }
            }
        }
    }

    // FR-6, FR-7, FR-8: Run model, return top 3 with confidence
    private func predictConditions(featureVector v: [String: Double]) -> [ConditionResult] {
        guard let model = try? SymptomClassifier(configuration: MLModelConfiguration()) else {
            return []
        }

        guard let prediction = try? model.prediction(input: SymptomClassifierInput(
            fever: v["fever"] ?? 0,
            cough: v["cough"] ?? 0,
            sore_throat: v["sore_throat"] ?? 0,
            runny_nose: v["runny_nose"] ?? 0,
            headache: v["headache"] ?? 0,
            fatigue: v["fatigue"] ?? 0,
            nausea: v["nausea"] ?? 0,
            vomiting: v["vomiting"] ?? 0,
            diarrhea: v["diarrhea"] ?? 0,
            chest_pain: v["chest_pain"] ?? 0,
            shortness_of_breath: v["shortness_of_breath"] ?? 0,
            rash: v["rash"] ?? 0,
            muscle_aches: v["muscle_aches"] ?? 0,
            chills: v["chills"] ?? 0,
            loss_of_appetite: v["loss_of_appetite"] ?? 0,
            dizziness: v["dizziness"] ?? 0,
            ear_pain: v["ear_pain"] ?? 0,
            eye_redness: v["eye_redness"] ?? 0,
            abdominal_pain: v["abdominal_pain"] ?? 0,
            joint_pain: v["joint_pain"] ?? 0,
            back_pain: v["back_pain"] ?? 0,
            sweating: v["sweating"] ?? 0,
            congestion: v["congestion"] ?? 0,
            sneezing: v["sneezing"] ?? 0,
            difficulty_swallowing: v["difficulty_swallowing"] ?? 0
        )) else {
            return []
        }

        return prediction.conditionProbability
            .sorted { $0.value > $1.value }
            .prefix(3)
            .map { condition, confidence in
                let (urgency, steps) = RecommendationsDB.get(for: condition)
                return ConditionResult(
                    conditionName: condition,
                    confidence: confidence,
                    urgency: urgency,
                    recommendations: steps
                )
            }
    }

    // FR-3: Build feature vector from selected symptoms
    private func buildFeatureVector(from symptoms: Set<String>) -> [String: Double] {
        var v = Dictionary(uniqueKeysWithValues: SymptomData.symptomKeys.map { ($0, 0.0) })
        for (i, name) in SymptomData.symptoms.enumerated() {
            if symptoms.contains(name) {
                v[SymptomData.symptomKeys[i]] = 1.0
            }
        }
        return v
    }

    // FR-5: Preprocess text input
    private func parseTextSymptoms(_ text: String) -> Set<String> {
        guard !text.isEmpty else { return [] }

        let lower = text.lowercased()
        let map: [String: String] = [
            "fever": "Fever",
            "cough": "Cough",
            "throat": "Sore Throat",
            "runny": "Runny Nose",
            "headache": "Headache",
            "tired": "Fatigue",
            "fatigue": "Fatigue",
            "nausea": "Nausea",
            "vomit": "Vomiting",
            "diarrhea": "Diarrhea",
            "chest": "Chest Pain",
            "breath": "Shortness of Breath",
            "rash": "Rash",
            "muscle": "Muscle Aches",
            "chill": "Chills",
            "dizzy": "Dizziness",
            "ear": "Ear Pain",
            "eye": "Eye Redness",
            "stomach": "Abdominal Pain",
            "joint": "Joint Pain",
            "back": "Back Pain",
            "sweat": "Sweating",
            "congest": "Congestion",
            "sneez": "Sneezing",
            "swallow": "Difficulty Swallowing"
        ]

        return Set(map.compactMap { lower.contains($0.key) ? $0.value : nil })
    }

    // FR-11: Save entry to Core Data
    func saveToHistory(symptoms: Set<String>, topResult: ConditionResult) {
        let entry = SymptomEntry(context: context)
        entry.id = UUID()
        entry.date = Date()
        entry.selectedSymptoms = symptoms.sorted().joined(separator: ", ")
        entry.topCondition = topResult.conditionName
        entry.urgencyLevel = topResult.urgency.rawValue
        entry.notes = ""

        PersistenceController.shared.save()
        loadHistory()
    }

    // FR-12: Load history sorted newest first
    func loadHistory() {
        let req: NSFetchRequest<SymptomEntry> = SymptomEntry.fetchRequest()
        req.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        historyEntries = (try? context.fetch(req)) ?? []
    }

    // FR-18: Clear all stored history
    func clearAllHistory() {
        let req: NSFetchRequest<NSFetchRequestResult> = SymptomEntry.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: req)
        _ = try? context.execute(deleteRequest)
        PersistenceController.shared.save()
        historyEntries = []
    }

    func resetInput() {
        selectedSymptoms = []
        textInput = ""
        predictionResults = []
        errorMessage = nil
    }

    // FR-13: Symptom frequency for trend chart
    var symptomFrequency: [(symptom: String, count: Int)] {
        var counts: [String: Int] = [:]

        for entry in historyEntries {
            for symptom in (entry.selectedSymptoms?.components(separatedBy: ", ") ?? []) {
                counts[symptom, default: 0] += 1
            }
        }

        return counts
            .sorted { $0.value > $1.value }
            .prefix(8)
            .map { ($0.key, $0.value) }
    }
}

