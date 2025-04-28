//
//  BookListView.swift
//  TestAssignment
//
//  Created by Artem Mihelson on 26.04.2025.
//
import SwiftUI
import ComposableArchitecture

struct BookListView: View {
    let store: StoreOf<BookListFeature>
    @EnvironmentObject var bookRepository: BookRepository
    
    var body: some View {
        WithViewStore(store, observe: { $0} ) { viewStore in
            NavigationView {
                List {
                    ForEach(viewStore.books) { book in
                        Button {
                            viewStore.send(.bookSelected(book.id))
                        } label: {
                            BookListItemView(book: book)
                        }
                        .tint(.primary)
                    }
                }
                .navigationTitle(Constants.Navigation.bookListTitle)
            }
            .onAppear {
                store.send(.loadBooks)
            }
            .fullScreenCover(isPresented: Binding(
                get: { viewStore.bookListener != nil },
                set: { if !$0 { viewStore.send(.bookSelected(UUID())) } }
            )) {
                IfLetStore(
                    self.store.scope(
                        state: \.bookListener,
                        action: \.bookListener
                    )
                ) { store in
                    BookListenerView(store: store)
                }
            }
        }
    }
}

#Preview {
    return BookListView(
        store: Store(initialState: BookListFeature.State(), reducer: {
            BookListFeature()
        })
    )
}
