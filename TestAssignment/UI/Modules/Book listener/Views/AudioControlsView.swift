//
//  AudioControlsView.swift
//  TestAssignment
//
//  Created by Artem Mihelson on 28.04.2025.
//

import SwiftUI
import ComposableArchitecture

struct AudioControlsView: View {
    let viewStore: ViewStore<BookListenerFeature.State, BookListenerFeature.Action>
    
    var body: some View {
        HStack(spacing: Constants.UI.Sizes.iconSize) {
            previousButton
            skipBackButton
            playPauseButton
            skipForwardButton
            nextButton
        }
        .padding(Constants.UI.defaultPadding * 2)
    }
    
    private var previousButton: some View {
        controlButton(systemName: "backward.end.fill",
                      action: { viewStore.send(.previousChapter) },
                      disabled: viewStore.selectedChapterIndex <= 0)
        .accessibilityLabel(Constants.Accessibility.prevChapterButtonLabel)
    }
    
    private var nextButton: some View {
        controlButton(systemName: "forward.end.fill",
                      action: { viewStore.send(.nextChapter) },
                      disabled: viewStore.selectedChapterIndex >= viewStore.book.chapters.count - 1)
        .accessibilityLabel(Constants.Accessibility.nextChapterButtonLabel)
    }
    
    private var skipBackButton: some View {
        controlButton(systemName: "gobackward.5",
                      action: { viewStore.send(.skipBackwardTapped) },
                      disabled: !viewStore.isPlaying)
        .accessibilityLabel(Constants.Accessibility.skipBackwardButtonLabel)
    }
    
    private var skipForwardButton: some View {
        controlButton(systemName: "goforward.10",
                      action: { viewStore.send(.skipForwardTapped) },
                      disabled: !viewStore.isPlaying)
        .accessibilityLabel(Constants.Accessibility.skipForwardButtonLabel)
    }
    
    private var playPauseButton: some View {
        Group {
            if viewStore.isLoading {
                ProgressView().padding()
            } else {
                Button {
                    if viewStore.isPlaying {
                        viewStore.send(viewStore.isPaused ? .resumeTapped : .pauseTapped)
                    } else {
                        viewStore.send(.playTapped)
                    }
                } label: {
                    Image(systemName: viewStore.isPlaying
                          ? (viewStore.isPaused ? "play.fill" : "pause.fill")
                          : "play.fill")
                        .resizable()
                        .frame(width: Constants.UI.Sizes.iconSize,
                               height: Constants.UI.Sizes.iconSize)
                        .foregroundColor(.primary)
                }
                .accessibilityLabel(Constants.Accessibility.playButtonLabel)
            }
        }
    }
    
    private func controlButton(systemName: String, action: @escaping () -> Void, disabled: Bool) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: Constants.UI.Sizes.iconSize,
                       height: Constants.UI.Sizes.iconSize)
                .foregroundColor(disabled ? .gray : .primary)
        }
        .disabled(disabled)
    }
}
