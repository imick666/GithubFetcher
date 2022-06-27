//
//  RepositoryViewModelTests.swift
//  GithubFetcher2.0Tests
//
//  Created by Mickael Ruzel on 25/06/2022.
//

import XCTest
import RxSwift
import RxTest
@testable import GithubFetcher2_0

class RepositoryViewModelTests: XCTestCase {
    
    // MARK: - Properties
    
    var sut: RepositoryViewModel!
    var scheduler: TestScheduler!
    var bag: DisposeBag!
    
    // MARK: - Setup / TearDown
    
    override func setUpWithError() throws {
        scheduler = TestScheduler(initialClock: 0)
        bag = DisposeBag()
        try super.setUpWithError()
    }

    override func tearDownWithError() throws {
        scheduler = nil
        bag = nil
        sut = nil
        try super.tearDownWithError()
    }

    // MARK: - Methodes
    
    // MARK: - Tests
    
    func testRepositoryViewModel_onFetchRepository_badResponseOccured() {
        let provider = MockMoyaProvider(dataResponse: .good, httpResponse: .bad).immediateResponse()
        let service = GithubService(provider: provider)
        
        sut = RepositoryViewModel(service: service)
        let observer = scheduler.createObserver(String?.self)
        
        sut.output.shownedError
            .drive(observer)
            .disposed(by: bag)
        
        sut.fetchrepository(fullName: "")
        
        scheduler.start()
        
        XCTAssertEqual(observer.events, [
            .next(0, GFNetworkError.badResponse.localizedDescription)
        ])
    }
    
    func testRepositoryViewModel_onFetchRepository_badDataOccured() {
        let provider = MockMoyaProvider(dataResponse: .bad, httpResponse: .good).immediateResponse()
        let service = GithubService(provider: provider)
        
        sut = RepositoryViewModel(service: service)
        let observer = scheduler.createObserver(String?.self)
        
        sut.output.shownedError
            .drive(observer)
            .disposed(by: bag)
        
        sut.fetchrepository(fullName: "")
        
        scheduler.start()
        
        XCTAssertEqual(observer.events, [
            .next(0, GFNetworkError.BadData.localizedDescription)
        ])
    }
    
    func testRepositoryViewModel_onFetchRepository_fetchSucced() {
        let provider = MockMoyaProvider(dataResponse: .good, httpResponse: .good).immediateResponse()
        let service = GithubService(provider: provider)
        
        sut = RepositoryViewModel(service: service)
        let observer = scheduler.createObserver(String.self)
        
        sut.output.userName
            .drive(observer)
            .disposed(by: bag)
        
        sut.fetchrepository(fullName: "")
        
        scheduler.start()
        
        var expected: String {
            let repository: Repository = SampleDataKeeper.repository.asObject()
            let nameComponnents = repository.fullName.components(separatedBy: "/")
            return nameComponnents[0]
        }
        
        XCTAssertEqual(observer.events, [
            .next(0, expected)
        ])
    }

}
