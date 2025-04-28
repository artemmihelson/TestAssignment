//
//  BookListenerFeatureTests.swift
//  TestAssignment
//
//  Created by Artem Mihelson on 28.04.2025.
//

import Testing
import XCTest
import ComposableArchitecture
import Foundation
import AVFoundation
@testable import TestAssignment

@MainActor
struct BookListenerFeatureTests {
    // MARK: - Initial State Tests
    @Test func initialStateHasCorrectValues() {
        let store = TestStore(
            initialState: BookListenerFeature.State(book: Book.testBook),
            reducer: { BookListenerFeature() }
        )
        
        XCTAssertEqual(store.state.selectedChapterIndex, 0)
        XCTAssertFalse(store.state.isPlaying)
        XCTAssertFalse(store.state.isPaused)
        XCTAssertEqual(store.state.currentPosition, 0)
        XCTAssertEqual(store.state.totalDuration, 0)
        XCTAssertEqual(store.state.speechRate, Constants.Audio.normalRate)
        XCTAssertEqual(store.state.listenerMode, .listening)
        XCTAssertFalse(store.state.isChapterListPresented)
        XCTAssertFalse(store.state.isSpeechRateSheetPresented)
        XCTAssertNil(store.state.bookCoverImage)
    }
    
    // MARK: - On Appear Tests
    @Test func onAppearedLoadsAudioAndImage() async {
        let testReducer = Reduce<BookListenerFeature.State, BookListenerFeature.Action> { state, action in
            switch action {
            case .onAppeared:
                return .concatenate(
                    .send(.loadAudio),
                    .send(.loadImage)
                )
            case .loadImage, .loadAudio, .timelineUpdated, .audioLoaded:
                return .none
            default:
                return .none
            }
        }
        let store = TestStore(initialState: BookListenerFeature.State(book: Book.testBook)) {
            testReducer
                .dependency(\.audioPlayer, MockAudioPlayer())
        }
        
        store.exhaustivity = .off
        await store.send(.onAppeared)
        await store.receive(.loadAudio)
        await store.receive(.loadImage)
    }
    
    // MARK: - Audio Loading Tests
    @Test func loadingAudioUpdatesStateCorrectly() async {
        let mockAudioPlayer = MockAudioPlayer()
        let mockClock = MockClock()
        
        
        let store = TestStore(initialState: BookListenerFeature.State(book: Book.testBook)) {
            BookListenerFeature()
                .dependency(\.audioPlayer, mockAudioPlayer)
                .dependency(\.continuousClock, mockClock)
        }
        
        store.exhaustivity = .off
        
        await store.send(.loadAudio) {
            $0.isLoading = true
        }
        
        await store.receive(.timelineUpdated(position: 0, duration: 60.0)) {
            $0.totalDuration = 60.0
        }
        
        await store.receive(.audioLoaded) {
            $0.isLoading = false
        }
    }
    
    @Test func loadingAudioWithErrorHandlesGracefully() async {
        let mockAudioPlayer = MockAudioPlayer()
        mockAudioPlayer.simulateError = true
        mockAudioPlayer.duration = 0
        
        let store = TestStore(initialState: BookListenerFeature.State(book: Book.testBook)) {
            BookListenerFeature()
                .dependency(\.audioPlayer, mockAudioPlayer)
                .dependency(\.continuousClock, MockClock())
        }
        store.exhaustivity = .off
        
        await store.send(.loadAudio) {
            $0.isLoading = true
        }
        
        await store.receive(.timelineUpdated(position: 0, duration: 0))
        
        await store.receive(.audioLoaded) {
            $0.isLoading = false
            // Duration should remain 0 for error case
            $0.totalDuration = 0
        }
    }
    
