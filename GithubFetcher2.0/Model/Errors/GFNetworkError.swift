//
//  GFError.swift
//  GithubFetcher2.0
//
//  Created by Mickael Ruzel on 31/05/2022.
//

import Foundation
import Moya

enum GFError: LocalizedError {
    
    case network
    
    var errorDescription: String? {
        nil
    }
    
}

enum GFNetworkError: LocalizedError {
case badResponse, BadData, other(_ error: Error)
    
    var errorDescription: String? {
        
        switch self {
        case .BadData: return "Not good data"
        case .badResponse: return "Not the good response"
        case .other(let error): return error.localizedDescription
        }
    }
    
    init(_ error: Error) {
        switch error {
        case MoyaError.statusCode(_): self = .badResponse
        case MoyaError.jsonMapping(_), MoyaError.objectMapping(_, _): self = .BadData
        default: self = .other(error)
        }
    }
}
