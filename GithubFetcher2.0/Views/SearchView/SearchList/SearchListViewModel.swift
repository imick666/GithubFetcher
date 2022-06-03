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
    private var showEmptySearchLabel = BehaviorSubject<Bool>(value: true)
    private var showTableView = BehaviorSubject<Bool>(value: false)
    private var showActivityIndicator = BehaviorSubject<Bool>(value: false)
    
    // Dependencies
    private var networkService: GithubService
    private var bag = DisposeBag()
    
    // MARK: - init
    
    init(networkService: GithubService = GithubService()) {
        self.networkService = networkService
        
        input = Input(searchterms: searchTerms.asObserver(),
                      searchButtonTapped: searchButtonTapped.asObserver())
        
        output = Output(items: items.asDriver(onErrorJustReturn: []),
                        displayedError: displayedError.asDriver(onErrorJustReturn: ""),
                        showEmptySearchLabel: showEmptySearchLabel.asDriver(onErrorJustReturn: true),
                        showTableView: showTableView.asDriver(onErrorJustReturn: false),
                        showActivityIndicator: showActivityIndicator.asDriver(onErrorJustReturn: false) )
        
        searchButtonTapped
            .subscribe(onNext: { _ in self.fetchReporistories() })
            .disposed(by: bag)
        
        updateEmptySearchLabel()
            .subscribe(showEmptySearchLabel)
            .disposed(by: bag)
        
        updateTableView()
            .subscribe(showTableView)
            .disposed(by: bag)
        
    }
    
    // MARK: - Methodes
    
    private func updateEmptySearchLabel() -> Observable<Bool> {
        Observable.combineLatest(showActivityIndicator, items)
            .map { !$0.0 && ($0.1.isEmpty || !self.items.hasObservers) }
    }
    
    private func updateTableView() -> Observable<Bool> {
        Observable.combineLatest(showActivityIndicator, items)
            .map { !$0.0 && !$0.1.isEmpty }
    }
    
    private func fetchReporistories() {
        showActivityIndicator.onNext(true)
        
        validateSearchTerms()
            .flatMap(networkService.fetchRepositories(searchTerms:))
            .map { $0.map { SearchListTableViewCellViewModel(repository: $0) } }
            .subscribe(onNext: { [weak self] repositories in
                self?.items.onNext(repositories)
                self?.showActivityIndicator.onNext(false)
            }, onError: { [weak self] error in
                self?.displayedError.onNext(error.localizedDescription)
                self?.showActivityIndicator.onNext(false)
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
        var showEmptySearchLabel: Driver<Bool>
        var showTableView: Driver<Bool>
        var showActivityIndicator: Driver<Bool>
    }
}
