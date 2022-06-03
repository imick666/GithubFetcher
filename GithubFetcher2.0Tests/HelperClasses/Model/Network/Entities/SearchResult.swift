//
//  SearchResult.swift
//  GithubFetcher2.0Tests
//
//  Created by Mickael Ruzel on 01/06/2022.
//

import Foundation
@testable import GithubFetcher2_0

struct SearchResult: Codable {
    var items: [Repository]
}