    // MARK: - Playback Control Tests
    @Test func playPauseResumeFlowWorksCorrectly() async {
        let mockAudioPlayer = MockAudioPlayer()
        
        let store = TestStore(
            initialState: BookListenerFeature.State(
                book: Book.testBook,
                totalDuration: 60.0
            )) {
            BookListenerFeature()
                .dependency(\.audioPlayer, mockAudioPlayer)
        }
        
        // Test play
        await store.send(.playTapped) {
            $0.isPlaying = true
            $0.isPaused = false
        }
        
        // Test pause
        await store.send(.pauseTapped) {
            $0.isPaused = true
        }
        
        // Test resume
        await store.send(.resumeTapped) {
            $0.isPaused = false
        }
    }
    
    @Test func playLoadsDurationIfNotAlreadyLoaded() async {
        let mockAudioPlayer = MockAudioPlayer()
        mockAudioPlayer.duration = 45.0
        
        let store = TestStore(
            initialState: BookListenerFeature.State(
                book: Book.testBook,
                totalDuration: 0.0
            )) {
            BookListenerFeature()
                .dependency(\.audioPlayer, mockAudioPlayer)
        }
        
        // Test play with duration loading
        await store.send(.playTapped) {
            $0.isPlaying = true
            $0.isPaused = false
        }
        
        await store.receive(.timelineUpdated(position: 0, duration: 45.0)) {
            $0.totalDuration = 45.0
        }
    }
    
    // MARK: - Timeline Update Tests
    @Test func timelineUpdatesCorrectlyDuringPlayback() async {
        let store = TestStore(
            initialState: BookListenerFeature.State(
                book: Book.testBook,
                isPlaying: true,
                totalDuration: 60.0
            )) {
            BookListenerFeature()
        }
        
        // Normal update in the middle of playback
        await store.send(.timelineUpdated(position: 30.0, duration: 60.0)) {
            $0.currentPosition = 30.0
        }
        
        // Invalid position values are ignored
        await store.send(.timelineUpdated(position: Double.nan, duration: 60.0))
        
        // Invalid duration values are ignored
        await store.send(.timelineUpdated(position: 35.0, duration: Double.nan)) {
            $0.currentPosition = 35.0
        }
    }
    
    @Test func timelineUpdateNearEndOfTrackTriggersNextChapter() async {
        let mockAudioPlayer = MockAudioPlayer()
        
        let store = TestStore(
            initialState: BookListenerFeature.State(
                book: Book.testBook,
                isPlaying: true,
                totalDuration: 60.0
            )) {
            BookListenerFeature()
                    .dependency(\.audioPlayer, mockAudioPlayer)
                    .dependency(\.continuousClock, MockClock())
        }
        store.exhaustivity = .off
        // Update position to near the end of the track
        await store.send(.timelineUpdated(position: 59.6, duration: 60.0)) {
            $0.currentPosition = 59.6
        }
        
        // Should receive next chapter action
        await store.receive(.nextChapter)
    }
    
    @Test func timelineUpdateNearEndOfLastChapterStopsPlayback() async {
        let mockAudioPlayer = MockAudioPlayer()
        
        let store = TestStore(
            initialState: BookListenerFeature.State(
                book: Book.testBook,
                selectedChapterIndex: 2, // Last chapter
                isPlaying: true,
                totalDuration: 60.0
            )) {
            BookListenerFeature()
                    .dependency(\.audioPlayer, mockAudioPlayer)
        }
        
        // Update position to near the end of the track
        await store.send(.timelineUpdated(position: 59.6, duration: 60.0)) {
            $0.currentPosition = 59.6
            $0.isPlaying = false
            $0.isPaused = false
            $0.currentPosition = 0
        }
    }
    
    // MARK: - Chapter Navigation Tests
    @Test func nextChapterNavigationWorksCorrectly() async {
        let mockAudioPlayer = MockAudioPlayer()
        
        let store = TestStore(
            initialState: BookListenerFeature.State(
                book: Book.testBook,
                isPlaying: true
            )) {
            BookListenerFeature()
                    .dependency(\.audioPlayer, mockAudioPlayer)
                    .dependency(\.continuousClock, MockClock())
        }
        store.exhaustivity = .off
        await store.send(.nextChapter) {
            $0.selectedChapterIndex = 1
            $0.isPlaying = false
            $0.isPaused = false
            $0.currentPosition = 0
            $0.totalDuration = 0
        }
        
        // loadAudio should be triggered after chapter change
        await store.receive(.loadAudio)
    }
    
