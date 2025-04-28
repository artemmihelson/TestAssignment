//
//  BookListenerView.swift
//  TestAssignment
//
//  Created by Artem Mihelson on 26.04.2025.
//

import SwiftUI
import ComposableArchitecture



struct BookListenerView: View {
    let store: StoreOf<BookListenerFeature>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            ZStack {
                VStack(spacing: Constants.UI.defaultPadding) {
                    content(viewStore)
                    Spacer()
                    listenerModeToggle(viewStore)
                }
                .background(Color(.systemBackground))
            }
            .onAppear { viewStore.send(.onAppeared) }
            .speechRateSheet(viewStore)
            .chapterListSheet(viewStore)
        }
    }
    
    @ViewBuilder
    private func content(_ viewStore: ViewStore<BookListenerFeature.State, BookListenerFeature.Action>) -> some View {
        switch viewStore.listenerMode {
        case .listening:
            listeningModeContent(viewStore)
        case .reading:
            readingModeContent(viewStore)
        }
    }
    
    private func listeningModeContent(_ viewStore: ViewStore<BookListenerFeature.State, BookListenerFeature.Action>) -> some View {
        VStack(spacing: Constants.UI.defaultPadding) {
            BookCoverImage(imageData: viewStore.bookCoverImage)
            chapterOverview(viewStore)
            audioSlider(viewStore)
            AudioControlsView(viewStore: viewStore)
        }
        .padding()
    }
    
    private func readingModeContent(_ viewStore: ViewStore<BookListenerFeature.State, BookListenerFeature.Action>) -> some View {
        VStack(alignment: .leading, spacing: Constants.UI.defaultPadding) {
            HStack {
                Text(viewStore.book.title).font(.title).bold()
                    .accessibilityLabel(Constants.Accessibility.bookTitleLabel)
                Spacer()
                Button { viewStore.send(.showChapterList(true)) } label: {
                    Image(systemName: "list.bullet").tint(.primary)
                }
                .accessibilityLabel(Constants.Accessibility.chapterPickerLabel)
            }
            Text(viewStore.book.chapters[viewStore.selectedChapterIndex].title).font(.title2)
                .accessibilityLabel(Constants.Accessibility.chapterTitleLabel)
            ScrollView {
                Text(viewStore.book.chapters[viewStore.selectedChapterIndex].summary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.callout)
                    .accessibilityLabel(Constants.Accessibility.chapterSummaryLabel)
            }
        }
        .padding()
    }
    
    private func chapterOverview(_ viewStore: ViewStore<BookListenerFeature.State, BookListenerFeature.Action>) -> some View {
        let chapterIndex = viewStore.selectedChapterIndex + 1
        let totalChapters = viewStore.book.chapters.count
        let chapterTitle = viewStore.book.chapters[viewStore.selectedChapterIndex].title
        
        return VStack(spacing: Constants.UI.defaultPadding) {
            Text(String(format: String(localized: "Chapter %d of %d"), chapterIndex, totalChapters))
                .textCase(.uppercase)
                .foregroundStyle(.secondary)
                .font(.subheadline)
                .accessibilityLabel(Constants.Accessibility.chapterIndexLabel)
            Text(chapterTitle).font(.subheadline)
                .accessibilityLabel(Constants.Accessibility.chapterTitleLabel)
        }
    }
    
    private func audioSlider(_ viewStore: ViewStore<BookListenerFeature.State, BookListenerFeature.Action>) -> some View {
        VStack(spacing: Constants.UI.defaultPadding) {
            Slider(value: viewStore.binding(get: \.currentPosition, send: BookListenerFeature.Action.seekToPosition),
                   in: 0...max(viewStore.totalDuration, 0.1)) {
                Text("")
            } minimumValueLabel: {
                Text(formatTime(viewStore.currentPosition)).font(.caption).foregroundStyle(.secondary)
            } maximumValueLabel: {
                Text(formatTime(viewStore.totalDuration)).font(.caption).foregroundStyle(.secondary)
            }
            .padding(.horizontal)
            .accessibilityLabel(Constants.Accessibility.currentPositionSliderLabel)
            
            Button { viewStore.send(.showSpeechRateSheet(true)) } label: {
                Text(String(format: NSLocalizedString("Speed: %.1fx", comment: ""), viewStore.speechRate))
                    .font(.caption).fontWeight(.bold)
                    .padding(8)
                    .background(.secondary.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 4))
            }
            .accessibilityLabel(Constants.Accessibility.chapterPickerLabel)
        }
    }
    
    private func listenerModeToggle(_ viewStore: ViewStore<BookListenerFeature.State, BookListenerFeature.Action>) -> some View {
        Toggle("", isOn: Binding(
            get: { viewStore.listenerMode == .reading },
            set: { viewStore.send(.switchListenerMode($0 ? .reading : .listening)) }
        ))
        .toggleStyle(ListenerToggleStyle())
    }
    
    private func formatTime(_ seconds: Double) -> String {
        let minutes = Int(seconds) / 60
        let seconds = Int(seconds) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

// MARK: - Sheets
private extension View {
    func speechRateSheet(_ viewStore: ViewStore<BookListenerFeature.State, BookListenerFeature.Action>) -> some View {
        sheet(isPresented: viewStore.binding(get: \.isSpeechRateSheetPresented, send: BookListenerFeature.Action.showSpeechRateSheet)) {
            SpeechRateView(rate: viewStore.binding(get: \.speechRate, send: BookListenerFeature.Action.changeSpeechRate))
                .presentationDetents([.height(240)])
        }
    }
    
    func chapterListSheet(_ viewStore: ViewStore<BookListenerFeature.State, BookListenerFeature.Action>) -> some View {
        sheet(isPresented: viewStore.binding(get: \.isChapterListPresented, send: BookListenerFeature.Action.showChapterList)) {
            List {
                ForEach(Array(viewStore.book.chapters.enumerated()), id: \.element.id) { index, chapter in
                    Button { viewStore.send(.selectChapter(index)) } label: {
                        Text(chapter.title).tint(.primary)
                    }
                }
            }
            .presentationDetents([.medium, .large])
        }
    }
}

struct BookCoverImage: View {
    let imageData: Data?
    
    var body: some View {
        if let imageData = imageData, let uiImage = UIImage(data: imageData) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFit()
                .clipShape(RoundedRectangle.init(cornerRadius: Constants.UI.cornerRadius))
                .frame(width: Constants.UI.Sizes.thumbnailDetailsHeight)
                .padding()
                .accessibilityLabel(Constants.Accessibility.bookCoverImageLabel)
        } else {
            ProgressView()
                .frame(width: Constants.UI.Sizes.thumbnailDetailsHeight)
        }
    }
}

#Preview {
    NavigationView {
        BookListenerView(
            store: Store(
                initialState: BookListenerFeature.State(
                    book: Book(
                        title: "The Great Gatsby",
                        author: "F. Scott Fitzgerald",
                        coverImageUrl: "https://media.harrypotterfanzone.com/sorcerers-stone-us-childrens-edition-2013-1050x0-c-default.jpg",
                        chapters: [
                            Chapter(
                                title: "Chapter 1",
                                summary: "Nick Carraway moves to West Egg, Long Island, and meets his mysterious neighbor Jay Gatsby.",
                                audioFileName: "book1chapter1.m4a"
                            ),
                            Chapter(
                                title: "Chapter 2",
                                summary: "Tom takes Nick to meet his mistress Myrtle Wilson in the Valley of Ashes.",
                                audioFileName: "book1chapter2.m4a"
                            )
                        ]
                    )
                ),
                reducer: { BookListenerFeature() }
            )
        )
    }
}
