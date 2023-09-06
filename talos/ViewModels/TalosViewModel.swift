//
//  TalosViewModel.swift
//  talos
//
//  Created by Tyler Torres on 9/4/23.
//

import Foundation
import Combine


class TalosViewModel : ObservableObject {
    
    private var cancellables: Set<AnyCancellable> = []
    private let networkService: OpenAIReactiveService = OpenAIReactiveService()
    
    @Published var modelText: String?
    @Published var networkError: Error?
    
    func fetchModelText() {
        
        networkService.fetchTranscription()
            .flatMap { [weak self] transcribedText in
                self?.networkService.fetchChatCompletion(input: transcribedText) ?? Empty<String, OpenAIError>().eraseToAnyPublisher()
            }
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    self?.networkError = error
                case .finished:
                    break
                }
            }, receiveValue: { [weak self] text in
                self?.modelText = text
            })
            .store(in: &cancellables)
    }
}
