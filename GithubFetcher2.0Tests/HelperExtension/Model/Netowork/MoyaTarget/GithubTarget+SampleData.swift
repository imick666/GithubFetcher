//
//  GithubTarget+SampleData.swift
//  GithubFetcher2.0Tests
//
//  Created by Mickael Ruzel on 31/05/2022.
//

import Foundation
@testable import GithubFetcher2_0

extension GithubTarget {
    var sampleData: Data {
        switch self {
        case .fetchRepositories(_): return SampleDataKeeper.repositories.data
        }
    }
}
