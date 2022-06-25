//
//  MockMoyaProvider.swift
//  GithubFetcher2.0Tests
//
//  Created by Mickael Ruzel on 31/05/2022.
//

import Foundation
import Moya
@testable import GithubFetcher2_0

final class MockMoyaProvider {
    
    // MARK: - Enum
    
    enum DataResponse {
        case good, bad
    }
    
    enum HTTPResponse {
        case good, bad
    }
    
    // MARK: - Properties
    
    private var dataResponse: DataResponse
    private var httpResponse: HTTPResponse
    
//    private var responseClosure: Endpoint.SampleResponseClosure {
//        switch (httpResponse, dataResponse) {
//        case (.good, .good): return { .networkResponse(200, SampleDataKeeper.repositories.data) }
//        case (.good, .bad): return { .networkResponse(200, Data()) }
//        case (.bad, _): return { .networkResponse(500, Data()) }
//        }
//    }
    
    // MARK: - Init
    
    init(dataResponse: MockMoyaProvider.DataResponse, httpResponse: MockMoyaProvider.HTTPResponse) {
        self.dataResponse = dataResponse
        self.httpResponse = httpResponse
    }
    
    // MARK: - Methodes
    
    func immediateResponse() -> MoyaProvider<GithubTarget> {
        let endpoint = { (target: GithubTarget) -> Endpoint in
            
            return Endpoint(url: URL(target: target).absoluteString,
                            sampleResponseClosure: self.responseClosure(data: target.sampleData),
                            method: target.method,
                            task: target.task,
                            httpHeaderFields: target.headers)
        }
        
        let provider = MoyaProvider<GithubTarget>(endpointClosure: endpoint,
                                                  stubClosure: MoyaProvider.immediatelyStub)
        
        return provider
    }
    
    private func responseClosure(data: Data) -> Endpoint.SampleResponseClosure {
        switch (httpResponse, dataResponse) {
        case (.good, .good): return { .networkResponse(200, data) }
        case (.good, .bad): return { .networkResponse(200, Data()) }
        case (.bad, _): return { .networkResponse(500, Data()) }
        }
    }
    
}