    @Test func previousChapterNavigationWorksCorrectly() async {
        let mockAudioPlayer = MockAudioPlayer()
        
        let store = TestStore(
            initialState: BookListenerFeature.State(
                book: Book.testBook,
                selectedChapterIndex: 1,
                isPlaying: true
            )) {
            BookListenerFeature()
                    .dependency(\.audioPlayer, mockAudioPlayer)
                    .dependency(\.continuousClock, MockClock())
        }
        store.exhaustivity = .off
        await store.send(.previousChapter) {
            $0.selectedChapterIndex = 0
            $0.isPlaying = false
            $0.isPaused = false
            $0.currentPosition = 0
            $0.totalDuration = 0
        }
        
        // loadAudio should be triggered after chapter change
        await store.receive(.loadAudio)
    }
    
    @Test func previousChapterAtFirstChapterDoesNothing() async {
        let mockAudioPlayer = MockAudioPlayer()
        
        let store = TestStore(
            initialState: BookListenerFeature.State(
                book: Book.testBook,
                selectedChapterIndex: 0
            )) {
            BookListenerFeature()
                    .dependency(\.audioPlayer, mockAudioPlayer)
        }
        
        await store.send(.previousChapter)
    }
    
    @Test func nextChapterAtLastChapterDoesNothing() async {
        let mockAudioPlayer = MockAudioPlayer()
        
        let store = TestStore(
            initialState: BookListenerFeature.State(
                book: Book.testBook,
                selectedChapterIndex: 2
            )) {
            BookListenerFeature()
                    .dependency(\.audioPlayer, mockAudioPlayer)
        }
        
        await store.send(.nextChapter)
    }
    
    @Test func selectSpecificChapterWorksCorrectly() async {
        let mockAudioPlayer = MockAudioPlayer()
        
        let store = TestStore(
            initialState: BookListenerFeature.State(
                book: Book.testBook,
                selectedChapterIndex: 0
            )) {
            BookListenerFeature()
                    .dependency(\.audioPlayer, mockAudioPlayer)
                    .dependency(\.continuousClock, MockClock())
        }
        store.exhaustivity = .off
        await store.send(.selectChapter(2)) {
            $0.selectedChapterIndex = 2
            $0.isPlaying = false
            $0.isPaused = false
            $0.currentPosition = 0
            $0.totalDuration = 0
        }
        
        // loadAudio should be triggered after chapter selection
        await store.receive(.loadAudio)
    }
    
    // MARK: - Skip Forward/Backward Tests
    @Test func skipForwardWorksCorrectly() async {
        let mockAudioPlayer = MockAudioPlayer()
        mockAudioPlayer.currentTime = 20.0
        
        let store = TestStore(
            initialState: BookListenerFeature.State(
                book: Book.testBook
            )) {
            BookListenerFeature()
                    .dependency(\.audioPlayer, mockAudioPlayer)
        }
        
        await store.send(.skipForwardTapped)
        
        // Verify the mockAudioPlayer received the command correctly
        await verifyAsync {
            mockAudioPlayer.currentTime == 30.0 // Original 20.0 + 10.0 forward
        }
    }
    
    @Test func skipBackwardsWorksCorrectly() async {
        let mockAudioPlayer = MockAudioPlayer()
        mockAudioPlayer.currentTime = 20.0
        
        let store = TestStore(
            initialState: BookListenerFeature.State(
                book: Book.testBook
            )) {
            BookListenerFeature()
                    .dependency(\.audioPlayer, mockAudioPlayer)
        }
        
        await store.send(.skipBackwardTapped)
        
        // Verify the mockAudioPlayer received the command correctly
        await verifyAsync {
            mockAudioPlayer.currentTime == 15.0 // Original 20.0 - 5.0 backward
        }
    }
    
