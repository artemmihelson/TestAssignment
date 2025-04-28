//
//  Book.swift
//  TestAssignment
//
//  Created by Artem Mihelson on 26.04.2025.
//

import Foundation

struct Book: Identifiable, Equatable {
    let id = UUID()
    let title: String
    let author: String
    let coverImageUrl: String
    let chapters: [Chapter]
}

extension Book {
    static let testBook = Book(
        title: "Test Book",
        author: "Test Author",
        coverImageUrl: "https://example.com/test-book-cover.jpg",
        chapters: Chapter.testChapters
    )
}
