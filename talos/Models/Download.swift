////
////  Download.swift
////  talos
////
////  Created by Tyler Torres on 4/22/23.
////
//
//import Foundation
//
//class Download: NSObject {
//    let url: URL
//    let downloadSession: URLSession
//
//    private var continuation: AsyncStream<Any>.Continuation?
//
//    private lazy var task: URLSessionDownloadTask = {
//        let task = downloadSession.downloadTask(with: url)
//        task.delegate = self
//        return task
//    }()
//
//    init(url: URL, downloadSession: URLSession) {
//        self.url = url
//        self.downloadSession = downloadSession
//    }
//
//    var isDownloading: Bool {
//        task.state == .running
//    }
//
//    var events: AsyncStream<Any> {
//        AsyncStream { continuation in
//            self.continuation = continuation
//            task.resume()
//            continuation.onTermination = { @Sendable [weak self] _ in
//                self?.task.cancel()
//            }
//        }
//    }
//
//    func pause() {
//        task.suspend()
//    }
//
//    func resume() {
//        task.resume()
//    }
//}
//
//extension Download {
//    
//    enum Event {
//        case progress(currentBytes: Int64, totalBytes: Int64)
//        case success(url: URL)
//    }
//}
//
//
//extension Download : URLSessionDownloadDelegate {
//    
//    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
//        URL.documentsDirectory.appending
//    }
//    
//    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
//        continuation?.yield(.success(url: location))
//        continuation?.finish()
//    }
//    
//    
//}
