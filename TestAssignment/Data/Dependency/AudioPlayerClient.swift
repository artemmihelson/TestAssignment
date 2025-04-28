//
//  AudioPlayerClient.swift
//  TestAssignment
//
//  Created by Artem Mihelson on 26.04.2025.
//


import Foundation
import AVFoundation
import Dependencies

// MARK: - Audio Player Dependency
protocol AudioPlayerProtocol {
    func loadAudio(fileName: String, completion: @escaping (Double) -> Void) async
    func play() async
    func pause() async
    func stop() async
    func setPlaybackRate(_ rate: Float) async
    func seekTo(time: Double) async
    func skipForward(seconds: Double) async
    func skipBackward(seconds: Double) async
    func getCurrentTime() async -> Double
    func getDuration() async -> Double
}
class AudioPlayerClient: AudioPlayerProtocol {
    private let player = AVPlayer()
    private var currentRate: Float = Constants.Audio.normalRate
    private var timeObserver: Any?
    private var progressHandler: ((Double, Double) -> Void)?
    
    //MARK: - Constants -
    private let waitInterval = 150
    
    init() {
        setupAudioSession()
    }
    
    private func setupAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback, options: .duckOthers)
            try audioSession.setActive(true)
        } catch {
            print("Error setting up audio session: \(error)")
        }
    }
    
    func loadAudio(fileName: String, completion: @escaping (Double) -> Void) async {
        if let url = Bundle.main.url(forResource: fileName.replacingOccurrences(of: ".m4a", with: ""),
                                     withExtension: "m4a") {
            // Create player item
            let playerItem = AVPlayerItem(url: url)
            
            // Replace the current item
            player.replaceCurrentItem(with: playerItem)
            player.automaticallyWaitsToMinimizeStalling = true
            
            // Wait for the duration to become available
            var duration: Double = 0
            for _ in 0..<waitInterval {
                if playerItem.status == .readyToPlay {
                    duration = playerItem.duration.seconds
                    if !duration.isNaN && duration > 0 {
                        break
                    }
                }
                try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
            }
            // If duration is still not available, try loading asset metadata
            if duration.isNaN || duration <= 0 {
                let asset = await playerItem.asset
                let durationKey = "duration"
                
                if #available(iOS 16.0, *) {
                    let loadedDuration = try? await asset.load(.duration)
                    duration = loadedDuration?.seconds ?? 0
                    print("iOS 16+ duration from asset: \(duration)")
                } else {
                    if asset.statusOfValue(forKey: durationKey, error: nil) != .loaded {
                        // Properly wrap the callback-based API
                        try? await withCheckedThrowingContinuation { continuation in
                            asset.loadValuesAsynchronously(forKeys: [durationKey]) {
                                continuation.resume()
                            }
                        }
                    }
                }
                
                // Try to get duration from the asset
                let assetDuration = try? await asset.load(.duration)
                duration = assetDuration?.seconds ?? 0
            }
            // Return the duration through the completion handler
            completion(duration.isNaN ? 0 : duration)
        } else {
            completion(0)
        }
    }
    
    private func setupTimeObserver() {
        let interval = cmTime(from: 0.1)
        timeObserver = player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            guard let self = self,
                  let duration = self.player.currentItem?.duration.seconds,
                  !duration.isNaN, // Add this check
                  let progressHandler = self.progressHandler else { return }
            
            let currentTime = time.seconds
            progressHandler(currentTime, duration)
        }
    }
    
    
    private func removeTimeObserver() {
        if let observer = timeObserver {
            player.removeTimeObserver(observer)
            timeObserver = nil
        }
    }
    
    func play() {
        player.play()
    }
    
    func pause() {
        player.pause()
    }
    
    func stop() {
        player.pause()
        player.seek(to: .zero)
    }
    
    func setPlaybackRate(_ rate: Float) {
        currentRate = rate
        player.rate = rate
    }
    
    func seekTo(time: Double) {
        player.seek(to: cmTime(from: time))
    }
    
    func skipForward(seconds: Double) {
        let currentTime = player.currentTime().seconds
        let newTime = min(currentTime + seconds, player.currentItem?.duration.seconds ?? 0)
        seekTo(time: newTime)
    }
    
    func skipBackward(seconds: Double) {
        let currentTime = player.currentTime().seconds
        let newTime = max(currentTime - seconds, 0)
        seekTo(time: newTime)
    }
    
    func getCurrentTime() async -> Double {
        return player.currentTime().seconds
    }
    
    func getDuration() async -> Double {
        return player.currentItem?.duration.seconds ?? 0
    }
    
    deinit {
        removeTimeObserver()
    }
    
    private func cmTime(from seconds: Double) -> CMTime {
        .init(seconds: seconds, preferredTimescale: 1000)
    }
}

// MARK: - TCA Dependency
private enum AudioPlayerKey: DependencyKey {
    static let liveValue: AudioPlayerProtocol = AudioPlayerClient()
}

extension DependencyValues {
    var audioPlayer: AudioPlayerProtocol {
        get { self[AudioPlayerKey.self] }
        set { self[AudioPlayerKey.self] = newValue }
    }
}
