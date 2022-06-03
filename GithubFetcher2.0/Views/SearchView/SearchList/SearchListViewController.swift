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
    
    var viewModel: SearchListViewModel!
    
    private var bag = DisposeBag()
    
    // MARK: - View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nib = UINib(nibName: ViewConstants.CellsConstants.SearchListTableViewCell.nibName, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: ViewConstants.CellsConstants.SearchListTableViewCell.reusableIdentifier)
        tableView.tableFooterView = UIView()
        
        binOutput()
        bindInput()
    }
    
    // MARK: - Methodes
    
    private func binOutput() {
        bag.insert(
            
            // Table View
            viewModel.output.items.drive(tableView.rx.items(cellIdentifier: ViewConstants.CellsConstants.SearchListTableViewCell.reusableIdentifier, cellType: SearchListTableViewCell.self)) {
            row, item, cell in
                cell.viewModel = item
            }
        
        )
    }
    
    private func bindInput() {
        bag.insert(
            // Search Bar
            searchBar.rx.text
                .orEmpty
                .bind(to: viewModel.input.searchterms),
            searchBar.rx.searchButtonClicked
                .bind(to: viewModel.input.searchButtonTapped)
        )
    }

}
