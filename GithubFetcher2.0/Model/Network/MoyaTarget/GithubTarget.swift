//
//  MoyaProvider.swift
//  GithubFetcher2.0
//
//  Created by Mickael Ruzel on 31/05/2022.
//

import Foundation
import Moya

enum GithubTarget {
    case fetchRepositories(searchTerms: String)
}

extension GithubTarget: TargetType {
    var baseURL: URL {
        URL(string: "https://api.github.com/")!
    }
    
    var path: String {
        switch self {
        case .fetchRepositories(_): return "search/repositories"
        }
    }
    
    var method: Moya.Method {
        return .get
    }
    
    var task: Task {
        switch self {
        case .fetchRepositories(let searchTerms):
            return .requestParameters(parameters: ["q": searchTerms], encoding: URLEncoding.queryString)
        }
    }
    
    var headers: [String : String]? {
        [:]
    }
}
