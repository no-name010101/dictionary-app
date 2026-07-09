//
//  PronunciationService.swift
//  词典
//
//  语音发音服务 - 使用 AVSpeechSynthesizer
//

import Foundation
import AVFoundation

@MainActor
class PronunciationService: Sendable {
    static let shared = PronunciationService()
    
    private let synthesizer = AVSpeechSynthesizer()
    
    // 英文发音
    func speakEnglish(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = 0.45
        utterance.pitchMultiplier = 1.0
        utterance.volume = 1.0
        synthesizer.stopSpeaking(at: .immediate)
        synthesizer.speak(utterance)
    }
    
    // 中文发音
    func speakChinese(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "zh-CN")
        utterance.rate = 0.45
        utterance.pitchMultiplier = 1.0
        utterance.volume = 1.0
        synthesizer.stopSpeaking(at: .immediate)
        synthesizer.speak(utterance)
    }
    
    // 英式发音
    func speakBritish(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-GB")
        utterance.rate = 0.45
        synthesizer.stopSpeaking(at: .immediate)
        synthesizer.speak(utterance)
    }
    
    // 停止发音
    func stopSpeaking() {
        synthesizer.stopSpeaking(at: .immediate)
    }
}
