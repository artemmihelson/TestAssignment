//
//  BookListenerFeature.swift
//  TestAssignment
//
//  Created by Artem Mihelson on 26.04.2025.
//


import ComposableArchitecture
import AVFoundation
import Foundation
import CasePaths

enum CancelID {
    case audioTimer
}
// MARK: - Book Listener Feature
struct BookListenerFeature: Reducer {
    
    // MARK: - Private -
    private let refreshIntervalMilliseconds = 100
    
    struct State: Equatable {
        let book: Book
        var bookCoverImage: Data?
        var selectedChapterIndex: Int = 0
        var isLoading: Bool = false
        var isPlaying: Bool = false
        var isPaused: Bool = false
        var speechRate: Float = Constants.Audio.normalRate
        var currentPosition: Double = 0
        var totalDuration: Double = 0
        var isSpeechRateSheetPresented: Bool = false
        var listenerMode: ListenerMode = .listening
        var isChapterListPresented: Bool = false
    }
    
    enum Action: Equatable {
        case onAppeared
        case selectChapter(Int)
        case previousChapter
        case nextChapter
        case loadAudio
        case audioLoaded
        case playTapped
        case pauseTapped
        case resumeTapped
        case skipForwardTapped
        case skipBackwardTapped
        case timelineUpdated(position: Double, duration: Double)
        case seekToPosition(Double)
        case changeSpeechRate(Float)
        case showSpeechRateSheet(Bool)
        case switchListenerMode(ListenerMode)
        case showChapterList(Bool)
        case loadImage
        case imageLoaded(Data)
    }
    
    @Dependency(\.audioPlayer) var audioPlayer
    @Dependency(\.continuousClock) var clock
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppeared:
                return .concatenate(
                    .send(.loadAudio),
                    .send(.loadImage)
                )
            case .previousChapter, .nextChapter:
                // Determine which chapter to select
                let newIndex = action == .previousChapter ?
                max(0, state.selectedChapterIndex - 1) :
                min(state.book.chapters.count - 1, state.selectedChapterIndex + 1)
                
                // Only proceed if we're actually changing chapters
                if newIndex != state.selectedChapterIndex {
                    // Stop current playback and reset state
                    state.isPlaying = false
                    state.isPaused = false
                    state.currentPosition = 0
                    state.totalDuration = 0
                    state.selectedChapterIndex = newIndex
                    
                    return .run { send in
                        await audioPlayer.stop()
                        await send(.loadAudio)
                    }
                }
                return .none
            case let .selectChapter(index):
                state.selectedChapterIndex = index
                state.isPlaying = false
                state.isPaused = false
                state.currentPosition = 0
                state.totalDuration = 0
                
                // Then load the new audio
                return .run { send in
                    await audioPlayer.stop()
                    await send(.loadAudio)
                }
                
            case .loadAudio:
                state.isLoading = true
                let chapter = state.book.chapters[state.selectedChapterIndex]
                
                return .concatenate(
                    .cancel(id: CancelID.audioTimer),
                    .run { send in
                        var duration = 0.0
                        await audioPlayer.loadAudio(fileName: chapter.audioFileName) { initialDuration in
                            duration = initialDuration
                        }
                        
                        await send(.timelineUpdated(position: 0, duration: duration))
                        await send(.audioLoaded)
                        
                        for await _ in self.clock.timer(interval: .milliseconds(refreshIntervalMilliseconds)) {
                            if Task.isCancelled {
                                break
                            }
                            let position = await audioPlayer.getCurrentTime()
                            await send(.timelineUpdated(position: position, duration: duration))
                        }
                    } catch: { _, _ in }
                        .cancellable(id: CancelID.audioTimer) // Mark this task cancellable
                    
                )
                
            case .audioLoaded:
                state.isLoading = false
                return .none
                
            case .playTapped:
                state.isPlaying = true
                state.isPaused = false
                
                let currentDuration = state.totalDuration
                
                return .run { send in
                    await audioPlayer.play()
                    if currentDuration <= 0 {
                        let duration = await audioPlayer.getDuration()
                        if duration > 0 {
                            await send(.timelineUpdated(position: 0, duration: duration))
                        }
                    }
                }
                
            case .pauseTapped:
                state.isPaused = true
                
                return .run { _ in
                    await audioPlayer.pause()
                }
                
            case .resumeTapped:
                state.isPaused = false
                
                return .run { _ in
                    await audioPlayer.play()
                }
                
            case .skipForwardTapped:
                return .run { _ in
                    await audioPlayer.skipForward(seconds: 10)
                }
                
            case .skipBackwardTapped:
                return .run { _ in
                    await audioPlayer.skipBackward(seconds: 5)
                }
                
            case let .timelineUpdated(position, duration):
                // Only update if values are reasonable
                if position >= 0 && !position.isNaN {
                    state.currentPosition = position
                }
                
                if duration > 0 && !duration.isNaN {
                    state.totalDuration = duration
                }
                
                // Check if we've reached the end of the track
                if position > 0 && duration > 0 && position >= duration - 0.5 {
                    // Auto-advance to next chapter or stop playback
                    if state.selectedChapterIndex < state.book.chapters.count - 1 {
                        return .send(.nextChapter)
                    } else {
                        state.isPlaying = false
                        state.isPaused = false
                        state.currentPosition = 0
                        return .run { _ in await audioPlayer.stop() }
                    }
                }
                return .none
                
            case let .seekToPosition(position):
                state.currentPosition = position
                
                return .run { _ in
                    await audioPlayer.seekTo(time: position)
                }
                
            case let .changeSpeechRate(rate):
                state.speechRate = rate
                if !state.isPlaying {
                    state.isPlaying = true
                }
                if state.isPaused {
                    state.isPaused = false
                }
                return .run { _ in
                    await audioPlayer.setPlaybackRate(rate)
                }
                
            case let .showSpeechRateSheet(isPresented):
                state.isSpeechRateSheetPresented = isPresented
                return .none
            case let .switchListenerMode(mode):
                state.listenerMode = mode
                return .none
            case let .showChapterList(isPresented):
                state.isChapterListPresented = isPresented
                return .none
            case .loadImage:
                guard let _ = state.bookCoverImage else {
                    guard let url = URL.init(string: state.book.coverImageUrl) else { return .none }
                    return .run { send in
                        let (data, _) = try await URLSession.shared.data(from: url)
                        await send(.imageLoaded(data))
                    }
                }
                return .none
            case let .imageLoaded(data):
                state.bookCoverImage = data
                return .none
            }
        }
    }
}
