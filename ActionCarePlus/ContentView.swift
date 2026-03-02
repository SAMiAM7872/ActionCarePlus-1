//
//  ContentView.swift
//  ActionCarePlus
//
//  Created by CAIT on 3/1/26.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var viewModel: SymptomViewModel

    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }

            SymptomInputView()
                .tabItem {
                    Label("Check", systemImage: "heart.text.square.fill")
                }

            HistoryView()
                .tabItem {
                    Label("History", systemImage: "clock.fill")
                }

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
        }
        .accentColor(.blue)
    }
}
