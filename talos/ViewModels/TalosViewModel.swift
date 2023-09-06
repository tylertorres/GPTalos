//
//  TalosViewModel.swift
//  talos
//
//  Created by Tyler Torres on 9/4/23.
//

import Foundation
import Combine


enum TalosState {
    case idle
    case recording
}

class TalosViewModel : ObservableObject {
    
    @Published var modelText: String = ""
    @Published var currentState: TalosState = .idle
    
    private var cancellables = Set<AnyCancellable>()
    private let networkService: OpenAIReactiveService
    private let speechService: SpeechRecognizer
    
    init(networkService: OpenAIReactiveService = OpenAIReactiveService(),
         speechService: SpeechRecognizer = SpeechRecognizer()) {
        self.networkService = networkService
        self.speechService = speechService
        
        setupSpeechRecognitionBinding()
    }
    
    func handleTapRecord() {
        speechService.toggleRecording()
    }
    
    func requestPermissions() {
        speechService.requestPermissions()
    }
    
    private func setupSpeechRecognitionBinding() {
        speechService.$status
            .filter { $0 == .stopped }
            .sink { [weak self] _ in
                self?.fetchModelText()
            }
            .store(in: &cancellables)
    }
    
    private func fetchModelText() {
        networkService.fetchTranscription()
            .flatMap { [weak self] transcribedText -> AnyPublisher<String, OpenAIError> in
                guard let self else {
                    return Fail(error: OpenAIError.invalidState).eraseToAnyPublisher()
                }
                return self.networkService.fetchChatCompletion(input: transcribedText)
            }
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    print(error)
                case .finished:
                    break
                }
            }, receiveValue: { [weak self] text in
                self?.modelText = text
            })
            .store(in: &cancellables)
        
//        FileUtils.deleteAudioFile()
    }
    
//    // TODO: Put into its own service
//    private func speakUsingGoogleTTS(with text: String) async {
//        let googleManager = GoogleTTSManager.shared
//
//        let audioContent = await googleManager.callTTS(with: text)
//
//        guard !audioContent.isEmpty,
//              let audioData = Data(base64Encoded: audioContent, options: .ignoreUnknownCharacters) else { return }
//
//        do {
//            audioPlayer = try AVAudioPlayer(data: audioData)
//            audioPlayer?.prepareToPlay()
//            audioPlayer?.play()
//        } catch {
//            print("Error: \(error.localizedDescription)")
//
//        }
//    }
}
