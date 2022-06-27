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
    private var cancelButtonTapped = PublishSubject<()>()
    private var begginEdditingSearchTerms = PublishSubject<()>()
    private var endEdditingSearchTerms = PublishSubject<()>()
    private var rowDidSelect = PublishSubject<SearchListTableViewCellViewModel>()
    
    // Output
    private var items = BehaviorSubject<[SearchListTableViewCellViewModel]>(value: [])
    private var displayedError = PublishSubject<String?>()
    private var isSearching = BehaviorSubject<Bool>(value: false)
    private var isEditingSearchTerms = BehaviorSubject<Bool>(value: false)
    
    // Dependencies
    private var networkService: GithubService
    private var bag = DisposeBag()
    var coordinator: MainCoordinator!
    
    // MARK: - init
    
    init(networkService: GithubService = GithubService()) {
        self.networkService = networkService
        
        input = Input(searchterms: searchTerms.asObserver(),
                      searchButtonTapped: searchButtonTapped.asObserver(),
                      cancelButtonTapped: cancelButtonTapped.asObserver(),
                      begginEdditingSearchTertms: begginEdditingSearchTerms.asObserver(),
                      endingEdditingSearchTerms: endEdditingSearchTerms.asObserver(),
                      rowDidSelect: rowDidSelect.asObserver())
        
        output = Output(items: items.skip(1).asDriver(onErrorJustReturn: []),
                        displayedError: displayedError.asDriver(onErrorJustReturn: ""),
                        showEmptySearchLabel: showEmptySearchLabel(),
                        showTableView: showTableView(),
                        showActivityIndicator: isSearching.asDriver(onErrorJustReturn: false),
                        isEdditingSearchTerms: isEditingSearchTerms.asDriver(onErrorJustReturn: false),
                        hideKeyboard: hideKeyboard())
        
        rowDidSelect
            .flatMap(\.output!.repository)
            .map(\.fullName)
            .subscribe(onNext: { [weak self] fullName in
                self?.coordinator.showRepository(fullName: fullName)
            },
                       onError: { [weak self] error in
                
            })
            .disposed(by: bag)
        
        searchButtonTapped
            .subscribe(onNext: { _ in self.fetchReporistories() })
            .disposed(by: bag)
        
        begginEdditingSearchTerms
            .map { true }
            .bind(to: isEditingSearchTerms)
            .disposed(by: bag)
        
        endEdditingSearchTerms
            .map { false }
            .bind(to: isEditingSearchTerms)
            .disposed(by: bag)
        
        searchTerms
            .filter { $0.isEmpty }
            .subscribe(onNext: { _ in
                self.items.onNext([])
            })
            .disposed(by: bag)
    }
    
    // MARK: - Methodes
    
    private func showTableView() -> Driver<Bool> {
        Observable.combineLatest(isSearching, items)
            .map { !$0.0 && !$0.1.isEmpty }
            .asDriver(onErrorJustReturn: false)
    }
    
    private func showEmptySearchLabel() -> Driver<Bool> {
        Observable.combineLatest(isSearching, items)
            .map { !$0.0 && $0.1.isEmpty}
            .asDriver(onErrorJustReturn: true)
    }
    
    private func hideKeyboard() -> Driver<Void> {
        Observable.of(searchButtonTapped, cancelButtonTapped)
            .merge()
            .asDriver(onErrorJustReturn: ())
    }
    
    private func fetchReporistories() {
        isSearching.onNext(true)
        
        validateSearchTerms()
            .flatMap(networkService.fetchRepositories(searchTerms:))
            .map { $0.map { SearchListTableViewCellViewModel(repository: $0) } }
            .subscribe(onNext: { [weak self] repositories in
                self?.items.onNext(repositories)
                self?.isSearching.onNext(false)
            }, onError: { [weak self] error in
                self?.displayedError.onNext(error.localizedDescription)
                self?.isSearching.onNext(false)
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

// MARK: - Input / Output

extension SearchListViewModel {
    struct Input {
        var searchterms: AnyObserver<String>
        var searchButtonTapped: AnyObserver<()>
        var cancelButtonTapped: AnyObserver<()>
        var begginEdditingSearchTertms: AnyObserver<()>
        var endingEdditingSearchTerms: AnyObserver<()>
        var rowDidSelect: AnyObserver<SearchListTableViewCellViewModel>
        
    }
    
    struct Output {
        var items: Driver<[SearchListTableViewCellViewModel]>
        var displayedError: Driver<String?>
        var showEmptySearchLabel: Driver<Bool>
        var showTableView: Driver<Bool>
        var showActivityIndicator: Driver<Bool>
        var isEdditingSearchTerms: Driver<Bool>
        var hideKeyboard: Driver<Void>
    }
}
