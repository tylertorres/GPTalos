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
    private let ttsService: GoogleTTSManager
    
    init(networkService: OpenAIReactiveService = OpenAIReactiveService(),
         speechService: SpeechRecognizer = SpeechRecognizer(),
         ttsService: GoogleTTSManager = GoogleTTSManager()) {
        self.networkService = networkService
        self.speechService = speechService
        self.ttsService = ttsService
        
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
            .filter { [weak self] status in
                return status == .stopped && self?.speechService.isAudioDataAvailable() == true
            }
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
                self.handleCompletion(completion)
            }, receiveValue: { [weak self] text in
                self?.handleFetchedModelText(text)
            })
            .store(in: &cancellables)
    }
    
    private func handleCompletion(_ completion: Subscribers.Completion<OpenAIError>) {
        switch completion {
        case .failure(let error):
            // TODO: Handle this error in UI
            print(error)
        case .finished:
            break
        }
    }
    
    private func handleFetchedModelText(_ text: String) {
        self.modelText = text
        speakModelText(text)
        FileUtils.deleteAudioFile()
    }
    
    private func speakModelText(_ text: String) {
        ttsService.speakText(text)
    }
}
