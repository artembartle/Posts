// Developed by Artem Bartle

import Combine

class StateCollector<T> {
    private(set) var collectedStates: [T] = []
    private var disposables = Set<AnyCancellable>()
    
    init(_ publisher: any Publisher<T, Never>) {
        publisher.sink { [weak self] in
            self?.collectedStates.append($0)
        }.store(in: &disposables)
    }
}
