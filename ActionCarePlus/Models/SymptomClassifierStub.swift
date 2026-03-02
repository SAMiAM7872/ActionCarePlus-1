// MARK: - Stub for SymptomClassifier (remove when adding SymptomClassifier.mlmodel)
// This file provides the same interface as Xcode's auto-generated Core ML code.
// Delete this file once you add SymptomClassifier.mlmodel to the project.

import CoreML
import Foundation

/// Stub input matching the expected 25-symptom feature vector.
/// Replace with Xcode-generated type when adding SymptomClassifier.mlmodel.
struct SymptomClassifierInput {
    var fever: Double = 0
    var cough: Double = 0
    var sore_throat: Double = 0
    var runny_nose: Double = 0
    var headache: Double = 0
    var fatigue: Double = 0
    var nausea: Double = 0
    var vomiting: Double = 0
    var diarrhea: Double = 0
    var chest_pain: Double = 0
    var shortness_of_breath: Double = 0
    var rash: Double = 0
    var muscle_aches: Double = 0
    var chills: Double = 0
    var loss_of_appetite: Double = 0
    var dizziness: Double = 0
    var ear_pain: Double = 0
    var eye_redness: Double = 0
    var abdominal_pain: Double = 0
    var joint_pain: Double = 0
    var back_pain: Double = 0
    var sweating: Double = 0
    var congestion: Double = 0
    var sneezing: Double = 0
    var difficulty_swallowing: Double = 0
}

/// Stub classifier that returns heuristic predictions based on symptom inputs.
/// Replace with Xcode-generated class when adding SymptomClassifier.mlmodel.
class SymptomClassifier {
    init(configuration: MLModelConfiguration = MLModelConfiguration()) throws {
        // Stub: no-op init
    }

    func prediction(input: SymptomClassifierInput) throws -> SymptomClassifierOutput {
        // Heuristic stub: map symptom patterns to likely conditions
        var probs: [String: Double] = [
            "Common Cold": 0.0,
            "Influenza (Flu)": 0.0,
            "Strep Throat": 0.0,
            "COVID-19": 0.0,
            "Allergies": 0.0,
            "Ear Infection": 0.0,
            "Gastroenteritis (Stomach Flu)": 0.0,
            "Migraine": 0.0,
            "Bronchitis": 0.0,
            "Pneumonia": 0.0
        ]

        let respiratory = input.cough + input.sore_throat + input.runny_nose + input.congestion + input.sneezing
        let feverish = input.fever + input.chills + input.muscle_aches + input.fatigue
        let gi = input.nausea + input.vomiting + input.diarrhea + input.abdominal_pain
        let chest = input.chest_pain + input.shortness_of_breath

        if respiratory > 0 {
            if input.fever > 0.5 && input.muscle_aches > 0.5 {
                probs["Influenza (Flu)"] = min(0.85, 0.4 + respiratory * 0.1)
            }
            if input.sore_throat > 0.5 && input.difficulty_swallowing > 0 {
                probs["Strep Throat"] = min(0.75, 0.35 + input.sore_throat * 0.2)
            }
            if input.sneezing > 0.5 && input.eye_redness > 0 {
                probs["Allergies"] = min(0.65, 0.3 + input.sneezing * 0.15)
            }
            probs["Common Cold"] = min(0.7, 0.25 + respiratory * 0.08)
        }
        if input.ear_pain > 0.5 {
            probs["Ear Infection"] = min(0.8, 0.5 + input.ear_pain * 0.2)
        }
        if gi > 0.5 {
            probs["Gastroenteritis (Stomach Flu)"] = min(0.75, 0.35 + gi * 0.1)
        }
        if input.headache > 0.5 && input.fatigue > 0 {
            probs["Migraine"] = min(0.6, 0.2 + input.headache * 0.2)
        }
        if input.cough > 0.5 && respiratory > 1 {
            probs["Bronchitis"] = min(0.65, 0.2 + input.cough * 0.15)
        }
        if chest > 0.5 || input.shortness_of_breath > 0.5 {
            probs["Pneumonia"] = min(0.7, 0.3 + chest * 0.2)
        }

        // Normalize and filter zeros; fallback to Common Cold if no strong signal
        var result = probs.filter { $0.value > 0 }
        let total = result.values.reduce(0, +)
        if total > 0 {
            result = Dictionary(uniqueKeysWithValues: result.map { ($0.key, $0.value / total) })
        } else {
            result = ["Common Cold": 0.5]
        }
        return SymptomClassifierOutput(conditionProbability: result)
    }
}

/// Output struct matching Core ML generated interface.
struct SymptomClassifierOutput {
    let conditionProbability: [String: Double]
}
