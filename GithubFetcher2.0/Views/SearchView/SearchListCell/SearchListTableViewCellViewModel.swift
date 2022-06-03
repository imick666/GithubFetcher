//
//  SearchListCellViewModel.swift
//  GithubFetcher2.0
//
//  Created by Mickael Ruzel on 03/06/2022.
//

import Foundation

final class SearchListTableViewCellViewModel {
    
    // MARK: - Properties
    var id: Int
    
    
    // MARK: - Init
    
    init(repository: Repository) {
        self.id = repository.id
    }
}

extension SearchListTableViewCellViewModel: Equatable {
    static func == (lhs: SearchListTableViewCellViewModel, rhs: SearchListTableViewCellViewModel) -> Bool {
        return lhs.id == rhs.id
    }
    
    
}
