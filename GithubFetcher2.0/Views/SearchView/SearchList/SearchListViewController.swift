//
//  SearchListViewController.swift
//  GithubFetcher2.0
//
//  Created by Mickael Ruzel on 03/06/2022.
//

import UIKit
import RxCocoa
import RxSwift

class SearchListViewController: UIViewController {
    
    // MARK: - Properties
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    weak var viewModel: SearchListViewModel!
    
    private var bag = DisposeBag()
    
    // MARK: - View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(SearchListTableViewCell.self, forCellReuseIdentifier: "cell")

    }
    
    // MARK: - Methodes
    
    private func binInput() {
        bag.insert(
            
            // Table View
            viewModel.output.items.drive(tableView.rx.items(cellIdentifier: "cell", cellType: SearchListTableViewCell.self)) {
            row, item, cell in
                cell.viewModel = item
            }
            
            // Search Bar
        
        )
    }
    
    private func bindOutput() {
        
    }

}
