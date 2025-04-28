//
//  MockAudioPlayerClient.swift
//  TestAssignment
//
//  Created by Artem Mihelson on 28.04.2025.
//


import Foundation
@testable import TestAssignment

// MARK: - Mock AudioPlayerClient for Tests
final class MockAudioPlayer: AudioPlayerProtocol {
    var loadedFileName: String?
    var isPlaying = false
    var isPaused = false
    var currentTime: Double = 0
    var duration: Double = 60.0
    var playbackRate: Float = 1.0
    var simulateError = false
    var simulateDelayedLoading = false
    
    func loadAudio(fileName: String, completion: @escaping (Double) -> Void) async {
        loadedFileName = fileName
        currentTime = 0
        
        if simulateError {
            completion(0)
        } else {
            completion(duration)
        }
    }
    
    func play() async {
        isPlaying = true
        isPaused = false
    }
    
    func pause() async {
        isPaused = true
    }
    
    func stop() async {
        isPlaying = false
        isPaused = false
        currentTime = 0
    }
    
    func setPlaybackRate(_ rate: Float) async {
        playbackRate = rate
    }
    
    func seekTo(time: Double) async {
        currentTime = min(max(0, time), duration)
    }
    
    func skipForward(seconds: Double) async {
        await seekTo(time: currentTime + seconds)
    }
    
    func skipBackward(seconds: Double) async {
        await seekTo(time: currentTime - seconds)
    }
    
    func getCurrentTime() async -> Double {
        return currentTime
    }
    
    func getDuration() async -> Double {
        return duration
    }
}
