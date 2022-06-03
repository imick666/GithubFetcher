//
//  SearchViewModel.swift
//  GithubFetcher2.0
//
//  Created by Mickael Ruzel on 03/06/2022.
//

import Foundation
import RxSwift
import RxCocoa

protocol ViewModel {
    associatedtype Input
    associatedtype Output
    
    var input: Input! { get set }
    var output: Output! { get set }
    
}

final class SearchListViewModel: ViewModel {
    
    // MARK: - Properties
    
    var input: Input!
    var output: Output!
    
    // Input
    private var searchTerms = BehaviorSubject<String>(value: "")
    private var searchButtonTapped = PublishSubject<()>()
    
    // Output
    private var items = PublishSubject<[SearchListTableViewCellViewModel]>()
    private var displayedError = PublishSubject<String?>()
    
    // Dependencies
    private var networkService: GithubService
    private var bag = DisposeBag()
    
    // MARK: - init
    
    init(networkService: GithubService = GithubService()) {
        self.networkService = networkService
        
        input = Input(searchterms: searchTerms.asObserver(),
                      searchButtonTapped: searchButtonTapped.asObserver())
        
        output = Output(items: items.asDriver(onErrorJustReturn: []),
                        displayedError: displayedError.asDriver(onErrorJustReturn: ""))
        
        searchButtonTapped
            .subscribe(onNext: { _ in self.fetchReporistories() })
            .disposed(by: bag)

    }
    
    // MARK: - Methodes
    
    private func fetchReporistories() {
        validateSearchTerms()
            .flatMap(networkService.fetchRepositories(searchTerms:))
            .map { $0.map { SearchListTableViewCellViewModel(repository: $0) } }
            .subscribe(onNext: { [weak self] repositories in
                self?.items.onNext(repositories)
                print(repositories)
            }, onError: { [weak self] error in
                self?.displayedError.onNext(error.localizedDescription)
                print(error)
            })
            .disposed(by: bag)
        
    }
    
    private func validateSearchTerms() -> Observable<String> {
        return searchTerms
            .take(1)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { terms in
                guard terms != "" else {
                    throw GFUserError.invalidEntry(detail: .emptyField)
                }
                return true
            }
    }
    
}

extension SearchListViewModel {
    struct Input {
        var searchterms: AnyObserver<String>
        var searchButtonTapped: AnyObserver<()>
    }
    
    struct Output {
        var items: Driver<[SearchListTableViewCellViewModel]>
        var displayedError: Driver<String?>
    }
}
