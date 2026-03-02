//
//  ActionCarePlusApp.swift
//  ActionCarePlus
//
//  Created by CAIT on 3/1/26.
//

import SwiftUI

@main
struct ActionCarePlusApp: App {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @StateObject private var viewModel = SymptomViewModel()

    var body: some Scene {
        WindowGroup {
            if hasSeenOnboarding {
                ContentView()
                    .environmentObject(viewModel)
                    .environment(\.managedObjectContext, PersistenceController.shared.context)
                    .onAppear {
                        viewModel.loadHistory()
                    }
            } else {
                OnboardingView(hasSeenOnboarding: $hasSeenOnboarding)
            }
        }
    }
}
