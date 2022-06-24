//
//  GFUserError.swift
//  GithubFetcher2.0
//
//  Created by Mickael Ruzel on 03/06/2022.
//

import Foundation

enum GFUserError: LocalizedError {
    
    enum InvalideEntryDetail: String {
        case emptyField = "Fiels must not be empty"
    }
    
    case invalidEntry(detail: InvalideEntryDetail)
    
    var errorDescription: String? {
        switch self {
        case .invalidEntry(let detail): return "Invalid entry: \(detail.rawValue)"
        }
    }
    
}
