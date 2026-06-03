//
//  ArrowDateSelectorApp.swift
//  ArrowDateSelector
//
//  Created by Vikas Raj Yadav on 02/07/25.
//

import SwiftUI

@main
struct ArrowDateSelectorApp: App {
    @State private var showsDateSelector = false

    var body: some Scene {
        WindowGroup {
            if showsDateSelector {
                ArrowDateSelectorView()
                    .overlay(alignment: .topTrailing) {
                        Button("Tutorial") {
                            showsDateSelector = false
                        }
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(.white.opacity(0.9))
                        .padding()
                    }
            } else {
                ArrowButtonTutorial {
                    showsDateSelector = true
                }
            }
        }
    }
}
