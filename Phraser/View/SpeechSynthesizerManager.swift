//
//  SpeechSynthesizerManager.swift
//  Phraser
//
//  Created by Jonas Kaad on 10/11/2024.
//

import AVFoundation

class SpeechSynthesizerManager {
    static let shared: AVSpeechSynthesizer = {
        // Initialize AVSpeechSynthesizer as a singleton
        let synthesizer = AVSpeechSynthesizer()
        configureAudioSession() // Configure audio session when creating the synthesizer
        return synthesizer
    }()

    private init() {} // Prevents instantiation from outside

    private static func configureAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback, mode: .default, options: [.duckOthers, .mixWithOthers])
            try audioSession.setActive(true)
        } catch {
            print("Failed to set audio session category: \(error)")
        }
    }
}
