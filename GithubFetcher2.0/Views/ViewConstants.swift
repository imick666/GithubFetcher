//
//  ViewConstants.swift
//  GithubFetcher2.0
//
//  Created by Mickael Ruzel on 03/06/2022.
//

import Foundation

enum ViewConstants {
    enum CellsConstants {
        case SearchListTableViewCell
        
        var reusableIdentifier: String {
            switch self {
            case .SearchListTableViewCell: return "SearchListTableViewCell"
            }
        }
        
        var nibName: String {
            switch self {
            case .SearchListTableViewCell: return "SearchListTableViewCell"
            }
        }
    }
}