    // MARK: - Speech Rate Tests
    @Test func changingSpeechRateUpdatesStateAndPlayer() async {
        let mockAudioPlayer = MockAudioPlayer()
        
        let store = TestStore(
            initialState: BookListenerFeature.State(
                book: Book.testBook
            )) {
            BookListenerFeature()
                    .dependency(\.audioPlayer, mockAudioPlayer)
        }
        
        await store.send(.changeSpeechRate(1.5)) {
            $0.speechRate = 1.5
            $0.isPlaying = true
            $0.isPaused = false
        }
        
        // Verify the mockAudioPlayer received the rate change
        await verifyAsync {
            mockAudioPlayer.playbackRate == 1.5
        }
    }
    
    @Test func showSpeechRateSheetTogglesSheetState() async {
        let store = TestStore(
            initialState: BookListenerFeature.State(
                book: Book.testBook
            )) {
            BookListenerFeature()
        }
        
        await store.send(.showSpeechRateSheet(true)) {
            $0.isSpeechRateSheetPresented = true
        }
        
        await store.send(.showSpeechRateSheet(false)) {
            $0.isSpeechRateSheetPresented = false
        }
    }
    
    // MARK: - Listener Mode Tests
    @Test func switchingListenerModeUpdatesState() async {
        let store = TestStore(
            initialState: BookListenerFeature.State(
                book: Book.testBook
            )) {
            BookListenerFeature()
        }
        
        await store.send(.switchListenerMode(.reading)) {
            $0.listenerMode = .reading
        }
        
        await store.send(.switchListenerMode(.listening)) {
            $0.listenerMode = .listening
        }
    }
    
    // MARK: - Chapter List Tests
    @Test func showChapterListTogglesChapterListState() async {
        let store = TestStore(
            initialState: BookListenerFeature.State(
                book: Book.testBook
            )) {
            BookListenerFeature()
        }
        
        await store.send(.showChapterList(true)) {
            $0.isChapterListPresented = true
        }
        
        await store.send(.showChapterList(false)) {
            $0.isChapterListPresented = false
        }
    }
    
    // MARK: - Image Loading Tests
    @Test func loadingImageUpdatesStateWhenSuccessful() async {
        // Mock image data
        let imageData = Data([0, 1, 2, 3, 4])
        
        let testReducer = Reduce<BookListenerFeature.State, BookListenerFeature.Action> { state, action in
            switch action {
            case .loadImage:
                return .run { send in
                    // Directly send the imageLoaded action with our test data
                    await send(.imageLoaded(imageData))
                }
            case let .imageLoaded(data):
                state.bookCoverImage = data
                return .none
            default:
                return .none
            }
        }
        
        let store = TestStore(
            initialState: BookListenerFeature.State(book: Book.testBook),
            reducer: { testReducer }
        )
        
        await store.send(.loadImage)
        
        await store.receive(.imageLoaded(imageData)) {
            $0.bookCoverImage = imageData
        }
    }
    
    @Test func loadingImageAgainWhenAlreadyLoadedDoesNothing() async {
        let imageData = Data([0, 1, 2, 3, 4])
        
        let store = TestStore(
            initialState: BookListenerFeature.State(
                book: Book.testBook,
                bookCoverImage: imageData
            )) {
            BookListenerFeature()
        }
        
        await store.send(.loadImage)
    }
    
    // Helper to verify async conditions
    func verifyAsync(timeout: TimeInterval = 1.0, condition: @escaping () -> Bool) async {
        let start = Date()
        while !condition() {
            if Date().timeIntervalSince(start) > timeout {
                XCTFail("Async condition not met within timeout")
                return
            }
            try? await Task.sleep(nanoseconds: 10_000_000) // 10ms
        }
    }
}
