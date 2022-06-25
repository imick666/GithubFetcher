//
//  GithubService.swift
//  GithubFetcher2.0
//
//  Created by Mickael Ruzel on 31/05/2022.
//

import Foundation
import Moya
import RxSwift

final class GithubService {
    
    // MARK: - Properties
    
    private let provider: MoyaProvider<GithubTarget>
    
    private var decoer: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
        
    }
    
    // MARK: - Init
    
    init(provider: MoyaProvider<GithubTarget> = MoyaProvider<GithubTarget>()) {
        self.provider = provider
    }
    
    // MARK: - Methodes
    
    func fetchRepositories(searchTerms terms: String) -> Observable<[Repository]> {
        provider.rx.request(.fetchRepositories(searchTerms: terms))
            .filterSuccessfulStatusAndRedirectCodes()
            .map([Repository].self, atKeyPath: "items", using: decoer)
            .catch { throw GFNetworkError($0) }
            .asObservable()
    }
    
    func fetchRepository(fullName: String) -> Observable<Repository> {
        provider.rx.request(.fetchRepository(fullName: fullName))
            .filterSuccessfulStatusAndRedirectCodes()
            .map(Repository.self, using: decoer)
            .catch { throw GFNetworkError($0) }
            .asObservable()
    }
    
}
