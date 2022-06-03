//
//  SearchViewModelTests.swift
//  GithubFetcher2.0Tests
//
//  Created by Mickael Ruzel on 03/06/2022.
//

import XCTest
import RxTest
import RxSwift
import RxCocoa
@testable import GithubFetcher2_0

class SearchViewModelTests: XCTestCase {
    
    // MARK: - Properties
    
    var sut: SearchViewModel!
    var bag: DisposeBag!
    var scheduler: TestScheduler!
    
    // MARK: - Setup / TearDown

    override func setUpWithError() throws {
        bag = DisposeBag()
        scheduler = TestScheduler(initialClock: 0)
        try super.setUpWithError()
    }

    override func tearDownWithError() throws {
        sut = nil
        bag = nil
        scheduler = nil
        try super.tearDownWithError()
    }
    
    // MARK: - Methodes
    
    private func createSut(dataResponse: MockMoyaProvider.DataResponse, httpReponse: MockMoyaProvider.HTTPResponse) {
        let mockProvider = MockMoyaProvider(dataResponse: dataResponse, httpResponse: httpReponse)
        let networkService = GithubService(provider: mockProvider.immediateResponse())
        sut = SearchViewModel(networkService: networkService)
    }
    
    private func createObserverForItemsAndErrors() -> (items: TestableObserver<[Repository]>, errors: TestableObserver<String?>) {
        let items = scheduler.createObserver([Repository].self)
        let error = scheduler.createObserver(String?.self)
        
        sut.output.items
            .drive(items)
            .disposed(by: bag)
        
        sut.output.displayedError
            .drive(error)
            .disposed(by: bag)
        
        return (items, error)
    }
    
    // MARK: - Tests
    
    func testSearchViewModel_onFetchRepositoriesWithEmptySearchTerms_InvalidEntryError() {
        createSut(dataResponse: .good, httpReponse: .good)
        
        let observer = createObserverForItemsAndErrors()
        
        scheduler.createColdObservable([
            .next(0, ())
            
        ])
        .bind(to: sut.input.searchButtonTapped)
        .disposed(by: bag)
        
        scheduler.start()
        
        XCTAssertEqual(observer.items.events.count, 0)
        XCTAssertEqual(observer.errors.events, [
            .next(0, GFUserError.invalidEntry(detail: .emptyField).localizedDescription)
        ])
    }
    
    func testSearchViewModel_onFetchRepositoriesWithSearchTerms_badResponseError() {
        createSut(dataResponse: .good, httpReponse: .bad)
        
        let observer = createObserverForItemsAndErrors()
        
        scheduler.createColdObservable([
            .next(0, "Bonjour")
        ])
        .bind(to: sut.input.searchterms)
        .disposed(by: bag)
        
        scheduler.createColdObservable([
            .next(0, ())
        ])
        .bind(to: sut.input.searchButtonTapped)
        .disposed(by: bag)
        
        scheduler.start()
        
        XCTAssertEqual(observer.items.events.count, 0)
        XCTAssertEqual(observer.errors.events, [
            .next(0, GFNetworkError.badResponse.localizedDescription)
        ])
    }
    
    func testSearchViewModel_onFetchRepositoriesWithSearchTerms_badDataError() {
        
        createSut(dataResponse: .bad, httpReponse: .good)
        
        let observer = createObserverForItemsAndErrors()
        
        scheduler.createColdObservable([
            .next(0, "Bonjour")
        ])
        .bind(to: sut.input.searchterms)
        .disposed(by: bag)
        
        scheduler.createColdObservable([
            .next(0, ())
        ])
        .bind(to: sut.input.searchButtonTapped)
        .disposed(by: bag)
        
        scheduler.start()
        
        XCTAssertEqual(observer.items.events.count, 0)
        XCTAssertEqual(observer.errors.events, [
            .next(0, GFNetworkError.BadData.localizedDescription)
        ])
    }
    
    func testSearchViewModel_AfterFetchRepo_onChangesearchTerms_notFetchAgain() {
        createSut(dataResponse: .good, httpReponse: .good)
        
        let observer = createObserverForItemsAndErrors()
        
        scheduler.createColdObservable([
            .next(0, "Bonjour"),
            .next(1, "Bonjou"),
            .next(2, "Bonjo")
        ])
        .bind(to: sut.input.searchterms)
        .disposed(by: bag)
        
        scheduler.createColdObservable([
            .next(0, ())
        ])
        .bind(to: sut.input.searchButtonTapped)
        .disposed(by: bag)
        
        scheduler.start()
        
        XCTAssertEqual(observer.items.events.count, 1)
        XCTAssertEqual(observer.errors.events.count, 0)
    }
    
    
    
    func testSearchViewModel_onFetchRepositories_success() {
        createSut(dataResponse: .good, httpReponse: .good)
        
        let observer = createObserverForItemsAndErrors()
        
        scheduler.createColdObservable([
            .next(0, "Bonjour")
        ])
        .bind(to: sut.input.searchterms)
        .disposed(by: bag)
        
        scheduler.createColdObservable([
            .next(0, ())
        ])
        .bind(to: sut.input.searchButtonTapped)
        .disposed(by: bag)
        
        scheduler.start()
        
        XCTAssertEqual(observer.items.events,[
            .next(0, SampleDataKeeper.repositories.asObject())
        ])
        XCTAssertEqual(observer.errors.events.count, 0)
    }
    

}
