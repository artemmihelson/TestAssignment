//
//  BookListFeature.swift
//  TestAssignment
//
//  Created by Artem Mihelson on 26.04.2025.
//


import ComposableArchitecture
import Foundation
import CasePaths

// MARK: - Book List Feature
struct BookListFeature: Reducer {
    struct State: Equatable {
        var books: [Book] = []
        var selectedBookID: UUID?
        var bookListener: BookListenerFeature.State?
    }
    
    @CasePathable
    enum Action: Equatable {
        case loadBooks
        case booksLoaded([Book])
        case bookSelected(UUID)
        case bookListener(BookListenerFeature.Action)
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
                case .loadBooks:
                    return .run { send in
                        let books = BookRepository().books
                        await send(.booksLoaded(books))
                    }
                    
                case let .booksLoaded(books):
                    state.books = books
                    return .none
                    
                case let .bookSelected(id):
                    state.selectedBookID = id
                    if let book = state.books.first(where: { $0.id == id }) {
                        state.bookListener = BookListenerFeature.State(book: book)
                    }
                    return .none
                    
                case .bookListener:
                    return .none
            }
        }
        .ifLet(\.bookListener, action: \.bookListener) {
            BookListenerFeature()
        }
    }
}
