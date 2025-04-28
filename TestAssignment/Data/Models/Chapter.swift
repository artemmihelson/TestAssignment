//
//  Chapter.swift
//  TestAssignment
//
//  Created by Artem Mihelson on 26.04.2025.
//

import Foundation

struct Chapter: Equatable, Identifiable {
    let id = UUID()
    let title: String
    let summary: String
    let audioFileName: String
}

extension Chapter {
    static let testChapters = [
        Chapter(title: "Chapter 1", summary: "Test summary 1", audioFileName: "chapter1.m4a"),
        Chapter(title: "Chapter 2", summary: "Test summary 2", audioFileName: "chapter2.m4a"),
        Chapter(title: "Chapter 3", summary: "Test summary 3", audioFileName: "chapter3.m4a")
    ]
}
