//
//  BookListItemView.swift
//  TestAssignment
//
//  Created by Artem Mihelson on 26.04.2025.
//

import SwiftUI

struct BookListItemView: View {
    let book: Book
    var body: some View {
        HStack {
            AsyncImage(url: URL.init(string: book.coverImageUrl)) { image in
                image
                .resizable()
                .scaledToFit()
                .frame(width: Constants.UI.Sizes.thumbnailSize)
                
            } placeholder: {
                ProgressView()
                    .frame(width: Constants.UI.Sizes.thumbnailSize)
            }
            VStack(alignment: .leading) {
                Text(book.title)
                    .font(.headline)
                Text(book.author)
                    .font(.subheadline)
            }
        }
    }
}

#Preview {
    BookListItemView(
        book: Book(
            title: "Harry Potter and the Philosopher’s Stone",
            author: "J. K. Rowling",
            coverImageUrl: "https://media.harrypotterfanzone.com/sorcerers-stone-us-childrens-edition-2013-1050x0-c-default.jpg",
            chapters: []
        )
    )
}
