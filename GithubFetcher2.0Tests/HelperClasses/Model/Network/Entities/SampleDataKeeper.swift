//
//  SampleDataKeeper.swift
//  GithubFetcher2.0Tests
//
//  Created by Mickael Ruzel on 31/05/2022.
//

import Foundation
import ImageIO
@testable import GithubFetcher2_0

enum SampleDataKeeper {
    case repositories, repository
    
    var data: Data {
        switch self {
        case .repositories:
            let bundle = Bundle(for: MockMoyaProvider.self)
            let url = bundle.url(forResource: "RepositoriesResponse", withExtension: "json")!
            return try! Data(contentsOf: url)
        case .repository:
            let bundle = Bundle(for: MockMoyaProvider.self)
            let url = bundle.url(forResource: "RepositoryResponse", withExtension: "json")!
            return try! Data(contentsOf: url)
        }
    
    }
    
    func asObject<T: Codable>() -> T {
        switch self {
        case .repositories:
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            
            let searchResult = try! decoder.decode(SearchResult.self, from: self.data)
            return searchResult.items as! T
        case .repository:
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            
            let searchResult = try! decoder.decode(Repository.self, from: self.data)
            return searchResult as! T
        }
    }
}
