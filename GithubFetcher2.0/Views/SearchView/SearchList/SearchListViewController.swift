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
    @IBOutlet weak var emptySearchLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var viewModel: SearchListViewModel!
    
    private var bag = DisposeBag()
    
    // MARK: - View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nib = UINib(nibName: ViewConstants.CellsConstants.SearchListTableViewCell.nibName, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: ViewConstants.CellsConstants.SearchListTableViewCell.reusableIdentifier)
        tableView.keyboardDismissMode = .onDrag
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
            },
            viewModel.output.showTableView
                .map(!)
                .drive(tableView.rx.isHidden),
            
            // EmptySearchlabel
            viewModel.output.showEmptySearchLabel
                .map(!)
                .drive(emptySearchLabel.rx.isHidden),
            
            // ActiviIndicator
            viewModel.output.showActivityIndicator
                .map(!)
                .drive(activityIndicator.rx.isHidden,
                       activityIndicator.rx.isAnimating),
            // AlertView
            viewModel.output.displayedError
                .filter { $0 != nil }
                .drive(onNext: { [weak self] message in
                    self?.showAlertController(with: message!)
                }),
            
            // SearchBar
            viewModel.output.isEdditingSearchTerms
                .drive(onNext: { [weak self] showCancelButton in
                    self?.searchBar.setShowsCancelButton(showCancelButton, animated: true)
                }),
            
            viewModel.output.hideKeyboard
                .drive(onNext: { self.searchBar.resignFirstResponder() })
        )
    }
    
    private func bindInput() {
        bag.insert(
            // Search Bar
            searchBar.rx.text
                .orEmpty
                .bind(to: viewModel.input.searchterms),
            searchBar.rx.searchButtonClicked
                .bind(to: viewModel.input.searchButtonTapped),
            searchBar.rx.cancelButtonClicked
                .bind(to: viewModel.input.cancelButtonTapped),
            searchBar.rx.textDidBeginEditing
                .bind(to: viewModel.input.begginEdditingSearchTertms),
            searchBar.rx.textDidEndEditing
                .bind(to: viewModel.input.endingEdditingSearchTerms)
            
        )
    }
    
    private func showAlertController(with message: String) {
        let alertView = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "OK", style: .cancel)
        alertView.addAction(cancelAction)
        
        navigationController?.present(alertView, animated: true, completion: nil)
    }
}
