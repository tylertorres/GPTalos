//
//  Queue.swift
//  talos
//
//  Created by Tyler Torres on 4/20/23.
//

import Foundation

// can improve upon this using a circular buffer but for our purposes, simple is best

class Queue<T> {
    
    private var queue: [T] = []
    
    var isEmpty: Bool {
        return queue.isEmpty
    }
    
    var count: Int {
        return queue.count
    }
    
    func enqueue(_ element: T) {
        queue.append(element)
    }
    
    func dequeue() -> T? {
        if isEmpty {
            return nil
        } else {
            return queue.removeFirst()
        }
    }
    
    func peek() -> T? {
        return queue.first
    }
    
    func clear() {
        queue.removeAll()
    }
}
