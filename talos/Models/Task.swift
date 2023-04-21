//
//  Task.swift
//  talos
//
//  Created by Tyler Torres on 4/20/23.
//

import Foundation


struct Task : Codable {
    let id : String
    let name : String
    var data : [String : String] = [:]
}
