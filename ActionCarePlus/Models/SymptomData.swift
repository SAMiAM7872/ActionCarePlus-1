import SwiftUI

struct SymptomData {
    static let symptoms: [String] = [
        "Fever", "Cough", "Sore Throat", "Runny Nose", "Headache",
        "Fatigue", "Nausea", "Vomiting", "Diarrhea", "Chest Pain",
        "Shortness of Breath", "Rash", "Muscle Aches", "Chills",
        "Loss of Appetite", "Dizziness", "Ear Pain", "Eye Redness",
        "Abdominal Pain", "Joint Pain", "Back Pain", "Sweating",
        "Congestion", "Sneezing", "Difficulty Swallowing"
    ]

    static let symptomKeys: [String] = [
        "fever", "cough", "sore_throat", "runny_nose", "headache",
        "fatigue", "nausea", "vomiting", "diarrhea", "chest_pain",
        "shortness_of_breath", "rash", "muscle_aches", "chills",
        "loss_of_appetite", "dizziness", "ear_pain", "eye_redness",
        "abdominal_pain", "joint_pain", "back_pain", "sweating",
        "congestion", "sneezing", "difficulty_swallowing"
    ]
}

// FR-9: Urgency categories and display properties
enum UrgencyLevel: String {
    case selfCare = "Self-Care"
    case doctorVisit = "Doctor Visit"
    case emergency = "Emergency"

    var color: Color {
        switch self {
        case .selfCare:
            return .green
        case .doctorVisit:
            return .orange
        case .emergency:
            return .red
        }
    }

    var icon: String {
        switch self {
        case .selfCare:
            return "house.fill"
        case .doctorVisit:
            return "stethoscope"
        case .emergency:
            return "exclamationmark.triangle.fill"
        }
    }
}

struct ConditionResult: Identifiable {
    let id = UUID()
    let conditionName: String
    let confidence: Double
    let urgency: UrgencyLevel
    let recommendations: [String]
}

// FR-10: At least 3 actionable steps per condition (we provide 5)
struct RecommendationsDB {
    static func get(for condition: String) -> (urgency: UrgencyLevel, steps: [String]) {
        switch condition {
        case "Common Cold":
            return (.selfCare, [
                "Rest and get plenty of sleep",
                "Stay hydrated with water, herbal tea, or broth",
                "Use OTC decongestants or antihistamines as needed",
                "Gargle warm salt water for sore throat relief",
                "Use a humidifier to ease congestion"
            ])
        case "Influenza (Flu)":
            return (.doctorVisit, [
                "Rest at home and avoid contact with others",
                "Take fever-reducing medication (ibuprofen or acetaminophen)",
                "Drink fluids frequently to prevent dehydration",
                "Contact a doctor - antiviral medication may be prescribed",
                "Seek emergency care if breathing worsens"
            ])
        case "Strep Throat":
            return (.doctorVisit, [
                "See a doctor - strep requires a throat swab to confirm",
                "Antibiotics are typically prescribed - complete the full course",
                "Soothe throat with warm liquids and lozenges",
                "Avoid sharing utensils or drinks with others",
                "Stay home while contagious"
            ])
        case "COVID-19":
            return (.doctorVisit, [
                "Isolate immediately to prevent spreading",
                "Take a COVID-19 test to confirm",
                "Rest and monitor oxygen levels if possible",
                "Stay hydrated and take fever reducers as needed",
                "Seek emergency care if breathing is labored"
            ])
        case "Allergies":
            return (.selfCare, [
                "Take OTC antihistamines (cetirizine or loratadine)",
                "Identify and avoid known allergens",
                "Use saline nasal spray to clear passages",
                "Keep windows closed during high pollen days",
                "Consider seeing an allergist for long-term management"
            ])
        case "Ear Infection":
            return (.doctorVisit, [
                "See a doctor - ear infections often need antibiotics",
                "Apply a warm compress to the ear for pain relief",
                "Take OTC pain relievers like ibuprofen",
                "Do not insert anything into the ear canal",
                "Keep the ear dry during treatment"
            ])
        case "Gastroenteritis (Stomach Flu)":
            return (.selfCare, [
                "Sip water, electrolyte drinks, or clear broth slowly",
                "Follow the BRAT diet: Bananas, Rice, Applesauce, Toast",
                "Rest and avoid solid foods until vomiting stops",
                "Wash hands frequently to prevent spreading",
                "See a doctor if symptoms last more than 3 days"
            ])
        case "Migraine":
            return (.selfCare, [
                "Rest in a quiet, dark room",
                "Apply cold or warm compress to head or neck",
                "Take OTC pain relievers at the first sign of migraine",
                "Stay hydrated and avoid skipping meals",
                "See a neurologist if migraines are frequent or severe"
            ])
        case "Bronchitis":
            return (.doctorVisit, [
                "Rest and drink plenty of warm fluids",
                "Use a humidifier to loosen mucus",
                "Take OTC cough suppressants as directed",
                "Avoid all smoke and secondhand smoke",
                "See a doctor if symptoms last more than 3 weeks"
            ])
        case "Pneumonia":
            return (.emergency, [
                "Seek medical attention immediately",
                "Antibiotics or antivirals require a prescription",
                "Monitor breathing and oxygen levels closely",
                "Do not attempt to self-treat",
                "Rest completely and avoid all physical exertion"
            ])
        default:
            return (.selfCare, [
                "Rest and monitor your symptoms",
                "Stay well hydrated",
                "Consult a healthcare professional if symptoms worsen",
                "Keep a record of when symptoms started",
                "See a doctor for proper evaluation"
            ])
        }
    }
}

