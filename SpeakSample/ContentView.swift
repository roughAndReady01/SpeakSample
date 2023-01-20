//
//  ContentView.swift
//  SpeakSample
//
//  Created by 春蔵 on 2023/01/20.
//

import SwiftUI
import AVFoundation

struct ContentView: View {
    // ViewModel
    @StateObject var viewModel = ContentViewModel()
    
    var body: some View {
        NavigationView {
            Form {
                // 音声一覧
                Picker("音声を選択", selection: $viewModel.selectVoice) {
                    ForEach(viewModel.voices , id: \.self) { voice in
                        Text(voice.name)
                            .tag(voice.identifier)
                    }
                }
                
                // 話すテキスト
                TextField("", text: $viewModel.text)
                
                // 話す
                Button(action: {
                    viewModel.onSpeak()
                }) {
                    Text(viewModel.isSpeaking ? "停止" : "話す")
                }
            }
        }
        .padding()
    }
}

class ContentViewModel : NSObject, ObservableObject , AVSpeechSynthesizerDelegate{
    /// 日本語
    let locale = "ja-JP"
    /// 音声
    let synthesizer = AVSpeechSynthesizer()
    /// 音声一覧
    @Published var voices:[AVSpeechSynthesisVoice] = []
    /// デフォルト音声
    lazy var defaultVoice = AVSpeechSynthesisVoice.init(identifier: "com.apple.ttsbundle.siri_O-ren_ja-JP_compact")
    /// 選択された音声
    @Published var selectVoice = ""
    /// 話すテキスト
    @Published var text = "サンプルの文章です"
    /// ステータス
    @Published var isSpeaking = false
    
    override init(){
        super.init()
        
        // 音声一覧の取得
        voices = getVoices()
        // Delegate設定
        synthesizer.delegate = self
    }
    
    // 読み上げ
    func onSpeak(){
        if isSpeaking {
            // 停止
            stop()
        } else {
            // 選択された音声の検索
            if let voice = voices.filter({$0.identifier == selectVoice}).first {
                // 話す
                speak(text, voice: voice)
            } else {
                // 話す
                speak(text, voice: defaultVoice)
            }
        }
    }
    
    /// テキスト読上げ
    /// - Parameter text: 対象テキスト
    func speak(_ text:String , voice:AVSpeechSynthesisVoice?){
        // テキストの設定
        let utterance = AVSpeechUtterance.init(string: text)
        // 音声の設定
        utterance.voice = voice
        // 声の高さ(0.5〜2.0)
        utterance.pitchMultiplier = 1
        // 音量(0.0〜1.0)
        utterance.volume = 1
        // 読み上げスピード(0.0〜1.0)
        utterance.rate = 0.5
        // 話す
        synthesizer.speak(utterance)
        // ステータス変更
        self.isSpeaking = true
    }
    
    /// 停止
    func stop() {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: AVSpeechBoundary.immediate)
        }
        self.isSpeaking = false
    }
    
    /// 一時停止
    func pause() {
        if synthesizer.isSpeaking {
            synthesizer.pauseSpeaking(at: AVSpeechBoundary.immediate)
        }
        self.isSpeaking = false
    }
    
    /// 再開
    func resume() {
        if synthesizer.isSpeaking {
            synthesizer.continueSpeaking()
        }
        self.isSpeaking = true
    }
    
    /// 発話終了
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        isSpeaking = false
    }
    
    /// 音声の表示
    func getVoices()->[AVSpeechSynthesisVoice] {
        // 使用可能音声の取得
        let voices = AVSpeechSynthesisVoice.speechVoices()
        
        // 日本語のみ取得
        let jpVoices = voices.filter({$0.language == locale})
        
        // デバッグ用
        for jpVoice in jpVoices {
            print("voice.name:\(jpVoice.name)")
            print("voice.identifier:\(jpVoice.identifier)")
        }
        
        return jpVoices
    }
}
