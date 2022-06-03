//
//  SearchListTableViewCell.swift
//  GithubFetcher2.0
//
//  Created by Mickael Ruzel on 03/06/2022.
//

import UIKit
import RxSwift
import RxCocoa

class SearchListTableViewCell: UITableViewCell {
    
    // MARK: - Outlet
    
    @IBOutlet weak var starCountLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var languageLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var repositoryNameLabel: UILabel!
    
    // MARK: - Properties
    
    weak var viewModel: SearchListTableViewCellViewModel! {
        didSet {
            bindOutput()
        }
    }
    
    private var bag = DisposeBag()

    // MARK: - View Life Cycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // MARK: - Methodes
    
    private func bindOutput() {
        bag.insert(
            viewModel.output.repository
                .map { $0.fullName }
                .map { String($0.split(separator: "/").first ?? "N/C") }
                .drive(userNameLabel.rx.text),
            viewModel.output.repository
                .map { $0.fullName }
                .map { String($0.split(separator: "/").last ?? "N/C") }
                .drive(repositoryNameLabel.rx.text),
            viewModel.output.repository
                .map { $0.language ?? "N/C" }
                .drive(languageLabel.rx.text),
            viewModel.output.repository
                .map { $0.description }
                .drive(descriptionLabel.rx.text),
            viewModel.output.repository
                .map { String($0.stargazersCount) }
                .drive(starCountLabel.rx.text)
        )
    }
    
}
