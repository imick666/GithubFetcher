//
//  Repository.swift
//  GithubFetcher2.0
//
//  Created by Mickael Ruzel on 31/05/2022.
//

import Foundation

struct Repository: Codable, Equatable {
    let id: Int
    let fullName: String
    let description: String?
    let branchesUrl: String
    let contributorsUrl: String
    let createdAt: String
    let updatedAt: String
    let stargazersCount: Int
    let language: String
}
