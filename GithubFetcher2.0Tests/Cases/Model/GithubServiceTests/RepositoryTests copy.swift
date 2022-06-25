//
//  GithubServiceTests.swift
//  GithubFetcher2.0Tests
//
//  Created by Mickael Ruzel on 01/06/2022.
//

import XCTest
import RxTest
import RxSwift
import Moya
@testable import GithubFetcher2_0

class RepositoryTests: XCTestCase {

    
    // MARK: - Properties
    
    private var sut: GithubService!
    private var bag: DisposeBag!
    private var scheduler: TestScheduler!
    private var mockProvider: MoyaProvider<GithubTarget>!
    
    // MARK: - Setup / TearDown

    override func setUpWithError() throws {
        try super.setUpWithError()
        bag = DisposeBag()
        scheduler = TestScheduler(initialClock: 0)
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        bag = nil
        scheduler = nil
        sut = nil
        mockProvider = nil
        try super.tearDownWithError()
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    // MARK: - Methodes
    
    // MARK: - Tests
    
    func testGithubService_onFetchRepositories_returnBadResponse() {
        mockProvider = MockMoyaProvider(dataResponse: .good, httpResponse: .bad).immediateResponse()
        sut = GithubService(provider: mockProvider)
        
        let observer = scheduler.createObserver(Repository.self)
        
        sut.fetchRepository(fullName: "")
            .subscribe(observer)
            .disposed(by: bag)
        
        scheduler.start()
        
        XCTAssertEqual(observer.events, [
            .error(0, GFNetworkError.badResponse)
        ])
    }
    
    func testGithubService_onFetchRepositories_returnBadData() {
        mockProvider = MockMoyaProvider(dataResponse: .bad, httpResponse: .good).immediateResponse()
        sut = GithubService(provider: mockProvider)
        
        let observer = scheduler.createObserver(Repository.self)
        
        sut.fetchRepository(fullName: "")
            .subscribe(observer)
            .disposed(by: bag)
        
        scheduler.start()
        
        XCTAssertEqual(observer.events, [
            .error(0, GFNetworkError.BadData)
        ])
    }
    
    func testGithubService_onFetchRepositories_success() {
        mockProvider = MockMoyaProvider(dataResponse: .good, httpResponse: .good).immediateResponse()
        sut = GithubService(provider: mockProvider)

        let observer = scheduler.createObserver(Repository.self)
        
        sut.fetchRepository(fullName: "")
            .subscribe(observer)
            .disposed(by: bag)
        
        scheduler.start()
        
        XCTAssertEqual(observer.events, [
            .next(0, SampleDataKeeper.repository.asObject()),
            .completed(0)
        ])
    }

}
