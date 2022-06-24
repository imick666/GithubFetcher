//
//  SearchListCellViewModel.swift
//  GithubFetcher2.0
//
//  Created by Mickael Ruzel on 03/06/2022.
//

import Foundation
import RxSwift
import RxCocoa

final class SearchListTableViewCellViewModel: ViewModel {
    
    // MARK: - Properties
    var input: Input!
    var output: Output!
    
    private var id: Int
    
    // MARK: - Init
    
    init(repository: Repository) {
        self.id = repository.id
        
        input = Input()
        output = Output(repository: .just(repository))
    }
}

extension SearchListTableViewCellViewModel: Equatable {
    static func == (lhs: SearchListTableViewCellViewModel, rhs: SearchListTableViewCellViewModel) -> Bool {
        return lhs.id == rhs.id
    }
}

extension SearchListTableViewCellViewModel {
    struct Input {
        
    }
    
    struct Output {
        var repository: Driver<Repository>
    }
}
