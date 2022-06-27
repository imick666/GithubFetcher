//
//  RepositoryViewModel.swift
//  GithubFetcher2.0
//
//  Created by Mickael Ruzel on 25/06/2022.
//

import Foundation
import RxSwift
import RxCocoa

final class RepositoryViewModel: ViewModel {
    
    // MARK: - Properties
    
    var input: Input!
    var output: Output!
    
    // MARK: - Input
    
    // MARK: - Output
    
    private var userName = PublishSubject<String>()
    private var repositoryName = PublishSubject<String>()
    private var repositoryDescription = PublishSubject<String>()
    private var shownedError = PublishSubject<String?>()
    
    // MARK: - Dependencies
    
    private var service: GithubService!
    private var bag = DisposeBag()
    
    
    // MARK: - Init
    
    init(service: GithubService = GithubService()) {
        self.service = service
        
        // Setup Input Output
        
        input = Input()
        
        output = Output(userName: userName.asDriver(onErrorJustReturn: ""),
                        repositoryName: repositoryName.asDriver(onErrorJustReturn: ""),
                        repositoryDescription: repositoryDescription.asDriver(onErrorJustReturn: ""),
                        shownedError: shownedError.asDriver(onErrorJustReturn: nil))
    }
    
    // MARK: - Methodes
    
    func fetchrepository(fullName: String) {
        service.fetchRepository(fullName: fullName)
            .subscribe(onNext: { [weak self] repository in
                guard let self = self else { fatalError() }
                self.bindRepository(from: repository)
            },
                       onError: { [weak self] error in
                self?.shownedError.onNext(error.localizedDescription)
            })
            .disposed(by: bag)
    }
    
    private func bindRepository(from repository: Repository) {
        let namesComponnents = repository.fullName.components(separatedBy: "/")
        self.userName.onNext(namesComponnents[0])
        self.repositoryName.onNext(namesComponnents[1])
        self.repositoryDescription.onNext(repository.description ?? "No Description")
    }
    
}

extension RepositoryViewModel {
    
    struct Input {
        
        
    }
    
    struct Output {
        var userName: Driver<String>
        var repositoryName: Driver<String>
        var repositoryDescription: Driver<String>
        var shownedError: Driver<String?>
    }
}
