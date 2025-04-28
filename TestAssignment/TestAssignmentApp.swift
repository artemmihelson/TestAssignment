//
//  TestAssignmentApp.swift
//  TestAssignment
//
//  Created by Artem Mihelson on 26.04.2025.
//

import SwiftUI
import ComposableArchitecture

@main
struct TestAssignmentApp: App {

    var body: some Scene {
        WindowGroup {
            BookListView(
                store: Store(
                    initialState: BookListFeature.State(),
                    reducer: { BookListFeature() }
                )
            )
        }
    }
}
